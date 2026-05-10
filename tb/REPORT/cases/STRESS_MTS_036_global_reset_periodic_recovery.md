# ✅ STRESS_MTS_036_global_reset_periodic_recovery

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Assert and release global reset periodically during a long simulation; verify the DUT always recovers to a clean baseline. Covers hard reset endurance.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P036

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
| ✅ | observed_txn | `48` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_036_global_reset_periodic_recovery_after_s1.log`](../../uvm/logs/STRESS_MTS_036_global_reset_periodic_recovery_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_036_global_reset_periodic_recovery_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_036_global_reset_periodic_recovery_s1.ucdb) |
| ℹ️ | log.csr | `21` |
| ℹ️ | log.inputs | `48` |
| ℹ️ | log.beats | `48` |
| ℹ️ | log.payloads | `48` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `48` |
| ℹ️ | log.debug_burst | `48` |
| ℹ️ | log.ts_delta | `48` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `48` |
| ℹ️ | log.traces | `48` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `48` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.00 | 1.67 | 0.00 | 91.66 | 0.00 |
| branch | 64.45 | 1.34 | 0.00 | 81.25 | 0.00 |
| cond | 38.93 | 0.81 | 0.00 | 74.33 | 0.00 |
| expr | 50.00 | 1.04 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 1.56 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 0.69 | 11.11 | 44.44 | 0.23 |
| toggle | 22.36 | 0.47 | 0.05 | 41.90 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
