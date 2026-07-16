#!/usr/bin/env python3
"""Bind MTS DV and synthesis signoff evidence to one exact source snapshot.

The workflow is intentionally two phase:

* begin runs after generated outputs have been cleaned and before any EDA
  command. It records the source manifest and a nanosecond run-start fence.
* verify runs after every required command. It rejects changed sources,
  stale artifacts, incomplete UVM inventories, unhealthy logs/UCDBs, static
  findings, timing violations, out-of-model resources, and gate mismatches.

Only a successful verify writes the committed promotion receipt and the
current-release DV/SYN summaries. Check validates a committed receipt against
the source files available in a clone; raw generated artifacts are not
required for that clone-time check.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Mapping, Sequence

SCHEMA = "mu3e.mts.current-source-signoff/v1"
RUN_STATE_SCHEMA = "mu3e.mts.current-source-run-state/v1"
RELEASE = "26.6.0.0716"
ISOLATED_SEED = 1
FOCUSED_SEED = 260716
CASE_COUNT = 521
FRAME_COUNT = 5
VHDL_TARGET_COUNT = 5
VSIM_INVOCATION_COUNT = 6
FOCUSED_CASES = (
    "STD_MTS_020_op_mode_bits_readback",
    "STD_MTS_099_arrival_delta_uses_gts",
    "CORNER_MTS_035_mts_counter_wrap_pulse",
    "CORNER_MTS_071_debug_ts_minus_one",
    "NEG_MTS_041_negative_debug_ts_error",
)
PREFIX_COUNTS = {
    "STD": 130,
    "CORNER": 131,
    "STRESS": 130,
    "NEG": 130,
}
FRAME_RUNS = (
    ("mtsp_bucket_frame_BASIC", "bucket_frame", "BASIC", 130),
    ("mtsp_bucket_frame_EDGE", "bucket_frame", "EDGE", 131),
    ("mtsp_bucket_frame_PROF", "bucket_frame", "PROF", 130),
    ("mtsp_bucket_frame_ERROR", "bucket_frame", "ERROR", 130),
    ("mtsp_all_buckets_frame", "all_buckets_frame", "ALL", 521),
)
TIMING_CORNERS = {
    "slow_85c": ("slow", 85, "Slow 1100mV 85C Model"),
    "slow_0c": ("slow", 0, "Slow 1100mV 0C Model"),
    "fast_85c": ("fast", 85, "Fast 1100mV 85C Model"),
    "fast_0c": ("fast", 0, "Fast 1100mV 0C Model"),
}
TIMING_CHECKS = ("Setup", "Hold", "Recovery", "Removal", "Minimum Pulse Width")
RESOURCE_LIMITS = {
    "alms": (578, 3468),
    "registers": (980, 5880),
    "memory_bits": (245835, 1475010),
    "ram_blocks": (31, 186),
    "dsp_blocks": (0, 0),
}
SOURCE_PATHS = (
    "dual_port_rom.v",
    "dual_port_rom_init.txt",
    "mts_processor.svd",
    "mts_processor.vhd",
    "mts_processor_cmsis_svd.tcl",
    "mts_processor_csr_meta.tcl",
    "mts_processor_hw.tcl",
    "doc/RTL_PLAN.md",
    "tb/Makefile",
    "tb/mts_processor_asic_id_tb.vhd",
    "tb/mts_processor_external_epoch_tb.vhd",
    "tb/mts_processor_rearm_tb.vhd",
    "tb/mts_processor_tb.vhd",
    "tb/mts_processor_terminating_tb.vhd",
    "tb/DV_BASIC.md",
    "tb/DV_CROSS.md",
    "tb/DV_EDGE.md",
    "tb/DV_ERROR.md",
    "tb/DV_HARNESS.md",
    "tb/DV_PLAN.md",
    "tb/DV_PROF.md",
    "tb/gate/Makefile",
    "tb/gate/README.md",
    "tb/gate/mts_processor_gate_smoke_tb.sv",
    "tb/scripts/current_source_signoff.py",
    "tb/scripts/dv_report_gen_local.py",
    "tb/scripts/test_current_source_signoff.py",
    "tb/uvm/Makefile",
    "tb/uvm/mtsp_cases.svh",
    "tb/uvm/mtsp_env_pkg.sv",
    "tb/uvm/mtsp_if.sv",
    "tb/uvm/scripts/check_hw_tcl_validation.tcl",
    "tb/uvm/tb_top.sv",
    "syn/quartus/mts_processor_static.f",
    "syn/quartus/mts_processor_syn.qpf",
    "syn/quartus/mts_processor_syn.qsf",
    "syn/quartus/mts_processor_syn.sdc",
    "syn/quartus/mts_processor_syn_top.vhd",
    "syn/quartus/questa_lpm_pre.do",
    "syn/quartus/questa_lpm_static_stubs.vhd",
    "syn/quartus/questa_static_dual_port_rom_stub.v",
    "syn/quartus/questa_static_extra.do",
    "syn/quartus/run_signoff.sh",
)
QUARTUS_ARTIFACTS = (
    "syn/quartus/output_files/mts_processor_syn.done",
    "syn/quartus/output_files/mts_processor_syn.flow.rpt",
    "syn/quartus/output_files/mts_processor_syn.fit.summary",
    "syn/quartus/output_files/mts_processor_syn.fit.rpt",
    "syn/quartus/output_files/mts_processor_syn.sta.summary",
    "syn/quartus/output_files/mts_processor_syn.sta.rpt",
    "syn/quartus/gate_sim/mts_processor_syn.vo",
)
VHDL_PASS_MARKERS = (
    "mts_processor_tb PASSED",
    "mts_processor_terminating_tb PASSED",
    "mts_processor_rearm_tb PASSED",
    "mts_processor_asic_id_tb PASSED bank=UP",
    "mts_processor_asic_id_tb PASSED bank=DW",
    "mts_processor_external_epoch_tb PASSED",
)
CASE_RE = re.compile(r'^\s*"([A-Z_]+_MTS_[^"]+)"\s*:', re.MULTILINE)
SCB_RE = re.compile(r"\[MTSP_SCB\]\s+(?P<body>.*)$", re.MULTILINE)
KV_RE = re.compile(r"([A-Za-z0-9_]+)=(-?\d+)")
FRAME_SUMMARY_RE = re.compile(
    r"\[MTSP_FRAME_SUMMARY\]\s+(?P<body>.*)$", re.MULTILINE
)
FRAME_KV_RE = re.compile(r"([A-Za-z0-9_]+)=([^\s]+)")
UVM_BAD_RE = re.compile(
    r"UVM_(?:FATAL|ERROR)\s*:\s*[1-9]\d*|"
    r"^# \*\* (?:Fatal|Error):|"
    r"^(?:Fatal|Error):",
    re.MULTILINE,
)
GENERIC_BAD_RE = re.compile(
    r"^# \*\* (?:Fatal|Error):|^(?:Fatal|Error):|"
    r"\b(?:FAIL|FAILED):",
    re.MULTILINE,
)
BT = chr(96)


class EvidenceError(RuntimeError):
    """A fail-closed evidence validation error."""


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def canonical_bytes(value: Any) -> bytes:
    return (
        json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)
        + "\n"
    ).encode("utf-8")


def canonical_digest(value: Any) -> str:
    return hashlib.sha256(canonical_bytes(value)).hexdigest()


def receipt_digest(value: Mapping[str, Any]) -> str:
    payload = dict(value)
    payload.pop("receipt_sha256", None)
    return canonical_digest(payload)


def repo_relative(path: Path, repo: Path) -> str:
    try:
        return path.resolve().relative_to(repo.resolve()).as_posix()
    except ValueError:
        return str(path.resolve())


def atomic_write(path: Path, payload: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=path.name + ".", dir=str(path.parent))
    tmp = Path(temporary)
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(payload)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(tmp, path)
    finally:
        if tmp.exists():
            tmp.unlink()


def write_json(path: Path, value: Any) -> None:
    atomic_write(path, json.dumps(value, indent=2, sort_keys=True).encode() + b"\n")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise EvidenceError(message)


def source_manifest(repo: Path) -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    for relative in SOURCE_PATHS:
        path = repo / relative
        require(path.is_file(), "required source is missing: " + relative)
        files.append(
            {
                "path": relative,
                "sha256": sha256_file(path),
                "size": path.stat().st_size,
            }
        )
    aggregate = canonical_digest(
        [{"path": item["path"], "sha256": item["sha256"]} for item in files]
    )
    return {"algorithm": "sha256", "aggregate_sha256": aggregate, "files": files}


def parse_case_ids(repo: Path) -> list[str]:
    source = (repo / "tb/uvm/mtsp_cases.svh").read_text(
        encoding="utf-8", errors="strict"
    )
    raw = CASE_RE.findall(source)
    ordered = list(dict.fromkeys(raw))
    require(len(raw) == len(ordered), "duplicate explicit UVM case ID in dispatch table")
    require(len(ordered) == CASE_COUNT, f"expected {CASE_COUNT} UVM cases, found {len(ordered)}")
    counts = Counter(case_id.split("_MTS_", 1)[0] for case_id in ordered)
    require(dict(counts) == PREFIX_COUNTS, f"unexpected UVM bucket inventory: {dict(counts)}")
    return ordered


def git_text(repo: Path, *args: str) -> str:
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    require(proc.returncode == 0, "git command failed: " + " ".join(args))
    return proc.stdout.strip()


def clean_targets(repo: Path, case_ids: Sequence[str]) -> list[Path]:
    targets = [repo / "tb/uvm/work_after/.compiled"]
    for case_id in case_ids:
        targets.extend(
            (
                repo / f"tb/uvm/logs/{case_id}_after_s{ISOLATED_SEED}.log",
                repo / f"tb/uvm/cov_after/{case_id}_s{ISOLATED_SEED}.ucdb",
            )
        )
    for run_id, _kind, _bucket, _count in FRAME_RUNS:
        targets.extend(
            (
                repo / f"tb/uvm/logs/{run_id}_after_s{ISOLATED_SEED}.log",
                repo / f"tb/uvm/cov_after/{run_id}_s{ISOLATED_SEED}.ucdb",
            )
        )
    for case_id in FOCUSED_CASES:
        targets.extend(
            (
                repo / f"tb/uvm/logs/{case_id}_after_s{FOCUSED_SEED}.log",
                repo / f"tb/uvm/cov_after/{case_id}_s{FOCUSED_SEED}.ucdb",
            )
        )
    targets.extend(
        (
            repo / "tb/gate/logs/rtl_smoke.log",
            repo / "tb/gate/logs/gate_smoke.log",
        )
    )
    return targets


def command_begin(args: argparse.Namespace) -> int:
    repo = args.repo.resolve()
    state_path = args.state.resolve()
    require(repo.is_dir(), "repository path does not exist: " + str(repo))
    require(not state_path.exists(), "run-state already exists: " + str(state_path))
    cases = parse_case_ids(repo)
    stale = [path for path in clean_targets(repo, cases) if path.exists()]
    if stale:
        shown = "\n".join("  " + repo_relative(path, repo) for path in stale[:20])
        raise EvidenceError(
            "generated targets are not clean; run the documented clean commands first"
            + ("\n" + shown if shown else "")
        )

    manifest = source_manifest(repo)
    hw_tcl = (repo / "mts_processor_hw.tcl").read_text(encoding="utf-8")
    svd = (repo / "mts_processor.svd").read_text(encoding="utf-8")
    require("VERSION_MINOR_DEFAULT_CONST            6" in hw_tcl, "HW Tcl minor version is not 6")
    require("VERSION_DATE_DEFAULT_CONST             20260716" in hw_tcl, "HW Tcl date is not 20260716")
    require(f"<version>{RELEASE}</version>" in svd, "SVD release does not match " + RELEASE)

    state = {
        "schema": RUN_STATE_SCHEMA,
        "release": RELEASE,
        "started_utc": utc_now(),
        "started_ns": time.time_ns(),
        "repo": str(repo),
        "git": {
            "branch": git_text(repo, "rev-parse", "--abbrev-ref", "HEAD"),
            "head": git_text(repo, "rev-parse", "HEAD"),
            "describe": git_text(repo, "describe", "--always", "--dirty", "--tags"),
        },
        "source": manifest,
        "inventory": {
            "isolated_seed": ISOLATED_SEED,
            "isolated_case_ids": cases,
            "focused_seed": FOCUSED_SEED,
            "focused_case_ids": list(FOCUSED_CASES),
            "frames": [
                {
                    "run_id": run_id,
                    "kind": kind,
                    "bucket": bucket,
                    "case_count": count,
                }
                for run_id, kind, bucket, count in FRAME_RUNS
            ],
            "vhdl_targets": VHDL_TARGET_COUNT,
            "vsim_invocations": VSIM_INVOCATION_COUNT,
        },
    }
    state["state_sha256"] = canonical_digest(state)
    if args.dry_run:
        print(json.dumps(state, indent=2, sort_keys=True))
        return 0
    write_json(state_path, state)
    print("MTS_CURRENT_SOURCE_BEGIN_PASS")
    print("state=" + str(state_path))
    print("source_sha256=" + manifest["aggregate_sha256"])
    return 0


def load_run_state(path: Path) -> dict[str, Any]:
    require(path.is_file(), "run-state is missing: " + str(path))
    state = json.loads(path.read_text(encoding="utf-8"))
    require(state.get("schema") == RUN_STATE_SCHEMA, "run-state schema mismatch")
    claimed = state.get("state_sha256")
    payload = dict(state)
    payload.pop("state_sha256", None)
    require(claimed == canonical_digest(payload), "run-state digest mismatch")
    require(state.get("release") == RELEASE, "run-state release mismatch")
    return state


def artifact_record(
    path: Path, repo: Path, started_ns: int, *, require_nonempty: bool = True
) -> dict[str, Any]:
    require(path.is_file(), "required artifact is missing: " + str(path))
    stat = path.stat()
    require(
        stat.st_mtime_ns >= started_ns,
        "artifact predates current-source run fence: " + str(path),
    )
    if require_nonempty:
        require(stat.st_size > 0, "required artifact is empty: " + str(path))
    return {
        "path": repo_relative(path, repo),
        "sha256": sha256_file(path),
        "size": stat.st_size,
        "mtime_ns": stat.st_mtime_ns,
    }


def parse_scoreboard(text: str) -> dict[str, int]:
    matches = [match.group("body") for match in SCB_RE.finditer(text)]
    require(bool(matches), "UVM log lacks MTSP_SCB summary")
    for body in reversed(matches):
        pairs = KV_RE.findall(body)
        if pairs:
            return {key: int(value) for key, value in pairs}
    raise EvidenceError("MTSP_SCB summary lacks numeric fields")


def verify_uvm_log(
    path: Path,
    *,
    seed: int,
    case_id: str | None = None,
    frame: tuple[str, str, int] | None = None,
) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8", errors="replace")
    require(f"-sv_seed {seed}" in text, f"wrong or missing seed in {path}")
    require(text.count("*** TEST PASSED ***") == 1, f"missing/duplicate pass marker in {path}")
    require("UVM_ERROR :    0" in text, f"UVM_ERROR is not zero in {path}")
    require("UVM_FATAL :    0" in text, f"UVM_FATAL is not zero in {path}")
    require(not UVM_BAD_RE.search(text), f"fatal/error marker in {path}")
    require("Coverage database has been saved successfully." in text, f"coverage save missing in {path}")
    if case_id:
        require(f"+MTSP_CASE_ID={case_id}" in text, f"case marker mismatch in {path}")
        require("+MTSP_FRAME_KIND=isolated" in text, f"isolated marker missing in {path}")
    scoreboard = parse_scoreboard(text)
    require(
        scoreboard.get("latency48_identity", -1) == scoreboard.get("beats", -2),
        f"latency48 identity count does not equal valid beats in {path}",
    )
    if frame:
        kind, bucket, expected = frame
        summaries = [
            match.group("body")
            for match in FRAME_SUMMARY_RE.finditer(text)
            if "kind=" in match.group("body")
            and "checkpoints=" in match.group("body")
        ]
        require(len(summaries) == 1, f"expected one frame summary in {path}")
        values = {key: value for key, value in FRAME_KV_RE.findall(summaries[0])}
        require(values.get("kind") == kind, f"frame kind mismatch in {path}")
        require(values.get("bucket") == bucket, f"frame bucket mismatch in {path}")
        for key in ("checkpoints", "inputs", "payloads", "dual_path_pairs", "traces"):
            require(int(values.get(key, "-1")) == expected, f"{key} mismatch in {path}")
        require(scoreboard.get("latency48_negative_diagnostics", -1) == 0, f"negative nominal frame latency in {path}")
    return scoreboard


def verify_ucdb_magic(path: Path) -> None:
    with path.open("rb") as handle:
        prefix = handle.read(64)
    require(b"QUESTA_UCDB_FILE" in prefix, "invalid UCDB header: " + str(path))


def find_vcover(explicit: str | None) -> str:
    candidates = (
        explicit,
        os.environ.get("VCOVER"),
        "/data1/questaone_sim/questasim/bin/vcover",
        shutil.which("vcover"),
    )
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return str(Path(candidate).resolve())
    raise EvidenceError("vcover not found; pass --vcover")


def vcover_health_merge(vcover: str, output: Path, ucdbs: Sequence[Path]) -> dict[str, Any]:
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()
    proc = subprocess.run(
        [vcover, "merge", str(output), *[str(path) for path in ucdbs]],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    require(proc.returncode == 0, "vcover health merge failed\n" + proc.stdout[-4000:])
    require(output.is_file() and output.stat().st_size > 0, "vcover health merge produced no UCDB")
    return {
        "tool": vcover,
        "input_count": len(ucdbs),
        "merged_sha256": sha256_file(output),
        "merged_size": output.stat().st_size,
    }


def require_fresh_text(path: Path, repo: Path, started_ns: int) -> tuple[str, dict[str, Any]]:
    record = artifact_record(path, repo, started_ns)
    return path.read_text(encoding="utf-8", errors="replace"), record


def verify_compile_log(path: Path, repo: Path, started_ns: int) -> dict[str, Any]:
    text, record = require_fresh_text(path, repo, started_ns)
    for marker in ("mts_processor.vhd", "mtsp_env_pkg.sv", "tb_top.sv"):
        require(marker in text, "compile log lacks source marker " + marker)
    require(not GENERIC_BAD_RE.search(text), "compile log contains a failure marker")
    return record


def verify_vhdl_log(path: Path, repo: Path, started_ns: int) -> dict[str, Any]:
    text, record = require_fresh_text(path, repo, started_ns)
    require(not GENERIC_BAD_RE.search(text), "VHDL smoke log contains a failure marker")
    for marker in VHDL_PASS_MARKERS:
        require(text.count(marker) == 1, "VHDL pass marker count mismatch: " + marker)
    require(text.count(" PASSED") == VSIM_INVOCATION_COUNT, "VHDL log does not contain exactly six pass markers")
    record["targets"] = VHDL_TARGET_COUNT
    record["vsim_invocations"] = VSIM_INVOCATION_COUNT
    return record


def verify_hw_tcl_log(path: Path, repo: Path, started_ns: int) -> dict[str, Any]:
    text, record = require_fresh_text(path, repo, started_ns)
    require(text.count("PASS: ") == 3, "HW Tcl guard log does not contain three case passes")
    require("HW_TCL_VALIDATE_CHECK_PASS cases=3" in text, "HW Tcl final pass marker missing")
    require("FAIL:" not in text, "HW Tcl validation contains FAIL")
    record["cases"] = 3
    return record


def verify_static_log(path: Path, repo: Path, started_ns: int) -> dict[str, Any]:
    text, record = require_fresh_text(path, repo, started_ns)
    for marker in ("lint run -d mts_processor_syn_top", "cdc run", "rdc run"):
        require(marker in text, "static log lacks mode marker: " + marker)
    require(re.search(r"# Error \(0\)", text) is not None, "static lint Error (0) marker missing")
    require(re.search(r"# Violations \(0\)", text) is not None, "static CDC Violations (0) marker missing")
    require(re.search(r"# Violation \(0\)", text) is not None, "static RDC Violation (0) marker missing")
    require(re.search(r"# Error \([1-9]\d*\)", text) is None, "static lint has errors")
    require(re.search(r"# Violations? \([1-9]\d*\)", text) is None, "static CDC/RDC has violations")
    require(
        re.search(r"mts_processor\(rtl\)#[^'\n]*TRUE'", text) is not None,
        "static log does not prove the external-epoch generic profile",
    )
    record.update({"lint_errors": 0, "cdc_violations": 0, "rdc_violations": 0})
    return record


def parse_resources(text: str) -> dict[str, int]:
    patterns = {
        "alms": r"Logic utilization \(in ALMs\)\s*:\s*([\d,]+)",
        "registers": r"Total registers\s*:\s*([\d,]+)",
        "memory_bits": r"Total block memory bits\s*:\s*([\d,]+)",
        "ram_blocks": r"Total RAM Blocks\s*:\s*([\d,]+)",
        "dsp_blocks": r"Total DSP Blocks\s*:\s*([\d,]+)",
    }
    values: dict[str, int] = {}
    for key, pattern in patterns.items():
        match = re.search(pattern, text)
        require(match is not None, "fit summary lacks resource " + key)
        values[key] = int(match.group(1).replace(",", ""))
        lower, upper = RESOURCE_LIMITS[key]
        require(lower <= values[key] <= upper, f"resource {key}={values[key]} outside {lower}..{upper}")
    return values


def explicit_corner_sta_summary(values: Mapping[str, float]) -> dict[str, dict[str, float]]:
    """Project a verified explicit report into the canonical timing table.

    Quartus rewrites ``*.sta.summary`` on every explicit ``quartus_sta``
    invocation, so that file contains only the most recently requested corner.
    The four named console transcripts are the immutable all-corner evidence.
    ``verify_corner_log`` has already required nonnegative WNS and zero TNS for
    every check before this projection is called.
    """

    return {
        check.lower().replace(" ", "_"): {
            "slack": float(values[check.lower().replace(" ", "_")]),
            "tns": 0.0,
        }
        for check in TIMING_CHECKS
    }


def verify_corner_log(
    key: str, path: Path, repo: Path, started_ns: int
) -> tuple[dict[str, Any], dict[str, float]]:
    model, temperature, _label = TIMING_CORNERS[key]
    text, record = require_fresh_text(path, repo, started_ns)
    require(f"--model={model}" in text, f"timing model mismatch in {path}")
    require(f"--temperature={temperature}" in text, f"timing temperature mismatch in {path}")
    require("--voltage=1100" in text, f"timing voltage mismatch in {path}")
    require("Timing Analyzer was successful. 0 errors" in text, f"timing analyzer did not close in {path}")
    values: dict[str, float] = {}
    names = {
        "setup": "setup",
        "hold": "hold",
        "recovery": "recovery",
        "removal": "removal",
        "minimum_pulse_width": "minimum pulse width",
    }
    for field, phrase in names.items():
        match = re.search(
            r"Worst-case " + re.escape(phrase) + r" slack is (-?\d+(?:\.\d+)?)",
            text,
        )
        require(match is not None, f"missing {field} WNS in {path}")
        values[field] = float(match.group(1))
        require(values[field] >= 0.0, f"negative {field} WNS at {key}")
    tns_values = [
        float(value)
        for value in re.findall(
            r"Info \(332119\):\s+-?\d+(?:\.\d+)?\s+(-?\d+(?:\.\d+)?)\s+clk\s*$",
            text,
            re.MULTILINE,
        )
    ]
    require(len(tns_values) >= 5, f"timing TNS rows missing in {path}")
    require(all(abs(value) < 0.0005 for value in tns_values[:5]), f"nonzero TNS in {path}")
    require(re.search(r"\([1-9]\d* violated\)", text) is None, f"violated timing paths in {path}")
    return record, values


def verify_quartus(
    repo: Path,
    started_ns: int,
    flow_log: Path,
    timing_reports: Mapping[str, Path],
) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    flow_text, flow_record = require_fresh_text(flow_log, repo, started_ns)
    require("Full Compilation was successful" in flow_text, "Quartus full-compile pass marker missing")
    require(re.search(r"successful\.\s+0 errors", flow_text, re.IGNORECASE) is not None, "Quartus error count is not zero")

    artifacts: list[dict[str, Any]] = [flow_record]
    for relative in QUARTUS_ARTIFACTS:
        artifacts.append(artifact_record(repo / relative, repo, started_ns))

    fit_path = repo / "syn/quartus/output_files/mts_processor_syn.fit.summary"
    fit_text = fit_path.read_text(encoding="utf-8", errors="replace")
    require("Fitter Status : Successful" in fit_text, "fitter status is not successful")
    require("Top-level Entity Name : mts_processor_syn_top" in fit_text, "wrong Quartus top")
    require("Device : 5AGXBA7D4F31C5" in fit_text, "wrong Quartus device")
    resources = parse_resources(fit_text)

    corners: dict[str, Any] = {}
    require(set(timing_reports) == set(TIMING_CORNERS), "exactly four named timing reports are required")
    for key in TIMING_CORNERS:
        record, values = verify_corner_log(key, timing_reports[key], repo, started_ns)
        artifacts.append(record)
        corners[key] = {
            "explicit_report": record,
            "worst_slack": values,
            "sta_summary": explicit_corner_sta_summary(values),
        }

    qsf = (repo / "syn/quartus/mts_processor_syn.qsf").read_text(encoding="utf-8")
    sdc = (repo / "syn/quartus/mts_processor_syn.sdc").read_text(encoding="utf-8")
    require('FITTER_EFFORT "STANDARD FIT"' in qsf, "Quartus effort is not Standard Fit")
    require("set_global_assignment -name SEED 1" in qsf, "Quartus seed is not 1")
    require("-period 7.273" in sdc, "standalone signoff period is not 7.273 ns")
    result = {
        "status": "pass",
        "device": "5AGXBA7D4F31C5",
        "quartus": "18.1.0 Build 625 Standard Edition",
        "fit_effort": "STANDARD FIT",
        "seed": 1,
        "clock_period_ns": 7.273,
        "resources": resources,
        "resource_limits": {
            key: {"min": value[0], "max": value[1]} for key, value in RESOURCE_LIMITS.items()
        },
        "timing": corners,
    }
    return result, artifacts


def verify_gate_log(path: Path, repo: Path, started_ns: int) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    compare_text, compare_record = require_fresh_text(path, repo, started_ns)
    rtl_path = repo / "tb/gate/logs/rtl_smoke.log"
    gate_path = repo / "tb/gate/logs/gate_smoke.log"
    records = [
        compare_record,
        artifact_record(rtl_path, repo, started_ns),
        artifact_record(gate_path, repo, started_ns),
    ]
    signatures = []
    for item in (rtl_path, gate_path):
        text = item.read_text(encoding="utf-8", errors="replace")
        require(text.count("*** TEST PASSED ***") == 1, f"gate smoke pass marker mismatch in {item}")
        require(not GENERIC_BAD_RE.search(text), f"gate smoke failure marker in {item}")
        matches = re.findall(r"MTS_GATE_SMOKE_SIGNATURE=([0-9A-Fa-f]+)", text)
        require(len(matches) == 1, f"gate signature count mismatch in {item}")
        signatures.append(matches[0].lower())
    require(signatures[0] == signatures[1], "RTL/post-fit signature mismatch")
    require("PASS: matching MTS signature " + signatures[1] in compare_text, "gate compare final pass marker missing")
    return {"status": "pass", "signature": signatures[1], "sdf": False}, records


def parse_timing_args(values: Sequence[str]) -> dict[str, Path]:
    out: dict[str, Path] = {}
    for value in values:
        require("=" in value, "--timing-report must be KEY=PATH")
        key, path = value.split("=", 1)
        require(key in TIMING_CORNERS, "unknown timing corner key: " + key)
        require(key not in out, "duplicate timing corner key: " + key)
        out[key] = Path(path).resolve()
    return out


def category_digest(records: Sequence[Mapping[str, Any]]) -> str:
    return canonical_digest(
        [
            {"path": record["path"], "sha256": record["sha256"]}
            for record in sorted(records, key=lambda item: str(item["path"]))
        ]
    )


def verify_source_state(repo: Path, state: Mapping[str, Any]) -> dict[str, Any]:
    current = source_manifest(repo)
    expected = state.get("source") or {}
    require(
        current["aggregate_sha256"] == expected.get("aggregate_sha256"),
        "source manifest changed after begin; rerun the complete signoff",
    )
    require(current["files"] == expected.get("files"), "source file ledger changed after begin")
    return current


def command_verify(args: argparse.Namespace) -> int:
    repo = args.repo.resolve()
    state_path = args.state.resolve()
    state = load_run_state(state_path)
    require(Path(state["repo"]).resolve() == repo, "run-state repository mismatch")
    source = verify_source_state(repo, state)
    started_ns = int(state["started_ns"])
    case_ids = parse_case_ids(repo)
    require(case_ids == state["inventory"]["isolated_case_ids"], "case order changed after begin")

    artifact_groups: dict[str, list[dict[str, Any]]] = {
        "uvm_isolated": [],
        "uvm_frames": [],
        "uvm_focused": [],
        "support": [],
        "static": [],
        "quartus": [],
        "gate": [],
    }
    ucdb_paths: list[Path] = []
    isolated_identity = 0
    isolated_negative = 0
    isolated_negative_cases = 0
    for case_id in case_ids:
        log = repo / f"tb/uvm/logs/{case_id}_after_s{ISOLATED_SEED}.log"
        ucdb = repo / f"tb/uvm/cov_after/{case_id}_s{ISOLATED_SEED}.ucdb"
        log_record = artifact_record(log, repo, started_ns)
        ucdb_record = artifact_record(ucdb, repo, started_ns)
        verify_ucdb_magic(ucdb)
        scb = verify_uvm_log(log, seed=ISOLATED_SEED, case_id=case_id)
        isolated_identity += scb.get("latency48_identity", 0)
        negative = scb.get("latency48_negative_diagnostics", 0)
        isolated_negative += negative
        isolated_negative_cases += int(negative > 0)
        artifact_groups["uvm_isolated"].extend((log_record, ucdb_record))
        ucdb_paths.append(ucdb)

    frame_details: list[dict[str, Any]] = []
    for run_id, kind, bucket, count in FRAME_RUNS:
        log = repo / f"tb/uvm/logs/{run_id}_after_s{ISOLATED_SEED}.log"
        ucdb = repo / f"tb/uvm/cov_after/{run_id}_s{ISOLATED_SEED}.ucdb"
        records = (
            artifact_record(log, repo, started_ns),
            artifact_record(ucdb, repo, started_ns),
        )
        verify_ucdb_magic(ucdb)
        scb = verify_uvm_log(log, seed=ISOLATED_SEED, frame=(kind, bucket, count))
        frame_details.append(
            {
                "run_id": run_id,
                "case_count": count,
                "beats": scb.get("beats", 0),
                "latency48_identity": scb.get("latency48_identity", 0),
                "latency48_negative_diagnostics": scb.get("latency48_negative_diagnostics", 0),
            }
        )
        artifact_groups["uvm_frames"].extend(records)
        ucdb_paths.append(ucdb)

    for case_id in FOCUSED_CASES:
        log = repo / f"tb/uvm/logs/{case_id}_after_s{FOCUSED_SEED}.log"
        ucdb = repo / f"tb/uvm/cov_after/{case_id}_s{FOCUSED_SEED}.ucdb"
        records = (
            artifact_record(log, repo, started_ns),
            artifact_record(ucdb, repo, started_ns),
        )
        verify_ucdb_magic(ucdb)
        verify_uvm_log(log, seed=FOCUSED_SEED, case_id=case_id)
        artifact_groups["uvm_focused"].extend(records)
        ucdb_paths.append(ucdb)

    compile_record = verify_compile_log(args.compile_log.resolve(), repo, started_ns)
    # The UVM Makefile deliberately creates this as a zero-byte stamp with
    # ``touch``.  Freshness and the independently parsed compile log establish
    # the compile result; requiring payload bytes would reject the Makefile's
    # valid stamp contract.
    compiled_record = artifact_record(
        repo / "tb/uvm/work_after/.compiled",
        repo,
        started_ns,
        require_nonempty=False,
    )
    vhdl_record = verify_vhdl_log(args.vhdl_log.resolve(), repo, started_ns)
    hw_tcl_record = verify_hw_tcl_log(args.hw_tcl_log.resolve(), repo, started_ns)
    artifact_groups["support"].extend(
        (compile_record, compiled_record, vhdl_record, hw_tcl_record)
    )
    static_record = verify_static_log(args.static_log.resolve(), repo, started_ns)
    artifact_groups["static"].append(static_record)

    timing_reports = parse_timing_args(args.timing_report)
    synthesis, quartus_records = verify_quartus(
        repo, started_ns, args.quartus_flow_log.resolve(), timing_reports
    )
    artifact_groups["quartus"].extend(quartus_records)
    gate, gate_records = verify_gate_log(
        args.gate_compare_log.resolve(), repo, started_ns
    )
    artifact_groups["gate"].extend(gate_records)

    vcover = find_vcover(args.vcover)
    health_path = state_path.parent / "all_required_ucdb_health_merge.ucdb"
    ucdb_health = vcover_health_merge(vcover, health_path, ucdb_paths)
    artifact_groups["support"].append(
        artifact_record(health_path, repo, started_ns)
    )

    full_manifest = {
        "schema": "mu3e.mts.current-source-artifacts/v1",
        "release": RELEASE,
        "source_sha256": source["aggregate_sha256"],
        "started_utc": state["started_utc"],
        "verified_utc": utc_now(),
        "groups": artifact_groups,
    }
    full_manifest["aggregate_sha256"] = canonical_digest(
        {
            key: category_digest(records)
            for key, records in sorted(artifact_groups.items())
        }
    )
    artifact_manifest_path = state_path.parent / "artifact_manifest.json"
    if not args.dry_run:
        write_json(artifact_manifest_path, full_manifest)
    artifact_manifest_sha = canonical_digest(full_manifest)

    promotion = {
        "schema": SCHEMA,
        "status": "pass",
        "release": RELEASE,
        "started_utc": state["started_utc"],
        "verified_utc": full_manifest["verified_utc"],
        "source": source,
        "git_at_begin": state["git"],
        "run_state": {
            "path": str(state_path),
            "sha256": sha256_file(state_path),
            "started_ns": started_ns,
        },
        "artifact_manifest": {
            "path": str(artifact_manifest_path),
            "sha256": artifact_manifest_sha,
            "aggregate_sha256": full_manifest["aggregate_sha256"],
            "group_sha256": {
                key: category_digest(records)
                for key, records in sorted(artifact_groups.items())
            },
        },
        "uvm": {
            "status": "pass",
            "isolated_seed": ISOLATED_SEED,
            "isolated_cases": CASE_COUNT,
            "bucket_counts": PREFIX_COUNTS,
            "frame_runs": FRAME_COUNT,
            "frame_details": frame_details,
            "focused_seed": FOCUSED_SEED,
            "focused_cases": list(FOCUSED_CASES),
            "focused_passed": len(FOCUSED_CASES),
            "missing_logs": 0,
            "missing_ucdbs": 0,
            "bad_logs": 0,
            "latency48_identity_total": isolated_identity,
            "latency48_identity_mismatches": 0,
            "production_negative_errors": 0,
            "directed_negative_diagnostics": isolated_negative,
            "directed_negative_cases": isolated_negative_cases,
            "ucdb_health": ucdb_health,
        },
        "vhdl": {
            "status": "pass",
            "targets": VHDL_TARGET_COUNT,
            "vsim_invocations": VSIM_INVOCATION_COUNT,
            "log": vhdl_record,
        },
        "hw_tcl": {"status": "pass", "cases": 3, "log": hw_tcl_record},
        "static": {"status": "pass", "lint": 0, "cdc": 0, "rdc": 0, "log": static_record},
        "synthesis": synthesis,
        "gate": gate,
    }
    promotion["receipt_sha256"] = receipt_digest(promotion)
    validate_promotion(repo, promotion)

    if args.dry_run:
        print(json.dumps(promotion, indent=2, sort_keys=True))
        print("MTS_CURRENT_SOURCE_VERIFY_DRY_RUN_PASS")
        return 0

    write_json(args.json_out.resolve(), promotion)
    atomic_write(args.md_out.resolve(), render_dv_evidence(promotion).encode("utf-8"))
    atomic_write(args.syn_report.resolve(), render_syn_report(promotion).encode("utf-8"))
    print("MTS_CURRENT_SOURCE_VERIFY_PASS")
    print("promotion_json=" + str(args.json_out.resolve()))
    print("source_sha256=" + source["aggregate_sha256"])
    print("receipt_sha256=" + promotion["receipt_sha256"])
    return 0


def validate_promotion(repo: Path, evidence: Mapping[str, Any]) -> dict[str, Any]:
    require(evidence.get("schema") == SCHEMA, "promotion schema mismatch")
    require(evidence.get("status") == "pass", "promotion status is not pass")
    require(evidence.get("release") == RELEASE, "promotion release mismatch")
    require(evidence.get("receipt_sha256") == receipt_digest(evidence), "promotion receipt digest mismatch")
    source = source_manifest(repo)
    claimed_source = evidence.get("source") or {}
    require(
        claimed_source.get("aggregate_sha256") == source["aggregate_sha256"],
        "promotion source manifest is stale for this checkout",
    )
    require(claimed_source.get("files") == source["files"], "promotion source file ledger mismatch")
    uvm = evidence.get("uvm") or {}
    require(uvm.get("status") == "pass", "UVM promotion gate is not pass")
    require(uvm.get("isolated_cases") == CASE_COUNT, "promotion isolated case count mismatch")
    require(uvm.get("frame_runs") == FRAME_COUNT, "promotion frame count mismatch")
    require(uvm.get("focused_seed") == FOCUSED_SEED, "promotion focused seed mismatch")
    require(tuple(uvm.get("focused_cases") or ()) == FOCUSED_CASES, "promotion focused case list mismatch")
    require(uvm.get("focused_passed") == len(FOCUSED_CASES), "promotion focused pass count mismatch")
    require(uvm.get("missing_logs") == 0, "promotion records missing UVM logs")
    require(uvm.get("missing_ucdbs") == 0, "promotion records missing UCDBs")
    require(uvm.get("bad_logs") == 0, "promotion records bad UVM logs")
    require(uvm.get("latency48_identity_mismatches") == 0, "promotion records latency48 mismatches")
    require(uvm.get("production_negative_errors") == 0, "promotion records negative production latency")
    require((evidence.get("vhdl") or {}).get("status") == "pass", "VHDL gate is not pass")
    require((evidence.get("static") or {}).get("status") == "pass", "static gate is not pass")
    require((evidence.get("synthesis") or {}).get("status") == "pass", "synthesis gate is not pass")
    require((evidence.get("gate") or {}).get("status") == "pass", "gate comparison is not pass")
    return dict(evidence)


def load_promoted_evidence(repo: Path, path: Path) -> dict[str, Any]:
    require(path.is_file(), "promotion evidence is missing: " + str(path))
    value = json.loads(path.read_text(encoding="utf-8"))
    return validate_promotion(repo.resolve(), value)


def command_check(args: argparse.Namespace) -> int:
    evidence = load_promoted_evidence(args.repo.resolve(), args.evidence.resolve())
    print("MTS_CURRENT_SOURCE_PROMOTION_CHECK_PASS")
    print("source_sha256=" + evidence["source"]["aggregate_sha256"])
    print("receipt_sha256=" + evidence["receipt_sha256"])
    return 0


def bt(value: Any) -> str:
    return BT + str(value) + BT


def render_dv_evidence(evidence: Mapping[str, Any]) -> str:
    uvm = evidence["uvm"]
    source = evidence["source"]
    lines = [
        "# VERSION " + RELEASE + " exact-source DV and SYN evidence",
        "",
        "**Verified:** " + bt(evidence["verified_utc"]) + "  ",
        "**Source manifest:** " + bt(source["aggregate_sha256"]) + "  ",
        "**Promotion receipt:** " + bt(evidence["receipt_sha256"]) + "  ",
        "**Status:** " + bt("PASS - ALL REQUIRED GATES VERIFIED"),
        "",
        "This receipt was produced only after the pre-run source ledger remained",
        "byte-identical and every generated artifact was newer than the run-start",
        "fence. Same-name logs from an earlier run cannot satisfy this gate.",
        "",
        "## Results",
        "",
        "| Gate | Result | Evidence |",
        "|---|:---:|---|",
        "| Exact isolated UVM catalog | PASS | "
        + bt(str(uvm["isolated_cases"]) + "/" + str(uvm["isolated_cases"]))
        + ", seed "
        + bt(uvm["isolated_seed"])
        + " |",
        "| Continuous-frame UVM | PASS | "
        + bt(str(uvm["frame_runs"]) + "/" + str(uvm["frame_runs"]))
        + " |",
        "| Focused release cases | PASS | "
        + bt(str(uvm["focused_passed"]) + "/" + str(len(FOCUSED_CASES)))
        + ", seed "
        + bt(uvm["focused_seed"])
        + " |",
        "| UCDB health | PASS | "
        + bt(uvm["ucdb_health"]["input_count"])
        + " inputs merged successfully |",
        "| Maintained VHDL smoke | PASS | "
        + bt(VHDL_TARGET_COUNT)
        + " targets / "
        + bt(VSIM_INVOCATION_COUNT)
        + " simulator invocations |",
        "| HW Tcl guards | PASS | " + bt("3/3") + " |",
        "| Questa static | PASS | lint " + bt(0) + ", CDC " + bt(0) + ", RDC " + bt(0) + " |",
        "| Quartus fit/resources/all-corner STA | PASS | Standard Fit, seed "
        + bt(1)
        + ", "
        + bt("7.273 ns")
        + " |",
        "| RTL/post-fit signature | PASS | " + bt(evidence["gate"]["signature"]) + " |",
        "",
        "## Physical latency48 audit",
        "",
        "The UVM scoreboard treated latency48 as hit lifetime: co-sampled arrival48",
        "minus true-hit timestamp48. It recorded "
        + bt(uvm["latency48_identity_total"])
        + " exact identities, "
        + bt(uvm["latency48_identity_mismatches"])
        + " mismatches, and "
        + bt(uvm["production_negative_errors"])
        + " negative production-latency errors. Signed-negative samples remained",
        "visible only in explicitly directed diagnostic cases: "
        + bt(uvm["directed_negative_diagnostics"])
        + " samples across "
        + bt(uvm["directed_negative_cases"])
        + " cases.",
        "",
        "## Exact-source ledger",
        "",
        "| Source | SHA-256 |",
        "|---|---|",
    ]
    lines.extend(
        "| " + bt(item["path"]) + " | " + bt(item["sha256"]) + " |"
        for item in source["files"]
    )
    lines.extend(
        [
            "",
            "The complete generated-artifact manifest remains outside Git at "
            + bt(evidence["artifact_manifest"]["path"])
            + ". Its SHA-256 is "
            + bt(evidence["artifact_manifest"]["sha256"])
            + ", and the ordered artifact aggregate is "
            + bt(evidence["artifact_manifest"]["aggregate_sha256"])
            + ". Raw logs, UCDBs, fitter databases, and the netlist remain generated",
            "local artifacts.",
            "",
        ]
    )
    return "\n".join(lines)


def render_syn_report(evidence: Mapping[str, Any]) -> str:
    syn = evidence["synthesis"]
    resources = syn["resources"]
    lines = [
        "# ✅ SYN Report — mutrig_timestamp_processor",
        "",
        "**Release:** " + bt(RELEASE) + "  ",
        "**Device:** " + bt(syn["device"]) + "  ",
        "**Quartus:** " + bt(syn["quartus"]) + "  ",
        "**Source manifest:** " + bt(evidence["source"]["aggregate_sha256"]),
        "",
        "## Signoff Summary",
        "",
        "| status | gate | evidence |",
        "|:---:|---|---|",
        "| ✅ | Standard Fit | seed "
        + bt(syn["seed"])
        + ", period "
        + bt(str(syn["clock_period_ns"]) + " ns")
        + ", effort "
        + bt(syn["fit_effort"])
        + " |",
        "| ✅ | All-corner TimeQuest | setup, hold, recovery, removal, and minimum-pulse-width WNS are nonnegative; every TNS is zero |",
        "| ✅ | Resource model | ALMs "
        + bt(resources["alms"])
        + ", registers "
        + bt(resources["registers"])
        + ", memory bits "
        + bt(resources["memory_bits"])
        + ", RAM blocks "
        + bt(resources["ram_blocks"])
        + ", DSPs "
        + bt(resources["dsp_blocks"])
        + " |",
        "| ✅ | Questa static | lint " + bt(0) + ", CDC " + bt(0) + ", RDC " + bt(0) + " |",
        "| ✅ | RTL/post-fit functional signature | " + bt(evidence["gate"]["signature"]) + "; zero-delay, no SDF |",
        "",
        "## Timing",
        "",
        "| corner | setup | hold | recovery | removal | minimum pulse width |",
        "|---|---:|---:|---:|---:|---:|",
    ]
    for key in TIMING_CORNERS:
        timing = syn["timing"][key]["sta_summary"]
        lines.append(
            "| "
            + key
            + " | "
            + " | ".join(
                bt(str(timing[name]["slack"]) + " ns / TNS " + str(timing[name]["tns"]))
                for name in ("setup", "hold", "recovery", "removal", "minimum_pulse_width")
            )
            + " |"
        )
    lines.extend(
        [
            "",
            "## Resource acceptance",
            "",
            "| resource | result | accepted range |",
            "|---|---:|---:|",
        ]
    )
    for key in ("alms", "registers", "memory_bits", "ram_blocks", "dsp_blocks"):
        bounds = syn["resource_limits"][key]
        lines.append(
            "| "
            + key
            + " | "
            + bt(resources[key])
            + " | "
            + bt(str(bounds["min"]) + ".." + str(bounds["max"]))
            + " |"
        )
    lines.extend(
        [
            "",
            "This report is bound to promotion receipt "
            + bt(evidence["receipt_sha256"])
            + ". The gate comparison is a zero-delay functional-netlist smoke;",
            "TimeQuest, not that simulation, owns timing closure.",
            "",
            "**Result: PASS.**",
            "",
        ]
    )
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--repo",
        type=Path,
        default=Path(__file__).resolve().parents[2],
        help="mutrig_timestamp_processor repository root",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    begin = sub.add_parser("begin", help="capture exact source and clean-run fence")
    begin.add_argument("--state", type=Path, required=True)
    begin.add_argument("--dry-run", action="store_true")
    begin.set_defaults(func=command_begin)

    verify = sub.add_parser("verify", help="verify all gates and emit promotion receipt")
    verify.add_argument("--state", type=Path, required=True)
    verify.add_argument("--compile-log", type=Path, required=True)
    verify.add_argument("--vhdl-log", type=Path, required=True)
    verify.add_argument("--hw-tcl-log", type=Path, required=True)
    verify.add_argument("--static-log", type=Path, required=True)
    verify.add_argument("--quartus-flow-log", type=Path, required=True)
    verify.add_argument(
        "--timing-report",
        action="append",
        default=[],
        metavar="KEY=PATH",
        help="repeat for slow_85c, slow_0c, fast_85c, fast_0c",
    )
    verify.add_argument("--gate-compare-log", type=Path, required=True)
    verify.add_argument("--vcover")
    verify.add_argument(
        "--json-out",
        type=Path,
        default=Path("tb/evidence/current_source_signoff.json"),
    )
    verify.add_argument(
        "--md-out",
        type=Path,
        default=Path("tb/REPORT/current_release/full_dv_26_6_0_0716.md"),
    )
    verify.add_argument(
        "--syn-report",
        type=Path,
        default=Path("syn/SYN_REPORT.md"),
    )
    verify.add_argument("--dry-run", action="store_true")
    verify.set_defaults(func=command_verify)

    check = sub.add_parser("check", help="validate a committed promotion receipt")
    check.add_argument(
        "--evidence",
        type=Path,
        default=Path("tb/evidence/current_source_signoff.json"),
    )
    check.set_defaults(func=command_check)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.func(args))
    except (EvidenceError, OSError, ValueError, json.JSONDecodeError) as exc:
        print("MTS_CURRENT_SOURCE_EVIDENCE_FAIL: " + str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
