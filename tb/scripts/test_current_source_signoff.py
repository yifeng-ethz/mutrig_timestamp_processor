#!/usr/bin/env python3
"""Unit tests for the exact-source MTS signoff evidence helper."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().with_name("current_source_signoff.py")
SPEC = importlib.util.spec_from_file_location("mts_current_source_signoff", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
signoff = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(signoff)


class CurrentSourceSignoffTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.repo = SCRIPT.parents[2]

    def test_exact_case_inventory(self) -> None:
        case_ids = signoff.parse_case_ids(self.repo)
        self.assertEqual(len(case_ids), 521)
        self.assertEqual(len(set(case_ids)), 521)

    def test_source_manifest_is_deterministic(self) -> None:
        first = signoff.source_manifest(self.repo)
        second = signoff.source_manifest(self.repo)
        self.assertEqual(first, second)
        self.assertEqual(len(first["aggregate_sha256"]), 64)

    def test_uvm_log_health_and_latency_identity(self) -> None:
        case_id = "STD_MTS_020_op_mode_bits_readback"
        text = "\n".join(
            (
                "# vsim -sv_seed 260716 +MTSP_CASE_ID=" + case_id
                + " +MTSP_FRAME_KIND=isolated",
                "# [MTSP_SCB] beats=2 latency48_identity=2 latency48_negative_diagnostics=0",
                "# *** TEST PASSED ***",
                "# UVM_ERROR :    0",
                "# UVM_FATAL :    0",
                "# [MTSP_SCB]     1",
                "# Coverage database has been saved successfully.",
            )
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "case.log"
            path.write_text(text, encoding="utf-8")
            summary = signoff.verify_uvm_log(
                path, seed=260716, case_id=case_id
            )
        self.assertEqual(summary["latency48_identity"], 2)

    def test_uvm_log_rejects_identity_mismatch(self) -> None:
        case_id = "STD_MTS_020_op_mode_bits_readback"
        text = "\n".join(
            (
                "# vsim -sv_seed 260716 +MTSP_CASE_ID=" + case_id
                + " +MTSP_FRAME_KIND=isolated",
                "# [MTSP_SCB] beats=2 latency48_identity=1 latency48_negative_diagnostics=0",
                "# *** TEST PASSED ***",
                "# UVM_ERROR :    0",
                "# UVM_FATAL :    0",
                "# [MTSP_SCB]     1",
                "# Coverage database has been saved successfully.",
            )
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "case.log"
            path.write_text(text, encoding="utf-8")
            with self.assertRaises(signoff.EvidenceError):
                signoff.verify_uvm_log(path, seed=260716, case_id=case_id)

    def test_frame_report_count_lines_do_not_shadow_summaries(self) -> None:
        text = "\n".join(
            (
                "# vsim -sv_seed 1 +MTSP_FRAME_KIND=bucket_frame "
                "+MTSP_FRAME_BUCKET=BASIC",
                "# [MTSP_FRAME_SUMMARY] kind=bucket_frame bucket=BASIC "
                "checkpoints=130 inputs=130 payloads=130 beats=134 "
                "dual_path_pairs=130 traces=130",
                "# [MTSP_SCB] beats=134 latency48_identity=134 "
                "latency48_negative_diagnostics=0",
                "# *** TEST PASSED ***",
                "# UVM_ERROR :    0",
                "# UVM_FATAL :    0",
                "# [MTSP_FRAME_SUMMARY]     1",
                "# [MTSP_SCB]     1",
                "# Coverage database has been saved successfully.",
            )
        )
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "frame.log"
            path.write_text(text, encoding="utf-8")
            summary = signoff.verify_uvm_log(
                path, seed=1, frame=("bucket_frame", "BASIC", 130)
            )
        self.assertEqual(summary["latency48_identity"], 134)

    def test_resource_limits_accept_baseline_shape(self) -> None:
        text = "\n".join(
            (
                "Logic utilization (in ALMs) : 1,156 / 91,680",
                "Total registers : 1960",
                "Total block memory bits : 491,670 / 13,987,840",
                "Total RAM Blocks : 62 / 1,366",
                "Total DSP Blocks : 0 / 800",
            )
        )
        values = signoff.parse_resources(text)
        self.assertEqual(values["alms"], 1156)
        self.assertEqual(values["dsp_blocks"], 0)

    def test_resource_limits_reject_outlier(self) -> None:
        text = "\n".join(
            (
                "Logic utilization (in ALMs) : 10 / 91,680",
                "Total registers : 1960",
                "Total block memory bits : 491,670 / 13,987,840",
                "Total RAM Blocks : 62 / 1,366",
                "Total DSP Blocks : 0 / 800",
            )
        )
        with self.assertRaises(signoff.EvidenceError):
            signoff.parse_resources(text)

    def test_explicit_corner_sta_summary_projection(self) -> None:
        values = {
            "setup": 1.25,
            "hold": 0.25,
            "recovery": 2.0,
            "removal": 0.5,
            "minimum_pulse_width": 3.0,
        }
        result = signoff.explicit_corner_sta_summary(values)
        self.assertEqual(result["setup"], {"slack": 1.25, "tns": 0.0})
        self.assertEqual(result["minimum_pulse_width"], {"slack": 3.0, "tns": 0.0})

    def test_receipt_digest_detects_tamper(self) -> None:
        evidence = {"schema": signoff.SCHEMA, "status": "pass"}
        evidence["receipt_sha256"] = signoff.receipt_digest(evidence)
        self.assertEqual(
            evidence["receipt_sha256"], signoff.receipt_digest(evidence)
        )
        evidence["status"] = "fail"
        self.assertNotEqual(
            evidence["receipt_sha256"], signoff.receipt_digest(evidence)
        )

    def test_ucdb_magic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "test.ucdb"
            path.write_bytes(b"\n\nQUESTA_UCDB_FILE\nfixture")
            signoff.verify_ucdb_magic(path)
            path.write_bytes(b"not a ucdb")
            with self.assertRaises(signoff.EvidenceError):
                signoff.verify_ucdb_magic(path)

    def test_zero_byte_make_stamp_is_a_valid_fresh_artifact(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            path = repo / ".compiled"
            path.touch()
            record = signoff.artifact_record(
                path, repo, 0, require_nonempty=False
            )
            self.assertEqual(record["size"], 0)
            with self.assertRaises(signoff.EvidenceError):
                signoff.artifact_record(path, repo, 0)


if __name__ == "__main__":
    unittest.main()
