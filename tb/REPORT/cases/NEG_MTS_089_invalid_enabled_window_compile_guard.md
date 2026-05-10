# ✅ NEG_MTS_089_invalid_enabled_window_compile_guard

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Use an invalid enabled-channel window and require the build or configuration layer to reject it explicitly. Covers configuration sanity.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X089

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_089_invalid_enabled_window_compile_guard_after_s1.log`](../../uvm/logs/NEG_MTS_089_invalid_enabled_window_compile_guard_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_089_invalid_enabled_window_compile_guard_s1.ucdb`](../../uvm/cov_after/NEG_MTS_089_invalid_enabled_window_compile_guard_s1.ucdb) |
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
| stmt | 82.59 | 7.51 | 0.00 | 95.18 | 0.00 |
| branch | 71.87 | 6.53 | 0.00 | 89.49 | 0.00 |
| cond | 54.86 | 4.99 | 0.00 | 79.64 | 0.00 |
| expr | 50.00 | 4.55 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 9.09 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 4.04 | 0.00 | 66.66 | 0.00 |
| toggle | 9.99 | 0.91 | 0.20 | 47.86 | 0.02 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
