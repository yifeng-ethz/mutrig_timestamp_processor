# ✅ STD_MTS_003_direct_running_entry_allowed

**Bucket:** `BASIC` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Send only the `RUNNING` control word after reset; expect the current RTL to enter `RUNNING` directly because `csr.go` defaults high. Locks down the legacy nonstandard fast-entry path.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_BASIC.md:B003

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
| ℹ️ | log | [`uvm/logs/STD_MTS_003_direct_running_entry_allowed_after_s1.log`](../../uvm/logs/STD_MTS_003_direct_running_entry_allowed_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STD_MTS_003_direct_running_entry_allowed_s1.ucdb`](../../uvm/cov_after/STD_MTS_003_direct_running_entry_allowed_s1.ucdb) |
| ℹ️ | log.beats | `1` |
| ℹ️ | log.csr | `0` |
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
| ℹ️ | log.trace_detail_lines | `0` |
| ℹ️ | log.traces | `1` |
| ℹ️ | log.ts_delta | `0` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 72.77 | 72.77 | 23.51 | 73.51 | 23.51 |
| branch | 52.34 | 52.34 | 22.26 | 53.90 | 22.26 |
| cond | 27.43 | 27.43 | 23.01 | 27.43 | 23.01 |
| expr | 50.00 | 50.00 | 50.00 | 50.00 | 50.00 |
| fsm_state | 50.00 | 50.00 | 25.00 | 50.00 | 25.00 |
| fsm_trans | 11.11 | 11.11 | 11.11 | 11.11 | 11.11 |
| toggle | 7.49 | 7.49 | 6.73 | 7.72 | 6.73 |

---
_Back to [bucket](../buckets/BASIC.md) &middot; [dashboard](../../DV_REPORT.md)_
