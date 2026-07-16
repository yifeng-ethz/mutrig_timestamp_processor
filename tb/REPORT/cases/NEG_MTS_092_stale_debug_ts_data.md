# ✅ NEG_MTS_092_stale_debug_ts_data

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Require `debug_ts_data` to update coherently when `debug_ts_valid` toggles; stale data is a failure. Covers side-stream data freshness.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X092

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
| ✅ | observed_txn | `6` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/NEG_MTS_092_stale_debug_ts_data_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/NEG_MTS_092_stale_debug_ts_data_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `6` |
| ℹ️ | log.csr | `3` |
| ℹ️ | log.debug_burst | `5` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `6` |
| ℹ️ | log.dual_path_pairs | `6` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `6` |
| ℹ️ | log.latency48_identity | `6` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `6` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `11` |
| ℹ️ | log.traces | `6` |
| ℹ️ | log.ts_delta | `5` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.46 | 13.24 | 0.00 | 93.19 | 0.00 |
| branch | 61.68 | 10.28 | 0.00 | 84.09 | 0.00 |
| cond | 37.09 | 6.18 | 0.00 | 83.06 | 0.00 |
| expr | 50.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 12.50 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 3.70 | 0.00 | 77.77 | 0.00 |
| toggle | 16.67 | 2.78 | 0.00 | 45.50 | 0.00 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
