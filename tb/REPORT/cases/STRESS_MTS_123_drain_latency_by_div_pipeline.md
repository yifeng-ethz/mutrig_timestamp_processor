# ✅ STRESS_MTS_123_drain_latency_by_div_pipeline

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Break the drain-latency histogram out by `LPM_DIV_PIPELINE` value. Quantifies the packaged-vs-source configuration difference.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P123

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
| ✅ | observed_txn | `121` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/STRESS_MTS_123_drain_latency_by_div_pipeline_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_123_drain_latency_by_div_pipeline_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `121` |
| ℹ️ | log.csr | `81` |
| ℹ️ | log.debug_burst | `30` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `57` |
| ℹ️ | log.dual_path_pairs | `57` |
| ℹ️ | log.empty_eops | `64` |
| ℹ️ | log.eops | `64` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `57` |
| ℹ️ | log.latency48_identity | `121` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `57` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `57` |
| ℹ️ | log.traces | `57` |
| ℹ️ | log.ts_delta | `30` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.67 | 0.68 | 0.00 | 93.70 | 0.00 |
| branch | 69.80 | 0.58 | 0.00 | 82.46 | 0.00 |
| cond | 54.03 | 0.45 | 0.00 | 79.03 | 0.00 |
| expr | 50.00 | 0.41 | 0.00 | 83.33 | 0.00 |
| fsm_state | 100.00 | 0.83 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 0.37 | 0.00 | 66.66 | 0.00 |
| toggle | 16.65 | 0.14 | 0.00 | 50.91 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
