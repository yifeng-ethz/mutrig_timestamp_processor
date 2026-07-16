#!/usr/bin/env python3
"""Generate the MTSP DV dashboard from the explicit UVM log/UCDB artifacts."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import date
from pathlib import Path
from typing import Any

SKILL_GEN = Path("/home/yifeng/.codex/skills/dv-workflow/scripts/dv_report_gen.py")
DV_REPORT_FORMAT_LINTER = Path(
    "/home/yifeng/.codex/skills/dv-workflow/scripts/dv_report_format_check.py"
)
CURRENT_SOURCE_EVIDENCE_HELPER = Path(__file__).resolve().with_name(
    "current_source_signoff.py"
)

BUCKET_ORDER = ("BASIC", "EDGE", "PROF", "ERROR")
PREFIX_TO_BUCKET = {
    "STD": "BASIC",
    "CORNER": "EDGE",
    "STRESS": "PROF",
    "NEG": "ERROR",
}
BUCKET_DOC = {
    "BASIC": "DV_BASIC.md",
    "EDGE": "DV_EDGE.md",
    "PROF": "DV_PROF.md",
    "ERROR": "DV_ERROR.md",
}
FRAME_RUNS = [
    ("mtsp_bucket_frame_BASIC", "bucket_frame", "BASIC", 130),
    ("mtsp_bucket_frame_EDGE", "bucket_frame", "EDGE", 131),
    ("mtsp_bucket_frame_PROF", "bucket_frame", "PROF", 130),
    ("mtsp_bucket_frame_ERROR", "bucket_frame", "ERROR", 130),
    ("mtsp_all_buckets_frame", "all_buckets_frame", "-", 521),
]
CURRENT_RELEASE = "26.6.0.0716"
CURRENT_RELEASE_EXPLICIT_UVM_CASES = 521
CURRENT_RELEASE_VHDL_TARGETS = 5
CURRENT_RELEASE_VSIM_INVOCATIONS = 6
CURRENT_RELEASE_DELTA_CASES = (
    "STD_MTS_020_op_mode_bits_readback",
    "STD_MTS_099_arrival_delta_uses_gts",
    "CORNER_MTS_035_mts_counter_wrap_pulse",
    "CORNER_MTS_071_debug_ts_minus_one",
    "NEG_MTS_041_negative_debug_ts_error",
)
CURRENT_RELEASE_DELTA_SEED = 260716
CURRENT_RELEASE_EVIDENCE_JSON = "evidence/current_source_signoff.json"
CURRENT_RELEASE_FULL_EVIDENCE = (
    "REPORT/current_release/full_dv_26_6_0_0716.md"
)
ARCHIVED_PRE_26_6_EVIDENCE = "REPORT/current_release/full_dv_20260716.md"
CURRENT_SOURCE_PENDING_REASON = (
    "VERSION 26.6.0.0716 adds the external-epoch-reset RTL/profile after the "
    "archived 521-case artifacts; an exact-source rerun is required"
)
BASELINE_EVIDENCE_COMMIT = "b8c02b8"
BASELINE_EVIDENCE_DATE = "2026-05-10"
CASE_RE = re.compile(r'^\s*"([A-Z_]+_MTS_[^"]+)"\s*:', re.MULTILINE)
PLAN_CASE_RE = re.compile(
    r"^\s*-\s+`(?P<short>[A-Z]\d{3})\s+\|\s+"
    r"(?P<case>[A-Z_]+_MTS_[^`:\s]+)`:?\s*(?P<desc>.*)$"
)
PLAN_TABLE_ROW_RE = re.compile(r"^\|\s*(?P<short>[A-Z]\d{3})\s*\|")
SCB_RE = re.compile(r"\[MTSP_SCB\]\s+(?P<body>.*)$", re.MULTILINE)
KV_RE = re.compile(r"([A-Za-z0-9_]+)=(-?\d+)")
TRACE_RE = re.compile(r"\[MTSP_TRACE\]\s+(?P<body>.*)$", re.MULTILINE)
FRAME_CHECKPOINT_RE = re.compile(r"\[MTSP_FRAME\]\s+checkpoint\s+(?P<body>.*)$", re.MULTILINE)
FRAME_SUMMARY_RE = re.compile(r"\[MTSP_FRAME_SUMMARY\]\s+(?P<body>.*)$", re.MULTILINE)
FRAME_KV_RE = re.compile(r"([A-Za-z0-9_]+)=([^\s]+)")
DUT_INSTANCE_RE = re.compile(
    r"=== Instance: /tb_top/dut\s*\n"
    r"=== Design Unit: work\.mts_processor\(rtl\)\s*\n"
    r"=+\n(?P<body>.*?)(?=\n=+\n=== Instance: |\Z)",
    re.DOTALL,
)
METRIC_RE = re.compile(
    r"^\s*(Branches|Conditions|Expressions|FSM States|FSM Transitions|Statements|Toggles)"
    r"\s+\d+\s+\d+\s+\d+\s+([0-9]+(?:\.[0-9]+)?)%",
    re.MULTILINE,
)
BAD_LOG_RE = re.compile(
    r"UVM_(FATAL|ERROR)[\s:]+[1-9]|"
    r"^# UVM_(FATAL|ERROR)\s+[^:]|"
    r"^# \*\* (Fatal|Error):|"
    r"^(Fatal|Error):",
    re.MULTILINE,
)
LOCAL_GENERATED_ARTIFACT_LINK_RE = re.compile(
    r"\[`(?P<path>uvm/(?:logs|cov_after)/[^`]+)`\]\([^)]+\)"
)
PENDING_NON_CLAIM_PREFIX = "CURRENT-SOURCE RERUN PENDING:"

METRIC_NAMES = {
    "Statements": "stmt",
    "Branches": "branch",
    "Conditions": "cond",
    "Expressions": "expr",
    "FSM States": "fsm_state",
    "FSM Transitions": "fsm_trans",
    "Toggles": "toggle",
}


def load_base():
    spec = importlib.util.spec_from_file_location("dv_report_gen_base", SKILL_GEN)
    if spec is None or spec.loader is None:
        raise SystemExit(f"failed to load base dv_report_gen from {SKILL_GEN}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


base = load_base()


def load_current_source_helper():
    spec = importlib.util.spec_from_file_location(
        "mts_current_source_signoff", CURRENT_SOURCE_EVIDENCE_HELPER
    )
    if spec is None or spec.loader is None:
        raise SystemExit(
            "failed to load exact-source evidence helper from "
            f"{CURRENT_SOURCE_EVIDENCE_HELPER}"
        )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


current_source_helper = load_current_source_helper()


def rel(path: Path, root: Path) -> str:
    return str(path.relative_to(root)).replace(os.sep, "/")


def render_publication_safe_artifacts(text: str) -> str:
    """Render ignored logs/UCDBs as local-only paths, never Git links."""

    return LOCAL_GENERATED_ARTIFACT_LINK_RE.sub(
        lambda match: (
            f"`{match.group('path')}` — local generated artifact; "
            "intentionally not published"
        ),
        text,
    )


def qualify_current_source_pending(data: dict[str, Any], reason: str) -> None:
    """Prevent archived evidence from being promoted as current-source closure."""

    reason = reason.strip()
    if not reason:
        raise SystemExit("error: --current-source-pending requires a non-empty reason")

    delta = data.setdefault("current_release_delta", {})
    delta["status"] = "pending"
    delta["full_regression_status"] = "pending"
    delta["source_evidence_status"] = "pending"
    delta["source_evidence_reason"] = reason
    delta["vhdl_status"] = "pending"
    delta["static_status"] = "pending"
    delta["synthesis_status"] = "pending"
    delta["gate_sim_status"] = "pending"

    scope = data.setdefault("signoff_scope", {})
    scope["CURRENT_RELEASE_DELTA_UVM"] = (
        "PENDING current-source rerun; archived 5/5 directed result is not promoted"
    )
    scope["CURRENT_RELEASE_FULL_521"] = (
        "PENDING current-source rerun; archived 521/521 isolated and 5/5 "
        "continuous-frame artifacts are not promoted"
    )
    scope["CURRENT_RELEASE_VHDL_SMOKE"] = "PENDING exact-source promotion receipt"
    scope["CURRENT_RELEASE_STATIC"] = "PENDING exact-source promotion receipt"
    scope["CURRENT_RELEASE_SYNTHESIS"] = (
        "PENDING Standard Fit, all-corner STA, and resource verification"
    )
    scope["CURRENT_RELEASE_GATE_SIM"] = "PENDING exact-source gate comparison"

    pending_claim = f"{PENDING_NON_CLAIM_PREFIX} {reason}"
    non_claims = [
        item
        for item in (data.get("non_claims") or [])
        if not str(item).startswith(PENDING_NON_CLAIM_PREFIX)
    ]
    data["non_claims"] = [pending_claim] + non_claims


def load_verified_current_source_evidence(
    tb: Path, evidence_path: Path
) -> dict[str, Any]:
    try:
        return current_source_helper.load_promoted_evidence(
            tb.parent, evidence_path
        )
    except Exception as exc:
        raise SystemExit(
            "error: exact-source promotion receipt rejected: "
            f"{evidence_path}\n{exc}"
        ) from exc


def apply_verified_current_source_evidence(
    data: dict[str, Any], evidence: dict[str, Any]
) -> None:
    """Promote the dashboard only after cross-checking the receipt and raw model."""

    totals = data.get("totals") or {}
    audit = data.get("artifact_audit") or {}
    implementation = data.get("implementation_summary") or {}
    uvm = evidence.get("uvm") or {}
    failures: list[str] = []

    if totals.get("planned_cases") != CURRENT_RELEASE_EXPLICIT_UVM_CASES:
        failures.append("dashboard planned_cases is not 521")
    if totals.get("evidenced_cases") != CURRENT_RELEASE_EXPLICIT_UVM_CASES:
        failures.append("dashboard evidenced_cases is not 521")
    if data.get("failed_cases"):
        failures.append("dashboard has failed cases")
    if audit.get("missing_logs") != 0:
        failures.append("dashboard has missing isolated logs")
    if audit.get("missing_ucdb") != 0:
        failures.append("dashboard has missing isolated UCDBs")
    if implementation.get("bad_or_incomplete_log_count") != 0:
        failures.append("dashboard has bad/incomplete isolated logs")
    if implementation.get("stale_artifact_without_engine_marker_count") != 0:
        failures.append("dashboard has stale/missing engine markers")

    continuous = [
        run
        for run in (data.get("signoff_runs") or [])
        if run.get("kind") in ("bucket_frame", "all_buckets_frame")
    ]
    if len(continuous) != len(FRAME_RUNS):
        failures.append("dashboard does not contain exactly five frame runs")

    delta = data.get("current_release_delta") or {}
    if int(delta.get("latency48_identity_total", -1)) != int(
        uvm.get("latency48_identity_total", -2)
    ):
        failures.append("latency48 identity total disagrees with promotion receipt")
    if int(delta.get("latency48_negative_total", -1)) != int(
        uvm.get("directed_negative_diagnostics", -2)
    ):
        failures.append(
            "directed-negative diagnostic total disagrees with promotion receipt"
        )
    if int(delta.get("latency48_negative_cases", -1)) != int(
        uvm.get("directed_negative_cases", -2)
    ):
        failures.append(
            "directed-negative case count disagrees with promotion receipt"
        )
    if failures:
        raise SystemExit(
            "error: exact-source receipt cannot promote this DV_REPORT model:\n  "
            + "\n  ".join(failures)
        )

    source = evidence["source"]
    synthesis = evidence["synthesis"]
    delta.update(
        {
            "release": CURRENT_RELEASE,
            "seed": uvm["focused_seed"],
            "cases": list(uvm["focused_cases"]),
            "status": "pass",
            "full_regression_status": "pass",
            "source_evidence_status": "verified",
            "source_evidence_reason": "",
            "vhdl_status": "pass",
            "static_status": "pass",
            "synthesis_status": "pass",
            "gate_sim_status": "pass",
            "source_manifest_sha256": source["aggregate_sha256"],
            "promotion_receipt_sha256": evidence["receipt_sha256"],
            "verified_utc": evidence["verified_utc"],
            "latency48_identity_total": uvm["latency48_identity_total"],
            "latency48_negative_total": uvm[
                "directed_negative_diagnostics"
            ],
            "latency48_negative_cases": uvm["directed_negative_cases"],
            "quartus_worst_setup_slack": min(
                corner["sta_summary"]["setup"]["slack"]
                for corner in synthesis["timing"].values()
            ),
            "quartus_worst_hold_slack": min(
                corner["sta_summary"]["hold"]["slack"]
                for corner in synthesis["timing"].values()
            ),
            "quartus_resources": synthesis["resources"],
        }
    )
    data["current_release_delta"] = delta

    git_at_begin = evidence.get("git_at_begin") or {}
    scope = data.setdefault("signoff_scope", {})
    scope.update(
        {
            "EVIDENCE_GIT_BRANCH": str(git_at_begin.get("branch", "unknown")),
            "EVIDENCE_GIT_COMMIT": (
                str(git_at_begin.get("head", "unknown"))[:12]
                + " + exact source manifest"
            ),
            "EVIDENCE_DATE": str(evidence["verified_utc"]).split("T", 1)[0],
            "CURRENT_SOURCE_GIT_HEAD": str(
                git_at_begin.get("head", "unknown")
            )[:12],
            "CURRENT_SOURCE_MANIFEST": source["aggregate_sha256"],
            "CURRENT_RELEASE_UVM_SCOPE": (
                "521/521 isolated PASS, seed=1; 5/5 continuous-frame PASS"
            ),
            "CURRENT_RELEASE_DELTA_UVM": (
                "5/5 PASS, seed="
                f"{uvm['focused_seed']}; exact-source receipt verified"
            ),
            "CURRENT_RELEASE_VHDL_SMOKE": (
                "5/5 maintained targets PASS (6 vsim invocations)"
            ),
            "CURRENT_RELEASE_STATIC": "lint=0, cdc=0, rdc=0",
            "CURRENT_RELEASE_FULL_521": (
                "PASS exact-source 521/521 isolated and 5/5 continuous-frame"
            ),
            "CURRENT_RELEASE_SYNTHESIS": (
                "PASS Standard Fit seed=1, 7.273 ns, four-corner STA/resources"
            ),
            "CURRENT_RELEASE_GATE_SIM": (
                "PASS matching RTL/post-fit signature "
                f"{evidence['gate']['signature']}"
            ),
            "CURRENT_RELEASE_PROMOTION_RECEIPT": evidence[
                "receipt_sha256"
            ],
        }
    )

    stale_prefixes = (
        PENDING_NON_CLAIM_PREFIX,
        "Archived pre-26.6 evidence parsed",
        "VERSION 26.6.0.0716 adds the external-epoch-reset",
        "Current-release standalone Quartus fit/resource/STA closure",
    )
    data["non_claims"] = [
        item
        for item in (data.get("non_claims") or [])
        if not str(item).startswith(stale_prefixes)
    ]


def render_publication_qualification(text: str, data: dict[str, Any]) -> str:
    """Apply publication safety and, when requested, a visible stale-evidence gate."""

    text = render_publication_safe_artifacts(text)
    delta = data.get("current_release_delta") or {}
    if delta.get("source_evidence_status") != "pending":
        return text

    reason = str(delta.get("source_evidence_reason") or "current-source rerun required")
    banner = (
        "> ❓ **Publication qualification:** current-source rerun pending. PASS "
        "counts below describe archived execution artifacts only and are not "
        f"current-source closure. Reason: {reason}"
    )
    lines = text.splitlines()
    if lines and lines[0].startswith("# "):
        lines[0] = re.sub(r"^#\s+[✅⚠️❌❓ℹ️]", "# ❓", lines[0], count=1)
        insert_at = 1
        metadata_seen = False
        while insert_at < len(lines):
            stripped = lines[insert_at].strip()
            if not stripped:
                insert_at += 1
                continue
            if stripped.startswith("**"):
                metadata_seen = True
                insert_at += 1
                continue
            break
        if not metadata_seen:
            insert_at = 1
        prefix = lines[:insert_at]
        suffix = lines[insert_at:]
        while prefix and not prefix[-1].strip():
            prefix.pop()
        while suffix and not suffix[0].strip():
            suffix.pop(0)
        qualified = prefix + ["", banner, ""] + suffix
        return "\n".join(qualified)
    return banner + "\n\n" + text


def find_vcover() -> str:
    candidates = [
        os.environ.get("VCOVER"),
        "/data1/questaone_sim/questasim/bin/vcover",
        "/data1/intelFPGA_pro/23.1/questa_fse/bin/vcover",
        shutil.which("vcover"),
    ]
    for candidate in candidates:
        if candidate and Path(candidate).exists():
            return candidate
    raise SystemExit("error: vcover not found; set VCOVER or load the Questa environment")


def run_tool(cmd: list[str], *, cwd: Path | None = None, capture: bool = True) -> str:
    proc = subprocess.run(
        cmd,
        cwd=str(cwd) if cwd else None,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if proc.returncode != 0:
        output = proc.stdout or ""
        raise SystemExit(
            "error: command failed with exit "
            f"{proc.returncode}: {' '.join(cmd)}\n{output[-4000:]}"
        )
    return proc.stdout or ""


def parse_dut_metrics(report: str, *, context: str) -> dict[str, dict[str, float]]:
    match = DUT_INSTANCE_RE.search(report)
    if not match:
        raise SystemExit(f"error: /tb_top/dut coverage block missing in {context}")
    metrics: dict[str, dict[str, float]] = {}
    for metric, pct_s in METRIC_RE.findall(match.group("body")):
        key = METRIC_NAMES[metric]
        metrics[key] = {"pct": round(float(pct_s), 2)}
    missing = [key for key in base.COV_KEYS if key not in metrics]
    if missing:
        raise SystemExit(f"error: missing DUT coverage metrics in {context}: {missing}")
    return metrics


def vcover_report_metrics(vcover: str, ucdb: Path, *, context: str) -> dict[str, dict[str, float]]:
    report = run_tool([vcover, "report", "-code", "bcesft", str(ucdb)])
    return parse_dut_metrics(report, context=context)


def merge_ucdb(vcover: str, out_ucdb: Path, inputs: list[Path]) -> None:
    out_ucdb.parent.mkdir(parents=True, exist_ok=True)
    if out_ucdb.exists():
        out_ucdb.unlink()
    run_tool([vcover, "merge", str(out_ucdb)] + [str(item) for item in inputs])


def coverage_delta(
    after: dict[str, dict[str, float]],
    before: dict[str, dict[str, float]] | None,
) -> dict[str, dict[str, float]]:
    out: dict[str, dict[str, float]] = {}
    for key in base.COV_KEYS:
        after_pct = after.get(key, {}).get("pct", 0.0)
        before_pct = before.get(key, {}).get("pct", 0.0) if before else 0.0
        out[key] = {"pct": round(max(after_pct - before_pct, 0.0), 2)}
    return out


def coverage_per_txn(
    cov: dict[str, dict[str, float]],
    observed_txn: int,
) -> dict[str, dict[str, float]]:
    denom = max(observed_txn, 1)
    return {
        key: {"pct": round(value.get("pct", 0.0) / denom, 4)}
        for key, value in cov.items()
    }


def parse_case_ids(tb: Path) -> list[str]:
    source = (tb / "uvm" / "mtsp_cases.svh").read_text(encoding="utf-8")
    case_ids = CASE_RE.findall(source)
    seen: set[str] = set()
    ordered: list[str] = []
    for case_id in case_ids:
        if case_id not in seen:
            seen.add(case_id)
            ordered.append(case_id)
    return ordered


def case_prefix(case_id: str) -> str:
    return case_id.split("_MTS_", 1)[0]


def case_index(case_id: str) -> int:
    match = re.search(r"_MTS_(\d{3})", case_id)
    return int(match.group(1)) if match else 0


def parse_plan_docs(tb: Path) -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    for bucket, doc_name in BUCKET_DOC.items():
        path = tb / doc_name
        if not path.exists():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            match = PLAN_CASE_RE.match(line)
            if match:
                case_id = match.group("case")
                desc = match.group("desc").strip()
                out[case_id] = {
                    "short_id": match.group("short"),
                    "bucket": bucket,
                    "description": desc,
                    "doc": doc_name,
                }
                continue

            if not PLAN_TABLE_ROW_RE.match(line):
                continue
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if len(cells) != 7:
                continue
            short_id, _method, scenario, _iter, stimulus, pass_criteria, _ref = cells
            words = scenario.split()
            if len(words) < 4 or words[1] != "MTS" or not words[2].isdigit():
                continue
            prefix = words[0].upper()
            number = words[2]
            suffix = "_".join(word.lower() for word in words[3:])
            case_id = f"{prefix}_MTS_{number}_{suffix}"
            desc = stimulus.strip()
            if pass_criteria and pass_criteria != stimulus:
                desc = f"{stimulus.strip()} Pass criteria: {pass_criteria.strip()}"
            out[case_id] = {
                "short_id": short_id,
                "bucket": bucket,
                "description": desc,
                "doc": doc_name,
            }
    return out


def parse_scoreboard(log_text: str) -> dict[str, int]:
    summaries = [match.group("body") for match in SCB_RE.finditer(log_text)]
    for summary in reversed(summaries):
        pairs = KV_RE.findall(summary)
        if pairs:
            return {key: int(value) for key, value in pairs}
    return {}


def parse_traces(log_text: str) -> dict[str, Any]:
    lines = [
        match.group("body").strip()
        for match in TRACE_RE.finditer(log_text)
        if KV_RE.search(match.group("body"))
    ]
    math_error = sum(1 for line in lines if "math_error=1" in line)
    hit_error = sum(1 for line in lines if "hit_error=1" in line)
    return {
        "trace_detail_lines": len(lines),
        "math_error_traces": math_error,
        "hit_error_traces": hit_error,
        "last_trace": lines[-1] if lines else "",
    }


def parse_frame_kv(body: str) -> dict[str, str]:
    return {key: value for key, value in FRAME_KV_RE.findall(body)}


def parse_frame_summary(log_text: str) -> dict[str, str]:
    summaries = [match.group("body") for match in FRAME_SUMMARY_RE.finditer(log_text)]
    for summary in reversed(summaries):
        if "kind=" in summary and "checkpoints=" in summary:
            return parse_frame_kv(summary)
    return {}


def parse_frame_checkpoints(log_text: str) -> list[dict[str, str]]:
    return [parse_frame_kv(match.group("body")) for match in FRAME_CHECKPOINT_RE.finditer(log_text)]


def log_health(log_text: str) -> tuple[bool, bool]:
    passed = "*** TEST PASSED ***" in log_text
    bad = bool(BAD_LOG_RE.search(log_text))
    return passed and not bad, bad


def build_case_shells(tb: Path) -> dict[str, list[dict[str, Any]]]:
    plan = parse_plan_docs(tb)
    by_bucket: dict[str, list[dict[str, Any]]] = {bucket: [] for bucket in BUCKET_ORDER}
    for full_case_id in parse_case_ids(tb):
        prefix = case_prefix(full_case_id)
        bucket = PREFIX_TO_BUCKET.get(prefix)
        if bucket is None:
            continue
        meta = plan.get(full_case_id, {})
        short_id = meta.get("short_id") or f"{bucket[0]}{case_index(full_case_id):03d}"
        description = meta.get("description") or full_case_id.replace("_", " ")
        doc_name = meta.get("doc") or BUCKET_DOC[bucket]
        by_bucket[bucket].append(
            {
                "case_id": short_id,
                "full_case_id": full_case_id,
                "legacy_test_name": full_case_id,
                "bucket": bucket,
                "method": "D",
                "implemented": True,
                "implementation_mode": "explicit_uvm_handler",
                "build_tag": "after",
                "build_tag_lower": "after",
                "isolated_effort": "signoff",
                "scenario": description,
                "primary_checks": (
                    "UVM reference model checks normal payload, debug sideband, "
                    "CSR/readout, and bounded protocol invariants for this documented case."
                ),
                "contract_anchor": f"{doc_name}:{short_id}",
            }
        )
    for bucket in by_bucket:
        by_bucket[bucket].sort(key=lambda item: (case_index(item["full_case_id"]), item["full_case_id"]))
    return by_bucket


def annotate_case_evidence(
    tb: Path,
    vcover: str,
    case_item: dict[str, Any],
) -> tuple[bool, bool]:
    full_case_id = case_item["full_case_id"]
    log_path = tb / "uvm" / "logs" / f"{full_case_id}_after_s1.log"
    ucdb_path = tb / "uvm" / "cov_after" / f"{full_case_id}_s1.ucdb"
    missing = False
    bad = False

    if not log_path.exists():
        missing = True
        case_item.update({"passed": False, "evidence_state": "missing_log"})
        return missing, bad
    if not ucdb_path.exists():
        missing = True
        case_item.update({"passed": False, "evidence_state": "missing_ucdb"})
        return missing, bad

    log_text = log_path.read_text(encoding="utf-8", errors="replace")
    passed, bad = log_health(log_text)
    scb = parse_scoreboard(log_text)
    traces = parse_traces(log_text)
    observed_txn = max(scb.get("inputs", 0), scb.get("payloads", 0), scb.get("beats", 0), 1)
    stale_marker_missing = (
        f"+MTSP_CASE_ID={full_case_id}" not in log_text
        or "[MTSP_SCB]" not in log_text
        or "*** TEST PASSED ***" not in log_text
    )

    standalone = vcover_report_metrics(vcover, ucdb_path, context=full_case_id)
    case_item.update(
        {
            "passed": passed,
            "evidence_state": "log_ucdb_pass" if passed else "log_ucdb_fail",
            "observed_txn": observed_txn,
            "standalone_coverage": standalone,
            "isolated_cov_per_txn": coverage_per_txn(standalone, observed_txn),
            "log_summary": {
                "beats": scb.get("beats", 0),
                "csr": scb.get("csr", 0),
                "debug_burst": scb.get("debug_burst", 0),
                "debug_path_required": scb.get("debug_path_required", 0),
                "debug_ts": scb.get("debug_ts", 0),
                "dual_path_pairs": scb.get("dual_path_pairs", 0),
                "empty_eops": scb.get("empty_eops", 0),
                "eops": scb.get("eops", 0),
                "hit_error_traces": traces["hit_error_traces"],
                "inputs": scb.get("inputs", 0),
                "latency48_identity": scb.get("latency48_identity", 0),
                "latency48_negative_diagnostics": scb.get(
                    "latency48_negative_diagnostics", 0
                ),
                "math_error_traces": traces["math_error_traces"],
                "payloads": scb.get("payloads", 0),
                "ready_x": scb.get("ready_x", 0),
                "scoreboard_ports": "csr, hit0, hit1, debug_ts, debug_burst, ts_delta",
                "trace_detail_lines": traces["trace_detail_lines"],
                "traces": scb.get("traces", 0),
                "ts_delta": scb.get("ts_delta", 0),
            },
            "debug_meta": {
                "normal_path": {
                    "inputs": scb.get("inputs", 0),
                    "beats": scb.get("beats", 0),
                    "payloads": scb.get("payloads", 0),
                    "eops": scb.get("eops", 0),
                    "empty_eops": scb.get("empty_eops", 0),
                    "latency48_identity": scb.get("latency48_identity", 0),
                    "latency48_negative_diagnostics": scb.get(
                        "latency48_negative_diagnostics", 0
                    ),
                },
                "debug_path": {
                    "debug_ts": scb.get("debug_ts", 0),
                    "debug_burst": scb.get("debug_burst", 0),
                    "ts_delta": scb.get("ts_delta", 0),
                    "traces": scb.get("traces", 0),
                    "trace_detail_lines": traces["trace_detail_lines"],
                },
                "cross_validation": {
                    "dual_path_pairs": scb.get("dual_path_pairs", 0),
                    "debug_path_required": scb.get("debug_path_required", 0),
                    "last_trace": traces["last_trace"],
                },
            },
            "artifact_paths": {
                "log": rel(log_path, tb),
                "ucdb": rel(ucdb_path, tb),
            },
            "stale_artifact_marker_missing": stale_marker_missing,
        }
    )
    return missing, bad or not passed


def annotate_ordered_coverage(
    work: Path,
    tb: Path,
    vcover: str,
    buckets: dict[str, list[dict[str, Any]]],
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, float]]]:
    rendered_buckets: dict[str, dict[str, Any]] = {}
    final_ucdbs: list[Path] = []

    for bucket_name in BUCKET_ORDER:
        cases = buckets[bucket_name]
        previous_metrics: dict[str, dict[str, float]] | None = None
        current_ucdb: Path | None = None
        merge_trace: list[dict[str, Any]] = []

        for step, case_item in enumerate(cases, start=1):
            full_case_id = case_item["full_case_id"]
            case_ucdb = tb / "uvm" / "cov_after" / f"{full_case_id}_s1.ucdb"
            if step == 1:
                current_ucdb = case_ucdb
            else:
                assert current_ucdb is not None
                out_ucdb = work / f"{bucket_name.lower()}_{step % 2}.ucdb"
                merge_ucdb(vcover, out_ucdb, [current_ucdb, case_ucdb])
                if current_ucdb.parent == work and current_ucdb.exists():
                    current_ucdb.unlink()
                current_ucdb = out_ucdb

            merged_metrics = vcover_report_metrics(
                vcover,
                current_ucdb,
                context=f"{bucket_name} ordered step {step}",
            )
            gain = coverage_delta(merged_metrics, previous_metrics)
            observed_txn = int(case_item.get("observed_txn", 1) or 1)
            case_item["bucket_gain_by_case"] = gain
            case_item["bucket_merged_total_after_case"] = merged_metrics
            case_item["bucket_gain_per_txn"] = coverage_per_txn(gain, observed_txn)
            merge_trace.append(
                {
                    "step": step,
                    "case_id": case_item["case_id"],
                    "full_case_id": full_case_id,
                    "legacy_test_name": full_case_id,
                    "merged_total_after_case": merged_metrics,
                }
            )
            previous_metrics = merged_metrics

        if current_ucdb is None:
            raise SystemExit(f"error: no cases in bucket {bucket_name}")
        final_ucdb = work / f"{bucket_name.lower()}_final.ucdb"
        if current_ucdb != final_ucdb:
            shutil.copyfile(current_ucdb, final_ucdb)
        final_ucdbs.append(final_ucdb)

        planned = len(cases)
        evidenced = sum(1 for case_item in cases if case_item.get("passed") is True)
        functional_pct = round((100.0 * evidenced / planned) if planned else 0.0, 2)
        rendered_buckets[bucket_name] = {
            "bucket": bucket_name,
            "catalog_source": BUCKET_DOC[bucket_name],
            "catalog_summary": f"{planned} explicit MTSP {bucket_name} UVM handlers",
            "planned_cases": planned,
            "catalog_planned_cases": planned,
            "promoted_cases": planned,
            "evidenced_cases": evidenced,
            "catalog_pending_cases": 0,
            "ordered_case_ids": [case_item["full_case_id"] for case_item in cases],
            "cases": cases,
            "merge_trace": merge_trace,
            "merged_bucket_total": previous_metrics or {},
            "functional_coverage": {
                "pct": functional_pct,
                "evidenced": evidenced,
                "planned": planned,
            },
        }

    merged_all = work / "all_buckets_isolated_521.ucdb"
    merge_ucdb(vcover, merged_all, final_ucdbs)
    merged_total = vcover_report_metrics(vcover, merged_all, context="all buckets ordered isolated")
    return rendered_buckets, merged_total


def structural_holes(merged_total: dict[str, dict[str, float]]) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    open_items: list[str] = []
    dispositions: list[dict[str, Any]] = []
    for key, target in base.TARGETS.items():
        pct = merged_total.get(key, {}).get("pct")
        if pct is None or pct >= target:
            continue
        open_items.append(key)
        dispositions.append(
            {
                "area": key,
                "instance_summary": {
                    "metrics": {metric: merged_total.get(metric, {}).get("pct", 0.0) for metric in base.COV_KEYS},
                    "instance_count": 1,
                },
                "classification": "open",
                "reason": (
                    f"DUT {key} coverage is {pct:.2f}% against the {target:.1f}% "
                    "workflow target after all 521 isolated cases."
                ),
                "evidence_anchor": "DV_COV.md#targets-vs-merged-totals",
                "next_action": "Review uncovered RTL objects before any structural-coverage signoff tag.",
            }
        )

    status = "raw_target_met" if not open_items else "open_structural_targets_below_threshold"
    closure = {
        "status": status,
        "basis": (
            "DUT-only code coverage parsed from Questa vcover for the ordered merge of "
            "all 521 explicit isolated UVM case UCDBs."
        ),
        "disposition_count": len(dispositions),
        "open_dispositions": open_items,
    }
    return closure, dispositions


def build_frame_curve(checkpoints: list[dict[str, str]], expected_count: int, kind: str) -> str:
    chunks: list[str] = []
    denom = max(expected_count, 1)
    token_prefix = {
        "BASIC": "B",
        "EDGE": "E",
        "PROF": "P",
        "ERROR": "X",
    }
    for txn, checkpoint in enumerate(checkpoints, start=1):
        pct = round((100.0 * txn) / denom, 2)
        case_token = checkpoint.get("case_token", "")
        if not re.match(r"^[BEPX]\d{3}$", case_token):
            bucket = checkpoint.get("bucket", "")
            index = int(checkpoint.get("index", "0") or 0)
            prefix = token_prefix.get(bucket, "")
            case_token = f"{prefix}{index:03d}" if prefix and index else f"checkpoint_{txn}"
        chunks.append(
            " ".join(
                [
                    f"txn={txn}",
                    f"case={case_token}",
                    f"seq={kind}",
                    f"pct={pct}",
                    "delta_bins=1",
                    "reason=normal_debug_checkpoint",
                ]
            )
        )
    return "; ".join(chunks)


def annotate_frame_run(
    tb: Path,
    vcover: str,
    run_id: str,
    kind: str,
    bucket: str,
    expected_count: int,
) -> dict[str, Any]:
    log_path = tb / "uvm" / "logs" / f"{run_id}_after_s1.log"
    ucdb_path = tb / "uvm" / "cov_after" / f"{run_id}_s1.ucdb"
    if not log_path.exists():
        raise SystemExit(f"error: missing continuous-frame log: {log_path}")
    if not ucdb_path.exists():
        raise SystemExit(f"error: missing continuous-frame UCDB: {ucdb_path}")

    log_text = log_path.read_text(encoding="utf-8", errors="replace")
    passed, bad = log_health(log_text)
    if not passed or bad:
        raise SystemExit(f"error: continuous-frame run failed or has errors: {run_id}")

    checkpoints = parse_frame_checkpoints(log_text)
    summary = parse_frame_summary(log_text)
    scb = parse_scoreboard(log_text)
    traces = parse_traces(log_text)
    checkpoint_count = len(checkpoints)
    summary_checkpoints = int(summary.get("checkpoints", "0") or 0)
    if checkpoint_count != expected_count or summary_checkpoints != expected_count:
        raise SystemExit(
            f"error: {run_id} expected {expected_count} frame checkpoints, "
            f"got checkpoint_lines={checkpoint_count} summary={summary_checkpoints}"
        )
    if scb.get("dual_path_pairs", 0) < expected_count or scb.get("traces", 0) < expected_count:
        raise SystemExit(
            f"error: {run_id} did not report one normal/debug pair per checkpoint: "
            f"dual_path_pairs={scb.get('dual_path_pairs', 0)} traces={scb.get('traces', 0)}"
        )

    code_cov = vcover_report_metrics(vcover, ucdb_path, context=run_id)
    cross_pct = round(100.0 * checkpoint_count / max(expected_count, 1), 2)
    txns = max(
        scb.get("inputs", 0),
        scb.get("payloads", 0),
        scb.get("dual_path_pairs", 0),
        checkpoint_count,
    )
    return {
        "run_id": run_id,
        "kind": kind,
        "bucket": bucket,
        "build_tag": "after",
        "sequence_name": "mtsp_continuous_frame_test ordered checkpoint stream",
        "case_count": expected_count,
        "effort": "signoff",
        "iter_cap": None,
        "payload_cap": None,
        "code_coverage": code_cov,
        "cross_summary": {
            "pct": cross_pct,
            "txns": txns,
            "queued_overlap": 0,
            "counter_checks_passed": checkpoint_count,
            "counter_checks_failed": 0,
            "unexpected_outputs": 0,
            "curve": build_frame_curve(checkpoints, expected_count, kind),
            "checkpoints": checkpoints,
            "scoreboard": {
                "inputs": scb.get("inputs", 0),
                "beats": scb.get("beats", 0),
                "payloads": scb.get("payloads", 0),
                "eops": scb.get("eops", 0),
                "empty_eops": scb.get("empty_eops", 0),
                "debug_ts": scb.get("debug_ts", 0),
                "debug_burst": scb.get("debug_burst", 0),
                "ts_delta": scb.get("ts_delta", 0),
                "dual_path_pairs": scb.get("dual_path_pairs", 0),
                "traces": scb.get("traces", 0),
                "trace_detail_lines": traces["trace_detail_lines"],
                "latency48_identity": scb.get("latency48_identity", 0),
                "latency48_negative_diagnostics": scb.get(
                    "latency48_negative_diagnostics", 0
                ),
            },
        },
        "artifact_paths": {
            "log": rel(log_path, tb),
            "ucdb": rel(ucdb_path, tb),
        },
        "limitations": [
            "Continuous-frame run uses one compact normal/debug-paired payload checkpoint per documented case token; full case-specific assertions remain in isolated mode."
        ],
    }


def annotate_frame_runs(tb: Path, vcover: str) -> list[dict[str, Any]]:
    return [
        annotate_frame_run(tb, vcover, run_id, kind, bucket, expected_count)
        for run_id, kind, bucket, expected_count in FRAME_RUNS
    ]


def render_scoreboard_evidence(run: dict[str, Any]) -> str:
    cross = run.get("cross_summary") or {}
    scoreboard = cross.get("scoreboard") or {}
    if not scoreboard:
        return ""

    expected = int(run.get("case_count", 0) or 0)
    required_exact = {
        "inputs",
        "payloads",
        "debug_ts",
        "debug_burst",
        "ts_delta",
        "dual_path_pairs",
        "traces",
        "trace_detail_lines",
    }
    rows = [
        "## Scoreboard Evidence",
        "",
        "<!-- analysis-port evidence from normal payload, debug timestamp, debug burst, and timestamp-delta monitors. -->",
        "",
        "| status | port/counter | observed | requirement |",
        "|:---:|---|---:|---|",
    ]
    for field in (
        "inputs",
        "beats",
        "payloads",
        "eops",
        "empty_eops",
        "debug_ts",
        "debug_burst",
        "ts_delta",
        "dual_path_pairs",
        "traces",
        "trace_detail_lines",
        "latency48_identity",
        "latency48_negative_diagnostics",
    ):
        observed = int(scoreboard.get(field, 0) or 0)
        if field in required_exact:
            ok = observed == expected
            requirement = f"== case_count ({expected})"
        elif field == "latency48_identity":
            expected_beats = int(scoreboard.get("beats", 0) or 0)
            ok = observed == expected_beats
            requirement = f"== valid beats ({expected_beats})"
        elif field == "latency48_negative_diagnostics":
            ok = observed == 0
            requirement = "== 0 in nominal continuous traffic"
        elif field == "beats":
            ok = observed >= expected
            requirement = f">= case_count ({expected})"
        else:
            ok = observed > 0
            requirement = "> 0"
        status = base.PASS_EMOJI if ok else base.FAIL_EMOJI
        rows.append(f"| {status} | `{field}` | {observed} | `{requirement}` |")
    return "\n".join(rows)


def render_signoff_run(run: dict[str, Any]) -> str:
    rendered = base.render_signoff_run(run)
    scoreboard = render_scoreboard_evidence(run)
    if not scoreboard:
        return rendered
    marker = "\n## Transaction growth curve"
    if marker not in rendered:
        return rendered + "\n\n" + scoreboard
    return rendered.replace(marker, "\n" + scoreboard + "\n" + marker, 1)


def build_report_data(tb: Path, work: Path, vcover: str) -> dict[str, Any]:
    buckets = build_case_shells(tb)
    missing_logs = 0
    bad_logs = 0
    stale_markers = 0

    for bucket_cases in buckets.values():
        for case_item in bucket_cases:
            missing, bad = annotate_case_evidence(tb, vcover, case_item)
            missing_logs += int(missing)
            bad_logs += int(bad)
            stale_markers += int(case_item.get("stale_artifact_marker_missing", False))

    rendered_buckets, merged_total = annotate_ordered_coverage(work, tb, vcover, buckets)
    bucket_summary: list[dict[str, Any]] = []
    for bucket_name in BUCKET_ORDER:
        bucket = rendered_buckets[bucket_name]
        bucket_summary.append(
            {
                "bucket": bucket_name,
                "planned_cases": bucket["planned_cases"],
                "catalog_planned_cases": bucket["catalog_planned_cases"],
                "promoted_cases": bucket["promoted_cases"],
                "evidenced_cases": bucket["evidenced_cases"],
                "catalog_pending_cases": bucket["catalog_pending_cases"],
                "ordered_case_ids": bucket["ordered_case_ids"],
                "merged_bucket_total": bucket["merged_bucket_total"],
                "functional_coverage": bucket["functional_coverage"],
            }
        )

    all_cases = [case_item for bucket_name in BUCKET_ORDER for case_item in rendered_buckets[bucket_name]["cases"]]
    failed_cases = [case_item["full_case_id"] for case_item in all_cases if case_item.get("passed") is not True]
    planned_total = len(all_cases)
    if planned_total != CURRENT_RELEASE_EXPLICIT_UVM_CASES:
        raise SystemExit(
            "error: explicit UVM inventory changed: "
            f"expected {CURRENT_RELEASE_EXPLICIT_UVM_CASES}, found {planned_total}"
        )
    evidenced_total = planned_total - len(failed_cases)
    debug_required_cases = sum(
        1 for case_item in all_cases if case_item.get("log_summary", {}).get("debug_path_required", 0) == 1
    )
    dual_path_pairs = sum(int(case_item.get("log_summary", {}).get("dual_path_pairs", 0)) for case_item in all_cases)
    debug_scb_traces = sum(int(case_item.get("log_summary", {}).get("traces", 0)) for case_item in all_cases)
    trace_detail_lines = sum(
        int(case_item.get("log_summary", {}).get("trace_detail_lines", 0)) for case_item in all_cases
    )
    latency48_identity_total = sum(
        int(case_item.get("log_summary", {}).get("latency48_identity", 0))
        for case_item in all_cases
    )
    latency48_negative_total = sum(
        int(case_item.get("log_summary", {}).get("latency48_negative_diagnostics", 0))
        for case_item in all_cases
    )
    latency48_negative_cases = sum(
        1
        for case_item in all_cases
        if int(case_item.get("log_summary", {}).get("latency48_negative_diagnostics", 0)) > 0
    )
    frame_runs = annotate_frame_runs(tb, vcover)
    branch_name = run_tool(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=tb.parent).strip()
    commit = run_tool(["git", "rev-parse", "--short", "HEAD"], cwd=tb.parent).strip()
    archived_full_artifact_status = "pass" if not failed_cases else "fail"
    structural_closure, hole_disposition = structural_holes(merged_total)
    open_structural = structural_closure.get("open_dispositions", [])
    if open_structural == ["toggle"]:
        non_claims = [
            f"Archived pre-26.6 evidence parsed as {archived_full_artifact_status.upper()} for 521 explicit UVM cases and five continuous-frame runs; it is recorded in {ARCHIVED_PRE_26_6_EVIDENCE} and is not current-source closure.",
            CURRENT_SOURCE_PENDING_REASON + ".",
            "Current-release standalone Quartus fit/resource/STA closure and gate-level simulation remain pending and are not claimed by this DV dashboard.",
            "Raw DUT toggle coverage remains below the 80% target; statement, branch, FSM-state, FSM-transition, functional, and mandatory continuous-frame targets pass.",
        ]
    elif open_structural:
        non_claims = [
            f"Archived pre-26.6 evidence parsed as {archived_full_artifact_status.upper()} for 521 explicit UVM cases and five continuous-frame runs; it is recorded in {ARCHIVED_PRE_26_6_EVIDENCE} and is not current-source closure.",
            CURRENT_SOURCE_PENDING_REASON + ".",
            "Current-release standalone Quartus fit/resource/STA closure and gate-level simulation remain pending and are not claimed by this DV dashboard.",
            "Structural coverage below target remains an open item.",
        ]
    else:
        non_claims = [
            f"Archived pre-26.6 evidence parsed as {archived_full_artifact_status.upper()} for 521 explicit UVM cases and five continuous-frame runs; it is recorded in {ARCHIVED_PRE_26_6_EVIDENCE} and is not current-source closure.",
            CURRENT_SOURCE_PENDING_REASON + ".",
            "Current-release standalone Quartus fit/resource/STA closure and gate-level simulation remain pending and are not claimed by this DV dashboard.",
        ]

    data: dict[str, Any] = {
        "report_title": "mutrig_timestamp_processor mtsp_doc_case_test",
        "dut_name": "mts_processor",
        "date": date.today().isoformat(),
        "rtl_variant": "after",
        "seed": 1,
        "case_id_policy": {
            "source": "tb/uvm/mtsp_cases.svh explicit dispatch table",
            "bucket_order": list(BUCKET_ORDER),
        },
        "signoff_scope": {
            "DUT_IMPL": "VHDL rtl",
            "RTL_VARIANT": "after",
            "DEBUG_PATH_REQUIRED": "1",
            "RESET_EXPECTED_LATENCY": "2000",
            "EXPLICIT_CASES": str(planned_total),
            "DEBUG_REQUIRED_CASES": f"{debug_required_cases}/{planned_total}",
            "DUAL_PATH_PAIRS": str(dual_path_pairs),
            "SCOREBOARD_TRACES": str(debug_scb_traces),
            "TRACE_DETAIL_LINES": str(trace_detail_lines),
            "LATENCY48_IDENTITIES": str(latency48_identity_total),
            "LATENCY48_IDENTITY_MISMATCHES": "0",
            "LATENCY48_PRODUCTION_NEGATIVE_ERRORS": "0",
            "LATENCY48_DIRECTED_NEGATIVE_DIAGNOSTICS": (
                f"{latency48_negative_total} samples in {latency48_negative_cases} explicit cases"
            ),
            "BUCKET_FRAME_RUNS": "4/4",
            "ALL_BUCKETS_FRAME_RUNS": "1/1",
            "EVIDENCE_GIT_BRANCH": branch_name,
            "EVIDENCE_GIT_COMMIT": f"{commit}-dirty",
            "EVIDENCE_DATE": date.today().isoformat(),
            "CURRENT_RELEASE": CURRENT_RELEASE,
            "CURRENT_SOURCE_GIT_HEAD": commit,
            "CURRENT_RELEASE_UVM_SCOPE": (
                f"{CURRENT_RELEASE_EXPLICIT_UVM_CASES} explicit cases; "
                "current-source rerun pending"
            ),
            "CURRENT_RELEASE_DELTA_UVM": (
                f"PENDING current-source rerun; archived {len(CURRENT_RELEASE_DELTA_CASES)}/"
                f"{len(CURRENT_RELEASE_DELTA_CASES)} PASS, seed={CURRENT_RELEASE_DELTA_SEED}"
            ),
            "CURRENT_RELEASE_VHDL_SMOKE": "PENDING exact-source promotion receipt",
            "CURRENT_RELEASE_STATIC": "PENDING exact-source promotion receipt",
            "CURRENT_RELEASE_FULL_521": (
                "PENDING exact-source rerun; archived artifact parse="
                f"{archived_full_artifact_status.upper()} "
                "(521/521 isolated; 5/5 continuous-frame)"
            ),
            "CURRENT_RELEASE_SYNTHESIS": (
                "PENDING Standard Fit, all-corner STA, and resource verification"
            ),
            "CURRENT_RELEASE_GATE_SIM": "PENDING",
            "CURRENT_RELEASE_DELTA_REPORT": CURRENT_RELEASE_FULL_EVIDENCE,
            "probe_only_exclusions": "none",
        },
        "current_release_delta": {
            "release": CURRENT_RELEASE,
            "seed": CURRENT_RELEASE_DELTA_SEED,
            "cases": list(CURRENT_RELEASE_DELTA_CASES),
            "status": "pending",
            "full_regression_status": "pending",
            "source_evidence_status": "pending",
            "source_evidence_reason": CURRENT_SOURCE_PENDING_REASON,
            "vhdl_status": "pending",
            "static_status": "pending",
            "synthesis_status": "pending",
            "gate_sim_status": "pending",
            "evidence_summary": CURRENT_RELEASE_FULL_EVIDENCE,
            "archived_evidence_summary": ARCHIVED_PRE_26_6_EVIDENCE,
            "archived_full_artifact_status": archived_full_artifact_status,
            "explicit_uvm_cases": CURRENT_RELEASE_EXPLICIT_UVM_CASES,
            "vhdl_targets": CURRENT_RELEASE_VHDL_TARGETS,
            "vsim_invocations": CURRENT_RELEASE_VSIM_INVOCATIONS,
            "latency48_identity_total": latency48_identity_total,
            "latency48_negative_total": latency48_negative_total,
            "latency48_negative_cases": latency48_negative_cases,
        },
        "non_claims": non_claims,
        "coverage_category_status": {
            "supported_with_targets": {
                "stmt": "DUT statement coverage from Questa code coverage.",
                "branch": "DUT branch coverage from Questa code coverage.",
                "fsm_state": "DUT FSM-state coverage from Questa code coverage.",
                "fsm_trans": "DUT FSM-transition coverage from Questa code coverage.",
                "toggle": "DUT toggle coverage from Questa code coverage.",
            },
            "supported_without_hard_target": {
                "cond": "DUT condition coverage is reported without a hard workflow target.",
                "expr": "DUT expression coverage is reported without a hard workflow target.",
            },
            "unsupported": {},
        },
        "coverage_hole_disposition": hole_disposition,
        "structural_coverage_closure": structural_closure,
        "failed_cases": failed_cases,
        "implementation_summary": {
            "implemented_count": planned_total,
            "unimplemented_count": 0,
            "missing_artifact_count": missing_logs,
            "bad_or_incomplete_log_count": bad_logs,
            "stale_artifact_without_engine_marker_count": stale_markers,
            "debug_meta_source": "last [MTSP_SCB] and [MTSP_TRACE] lines in each UVM log",
        },
        "buckets": rendered_buckets,
        "bucket_summary": bucket_summary,
        "totals": {
            "planned_cases": planned_total,
            "catalog_planned_cases": planned_total,
            "promoted_cases": planned_total,
            "evidenced_cases": evidenced_total,
            "catalog_pending_cases": 0,
            "excluded_cases": 0,
            "merged_total_code_coverage": merged_total,
            "functional_coverage": {
                "pct": round((100.0 * evidenced_total / planned_total) if planned_total else 0.0, 2),
                "evidenced": evidenced_total,
                "planned": planned_total,
            },
            "structural_coverage_closure": structural_closure,
        },
        "execution_modes": {
            "isolated": {
                "bucket_order": list(BUCKET_ORDER),
                "per_bucket_case_order": {
                    bucket_name: rendered_buckets[bucket_name]["ordered_case_ids"]
                    for bucket_name in BUCKET_ORDER
                },
            },
            "bucket_frame": {
                "runs": [run["run_id"] for run in frame_runs if run["kind"] == "bucket_frame"],
                "bucket_order": list(BUCKET_ORDER),
                "restart_between_cases": False,
            },
            "all_buckets_frame": {
                "runs": [run["run_id"] for run in frame_runs if run["kind"] == "all_buckets_frame"],
                "bucket_order": list(BUCKET_ORDER),
                "restart_between_cases": False,
            },
        },
        "signoff_runs": [
            {
                "run_id": "mtsp_explicit_521_ordered_isolated_merge",
                "kind": "ordered_isolated_merge",
                "build_tag": "after",
                "sequence_name": "mtsp_doc_case_test plus MTSP_CASE_ID for all explicit handlers",
                "case_count": planned_total,
                "effort": "signoff",
                "code_coverage": merged_total,
                "cross_summary": {
                    "pct": round((100.0 * evidenced_total / planned_total) if planned_total else 0.0, 2),
                    "txns": sum(int(case_item.get("observed_txn", 0) or 0) for case_item in all_cases),
                    "counter_checks_passed": planned_total,
                    "counter_checks_failed": len(failed_cases),
                    "unexpected_outputs": 0,
                    "curve": "",
                    "checkpoints": [],
                },
                "limitations": [
                    "This signoff run is the ordered merge of isolated case UCDBs, not a no-restart frame simulation."
                ],
            }
        ]
        + frame_runs,
        "random_cases": [],
        "cases": all_cases,
        "artifact_audit": {
            "cases": planned_total,
            "missing_logs": missing_logs,
            "bad_or_incomplete_logs": bad_logs,
            "missing_ucdb": sum(
                1
                for case_item in all_cases
                if not (tb / "uvm" / "cov_after" / f"{case_item['full_case_id']}_s1.ucdb").exists()
            ),
            "continuous_frame_runs": len(frame_runs),
        },
    }
    return data


def clean_generated_tree(report: Path) -> None:
    for rel_dir in ("buckets", "cases", "cross", "txn_growth"):
        directory = report / rel_dir
        directory.mkdir(parents=True, exist_ok=True)
        for child in directory.glob("*.md"):
            child.unlink()
    readme = report / "README.md"
    if readme.exists():
        readme.unlink()


def render_dashboard(data: dict[str, Any]) -> str:
    text = base.render_dashboard(data)
    text = text.replace(
        "`~/.codex/skills/dv-workflow/scripts/dv_report_gen.py`",
        "`python3 tb/scripts/dv_report_gen_local.py --tb tb`",
    )
    delta = data.get("current_release_delta") or {}
    delta_status = delta.get("status", "pending")
    full_status = delta.get("full_regression_status", "pending")
    vhdl_status = delta.get("vhdl_status", "pending")
    static_status = delta.get("static_status", "pending")
    synthesis_status = delta.get("synthesis_status", "pending")
    gate_status = delta.get("gate_sim_status", "pending")
    archived = delta.get("source_evidence_status") == "pending"
    def status_icon(status: str) -> str:
        return "✅" if status == "pass" else ("❌" if status == "fail" else "❓")

    delta_icon = status_icon(delta_status)
    full_icon = status_icon(full_status)
    vhdl_icon = status_icon(vhdl_status)
    static_icon = status_icon(static_status)
    synthesis_icon = status_icon(synthesis_status)
    gate_icon = status_icon(gate_status)
    delta_case_count = len(delta.get("cases") or [])
    if archived:
        delta_evidence = (
            f"`{delta_status.upper()}`; archived `{delta_case_count}/{delta_case_count}` "
            f"PASS, seed `{delta.get('seed', '?')}`"
        )
        audit_qualifier = "archived "
        evidence_detail = (
            "Archived predecessor evidence: "
            f"[`{delta.get('archived_evidence_summary', ARCHIVED_PRE_26_6_EVIDENCE)}`]"
            f"({delta.get('archived_evidence_summary', ARCHIVED_PRE_26_6_EVIDENCE)}). "
            "The exact-source rerun will be recorded at "
            f"`{delta.get('evidence_summary', CURRENT_RELEASE_FULL_EVIDENCE)}`."
        )
    else:
        delta_evidence = (
            f"`{delta_case_count}/{delta_case_count}` PASS, "
            f"seed `{delta.get('seed', '?')}`"
        )
        audit_qualifier = ""
        evidence_detail = (
            "Detailed current-release evidence: "
            f"[`{delta.get('evidence_summary', CURRENT_RELEASE_FULL_EVIDENCE)}`]"
            f"({delta.get('evidence_summary', CURRENT_RELEASE_FULL_EVIDENCE)})."
        )
    closure = "\n".join(
        [
            "\n## Phase-I R16 Closure Evidence\n",
            "| status | gate | evidence |",
            "|:---:|---|---|",
            f"| {delta_icon} | VERSION `{delta.get('release', 'unknown')}` directed latency48 delta | {delta_evidence} |",
            f"| {vhdl_icon} | Maintained VHDL smoke | `{vhdl_status.upper()}`; required scope is `{delta.get('vhdl_targets', CURRENT_RELEASE_VHDL_TARGETS)}` targets / `{delta.get('vsim_invocations', CURRENT_RELEASE_VSIM_INVOCATIONS)}` `vsim` invocations |",
            f"| {static_icon} | Questa static screen | `{static_status.upper()}`; required findings are lint `0`, CDC `0`, RDC `0` |",
            f"| {full_icon} | Full current-release regression | `{full_status.upper()}` |",
            f"| {full_icon} | Physical latency48 audit | {audit_qualifier}`{delta.get('latency48_identity_total', 0)}` exact identities; `0` mismatches; `0` production-negative errors; `{delta.get('latency48_negative_total', 0)}` directed diagnostics in `{delta.get('latency48_negative_cases', 0)}` explicit cases |",
            f"| {synthesis_icon} | Standalone Quartus closure | `{synthesis_status.upper()}`; Standard Fit seed `1`, four-corner STA/resources at `7.273 ns` |",
            f"| {gate_icon} | Current-release gate simulation | `{gate_status.upper()}` |",
            "",
            evidence_detail,
            "",
        ]
    )
    return text.replace("\n## Signoff Scope\n", closure + "## Signoff Scope\n", 1)


def render_covmd(data: dict[str, Any]) -> str:
    text = base.render_covmd(data)
    text = text.replace(
        "`python3 ~/.codex/skills/dv-workflow/scripts/dv_report_gen.py --tb <tb>`",
        "`python3 tb/scripts/dv_report_gen_local.py --tb tb`",
    )
    return text.replace(
        "`python3 ~/.codex/skills/dv-workflow/scripts/dv_report_gen.py <tb>`",
        "`python3 tb/scripts/dv_report_gen_local.py --tb tb`",
    )


def write_report_tree(tb: Path, data: dict[str, Any]) -> None:
    report = tb / "REPORT"
    clean_generated_tree(report)
    seed = data.get("seed", 1)

    for bucket_name, bucket in (data.get("buckets") or {}).items():
        for case in bucket.get("cases", []):
            cid = case.get("full_case_id", case.get("case_id", "case"))
            build_tag = case.get("build_tag", data.get("rtl_variant", "after"))
            log_rel = f"uvm/logs/{cid}_{build_tag}_s{seed}.log"
            ucdb_rel = f"uvm/cov_after/{cid}_s{seed}.ucdb"
            base.write(
                report / "cases" / f"{cid}.md",
                render_publication_qualification(
                    base.render_case(case, log_rel, ucdb_rel), data
                ),
            )
        base.write(
            report / "buckets" / f"{bucket_name}.md",
            render_publication_qualification(base.render_bucket(bucket_name, bucket), data),
        )

    for run in data.get("signoff_runs") or []:
        base.write(
            report / "cross" / f"{base.slug(run.get('run_id', 'run'))}.md",
            render_publication_qualification(render_signoff_run(run), data),
        )

    base.write(
        report / "README.md",
        render_publication_qualification(base.render_report_readme(data), data),
    )
    base.write(
        tb / "DV_REPORT.md",
        render_publication_qualification(render_dashboard(data), data),
    )
    base.write(
        tb / "DV_COV.md",
        render_publication_qualification(render_covmd(data), data),
    )


def lint_dashboard(tb: Path) -> None:
    lint = subprocess.run(
        ["python3", str(DV_REPORT_FORMAT_LINTER), str(tb / "DV_REPORT.md"), "--quiet"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if lint.returncode != 0:
        output = lint.stdout or ""
        raise SystemExit(
            "error: DV_REPORT.md does not match the packet_scheduler canonical "
            f"dashboard format\n{output}"
        )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tb", default=str(Path(__file__).resolve().parents[1]))
    parser.add_argument("--json", default=None)
    parser.add_argument("--render-only", action="store_true")
    parser.add_argument("--keep-work", action="store_true")
    parser.add_argument(
        "--verified-evidence",
        default=None,
        help=(
            "promotion receipt produced by current_source_signoff.py; defaults "
            "to tb/evidence/current_source_signoff.json when that file exists"
        ),
    )
    parser.add_argument(
        "--current-source-pending",
        metavar="REASON",
        help=(
            "render archived evidence with an explicit current-source rerun gate; "
            "also records the pending qualification in DV_REPORT.json"
        ),
    )
    args = parser.parse_args(argv)

    tb = Path(args.tb).resolve()
    json_path = Path(args.json).resolve() if args.json else tb / "DV_REPORT.json"
    if not tb.is_dir():
        raise SystemExit(f"error: --tb is not a directory: {tb}")
    default_evidence_path = tb / CURRENT_RELEASE_EVIDENCE_JSON
    evidence_path = (
        Path(args.verified_evidence).resolve()
        if args.verified_evidence
        else default_evidence_path
    )
    if args.current_source_pending and evidence_path.is_file():
        raise SystemExit(
            "error: --current-source-pending conflicts with a verified "
            f"promotion receipt: {evidence_path}"
        )

    if args.render_only:
        data = json.loads(json_path.read_text(encoding="utf-8"))
    else:
        vcover = find_vcover()
        work_parent = Path(tempfile.mkdtemp(prefix="mtsp_dv_report_"))
        try:
            data = build_report_data(tb, work_parent, vcover)
        finally:
            if args.keep_work:
                print(f"kept coverage work directory: {work_parent}")
            else:
                shutil.rmtree(work_parent, ignore_errors=True)

    if evidence_path.is_file():
        evidence = load_verified_current_source_evidence(tb, evidence_path)
        apply_verified_current_source_evidence(data, evidence)
    elif args.verified_evidence:
        raise SystemExit(
            f"error: explicit --verified-evidence is missing: {evidence_path}"
        )
    else:
        qualify_current_source_pending(
            data, args.current_source_pending or CURRENT_SOURCE_PENDING_REASON
        )
    json_path.write_text(
        json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )

    write_report_tree(tb, data)
    lint_dashboard(tb)
    print(
        f"generated {tb / 'REPORT'} "
        f"(buckets={len(data.get('buckets') or {})}, "
        f"cases={sum(len(bucket.get('cases', [])) for bucket in (data.get('buckets') or {}).values())}, "
        f"signoff_runs={len(data.get('signoff_runs') or [])})"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
