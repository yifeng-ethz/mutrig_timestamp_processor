# ✅ STRESS_MTS_066_alternate_standard_and_legacy_starts

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Alternate standard sequences and legacy direct starts; verify both remain functional in the same regression. Covers mixed startup styles.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P066

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
| ✅ | observed_txn | `500` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | [`uvm/logs/STRESS_MTS_066_alternate_standard_and_legacy_starts_after_s1.log`](../../uvm/logs/STRESS_MTS_066_alternate_standard_and_legacy_starts_after_s1.log) |
| ℹ️ | ucdb | [`uvm/cov_after/STRESS_MTS_066_alternate_standard_and_legacy_starts_s1.ucdb`](../../uvm/cov_after/STRESS_MTS_066_alternate_standard_and_legacy_starts_s1.ucdb) |
| ℹ️ | log.csr | `504` |
| ℹ️ | log.inputs | `100` |
| ℹ️ | log.beats | `500` |
| ℹ️ | log.payloads | `100` |
| ℹ️ | log.eops | `400` |
| ℹ️ | log.empty_eops | `400` |
| ℹ️ | log.debug_ts | `100` |
| ℹ️ | log.debug_burst | `100` |
| ℹ️ | log.ts_delta | `100` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.dual_path_pairs | `100` |
| ℹ️ | log.traces | `100` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.trace_detail_lines | `100` |
| ℹ️ | log.math_error_traces | `50` |
| ℹ️ | log.hit_error_traces | `50` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 85.18 | 0.17 | 0.00 | 95.00 | 0.00 |
| branch | 73.43 | 0.15 | 0.00 | 85.93 | 0.00 |
| cond | 52.21 | 0.10 | 0.00 | 79.64 | 0.00 |
| expr | 50.00 | 0.10 | 0.00 | 50.00 | 0.00 |
| fsm_state | 100.00 | 0.20 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 55.55 | 0.11 | 0.00 | 66.66 | 0.00 |
| toggle | 19.68 | 0.04 | 0.03 | 49.80 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
