# ✅ STD_MTS_004_run_prepare_enters_reset_sclr

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** From `IDLE`, send `RUN_PREPARE`; expect `processor_state=RESET`, `reset_flow=SCLR`, and `asi_hit_type0_ready=1` for flush acceptance. Verifies the standard first step.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B004

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
| ✅ | observed_txn | `1` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STD_MTS_004_run_prepare_enters_reset_sclr_after_s1.log`](../../uvm/logs/STD_MTS_004_run_prepare_enters_reset_sclr_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_004_run_prepare_enters_reset_sclr_s1.ucdb`](../../uvm/cov_after/STD_MTS_004_run_prepare_enters_reset_sclr_s1.ucdb) |
| ℹ️ | log.beats | `0` |
| ℹ️ | log.csr | `0` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `0` |
| ℹ️ | log.dual_path_pairs | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `0` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `0` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 50.37 | 50.37 | 0.93 | 74.44 | 0.93 |
| branch | 35.15 | 35.15 | 3.91 | 57.81 | 3.91 |
| cond | 7.96 | 7.96 | 2.65 | 30.08 | 2.65 |
| expr | 0.00 | 0.00 | 0.00 | 50.00 | 0.00 |
| fsm_state | 50.00 | 50.00 | 25.00 | 75.00 | 25.00 |
| fsm_trans | 11.11 | 11.11 | 11.11 | 22.22 | 11.11 |
| toggle | 1.19 | 1.19 | 0.14 | 7.86 | 0.14 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
