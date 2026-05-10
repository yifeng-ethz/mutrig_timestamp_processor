# ✅ STRESS_MTS_039_force_stop_pulse_every_100_hits

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Pulse `force_stop` every 100 hits in a long run; verify acceptance halts and resumes deterministically each time. Covers repeated software throttling.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P039

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
| ✅ | observed_txn | `500` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_039_force_stop_pulse_every_100_hits_after_s1.log`](../../uvm/logs/STRESS_MTS_039_force_stop_pulse_every_100_hits_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_039_force_stop_pulse_every_100_hits_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_039_force_stop_pulse_every_100_hits_s1.ucdb) |
| ℹ️ | log.beats | `495` |
| ℹ️ | log.csr | `16` |
| ℹ️ | log.debug_burst | `495` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `495` |
| ℹ️ | log.dual_path_pairs | `495` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `500` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `495` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `495` |
| ℹ️ | log.traces | `495` |
| ℹ️ | log.ts_delta | `495` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.97 | 0.16 | 0.19 | 92.46 | 0.00 |
| branch | 66.53 | 0.13 | 0.39 | 82.67 | 0.00 |
| cond | 41.37 | 0.08 | 0.87 | 75.00 | 0.00 |
| expr | 50.00 | 0.10 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 0.15 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.04 | 0.00 | 55.55 | 0.00 |
| toggle | 29.55 | 0.06 | 0.05 | 44.19 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
