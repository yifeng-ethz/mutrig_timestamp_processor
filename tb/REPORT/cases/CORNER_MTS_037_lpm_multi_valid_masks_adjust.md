# ✅ CORNER_MTS_037_lpm_multi_valid_masks_adjust

**Bucket:** `EDGE` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Create a dense hit burst across a one-tick overflow lookback window; verify the legal pre/active and expired output classes while the divider pipeline is busy. Covers the current per-hit overflow-adjust sampling contract; the old `lpm_multi_valid_cnt` mask no longer exists in the RTL.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_EDGE.md:E037

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
| ✅ | observed_txn | `80` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/CORNER_MTS_037_lpm_multi_valid_masks_adjust_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/CORNER_MTS_037_lpm_multi_valid_masks_adjust_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `80` |
| ℹ️ | log.csr | `3` |
| ℹ️ | log.debug_burst | `78` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `80` |
| ℹ️ | log.dual_path_pairs | `80` |
| ℹ️ | log.empty_eops | `0` |
| ℹ️ | log.eops | `0` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `80` |
| ℹ️ | log.latency48_identity | `80` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `80` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `1` |
| ℹ️ | log.traces | `80` |
| ℹ️ | log.ts_delta | `78` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 79.84 | 1.00 | 0.00 | 90.80 | 0.00 |
| branch | 63.31 | 0.79 | 0.00 | 80.96 | 0.00 |
| cond | 43.54 | 0.54 | 0.00 | 75.00 | 0.00 |
| expr | 50.00 | 0.62 | 0.00 | 100.00 | 0.00 |
| fsm_state | 75.00 | 0.94 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 22.22 | 0.28 | 0.00 | 66.66 | 0.00 |
| toggle | 22.26 | 0.28 | 1.80 | 44.26 | 0.02 |

---
_Back to [bucket](../buckets/EDGE.md) &middot; [dashboard](../../DV_REPORT.md)_
