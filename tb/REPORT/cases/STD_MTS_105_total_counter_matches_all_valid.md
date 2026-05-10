# ✅ STD_MTS_105_total_counter_matches_all_valid

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive a known mix of accepted and rejected hits and confirm the total counter matches all valid inputs. Validates software observability of ingress load.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B105

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
| ℹ️ | log | [`uvm/logs/STD_MTS_105_total_counter_matches_all_valid_after_s1.log`](../../uvm/logs/STD_MTS_105_total_counter_matches_all_valid_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_105_total_counter_matches_all_valid_s1.ucdb`](../../uvm/cov_after/STD_MTS_105_total_counter_matches_all_valid_s1.ucdb) |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.beats | `2` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.debug_burst | `2` |
| ℹ️ | log.ts_delta | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `2` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.18 | 26.73 | 0.00 | 95.00 | 0.00 |
| branch | 64.84 | 21.61 | 0.00 | 89.84 | 0.00 |
| cond | 42.47 | 14.16 | 0.00 | 78.76 | 0.00 |
| expr | 50.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 7.41 | 0.00 | 66.66 | 0.00 |
| toggle | 9.23 | 3.08 | 0.00 | 48.03 | 0.00 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
