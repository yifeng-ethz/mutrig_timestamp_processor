# ✅ NEG_MTS_004_illegal_ctrl_during_flushing

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive an illegal control word while `FLUSHING` holds control ready low; require it to be ignored until the stop drain completes. Covers hostile command injection during stop drain.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X004

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_004_illegal_ctrl_during_flushing_after_s1.log`](../../uvm/logs/NEG_MTS_004_illegal_ctrl_during_flushing_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_004_illegal_ctrl_during_flushing_s1.ucdb`](../../uvm/cov_after/NEG_MTS_004_illegal_ctrl_during_flushing_s1.ucdb) |
| ℹ️ | log.csr | `2` |
| ℹ️ | log.inputs | `1` |
| ℹ️ | log.beats | `5` |
| ℹ️ | log.payloads | `1` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.ts_delta | `0` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.07 | 15.81 | 4.81 | 82.77 | 0.96 |
| branch | 67.96 | 13.59 | 9.37 | 72.26 | 1.87 |
| cond | 53.09 | 10.62 | 16.82 | 55.75 | 3.36 |
| expr | 50.00 | 10.00 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 20.00 | 25.00 | 100.00 | 5.00 |
| fsm_trans | 44.44 | 8.89 | 22.22 | 44.44 | 4.44 |
| toggle | 8.39 | 1.68 | 1.06 | 8.88 | 0.21 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
