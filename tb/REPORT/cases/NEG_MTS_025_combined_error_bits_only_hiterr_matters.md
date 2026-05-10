# ✅ NEG_MTS_025_combined_error_bits_only_hiterr_matters

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive all three error bits high and vary `HITERR_BIT_LOC`; verify only the mapped hiterr bit controls acceptance today. Covers combined-error behavior.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X025

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_025_combined_error_bits_only_hiterr_matters_after_s1.log`](../../uvm/logs/NEG_MTS_025_combined_error_bits_only_hiterr_matters_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_025_combined_error_bits_only_hiterr_matters_s1.ucdb`](../../uvm/cov_after/NEG_MTS_025_combined_error_bits_only_hiterr_matters_s1.ucdb) |
| ℹ️ | log.beats | `2` |
| ℹ️ | log.csr | `10` |
| ℹ️ | log.debug_burst | `2` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `1` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.math_error_traces | `1` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `2` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.ts_delta | `2` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.79 | 26.93 | 0.19 | 91.90 | 0.06 |
| branch | 66.14 | 22.05 | 0.78 | 81.88 | 0.26 |
| cond | 42.24 | 14.08 | 0.00 | 74.13 | 0.00 |
| expr | 50.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 7.41 | 0.00 | 77.77 | 0.00 |
| toggle | 19.64 | 6.55 | 8.83 | 28.62 | 2.94 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
