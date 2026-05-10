# ✅ CORNER_MTS_003_terminate_on_final_eop_cycle

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Assert `TERMINATING` on the same cycle as an accepted input EOP beat; verify one and only one delayed boundary is generated. Covers the stop-edge coincidence.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E003

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
| ✅ | observed_txn | `5` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_003_terminate_on_final_eop_cycle_after_s1.log`](../../uvm/logs/CORNER_MTS_003_terminate_on_final_eop_cycle_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_003_terminate_on_final_eop_cycle_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_003_terminate_on_final_eop_cycle_s1.ucdb) |
| ℹ️ | log.beats | `5` |
| ℹ️ | log.csr | `2` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `1` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `1` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 77.96 | 15.59 | 7.54 | 80.60 | 1.51 |
| branch | 66.92 | 13.38 | 16.14 | 68.89 | 3.23 |
| cond | 50.00 | 10.00 | 26.73 | 54.31 | 5.35 |
| expr | 50.00 | 10.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 20.00 | 50.00 | 100.00 | 10.00 |
| fsm_trans | 33.33 | 6.67 | 33.33 | 44.44 | 6.67 |
| toggle | 8.64 | 1.73 | 1.68 | 8.95 | 0.34 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
