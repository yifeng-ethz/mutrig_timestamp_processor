# ✅ STRESS_MTS_122_drain_latency_histogram

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Measure cycles from `TERMINATING` command to the last emitted output beat across many runs. Creates the primary current and future drain metric.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P122

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
| ✅ | observed_txn | `246` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_122_drain_latency_histogram_after_s1.log`](../../uvm/logs/STRESS_MTS_122_drain_latency_histogram_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_122_drain_latency_histogram_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_122_drain_latency_histogram_s1.ucdb) |
| ℹ️ | log.beats | `246` |
| ℹ️ | log.csr | `161` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `118` |
| ℹ️ | log.dual_path_pairs | `118` |
| ℹ️ | log.empty_eops | `128` |
| ℹ️ | log.eops | `128` |
| ℹ️ | log.hit_error_traces | `69` |
| ℹ️ | log.inputs | `118` |
| ℹ️ | log.math_error_traces | `69` |
| ℹ️ | log.payloads | `118` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `118` |
| ℹ️ | log.traces | `118` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.54 | 0.33 | 0.00 | 95.29 | 0.00 |
| branch | 71.65 | 0.29 | 0.00 | 87.45 | 0.00 |
| cond | 52.58 | 0.21 | 0.00 | 79.31 | 0.00 |
| expr | 50.00 | 0.20 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 0.41 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 44.44 | 0.18 | 0.00 | 66.66 | 0.00 |
| toggle | 18.76 | 0.08 | 0.00 | 53.45 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
