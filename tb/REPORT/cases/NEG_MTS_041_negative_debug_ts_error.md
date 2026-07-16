# ✅ NEG_MTS_041_negative_debug_ts_error

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** First prove the retained production fault at `-1`; then select CSR bit 6 and emit phase 900 twice, separated by 910 cycles, followed by a standard `IDLE -> RUN_PREPARE -> SYNC -> RUNNING` restart. Pass criteria: Production `-1` remains an error diagnostic. Debug-coordinate latency is exactly `-900`, maps to diagnostic bin 10 modulo 910, repeats one frame later and after SYNC, and is never classified as physical lifetime.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X041

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
| ℹ️ | log | `uvm/logs/NEG_MTS_041_negative_debug_ts_error_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/NEG_MTS_041_negative_debug_ts_error_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `6` |
| ℹ️ | log.csr | `9` |
| ℹ️ | log.debug_burst | `5` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `6` |
| ℹ️ | log.dual_path_pairs | `6` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `3` |
| ℹ️ | log.inputs | `6` |
| ℹ️ | log.latency48_identity | `6` |
| ℹ️ | log.latency48_negative_diagnostics | `3` |
| ℹ️ | log.math_error_traces | `3` |
| ℹ️ | log.payloads | `6` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `5` |
| ℹ️ | log.traces | `6` |
| ℹ️ | log.ts_delta | `5` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.97 | 13.33 | 0.77 | 90.62 | 0.13 |
| branch | 62.66 | 10.44 | 1.62 | 78.89 | 0.27 |
| cond | 37.90 | 6.32 | 0.80 | 73.38 | 0.13 |
| expr | 50.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 12.50 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 5.55 | 0.00 | 77.77 | 0.00 |
| toggle | 22.31 | 3.72 | 6.69 | 30.33 | 1.11 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
