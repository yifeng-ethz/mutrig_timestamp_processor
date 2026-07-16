# ✅ STRESS_MTS_090_inert_parameter_sweep_compare

**Bucket:** `PROF` &nbsp; **Method:** `D` &nbsp; **Build:** `after` &nbsp; **Effort:** `signoff` &nbsp; **Result:** `pass`

## Intent

- **Scenario:** Sweep `PADDING_EOP_WAIT_CYCLE`, `CRCERR_BIT_LOC`, and `FRAME_CORRPT_BIT_LOC` across two builds and verify no current functional delta. Documents present inertness under stress.
- **Primary checks:** UVM reference model checks normal payload, debug sideband, CSR/readout, and bounded protocol invariants for this documented case.
- **Contract anchor:** DV_PROF.md:P090

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
| ✅ | observed_txn | `68` |
| ℹ️ | implementation_mode | `explicit_uvm_handler` |
| ℹ️ | log | `uvm/logs/STRESS_MTS_090_inert_parameter_sweep_compare_after_s1.log` — local generated artifact; intentionally not published |
| ℹ️ | ucdb | `uvm/cov_after/STRESS_MTS_090_inert_parameter_sweep_compare_s1.ucdb` — local generated artifact; intentionally not published |
| ℹ️ | log.beats | `68` |
| ℹ️ | log.csr | `5` |
| ℹ️ | log.debug_burst | `64` |
| ℹ️ | log.debug_path_required | `1` |
| ℹ️ | log.debug_ts | `64` |
| ℹ️ | log.dual_path_pairs | `64` |
| ℹ️ | log.empty_eops | `4` |
| ℹ️ | log.eops | `4` |
| ℹ️ | log.hit_error_traces | `0` |
| ℹ️ | log.inputs | `64` |
| ℹ️ | log.latency48_identity | `68` |
| ℹ️ | log.latency48_negative_diagnostics | `0` |
| ℹ️ | log.math_error_traces | `0` |
| ℹ️ | log.payloads | `64` |
| ℹ️ | log.ready_x | `0` |
| ℹ️ | log.scoreboard_ports | `csr, hit0, hit1, debug_ts, debug_burst, ts_delta` |
| ℹ️ | log.trace_detail_lines | `64` |
| ℹ️ | log.traces | `64` |
| ℹ️ | log.ts_delta | `64` |

## Coverage

<!-- code coverage vectors: stmt/branch/cond/expr/fsm_state/fsm_trans/toggle (percent) -->

| metric | standalone | isolated_per_txn | bucket_gain | bucket_merged_after | bucket_gain_per_txn |
|---|---|---|---|---|---|
| stmt | 80.74 | 1.19 | 0.00 | 93.70 | 0.00 |
| branch | 68.18 | 1.00 | 0.00 | 82.46 | 0.00 |
| cond | 48.38 | 0.71 | 0.00 | 79.03 | 0.00 |
| expr | 50.00 | 0.74 | 0.00 | 83.33 | 0.00 |
| fsm_state | 100.00 | 1.47 | 0.00 | 100.00 | 0.00 |
| fsm_trans | 33.33 | 0.49 | 0.00 | 66.66 | 0.00 |
| toggle | 22.28 | 0.33 | 0.03 | 50.60 | 0.00 |

---
_Back to [bucket](../buckets/PROF.md) &middot; [dashboard](../../DV_REPORT.md)_
