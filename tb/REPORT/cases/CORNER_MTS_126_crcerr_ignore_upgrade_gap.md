# ✅ CORNER_MTS_126_crcerr_ignore_upgrade_gap

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Mark the upgrade discussion around CRCERR handling during termination; today it is inert and must remain documented. Keeps the plan honest about current scope.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E126

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
| ℹ️ | log | [`uvm/logs/CORNER_MTS_126_crcerr_ignore_upgrade_gap_after_s1.log`](../../uvm/logs/CORNER_MTS_126_crcerr_ignore_upgrade_gap_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_126_crcerr_ignore_upgrade_gap_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_126_crcerr_ignore_upgrade_gap_s1.ucdb) |
| ℹ️ | log.beats | `5` |
| ℹ️ | log.csr | `3` |
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
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 78.53 | 15.71 | 0.00 | 95.51 | 0.00 |
| branch | 68.11 | 13.62 | 0.00 | 90.62 | 0.00 |
| cond | 51.72 | 10.34 | 0.00 | 80.17 | 0.00 |
| expr | 50.00 | 10.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 20.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 6.67 | 0.00 | 88.88 | 0.00 |
| toggle | 8.80 | 1.76 | 0.05 | 53.56 | 0.01 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
