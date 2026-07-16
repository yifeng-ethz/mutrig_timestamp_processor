# ✅ NEG_MTS_081_pipeline_two_math_regression

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Compare `LPM_DIV_PIPELINE=2` against `4` and require identical math results aside from latency; any arithmetic difference is a failure. Covers packaged-build correctness.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X081

## Execution Evidence

<!-- fields (chief-architect legend)
  status                       = this case's overall health (legend: ✅ pass / ⚠️ partial / ❌ fail / ❓ pending)
  method                       = D = directed (1 txn); R = randomised (N txns)
  observed_txn                 = number of scoreboard-observed transactions driven by this case
  standalone_coverage          = code coverage measured from this case's own isolated UCDB
  isolated_cov_per_txn         = standalone_coverage averaged over observed_txn (useful for random cases)
  bucket_gain_by_case          = incremental code coverage this case added to the bucket's ordered merge
  bucket_merged_total_after    = the bucket's merged code coverage after this case was merged
  bucket_gain_per_txn          = bucket_gain_by_case averaged over observed_txn
-->

| status | field | value |
|:---:|---|---|
| ✅ | observed_txn | `96` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/NEG_MTS_081_pipeline_two_math_regression_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/NEG_MTS_081_pipeline_two_math_regression_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `96` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `96` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `96` |
| ℹ️ | log.dual_path_pairs | `96` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `96` |
| ℹ️ | log.latency48_identity | `96` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `96` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `96` |
| ℹ️ | log.traces | `96` |
| ℹ️ | log.ts_delta | `96` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.84 | 0.83 | 0.00 | 92.68 | 0.00 |
| branch | 62.98 | 0.66 | 0.00 | 83.44 | 0.00 |
| cond | 38.70 | 0.40 | 0.00 | 82.25 | 0.00 |
| expr | 50.00 | 0.52 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 0.78 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.23 | 0.00 | 77.77 | 0.00 |
| toggle | 24.10 | 0.25 | 2.29 | 43.56 | 0.02 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
