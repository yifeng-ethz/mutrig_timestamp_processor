# ✅ NEG_MTS_035_output_ready_low_boundary_fault

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Hold output `ready=0` on the terminating EOP beat and verify the current DUT still emits it; tag it as the same negative protocol finding. Documents the ignored-ready boundary behavior.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X035

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
| ✅ | observed_txn | `4` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/NEG_MTS_035_output_ready_low_boundary_fault_after_s1.log`](../../uvm/logs/NEG_MTS_035_output_ready_low_boundary_fault_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_035_output_ready_low_boundary_fault_s1.ucdb`](../../uvm/cov_after/NEG_MTS_035_output_ready_low_boundary_fault_s1.ucdb) |
| ℹ️ | log.beats | `4` |
| ℹ️ | log.csr | `2` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `0` |
| ℹ️ | log.dual_path_pairs | `0` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
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
| stmt | 60.07 | 15.02 | 0.00 | 91.90 | 0.00 |
| branch | 55.51 | 13.88 | 0.00 | 82.28 | 0.00 |
| cond | 37.06 | 9.27 | 0.00 | 75.00 | 0.00 |
| expr | 0.00 | 0.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 8.33 | 0.00 | 77.77 | 0.00 |
| toggle | 2.94 | 0.73 | 0.00 | 30.66 | 0.00 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
