# ✅ STD_MTS_027_unsupported_read_addr5_zero

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Read an unsupported address such as word `0x14`; expect `readdata=0` with a clean acknowledgement. Defines the out-of-range software contract.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B027

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
| ✅ | observed_txn | `1` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STD_MTS_027_unsupported_read_addr5_zero_after_s1.log`](../../uvm/logs/STD_MTS_027_unsupported_read_addr5_zero_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_027_unsupported_read_addr5_zero_s1.ucdb`](../../uvm/cov_after/STD_MTS_027_unsupported_read_addr5_zero_s1.ucdb) |
| ℹ️ | log.csr | `1` |
| ℹ️ | log.inputs | `0` |
| ℹ️ | log.beats | `0` |
| ℹ️ | log.payloads | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.debug_ts | `0` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.ts_delta | `0` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `0` |
| ℹ️ | log.traces | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 49.62 | 49.62 | 0.18 | 90.18 | 0.18 |
| branch | 30.85 | 30.85 | 0.39 | 78.90 | 0.39 |
| cond | 4.42 | 4.42 | 0.00 | 69.02 | 0.00 |
| expr | 0.00 | 0.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 25.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 0.00 | 0.00 | 0.00 | 66.66 | 0.00 |
| toggle | 0.67 | 0.67 | 0.00 | 18.84 | 0.00 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
