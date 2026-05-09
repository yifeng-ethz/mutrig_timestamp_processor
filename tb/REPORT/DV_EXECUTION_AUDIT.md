# DV Execution Audit - mutrig_timestamp_processor

Date: 2026-05-09

## Scope

This audit records the current plan-to-UVM execution state after enabling the
dual normal/debug monitor path and replacing the old generic documented-case
fallback with explicit case dispatch.

## Current Coverage Of Documented Cases

| Bucket | Documented Cases | Explicit UVM Handlers | Current Log + UCDB Evidence |
|---|---:|---:|---:|
| BASIC | 130 | 38 | 38 |
| EDGE | 131 | 2 | 2 |
| PROF | 130 | 0 | 0 |
| ERROR | 130 | 2 | 2 |
| Total | 521 | 42 | 42 |

Notes:
- Unimplemented `mtsp_doc_case_test` case IDs now fail with `No explicit UVM stimulus handler`.
- The old generic smoke fallback is no longer counted as evidence.
- `DV_EDGE.md` currently contains a duplicate short ID `E127`; this remains an audit finding.
- `DV_PROF.md` has no explicit UVM handlers yet.

## Debug And RTL Findings From This Batch

| Finding | First Seen In | Resolution |
|---|---|---|
| `debug_ts_valid` could fire for reset/SCLR flush traffic with no normal `hit_type1` payload. | `STD_MTS_005_sync_enters_reset_sync` | RTL gates `debug_ts` to active output states and the drop policy. |
| First standard-sequence hit could be transformed before the harness had proven RUNNING status. | `STD_MTS_006_running_from_sync` | UVM `run_start()` now polls CSR running status and waits for hit input ready. |
| Input datapath, counters, and monitor could disagree around stale ready/accept windows. | `STD_MTS_006_running_from_sync` | RTL uses a combinational state-derived ready window and samples datapath payloads only on accepted ready/valid transfers. |
| CSR read data could be sampled from the previous transaction. | `STD_MTS_006_running_from_sync` | UVM CSR driver now drives requests on `negedge` and samples after positive-edge acknowledgement. |
| Termination case omitted the explicit upstream `endofrun` pulse required by current RTL. | `STD_MTS_077_terminating_input_eop_forwards_output_eop` | Case and `DV_BASIC.md` now use the current payload-drain plus `endofrun` sequence. |

## Evidence Commands

The focused after-fix regression was run with:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1
```

Current evidenced explicit cases are the 42 handlers in `tb/uvm/mtsp_cases.svh`.
Each has a matching `tb/uvm/logs/*_after_s1.log` and
`tb/uvm/cov_after/*_s1.ucdb` artifact.

## Open Work

DV closure is not complete. The remaining work is to implement real stimuli for
the uncovered BASIC, EDGE, PROF, and ERROR cases, then regenerate the ordered
coverage/report dashboard from current artifacts instead of relying on stale
proxy rows.
