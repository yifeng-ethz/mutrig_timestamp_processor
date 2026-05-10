# ✅ STRESS_MTS_010_flushing_after_large_backlog

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Drive a dense run, then enter `FLUSHING`; verify the pipeline drains deterministically without hanging. Establishes the basic drain-stress story.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P010

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
| ✅ | observed_txn | `37` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_010_flushing_after_large_backlog_after_s1.log`](../../uvm/logs/STRESS_MTS_010_flushing_after_large_backlog_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_010_flushing_after_large_backlog_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_010_flushing_after_large_backlog_s1.ucdb) |
| ℹ️ | log.beats | `37` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `22` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `33` |
| ℹ️ | log.dual_path_pairs | `33` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `33` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `33` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `33` |
| ℹ️ | log.traces | `33` |
| ℹ️ | log.ts_delta | `22` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 84.18 | 2.28 | 4.33 | 85.49 | 0.12 |
| branch | 73.22 | 1.98 | 8.66 | 75.98 | 0.23 |
| cond | 53.44 | 1.44 | 16.38 | 58.62 | 0.44 |
| expr | 50.00 | 1.35 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 2.70 | 25.00 | 100.00 | 0.68 |
| fsm_trans | 33.33 | 0.90 | 11.11 | 33.33 | 0.30 |
| toggle | 27.07 | 0.73 | 0.82 | 32.05 | 0.02 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
