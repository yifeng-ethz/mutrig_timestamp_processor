# ✅ CORNER_MTS_040_latency_write_at_overflow_boundary

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Rewrite `expected_latency` after an overflow-adjusted payload; verify padding math is unchanged and only subsequent debug trace metadata reports the new delay threshold. Covers the current split between the `MUTRIG_OVERFLOW_LOOKBACK_8N` padding threshold and the CSR delay-error threshold.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E040

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
| ✅ | observed_txn | `2` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_040_latency_write_at_overflow_boundary_after_s1.log`](../../uvm/logs/CORNER_MTS_040_latency_write_at_overflow_boundary_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_040_latency_write_at_overflow_boundary_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_040_latency_write_at_overflow_boundary_s1.ucdb) |
| ℹ️ | log.beats | `2` |
| ℹ️ | log.csr | `4` |
| ℹ️ | log.debug_burst | `1` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `2` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `2` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.ts_delta | `1` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.35 | 40.67 | 0.00 | 92.89 | 0.00 |
| branch | 66.14 | 33.07 | 0.00 | 86.71 | 0.00 |
| cond | 43.10 | 21.55 | 0.00 | 75.86 | 0.00 |
| expr | 50.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 37.50 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 11.11 | 0.00 | 66.66 | 0.00 |
| toggle | 22.14 | 11.07 | 0.00 | 50.54 | 0.00 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
