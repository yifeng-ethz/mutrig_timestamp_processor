# ✅ NEG_MTS_005_ctrl_valid_high_data_changes

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Hold `asi_ctrl_valid=1` while changing `asi_ctrl_data`; require the driver/SVA layer to flag the protocol violation. Covers source misuse.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X005

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_005_ctrl_valid_high_data_changes_after_s1.log`](../../uvm/logs/NEG_MTS_005_ctrl_valid_high_data_changes_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_005_ctrl_valid_high_data_changes_s1.ucdb`](../../uvm/cov_after/NEG_MTS_005_ctrl_valid_high_data_changes_s1.ucdb) |
| ℹ️ | log.beats | `0` |
| ℹ️ | log.csr | `0` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `0` |
| ℹ️ | log.dual_path_pairs | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `0` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `0` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 51.97 | 51.97 | 0.38 | 81.73 | 0.38 |
| branch | 38.97 | 38.97 | 0.40 | 71.65 | 0.40 |
| cond | 13.79 | 13.79 | 0.86 | 56.03 | 0.86 |
| expr | 0.00 | 0.00 | 0.00 | 50.00 | 0.00 |
| fsm_state | 50.00 | 50.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 11.11 | 11.11 | 0.00 | 44.44 | 0.00 |
| toggle | 1.13 | 1.13 | 0.03 | 9.11 | 0.03 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
