# ✅ STRESS_MTS_094_random_tot_mode_mix

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Randomly switch between short mode and ToT mode between packets; verify ET interpretation remains coherent. Covers ET-mode entropy.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P094

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
| ✅ | observed_txn | `80` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_094_random_tot_mode_mix_after_s1.log`](../../uvm/logs/STRESS_MTS_094_random_tot_mode_mix_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_094_random_tot_mode_mix_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_094_random_tot_mode_mix_s1.ucdb) |
| ℹ️ | log.csr | `86` |
| ℹ️ | log.inputs | `80` |
| ℹ️ | log.beats | `80` |
| ℹ️ | log.payloads | `80` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `80` |
| ℹ️ | log.debug_burst | `80` |
| ℹ️ | log.ts_delta | `80` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `80` |
| ℹ️ | log.traces | `80` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `80` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.11 | 1.01 | 0.00 | 95.37 | 0.00 |
| branch | 66.01 | 0.83 | 0.00 | 87.54 | 0.00 |
| cond | 37.16 | 0.46 | 0.00 | 79.64 | 0.00 |
| expr | 50.00 | 0.62 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 0.94 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.28 | 0.00 | 66.66 | 0.00 |
| toggle | 28.92 | 0.36 | 0.00 | 50.29 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
