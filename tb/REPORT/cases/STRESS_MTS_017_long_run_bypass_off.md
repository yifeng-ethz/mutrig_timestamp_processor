# ✅ STRESS_MTS_017_long_run_bypass_off

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Hold `bypass_lapse=0` for a long run; verify the white-timestamp model stays coherent across many accepted hits. Covers the normal padded path at scale.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P017

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
| ✅ | observed_txn | `64` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_017_long_run_bypass_off_after_s1.log`](../../uvm/logs/STRESS_MTS_017_long_run_bypass_off_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_017_long_run_bypass_off_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_017_long_run_bypass_off_s1.ucdb) |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.inputs | `64` |
| ℹ️ | log.beats | `64` |
| ℹ️ | log.payloads | `64` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `64` |
| ℹ️ | log.debug_burst | `64` |
| ℹ️ | log.ts_delta | `64` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `64` |
| ℹ️ | log.traces | `64` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `64` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.92 | 1.26 | 1.29 | 87.40 | 0.02 |
| branch | 66.01 | 1.03 | 1.95 | 78.90 | 0.03 |
| cond | 41.59 | 0.65 | 2.65 | 61.94 | 0.04 |
| expr | 50.00 | 0.78 | 0.00 | 50.00 | 0.00 |
| fsm_state | 75.00 | 1.17 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.35 | 0.00 | 33.33 | 0.00 |
| toggle | 25.52 | 0.40 | 5.14 | 37.14 | 0.08 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
