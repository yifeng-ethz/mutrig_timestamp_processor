# ✅ STD_MTS_055_expected_latency_updates_padding_upper

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Rewrite `expected_latency`; expect subsequent hits to use the new delay-error threshold while the overflow `padding_upper` remains controlled by `MUTRIG_OVERFLOW_LOOKBACK_8N`. Preserves the legacy case name while proving the current split between timestamp-error latency and wrap disambiguation.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B055

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
| ✅ | observed_txn | `2` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STD_MTS_055_expected_latency_updates_padding_upper_after_s1.log`](../../uvm/logs/STD_MTS_055_expected_latency_updates_padding_upper_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_055_expected_latency_updates_padding_upper_s1.ucdb`](../../uvm/cov_after/STD_MTS_055_expected_latency_updates_padding_upper_s1.ucdb) |
| ℹ️ | log.csr | `5` |
| ℹ️ | log.inputs | `2` |
| ℹ️ | log.beats | `2` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.debug_burst | `1` |
| ℹ️ | log.ts_delta | `1` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.66 | 40.83 | 0.37 | 93.51 | 0.18 |
| branch | 66.01 | 33.01 | 1.17 | 86.71 | 0.58 |
| cond | 43.36 | 21.68 | 1.77 | 74.33 | 0.89 |
| expr | 50.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 37.50 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 11.11 | 0.00 | 66.66 | 0.00 |
| toggle | 20.63 | 10.31 | 2.58 | 41.13 | 1.29 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
