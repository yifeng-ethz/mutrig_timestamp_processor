# ✅ STRESS_MTS_073_terminate_with_eop_on_last_beat

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Place the final input EOP on the last accepted beat before stop, then verify exactly one empty close-marker train. Covers the clean stop ideal.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P073

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
| ✅ | observed_txn | `12` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/STRESS_MTS_073_terminate_with_eop_on_last_beat_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_073_terminate_with_eop_on_last_beat_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `12` |
| ℹ️ | log.csr | `6` |
| ℹ️ | log.debug_burst | `8` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `8` |
| ℹ️ | log.dual_path_pairs | `8` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `8` |
| ℹ️ | log.latency48_identity | `12` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `8` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `8` |
| ℹ️ | log.traces | `8` |
| ℹ️ | log.ts_delta | `8` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.92 | 6.91 | 0.00 | 93.19 | 0.00 |
| branch | 70.12 | 5.84 | 0.00 | 81.49 | 0.00 |
| cond | 50.00 | 4.17 | 0.00 | 76.61 | 0.00 |
| expr | 50.00 | 4.17 | 0.00 | 83.33 | 0.00 |
| fsm_state | 100.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 3.70 | 0.00 | 66.66 | 0.00 |
| toggle | 16.61 | 1.38 | 0.00 | 49.02 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
