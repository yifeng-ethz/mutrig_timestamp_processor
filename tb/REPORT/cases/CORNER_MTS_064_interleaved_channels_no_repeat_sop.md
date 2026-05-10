# ✅ CORNER_MTS_064_interleaved_channels_no_repeat_sop

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Interleave hits from enabled and already-seen channels; verify SOP does not repeat for the already-seen channel. Covers mixed-channel marker persistence.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E064

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
| ✅ | observed_txn | `3` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/CORNER_MTS_064_interleaved_channels_no_repeat_sop_after_s1.log`](../../uvm/logs/CORNER_MTS_064_interleaved_channels_no_repeat_sop_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/CORNER_MTS_064_interleaved_channels_no_repeat_sop_s1.ucdb`](../../uvm/cov_after/CORNER_MTS_064_interleaved_channels_no_repeat_sop_s1.ucdb) |
| ℹ️ | log.csr | `3` |
| ℹ️ | log.inputs | `3` |
| ℹ️ | log.beats | `3` |
| ℹ️ | log.payloads | `3` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `3` |
| ℹ️ | log.debug_burst | `2` |
| ℹ️ | log.ts_delta | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `3` |
| ℹ️ | log.traces | `3` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `3` |
| ℹ️ | log.math_error_traces | `2` |
| ℹ️ | log.hit_error_traces | `2` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.37 | 26.79 | 0.73 | 94.66 | 0.24 |
| branch | 64.06 | 21.35 | 0.77 | 89.14 | 0.26 |
| cond | 38.93 | 12.98 | 0.00 | 77.87 | 0.00 |
| expr | 50.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 7.41 | 0.00 | 66.66 | 0.00 |
| toggle | 15.96 | 5.32 | 0.10 | 49.72 | 0.03 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
