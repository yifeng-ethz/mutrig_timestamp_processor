# ✅ STRESS_MTS_035_soft_reset_every_10k_cycles

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Pulse `soft_reset` every 10k cycles during a long simulation; verify counters restart cleanly and no state accumulates. Covers software reset endurance.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P035

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
| ℹ️ | log | [`uvm/logs/STRESS_MTS_035_soft_reset_every_10k_cycles_after_s1.log`](../../uvm/logs/STRESS_MTS_035_soft_reset_every_10k_cycles_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_035_soft_reset_every_10k_cycles_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_035_soft_reset_every_10k_cycles_s1.ucdb) |
| ℹ️ | log.csr | `24` |
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
| stmt | 84.07 | 1.75 | 3.15 | 91.66 | 0.07 |
| branch | 66.79 | 1.39 | 0.79 | 81.25 | 0.02 |
| cond | 53.09 | 1.11 | 11.50 | 74.33 | 0.24 |
| expr | 50.00 | 1.04 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 1.56 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.46 | 0.00 | 33.33 | 0.00 |
| toggle | 27.45 | 0.57 | 1.14 | 41.85 | 0.02 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
