# ✅ NEG_MTS_017_rapid_force_stop_toggle

**Bucket:** `ERROR` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Toggle `force_stop` on consecutive cycles during traffic and verify the DUT remains deterministic. Covers software thrash on a critical control bit.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_ERROR.md:X017

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
| ℹ️ | log | [`uvm/logs/NEG_MTS_017_rapid_force_stop_toggle_after_s1.log`](../../uvm/logs/NEG_MTS_017_rapid_force_stop_toggle_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/NEG_MTS_017_rapid_force_stop_toggle_s1.ucdb`](../../uvm/cov_after/NEG_MTS_017_rapid_force_stop_toggle_s1.ucdb) |
| ℹ️ | log.beats | `1` |
| ℹ️ | log.csr | `7` |
| ℹ️ | log.debug_burst | `0` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `1` |
| ℹ️ | log.dual_path_pairs | `1` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `2` |
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
| stmt | 78.34 | 39.17 | 0.37 | 91.14 | 0.18 |
| branch | 62.59 | 31.30 | 1.18 | 80.31 | 0.59 |
| cond | 41.37 | 20.68 | 2.59 | 72.41 | 1.29 |
| expr | 50.00 | 25.00 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 37.50 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 11.11 | 0.00 | 77.77 | 0.00 |
| toggle | 8.15 | 4.08 | 0.29 | 16.08 | 0.14 |

---
_Back to [bucket](../buckets/ERROR.md) &middot; [dashboard](../../DV_REPORT.md)_
