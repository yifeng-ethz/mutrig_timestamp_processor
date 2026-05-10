# ✅ STRESS_MTS_042_many_overflow_run

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Run long enough to cross many MTS overflows; verify no cumulative off-by-one drift. Covers extended wrap behavior.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P042

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
| ℹ️ | log | [`uvm/logs/STRESS_MTS_042_many_overflow_run_after_s1.log`](../../uvm/logs/STRESS_MTS_042_many_overflow_run_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_042_many_overflow_run_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_042_many_overflow_run_s1.ucdb) |
| ℹ️ | log.beats | `3` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `3` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `3` |
| ℹ️ | log.dual_path_pairs | `3` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `3` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `3` |
| ℹ️ | log.traces | `3` |
| ℹ️ | log.ts_delta | `3` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.40 | 27.47 | 1.11 | 94.25 | 0.37 |
| branch | 67.18 | 22.39 | 0.78 | 84.76 | 0.26 |
| cond | 45.13 | 15.04 | 1.77 | 79.64 | 0.59 |
| expr | 50.00 | 16.67 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 7.41 | 0.00 | 55.55 | 0.00 |
| toggle | 25.39 | 8.46 | 1.66 | 45.97 | 0.55 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
