# DV Execution Audit - mutrig_timestamp_processor

Date: 2026-05-09, refreshed through 2026-05-10 00:58 Europe/Zurich

## Scope

This audit records the current plan-to-UVM execution state after enabling the
dual normal/debug monitor path, replacing the old generic documented-case
fallback with explicit case dispatch, completing the BASIC B111-B130 batch, and
adding the first EDGE CSR/input-protocol, divider/ToT, and debug-threshold
boundary batches.

## Current Coverage Of Documented Cases

| Bucket | Documented Cases | Explicit UVM Handlers | Current Log + UCDB Evidence |
|---|---:|---:|---:|
| BASIC | 130 | 129 | 129 |
| EDGE | 131 | 48 | 48 |
| PROF | 130 | 0 | 0 |
| ERROR | 130 | 2 | 2 |
| Total | 521 | 179 | 179 |

Notes:
- Unimplemented `mtsp_doc_case_test` case IDs fail with
  `No explicit UVM stimulus handler`.
- The old generic smoke fallback is no longer counted as evidence.
- `STD_MTS_106_total_counter_hi_rollover` remains intentionally open. It needs
  a rollover-specific strategy, such as a legal long-run accelerator or a
  separately justified counter preload hook, rather than a fake pass through a
  short simulation.
- `CORNER_MTS_018_counter_read_on_low_word_rollover` remains open for the same
  class of rollover-snapshot strategy. It is not counted as covered by the new
  CSR boundary batch.
- `CORNER_MTS_057_toggle_derive_tot_between_hits` and
  `CORNER_MTS_058_toggle_delay_field_between_hits` remain open until the
  in-flight CSR mode-sampling contract is resolved. A weak post-output toggle
  check is not counted as evidence for the documented accepted-hit sampling
  requirement.
- `DV_EDGE.md` currently contains a duplicate short ID `E127`; this remains an
  audit finding.
- `DV_PROF.md` has no explicit UVM handlers yet.
- The top-level `tb/DV_COV.md` and `tb/DV_REPORT.md` still contain older
  generated 130/130 bucket rows from the pre-explicit-dispatch flow. They are
  not accepted as closure evidence until regenerated from the current explicit
  handler/artifact set.

## BASIC Reconciliation Notes

- `STD_MTS_008_idle_from_flushing` and
  `STD_MTS_045_terminating_without_eop_then_idle` were reconciled to the
  delivered stateful control-ready contract: enter `FLUSHING`, assert upstream
  `endofrun`, wait for the empty close-marker train, then send `IDLE`.
- `STD_MTS_032_idle_rejects_clean_hit` was reconciled to the ready/valid
  contract: a beat driven while `ready=0` is not an accepted transfer and does
  not change total/discard counters.
- `STD_MTS_055_expected_latency_updates_padding_upper` was reconciled to the
  current RTL split: `expected_latency` controls delay-error classification,
  while `padding_upper` is derived from `MUTRIG_OVERFLOW_LOOKBACK_8N`.
- `STD_MTS_071_sop_first_hit_channel0` through
  `STD_MTS_076_reset_clears_startofrun_sent`,
  `STD_MTS_079_empty_stays_zero`, and
  `STD_MTS_080_output_valid_only_in_run_or_flush` have explicit marker
  handlers. The SOP cases bind the documented channel to the downstream route
  lane by choosing raw TCC symbols whose quotient bits `[5:4]` select lanes
  0..3, while also setting the visible payload channel to the same lane.
- `STD_MTS_081_route_lane0` through
  `STD_MTS_090_delay_field_changes_error_source` have explicit routing and
  timestamp-delay handlers. These cases use a ROM-inverse lookup from
  `dual_port_rom_init.txt` to construct exact raw MuTRiG symbols for the
  requested decoded timestamp quotient, and every output hit is required to
  have a paired normal/debug trace entry.
- `STD_MTS_091_debug_burst_only_running` through
  `STD_MTS_100_debug_streams_clear_outside_running` check RUNNING-only debug
  sideband activity, first-hit history warm-up, signed timestamp deltas,
  sign-magnitude conversion, arrival delta dependence on GTS spacing, and debug
  stream clearing after IDLE.
- `STD_MTS_101_replay_smoke_positive_et` through
  `STD_MTS_105_total_counter_matches_all_valid` and
  `STD_MTS_107_soft_reset_clears_counters` through
  `STD_MTS_110_force_stop_persists_until_cleared` preserve the checked-in VHDL
  smoke ET vectors and add CSR-visible counter checks.
- `STD_MTS_111_compile_rtl_default_div_pipeline` and
  `STD_MTS_112_compile_packaged_div_pipeline` now compile/run with
  `LPM_DIV_PIPELINE=4` and `LPM_DIV_PIPELINE=2` respectively. The observed
  monitor-defined input/output latencies are 11 and 9 cycles.
- `STD_MTS_113_single_enabled_channel_window` and
  `STD_MTS_114_upper_enabled_window` now exercise compile-time enabled-channel
  windows and prove packet-open bookkeeping against outside-window and
  inside-window sideband lanes.
- `STD_MTS_115_remapped_hiterr_bit`,
  `STD_MTS_116_remapped_crcerr_still_inert`, and
  `STD_MTS_117_remapped_frame_corrupt_still_inert` now exercise the remapped
  error-bit generics. Only the configured `HITERR_BIT_LOC` affects discard
  behavior in the current RTL.
- `STD_MTS_118_changed_latency_generic_at_power_on` proves
  `MUTRIG_BUFFER_EXPECTED_LATENCY_8N=128` reaches CSR and debug trace metadata.
- `STD_MTS_119_bank_string_is_debug_only` proves `BANK=DOWN` changes debug
  report text only; normal payload and debug-side evidence remain functional.
- `STD_MTS_120_debug_zero_is_functionally_equivalent` proves `DEBUG=0`
  suppresses VHDL report text only. The current RTL still emits debug sideband
  outputs, and the UVM scoreboard continues to require normal/debug pairing.
- `STD_MTS_121` through `STD_MTS_130` now provide the terminate/drain,
  stateful-ready, terminal-boundary, and canonical
  `RUN_PREPARE -> SYNC -> RUNNING -> TERMINATING -> IDLE` bring-up sequence
  evidence for later hardware reference work.

## EDGE Reconciliation Notes

- `CORNER_MTS_012_expected_latency_one` calibrates the next output arrival,
  crafts a raw ROM symbol that produces `debug_delta=1`, and proves the strict
  `delta < expected_latency` comparison flags the equality case as an error.
- `CORNER_MTS_013` and `CORNER_MTS_014` prove large `expected_latency` CSR
  values (`0x0000ffff` and `0xffffffff`) propagate into the normal/debug trace
  metadata without hidden truncation in the scoreboard model.
- `CORNER_MTS_015` and `CORNER_MTS_016` cover reserved op-mode bit 28 and
  packed multi-field CSR writes, including force-stop, bypass, discard, and
  op-mode readback after `soft_reset` self-clears.
- `CORNER_MTS_017` required a UVM CSR burst helper. The ordinary CSR helper
  inserts an idle cycle after writes, which lets RTL self-clear `soft_reset`
  before the next read. The new no-idle write/read helper samples the asserted
  bit in the legal one-cycle visibility window and then checks counter clear.
- `CORNER_MTS_019` and `CORNER_MTS_020` prove CSR access during `FLUSHING` and
  stable zero readback for unsupported address 7 without perturbing close-marker
  generation or counters.
- `CORNER_MTS_021` through `CORNER_MTS_024` cover plain, SOP-only, EOP-only,
  and single-beat packet shapes. The reference behavior is that output SOP is
  generated by the downstream route start-of-run state, while input EOP does not
  directly become output EOP outside the terminate close-marker path.
- `CORNER_MTS_025` and `CORNER_MTS_026` check accepted hit spacing at zero-gap
  and one-cycle-gap ingress, with output fields still ordered by the accepted
  input sequence.
- `CORNER_MTS_027` proves sparse `RUNNING` traffic does not leak stale debug or
  counter state before the delayed hit appears.
- `CORNER_MTS_028` through `CORNER_MTS_030` add max payload field checks and a
  sideband-aware hit helper so the UVM path can drive full 6-bit
  `asi_hit_type0_channel` values independently from payload ASIC/channel fields.
- `CORNER_MTS_041` through `CORNER_MTS_045` now drive exact ROM-inverse
  decoded symbols for divide remainders 0 through 4 and require paired
  normal/debug trace evidence for each payload.
- `CORNER_MTS_046` through `CORNER_MTS_050` now check route bits `[5:4]` for
  lanes 0 through 3 plus a quotient boundary transition from route 0 to route
  1. The route sideband and packed payload quotient are checked together to
  catch route/data skew.
- `CORNER_MTS_051` through `CORNER_MTS_056` now cover short-mode EFlag masking,
  ToT-mode EFlag masking, smallest positive ToT delta, largest unsaturated
  delta, first saturated delta, and negative-delta clamp behavior. The initial
  `CORNER_MTS_053` bring-up exposed a test-vector unit mismatch: ToT is in
  decoded 1.6 ns ticks, not quotient steps. The stimulus was corrected before
  evidence was accepted.
- `CORNER_MTS_059` and `CORNER_MTS_060` now cover EFlag toggling and TFine
  extremes. `CORNER_MTS_057` and `CORNER_MTS_058` are intentionally not
  implemented by these helpers because their documented per-accepted-hit CSR
  mode sampling needs a separate RTL/harness decision.
- `CORNER_MTS_071` through `CORNER_MTS_076` now calibrate exact debug-delay
  targets and prove the error flag at `-1`, `0`, `+1`, `expected_latency-1`,
  `expected_latency`, and `expected_latency+1`.
- `CORNER_MTS_077` reuses the explicit T-vs-E delay-source flip sequence so
  both path selections are required to agree with payload and debug math.
- `CORNER_MTS_078` through `CORNER_MTS_080` now check the signed timestamp
  delta boundary through both `ts_delta` and the trimmed high byte in
  `debug_burst` for positive, negative, and zero deltas.

## Debug And RTL Findings From This Batch

| Finding | First Seen In | Resolution |
|---|---|---|
| `debug_ts_valid` could fire for reset/SCLR flush traffic with no normal `hit_type1` payload. | `STD_MTS_005_sync_enters_reset_sync` | RTL gates `debug_ts` to active output states and the drop policy. |
| First standard-sequence hit could be transformed before the harness had proven RUNNING status. | `STD_MTS_006_running_from_sync` | UVM `run_start()` now polls CSR running status and waits for hit input ready. |
| Input datapath, counters, and monitor could disagree around stale ready/accept windows. | `STD_MTS_006_running_from_sync` | RTL uses a combinational state-derived ready window and samples datapath payloads only on accepted ready/valid transfers. |
| CSR read data could be sampled from the previous transaction. | `STD_MTS_006_running_from_sync` | UVM CSR driver now drives requests on `negedge` and samples after positive-edge acknowledgement. |
| The existing CSR helper could not observe the one-cycle `soft_reset` readback window because it inserted an idle cycle after writes. | `CORNER_MTS_017_read_during_soft_reset_window` | UVM CSR items now support a held-bus no-idle write/read sequence used only by the explicit edge case. |
| Termination cases needed the explicit upstream `endofrun` pulse required by current RTL. | `STD_MTS_077_terminating_input_eop_forwards_output_eop` | Cases and `DV_BASIC.md` now use payload drain plus `endofrun` before expecting close markers. |
| A post-traffic SYNC reset cannot be driven as `RUNNING -> RUN_PREPARE -> SYNC`; current RTL only accepts `RUN_PREPARE` from `IDLE` or `FLUSHING`. | `STD_MTS_108_sync_clears_counters` | UVM now uses the legal `IDLE -> RUN_PREPARE -> SYNC` sequence before checking that counters clear in RESET/SYNC. |
| `IDLE` could be decoded while `asi_ctrl_ready=0`, aborting close-marker generation. | `STD_MTS_129_upgrade_case_idle_after_boundary_only` | RTL fix `e61fc9f22e83` gates control decode on `asi_ctrl_valid && ctrl_ready_comb`; before fails and after passes under `prove_delta`. |

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
`packet_scheduler` worktrees were dirty and divergent from those branch tips, so
no in-place checkout or pull was performed there.

## Evidence Commands

Focused B111-B130 regression:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<B111-B130 case_id> SEED=1
```

Result: `NEW_B111_B130_PASS`, then refreshed under the final full sweep.

Focused EDGE CSR/input-protocol batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E012-E017,E019-E030 case_id> SEED=1
```

Result: `EDGE_E012_E017_E019_E030_PASS`, then refreshed under the final full
sweep.

Focused EDGE divider/ToT batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E041-E056,E059-E060 case_id> SEED=1
```

Result: `EDGE_E041_E056_E059_E060_PASS`, then refreshed under the final full
sweep.

Focused EDGE debug-threshold batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E071-E080 case_id> SEED=1
```

Result: `EDGE_E071_E080_PASS`, then refreshed under the final full sweep.

RTL before/after bug proof:

```bash
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=STD_MTS_129_upgrade_case_idle_after_boundary_only SEED=1
```

Result: before RTL fails at 220 ns with `IDLE command must not be accepted
before close markers complete`; after RTL passes with
`beats=4 payloads=0 eops=4 empty_eops=4`.

Final explicit-case sweep:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1
```

Result: `FULL_EXPLICIT_SWEEP_PASS count=179`.

Combo terminate contract:

```bash
make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1
```

Result: passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8
debug_ts=2 dual_path_pairs=2 traces=2`.

Coverage:

```bash
make -C tb/uvm cov_report_total RTL_VARIANT=after
```

Current merged report: `tb/uvm/cov_after/merged.txt`.

Filtered instance coverage summary: `64.53%`.

Artifact check:

```text
explicit_cases=179 missing_artifacts=0
combo_pass=True
```

Additional checks:

```bash
git diff --check
./tb/run_mts_processor_tb.sh
python3 /home/yifeng/.codex/skills/rtl-writing/scripts/rtl_style_check.py mts_processor.vhd
python3 /home/yifeng/.codex/skills/dv-workflow/scripts/bug_history_format_check.py BUG_HISTORY.md
```

Results:
- `git diff --check`: pass.
- `./tb/run_mts_processor_tb.sh`: `mts_processor_tb PASSED`.
- `rtl_style_check.py`: fail on 952 legacy style issues in `mts_processor.vhd`
  such as tabs, legacy `i_` ports, constant naming, and alignment. This batch
  did not attempt a broad file restyle.
- `bug_history_format_check.py BUG_HISTORY.md`: pass.

Current evidenced explicit cases are the 179 handlers in
`tb/uvm/mtsp_cases.svh`. Each has a matching
`tb/uvm/logs/*_after_s1.log` and `tb/uvm/cov_after/*_s1.ucdb` artifact.

## Open Work

DV closure is not complete. The remaining work is to implement real stimuli for
the remaining 342 uncovered BASIC, EDGE, PROF, and ERROR cases, including
`STD_MTS_106_total_counter_hi_rollover` and
`CORNER_MTS_018_counter_read_on_low_word_rollover`, plus the in-flight CSR
mode-sampling cases `CORNER_MTS_057` and `CORNER_MTS_058`, then regenerate the
ordered coverage/report dashboard from current artifacts instead of relying on
stale proxy rows.
