# ✅ NEG_MTS_124_terminate_ack_after_drain_upgrade

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Require terminate acknowledgement to wait for payload drain and terminal boundary completion. Covers completion-based control handshaking.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X124

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
| ✅ | observed_txn | `5` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/NEG_MTS_124_terminate_ack_after_drain_upgrade_after_s1.log`](../../uvm/logs/NEG_MTS_124_terminate_ack_after_drain_upgrade_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_124_terminate_ack_after_drain_upgrade_s1.ucdb`](../../uvm/cov_after/NEG_MTS_124_terminate_ack_after_drain_upgrade_s1.ucdb) |
| ℹ️ | log.beats | `5` |
| ℹ️ | log.csr | `4` |
| ℹ️ | log.debug_burst | `1` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `1` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `1` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.ts_delta | `1` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 82.48 | 16.50 | 0.38 | 96.26 | 0.08 |
| branch | 71.25 | 14.25 | 0.39 | 92.60 | 0.08 |
| cond | 50.86 | 10.17 | 0.00 | 86.20 | 0.00 |
| expr | 50.00 | 10.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 100.00 | 20.00 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 55.55 | 11.11 | 11.11 | 88.88 | 2.22 |
| toggle | 9.49 | 1.90 | 0.00 | 54.07 | 0.00 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
