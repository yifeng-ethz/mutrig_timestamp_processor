# ✅ STRESS_MTS_045_mixed_t_and_e_adjust_eligibility

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Alternate hits that trigger T-only, E-only, both, and neither adjustments; verify the per-hit correction latches behave under load. Covers branch diversity near overflow.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P045

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
| ℹ️ | log | `uvm/logs/STRESS_MTS_045_mixed_t_and_e_adjust_eligibility_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_045_mixed_t_and_e_adjust_eligibility_s1.ucdb` — local generated artifact; intentionally not published |
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
| ℹ️ | log.latency48_identity | `4` |
| ℹ️ | log.latency48_negative_diagnostics | `2` |
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
| stmt | 81.25 | 20.31 | 0.26 | 92.68 | 0.07 |
| branch | 66.55 | 16.64 | 0.65 | 79.87 | 0.16 |
| cond | 41.93 | 10.48 | 0.00 | 76.61 | 0.00 |
| expr | 50.00 | 12.50 | 0.00 | 83.33 | 0.00 |
| fsm_state | 75.00 | 18.75 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 5.55 | 0.00 | 55.55 | 0.00 |
| toggle | 30.38 | 7.59 | 1.46 | 47.34 | 0.36 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
