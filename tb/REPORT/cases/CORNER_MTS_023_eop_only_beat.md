# ✅ CORNER_MTS_023_eop_only_beat

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive a valid beat with only EOP set; verify packet tracking closes if the sideband channel is currently in transaction and no false SOP appears. Covers packet-close boundaries.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E023

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
| ✅ | observed_txn | `6` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_023_eop_only_beat_after_s1.log`](../../uvm/logs/CORNER_MTS_023_eop_only_beat_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_023_eop_only_beat_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_023_eop_only_beat_s1.ucdb) |
| ℹ️ | log.beats | `6` |
| ℹ️ | log.csr | `2` |
| ℹ️ | log.debug_burst | `2` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `2` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.ts_delta | `2` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.54 | 13.59 | 0.00 | 90.46 | 0.00 |
| branch | 70.07 | 11.68 | 0.00 | 81.64 | 0.00 |
| cond | 50.86 | 8.48 | 0.00 | 68.96 | 0.00 |
| expr | 50.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 5.55 | 0.00 | 66.66 | 0.00 |
| toggle | 10.94 | 1.82 | 0.54 | 27.25 | 0.09 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
