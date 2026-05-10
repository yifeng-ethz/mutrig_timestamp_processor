# ✅ STRESS_MTS_130_full_signoff_mixed_soak

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Bundle overflow, counters, debug streams, repeated starts/stops, and termination bookkeeping into one long mixed soak. This is the eventual top-level signoff stress run.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P130

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
| ✅ | observed_txn | `236` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_130_full_signoff_mixed_soak_after_s1.log`](../../uvm/logs/STRESS_MTS_130_full_signoff_mixed_soak_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_130_full_signoff_mixed_soak_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_130_full_signoff_mixed_soak_s1.ucdb) |
| ℹ️ | log.beats | `236` |
| ℹ️ | log.csr | `164` |
| ℹ️ | log.debug_burst | `83` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `120` |
| ℹ️ | log.dual_path_pairs | `120` |
| ℹ️ | log.empty_eops | `116` |
| ℹ️ | log.eops | `116` |
| ℹ️ | log.hit_error_traces | `55` |
| ℹ️ | log.inputs | `120` |
| ℹ️ | log.math_error_traces | `55` |
| ℹ️ | log.payloads | `120` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `120` |
| ℹ️ | log.traces | `120` |
| ℹ️ | log.ts_delta | `83` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 89.07 | 0.38 | 0.00 | 95.37 | 0.00 |
| branch | 81.64 | 0.35 | 0.00 | 87.54 | 0.00 |
| cond | 61.06 | 0.26 | 0.00 | 80.53 | 0.00 |
| expr | 50.00 | 0.21 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 0.42 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 55.55 | 0.24 | 0.00 | 66.66 | 0.00 |
| toggle | 39.97 | 0.17 | 0.00 | 50.69 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
