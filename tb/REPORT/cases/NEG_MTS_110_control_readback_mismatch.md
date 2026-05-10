# ✅ NEG_MTS_110_control_readback_mismatch

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Require `force_stop`, `soft_reset`, `bypass_lapse`, `discard_hiterr`, and op-mode fields to read back as implemented; mismatch is a failure. Covers software-visible control state.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X110

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_110_control_readback_mismatch_after_s1.log`](../../uvm/logs/NEG_MTS_110_control_readback_mismatch_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_110_control_readback_mismatch_s1.ucdb`](../../uvm/cov_after/NEG_MTS_110_control_readback_mismatch_s1.ucdb) |
| ℹ️ | log.beats | `1` |
| ℹ️ | log.csr | `10` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `1` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `1` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 81.16 | 81.16 | 0.00 | 95.88 | 0.00 |
| branch | 62.59 | 62.59 | 0.00 | 92.21 | 0.00 |
| cond | 44.82 | 44.82 | 0.00 | 86.20 | 0.00 |
| expr | 50.00 | 50.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 75.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 22.22 | 0.00 | 77.77 | 0.00 |
| toggle | 6.27 | 6.27 | 0.05 | 54.05 | 0.05 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
