# ✅ STRESS_MTS_069_flushing_phase_csr_rewrites

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Rewrite nonfatal CSR fields during `FLUSHING`; verify the current DUT remains deterministic. Covers software writes during stop drain.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P069

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
| ✅ | observed_txn | `160` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_069_flushing_phase_csr_rewrites_after_s1.log`](../../uvm/logs/STRESS_MTS_069_flushing_phase_csr_rewrites_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_069_flushing_phase_csr_rewrites_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_069_flushing_phase_csr_rewrites_s1.ucdb) |
| ℹ️ | log.beats | `160` |
| ℹ️ | log.csr | `228` |
| ℹ️ | log.debug_burst | `32` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `32` |
| ℹ️ | log.dual_path_pairs | `32` |
| ℹ️ | log.empty_eops | `128` |
| ℹ️ | log.eops | `128` |
| ℹ️ | log.hit_error_traces | `24` |
| ℹ️ | log.inputs | `32` |
| ℹ️ | log.math_error_traces | `24` |
| ℹ️ | log.payloads | `32` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `32` |
| ℹ️ | log.traces | `32` |
| ℹ️ | log.ts_delta | `32` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 85.74 | 0.54 | 0.00 | 95.18 | 0.00 |
| branch | 73.82 | 0.46 | 0.00 | 86.32 | 0.00 |
| cond | 51.32 | 0.32 | 0.00 | 79.64 | 0.00 |
| expr | 50.00 | 0.31 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 0.62 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 0.28 | 0.00 | 66.66 | 0.00 |
| toggle | 20.38 | 0.13 | 0.00 | 50.04 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
