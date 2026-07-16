# ✅ STRESS_MTS_042_many_overflow_run

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Cross five consecutive MTS overflows and inject one checked hit after each wrap, covering all five deliberate near-wrap counter phases. Pass criteria: The overflow base increments exactly once per wrap, all five adjusted hits match, and counter phases `32764` and `32762` execute without cumulative drift.
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
| ✅ | observed_txn | `5` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/STRESS_MTS_042_many_overflow_run_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_042_many_overflow_run_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `5` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `5` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `5` |
| ℹ️ | log.dual_path_pairs | `5` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `5` |
| ℹ️ | log.latency48_identity | `5` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `5` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `5` |
| ℹ️ | log.traces | `5` |
| ℹ️ | log.ts_delta | `5` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.77 | 16.35 | 1.54 | 92.42 | 0.31 |
| branch | 65.58 | 13.12 | 1.30 | 79.22 | 0.26 |
| cond | 45.96 | 9.19 | 3.23 | 76.61 | 0.65 |
| expr | 50.00 | 10.00 | 0.00 | 83.33 | 0.00 |
| fsm_state | 75.00 | 15.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 4.44 | 0.00 | 55.55 | 0.00 |
| toggle | 30.15 | 6.03 | 3.27 | 45.88 | 0.65 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
