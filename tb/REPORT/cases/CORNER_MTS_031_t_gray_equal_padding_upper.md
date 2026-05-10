# ✅ CORNER_MTS_031_t_gray_equal_padding_upper

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive a decoded T gray value exactly equal to `padding_upper`; verify no overflow subtraction occurs because the comparison is strict greater-than. Covers the threshold equality.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E031

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
| ✅ | observed_txn | `1` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_031_t_gray_equal_padding_upper_after_s1.log`](../../uvm/logs/CORNER_MTS_031_t_gray_equal_padding_upper_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_031_t_gray_equal_padding_upper_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_031_t_gray_equal_padding_upper_s1.ucdb) |
| ℹ️ | log.csr | `3` |
| ℹ️ | log.inputs | `1` |
| ℹ️ | log.beats | `1` |
| ℹ️ | log.payloads | `1` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.ts_delta | `0` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.math_error_traces | `1` |
| ℹ️ | log.hit_error_traces | `1` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.18 | 80.18 | 1.10 | 92.09 | 1.10 |
| branch | 63.67 | 63.67 | 1.93 | 84.10 | 1.93 |
| cond | 41.59 | 41.59 | 2.66 | 73.45 | 2.66 |
| expr | 50.00 | 50.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 75.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 22.22 | 0.00 | 66.66 | 0.00 |
| toggle | 18.61 | 18.61 | 8.02 | 39.94 | 8.02 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
