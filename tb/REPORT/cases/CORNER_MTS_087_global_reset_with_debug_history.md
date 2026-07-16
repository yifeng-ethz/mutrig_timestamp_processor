# ✅ CORNER_MTS_087_global_reset_with_debug_history

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Assert global reset while debug-burst history registers are nonzero; verify subsequent debug outputs start from zero. Covers history cleanup.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E087

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
| ✅ | observed_txn | `3` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/CORNER_MTS_087_global_reset_with_debug_history_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/CORNER_MTS_087_global_reset_with_debug_history_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `3` |
| ℹ️ | log.csr | `5` |
| ℹ️ | log.debug_burst | `3` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `3` |
| ℹ️ | log.dual_path_pairs | `3` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.latency48_identity | `3` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `3` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `3` |
| ℹ️ | log.traces | `3` |
| ℹ️ | log.ts_delta | `3` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.33 | 26.44 | 0.00 | 92.08 | 0.00 |
| branch | 61.03 | 20.34 | 0.00 | 83.22 | 0.00 |
| cond | 37.90 | 12.63 | 0.00 | 77.41 | 0.00 |
| expr | 50.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 11.11 | 0.00 | 66.66 | 0.00 |
| toggle | 12.51 | 4.17 | 0.03 | 46.17 | 0.01 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
