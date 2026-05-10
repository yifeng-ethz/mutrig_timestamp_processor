# ✅ STRESS_MTS_043_hits_just_below_upper_across_overflow

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Concentrate decoded timestamps just below `padding_upper` across overflow events; verify the non-adjust path stays stable. Covers the lower side of the correction window under load.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P043

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
| ✅ | observed_txn | `4` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_043_hits_just_below_upper_across_overflow_after_s1.log`](../../uvm/logs/STRESS_MTS_043_hits_just_below_upper_across_overflow_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_043_hits_just_below_upper_across_overflow_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_043_hits_just_below_upper_across_overflow_s1.ucdb) |
| ℹ️ | log.beats | `4` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `4` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `4` |
| ℹ️ | log.dual_path_pairs | `4` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `4` |
| ℹ️ | log.inputs | `4` |
| ℹ️ | log.math_error_traces | `4` |
| ℹ️ | log.payloads | `4` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `4` |
| ℹ️ | log.traces | `4` |
| ℹ️ | log.ts_delta | `4` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.29 | 20.32 | 0.00 | 94.25 | 0.00 |
| branch | 66.01 | 16.50 | 0.00 | 84.76 | 0.00 |
| cond | 42.47 | 10.62 | 0.00 | 79.64 | 0.00 |
| expr | 50.00 | 12.50 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 18.75 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 5.55 | 0.00 | 55.55 | 0.00 |
| toggle | 28.69 | 7.17 | 0.10 | 46.07 | 0.03 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
