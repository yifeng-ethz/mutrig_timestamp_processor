# ✅ STD_MTS_077_terminating_input_eop_forwards_output_eop

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** In `TERMINATING`, accept an input beat with `endofpacket=1` and the explicit upstream `endofrun` pulse; expect the lane-close output `endofpacket` train after payload drain. Proves the current termination-EOP pipeline.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B077

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
| ℹ️ | log | [`uvm/logs/STD_MTS_077_terminating_input_eop_forwards_output_eop_after_s1.log`](../../uvm/logs/STD_MTS_077_terminating_input_eop_forwards_output_eop_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_077_terminating_input_eop_forwards_output_eop_s1.ucdb`](../../uvm/cov_after/STD_MTS_077_terminating_input_eop_forwards_output_eop_s1.ucdb) |
| ℹ️ | log.csr | `2` |
| ℹ️ | log.inputs | `2` |
| ℹ️ | log.beats | `6` |
| ℹ️ | log.payloads | `2` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.debug_ts | `2` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.ts_delta | `0` |
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
| stmt | 78.70 | 13.12 | 0.19 | 95.00 | 0.03 |
| branch | 67.57 | 11.26 | 0.78 | 89.84 | 0.13 |
| cond | 53.09 | 8.85 | 2.66 | 78.76 | 0.44 |
| expr | 50.00 | 8.33 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 16.67 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 5.55 | 0.00 | 66.66 | 0.00 |
| toggle | 16.50 | 2.75 | 0.14 | 47.21 | 0.02 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
