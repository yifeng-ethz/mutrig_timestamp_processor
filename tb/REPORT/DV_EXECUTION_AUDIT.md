# DV Execution Audit - mutrig_timestamp_processor

Date: 2026-05-09

## Scope

This audit records the current plan-to-UVM execution state after enabling the
dual normal/debug monitor path and replacing the old generic documented-case
fallback with explicit case dispatch.

## Current Coverage Of Documented Cases

| Bucket | Documented Cases | Explicit UVM Handlers | Current Log + UCDB Evidence |
|---|---:|---:|---:|
| BASIC | 130 | 80 | 80 |
| EDGE | 131 | 2 | 2 |
| PROF | 130 | 0 | 0 |
| ERROR | 130 | 2 | 2 |
| Total | 521 | 84 | 84 |

Notes:
- Unimplemented `mtsp_doc_case_test` case IDs now fail with `No explicit UVM stimulus handler`.
- The old generic smoke fallback is no longer counted as evidence.
- `DV_EDGE.md` currently contains a duplicate short ID `E127`; this remains an audit finding.
- `DV_PROF.md` has no explicit UVM handlers yet.
- `STD_MTS_032_idle_rejects_clean_hit` was reconciled to the ready/valid contract:
  a beat driven while `ready=0` is not an accepted transfer and does not change
  total/discard counters.
- `STD_MTS_055_expected_latency_updates_padding_upper` was reconciled to the
  current RTL split: `expected_latency` controls delay-error classification,
  while `padding_upper` is derived from `MUTRIG_OVERFLOW_LOOKBACK_8N`.
- `STD_MTS_071_sop_first_hit_channel0` through
  `STD_MTS_076_reset_clears_startofrun_sent`,
  `STD_MTS_079_empty_stays_zero`, and
  `STD_MTS_080_output_valid_only_in_run_or_flush` now have explicit marker
  handlers. The SOP cases bind the documented channel to the downstream route
  lane by choosing raw TCC symbols whose quotient bits `[5:4]` select lanes
  0..3, while also setting the visible payload channel to the same lane.

## Debug And RTL Findings From This Batch

| Finding | First Seen In | Resolution |
|---|---|---|
| `debug_ts_valid` could fire for reset/SCLR flush traffic with no normal `hit_type1` payload. | `STD_MTS_005_sync_enters_reset_sync` | RTL gates `debug_ts` to active output states and the drop policy. |
| First standard-sequence hit could be transformed before the harness had proven RUNNING status. | `STD_MTS_006_running_from_sync` | UVM `run_start()` now polls CSR running status and waits for hit input ready. |
| Input datapath, counters, and monitor could disagree around stale ready/accept windows. | `STD_MTS_006_running_from_sync` | RTL uses a combinational state-derived ready window and samples datapath payloads only on accepted ready/valid transfers. |
| CSR read data could be sampled from the previous transaction. | `STD_MTS_006_running_from_sync` | UVM CSR driver now drives requests on `negedge` and samples after positive-edge acknowledgement. |
| Termination case omitted the explicit upstream `endofrun` pulse required by current RTL. | `STD_MTS_077_terminating_input_eop_forwards_output_eop` | Case and `DV_BASIC.md` now use the current payload-drain plus `endofrun` sequence. |
| `B032` text conflicted with the ready/valid transfer contract by expecting counter increments while `ready=0`. | `STD_MTS_032_idle_rejects_clean_hit` | `DV_BASIC.md` and the UVM case now require no accepted hit, no output, and no counter change for the ready-low IDLE beat. |
| `B055` text still described the pre-5.12 padding contract where `expected_latency` implied the overflow window. | `STD_MTS_055_expected_latency_updates_padding_upper` | `DV_BASIC.md` now preserves the case ID but verifies the current split between delay-error threshold and overflow lookback padding. |
| White-timestamp quotient can exceed the 13-bit visible `hit_type1.tcc_8n` field. | `STD_MTS_056_no_adjust_below_upper_bound` | UVM checks compare the visible truncated payload field while the debug-sideband scoreboard still validates full-width delay math. |
| Delay-source checks initially sampled the reset-seeded debug-burst warm-up delta instead of the two-hit comparison delta. | `STD_MTS_066_delay_field_t_path` | UVM now waits for the second `ts_delta` sample before checking T/E-selected polarity. |
| Output-marker wording can be confused with payload-channel propagation even though RTL SOP bookkeeping is keyed by downstream route lane. | `STD_MTS_071_sop_first_hit_channel0` | UVM now checks SOP/EOP/EMPTY plus `aso_hit_type1_channel` for route lanes 0..3 and uses matching payload channels for trace readability. |

## Submodule Freshness Check

The OPQ IP-core chain requested on 2026-05-09 was fetched and located:

| Repository | Leading Commit | Branch |
|---|---|---|
| `packet_scheduler` | `245eb93` `[PATCH] Mirror OPQ handle CSR map in SVD` | `origin/codex/opq-feb-swb-debug-20260508` |
| `mu3e-ip-cores` | `c9ca241` `[PATCH] Advance packet scheduler SVD package pointer` | `origin/codex/opq-feb-swb-parent-20260508` |
| `musip` | `d3f4c05` `[PATCH] Advance Mu3e IP cores OPQ SVD pointer` | `yifeng-ip_sim-2604`, `origin/yifeng-ip_sim-2604` |

`/home/yifeng/packages/musip_2604/external` contains the clean chain:
`musip d3f4c05` -> `external/mu3e-ip-cores c9ca241` ->
`packet_scheduler 245eb93`. The active
`/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores` and
`packet_scheduler` worktrees are dirty and divergent from those branch tips, so
no in-place checkout or pull was performed there.

## Evidence Commands

The focused after-fix regression was run with:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1
```

The complete explicit-case sweep was rerun with all 84 current handlers and
ended with `ALL_84_EXPLICIT_CASES_PASS`.

The merged after-fix coverage report was regenerated with:

```bash
make -C tb/uvm cov_report_total RTL_VARIANT=after
```

The current merged report is `tb/uvm/cov_after/merged.txt`; its filtered
instance coverage summary is `64.51%`.

Current evidenced explicit cases are the 84 handlers in `tb/uvm/mtsp_cases.svh`.
Each has a matching `tb/uvm/logs/*_after_s1.log` and
`tb/uvm/cov_after/*_s1.ucdb` artifact.

## Open Work

DV closure is not complete. The remaining work is to implement real stimuli for
the remaining 437 uncovered BASIC, EDGE, PROF, and ERROR cases, then regenerate the ordered
coverage/report dashboard from current artifacts instead of relying on stale
proxy rows.
