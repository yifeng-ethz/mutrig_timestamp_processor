# ✅ CORNER_MTS_091_single_channel_window_index0

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Build with only channel 0 enabled; verify the start-of-run bookkeeping arrays index correctly. Covers the lower loop bound.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E091

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
| ✅ | observed_txn | `11` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_091_single_channel_window_index0_after_s1.log`](../../uvm/logs/CORNER_MTS_091_single_channel_window_index0_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_091_single_channel_window_index0_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_091_single_channel_window_index0_s1.ucdb) |
| ℹ️ | log.beats | `11` |
| ℹ️ | log.csr | `4` |
| ℹ️ | log.debug_burst | `2` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `3` |
| ℹ️ | log.dual_path_pairs | `3` |
| ℹ️ | log.empty_eops | `8` |
| ℹ️ | log.eops | `8` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `3` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `3` |
| ℹ️ | log.traces | `3` |
| ℹ️ | log.ts_delta | `2` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.59 | 7.51 | 0.37 | 95.22 | 0.03 |
| branch | 71.87 | 6.53 | 0.39 | 90.31 | 0.04 |
| cond | 54.86 | 4.99 | 0.00 | 80.53 | 0.00 |
| expr | 50.00 | 4.55 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 9.09 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 4.04 | 11.11 | 77.77 | 1.01 |
| toggle | 9.34 | 0.85 | 0.27 | 50.64 | 0.02 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
