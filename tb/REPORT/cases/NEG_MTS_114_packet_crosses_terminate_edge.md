# ✅ NEG_MTS_114_packet_crosses_terminate_edge

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Start a packet before `TERMINATING` and close it after the stop edge; require exactly one boundary and correct payload retention. Covers the core stop-crossing scenario.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X114

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_114_packet_crosses_terminate_edge_after_s1.log`](../../uvm/logs/NEG_MTS_114_packet_crosses_terminate_edge_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_114_packet_crosses_terminate_edge_s1.ucdb`](../../uvm/cov_after/NEG_MTS_114_packet_crosses_terminate_edge_s1.ucdb) |
| ℹ️ | log.beats | `6` |
| ℹ️ | log.csr | `5` |
| ℹ️ | log.debug_burst | `1` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.dual_path_pairs | `2` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `1` |
| ℹ️ | log.inputs | `2` |
| ℹ️ | log.math_error_traces | `1` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `2` |
| ℹ️ | log.traces | `2` |
| ℹ️ | log.ts_delta | `1` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.67 | 13.78 | 0.00 | 95.88 | 0.00 |
| branch | 72.04 | 12.01 | 0.00 | 92.21 | 0.00 |
| cond | 55.17 | 9.20 | 0.00 | 86.20 | 0.00 |
| expr | 50.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 5.55 | 0.00 | 77.77 | 0.00 |
| toggle | 17.52 | 2.92 | 0.00 | 54.07 | 0.00 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
