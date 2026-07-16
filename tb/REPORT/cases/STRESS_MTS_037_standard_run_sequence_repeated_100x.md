# ✅ STRESS_MTS_037_standard_run_sequence_repeated_100x

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Repeat `RUN_PREPARE -> SYNC -> RUNNING` 100 times with one true timestamp-zero hit per run; require each SYNC to clear GTS/overflow epoch, each hit to preserve `latency48 = arrival_gts - true_hit_ts`, nonnegative lifetime, bounded fresh-epoch arrival, and no stale EOP/counter state. Pass criteria: Repeat the standard sequence with traffic so a clean first run followed by a stale second epoch is observable.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P037

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
| ✅ | observed_txn | `100` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/STRESS_MTS_037_standard_run_sequence_repeated_100x_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_037_standard_run_sequence_repeated_100x_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `100` |
| ℹ️ | log.csr | `503` |
| ℹ️ | log.debug_burst | `100` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `100` |
| ℹ️ | log.dual_path_pairs | `100` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `100` |
| ℹ️ | log.latency48_identity | `100` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `100` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `100` |
| ℹ️ | log.ts_delta | `100` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 78.30 | 0.78 | 0.25 | 89.98 | 0.00 |
| branch | 61.68 | 0.62 | 0.65 | 75.97 | 0.01 |
| cond | 37.09 | 0.37 | 0.00 | 70.16 | 0.00 |
| expr | 50.00 | 0.50 | 0.00 | 83.33 | 0.00 |
| fsm_state | 75.00 | 0.75 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 0.33 | 0.00 | 44.44 | 0.00 |
| toggle | 10.93 | 0.11 | 0.00 | 39.56 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
