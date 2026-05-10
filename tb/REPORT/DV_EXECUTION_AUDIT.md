# DV Execution Audit - mutrig_timestamp_processor

Date: 2026-05-10, refreshed through 2026-05-10 09:26 CEST

## Scope

This audit records the current plan-to-UVM execution state after enabling the
dual normal/debug monitor path, replacing the old generic documented-case
fallback with explicit case dispatch, completing the BASIC B111-B130 batch, and
adding the first EDGE control-timing, CSR/input-protocol,
overflow/bypass/latency, divider/ToT, and debug-threshold boundary batches,
the EDGE reset and force-stop recovery batch, the EDGE
generic/configuration, ready-edge, termination-edge, ready-X monitor-trap, and
upgrade-readiness batches, plus the counter-rollover seed/readout, sampled CSR
mode, output-marker batches, the first PROF/STRESS throughput and soak batch,
the PROF/STRESS long-run mode stress batch, and the PROF/STRESS high-variance
input-pattern batch, the PROF/STRESS counter/reset/control-poll batch, and the
PROF/STRESS overflow-window stress batch, and the PROF/STRESS debug-stream
stress batch, the PROF/STRESS repeated run-control/CSR-chatter batch, and the
PROF/STRESS termination/drain stress batch, and the PROF/STRESS
parameter-sweep-under-load batch, and the PROF/STRESS randomized
entropy/control-noise batch, and the PROF/STRESS legacy smoke-vector endurance
batch.
This refresh also records the `bypass_lapse` per-hit RTL fix, the hit0 monitor
timing fix required for input analysis-port evidence, and the `csr.soft_reset`
RTL fix that clears local timing, datapath, output, and debug history. It also
records the illegal-control recovery RTL fix: unsupported control words still
decode to `ERROR`, but no longer leave `asi_ctrl_ready` stuck low forever. The
latest refresh also records `BUG-013-H`, a P090 terminate-stimulus packet-close
bug found and fixed while bringing up the inert parameter sweep. The P091-P100
refresh stopped on two harness reference-model mismatches, reviewed both
against the RTL timing/control contract, and accepted them only after the UVM
expectations were corrected; no new RTL bug was accepted in that batch.
The P101-P110 refresh stopped on `BUG-014-H`, a P110 debug-monitor bounded-wait
bug. The failure was reviewed against the four normal outputs and paired
`debug_ts` traces, then fixed in the harness without changing RTL.

## Current Coverage Of Documented Cases

| Bucket | Documented Cases | Explicit UVM Handlers | Current Log + UCDB Evidence |
|---|---:|---:|---:|
| BASIC | 130 | 130 | 130 |
| EDGE | 131 | 131 | 131 |
| PROF | 130 | 110 | 110 |
| ERROR | 130 | 2 | 2 |
| Total | 521 | 373 | 373 |

Notes:
- Unimplemented `mtsp_doc_case_test` case IDs fail with
  `No explicit UVM stimulus handler`.
- The old generic smoke fallback is no longer counted as evidence.
- `DV_EDGE.md` currently contains a duplicate short ID `E127`; this remains an
  audit finding.
- `DV_PROF.md` has explicit UVM handlers for P001 through P110; the remaining
  20 PROF stress cases still require real stimuli.
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
- `STD_MTS_106_total_counter_hi_rollover` now uses the disabled-by-default
  `DV_COUNTER_SEED_ENABLE` generic after the normal `run_start()` bring-up,
  seeds total count to `0x0000_ffff_ffff`, accepts one clean hit, and requires
  the high word to increment with a paired normal/debug trace.
- `STD_MTS_111_compile_rtl_default_div_pipeline` and
  `STD_MTS_112_compile_packaged_div_pipeline` now compile/run with
  `LPM_DIV_PIPELINE=4` and `LPM_DIV_PIPELINE=2` respectively. The observed
  accepted-hit-to-observed-output latencies are 10 and 8 cycles. The earlier
  11/9-cycle audit wording included a one-cycle early hit0 monitor timestamp
  and was corrected when the hit0 input analysis-port monitor was fixed.
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

- `CORNER_MTS_001` through `CORNER_MTS_010` now cover the initial
  control-timing edges: reset release with a coincident control pulse,
  same-cycle start/hit precedence, terminate/EOP coincidence, `IDLE` on the
  output-valid edge, prepare abort, tight `SYNC -> RUNNING`, repeated
  `RUNNING`, repeated `TERMINATING`, illegal active control words, and stale
  `asi_ctrl_data` while `valid=0`. The batch adds a UVM control-driver
  gap/hold mode so E010 can prove the RTL gates decode on `valid` rather than
  merely seeing a stale command word on the bus.
- `CORNER_MTS_105_output_ready_unknown_monitor_trap` now has a dedicated
  `hit_type1.ready` monitor feeding a scoreboard analysis port. The case drives
  `ready=X` during a real payload transfer, requires `ready_x=12` observations
  in the scoreboard summary, and still requires the emitted payload to have a
  paired normal/debug trace.
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
- `CORNER_MTS_018` now uses the same DV-only counter seed generic after
  standard run bring-up, reads the high word before rollover, then reads
  low/high after one accepted hit and recovers the coherent high-low-high
  snapshot `0x0001_0000_0000`.
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
- `CORNER_MTS_031` through `CORNER_MTS_040` now cover overflow padding
  thresholds, MTS counter wrap/active-lookback/expiry behavior, dense bursts
  across the overflow lookback while the divider is busy, `bypass_lapse` setup
  and in-flight stability, and `expected_latency` writes near overflow. E039
  exposed `BUG-008-R`: `bypass_lapse` was still read live for in-flight hits.
  The fixed RTL samples it per accepted hit, and the scoreboard requires the
  input analysis-port count, normal payloads, debug traces, and trace-pair count
  to agree before the case can pass.
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
- `CORNER_MTS_057` and `CORNER_MTS_058` now prove that `derive_tot` and
  `delay_ts_field_use_t` are sampled with each accepted hit. The before RTL
  failed these cases because later CSR writes could reinterpret already
  accepted hits; the current RTL carries the sampled mode bits through the
  ToT, delay-error, `debug_ts`, and `debug_burst` paths. `CORNER_MTS_059` and
  `CORNER_MTS_060` cover EFlag toggling and TFine extremes.
- `CORNER_MTS_061` through `CORNER_MTS_070` now cover output marker edges:
  first route-lane SOP after reset, no repeated SOP on interleaved lanes,
  enabled input-window sideband bookkeeping separated from route-lane SOP
  generation, terminal empty close-marker trains, ready-low close markers,
  non-terminating local EOPs, and `empty=0` payload versus `empty=1` close
  marker semantics. The accepted contract is that payload beats carry route
  SOP but not terminal EOP; terminal EOP appears on empty close markers after
  the input packet is closed by the legal upstream `endofrun` sequence.
- `CORNER_MTS_071` through `CORNER_MTS_076` now calibrate exact debug-delay
  targets and prove the error flag at `-1`, `0`, `+1`, `expected_latency-1`,
  `expected_latency`, and `expected_latency+1`.
- `CORNER_MTS_077` reuses the explicit T-vs-E delay-source flip sequence so
  both path selections are required to agree with payload and debug math.
- `CORNER_MTS_078` through `CORNER_MTS_080` now check the signed timestamp
  delta boundary through both `ts_delta` and the trimmed high byte in
  `debug_burst` for positive, negative, and zero deltas.
- `CORNER_MTS_081` through `CORNER_MTS_090` now cover same-cycle
  `force_stop` writes, force-stop clear/restart, soft reset during idle,
  soft reset with in-flight payload, soft reset while flushing, global reset
  with pending terminate/EOP traffic, debug-history reset, prepare after soft
  reset, sync after force-stop, and `IDLE` during SCLR flush. These cases keep
  normal payload checks and debug trace pairing active where payloads are
  expected, and require no-payload evidence where reset or force-stop suppresses
  output.
- `CORNER_MTS_091` through `CORNER_MTS_100` now cover enabled-channel window
  generics, packaged/source divider pipeline variants, zero and one-tick
  default latency generics, remapped hit-error handling, inert frame-corrupt
  relocation, and inert `PADDING_EOP_WAIT_CYCLE`. The terminate-delay cases
  use the observable accepted-hit-to-first-empty-close-marker contract:
  `LPM_DIV_PIPELINE + 7` cycles, measured as 9 cycles for the packaged
  `LPM_DIV_PIPELINE=2` override and 11 cycles for the RTL-default
  `LPM_DIV_PIPELINE=4` build.
- `CORNER_MTS_101` through `CORNER_MTS_104` now make `aso_hit_type1_ready`
  controllable from UVM and prove the current DUT still emits payload and
  close-marker beats while sink ready is low or toggling. `CORNER_MTS_106`
  through `CORNER_MTS_110` cover hit-input ready state semantics in
  `FLUSHING`, `IDLE`, `RESET/SCLR`, `RESET/SYNC`, and output quietness outside
  `RUNNING`/`FLUSHING`.
- `CORNER_MTS_111` through `CORNER_MTS_119` now cover current termination
  edges: no close markers before explicit upstream `endofrun`, tail EOP beats
  accepted one cycle before or on the same cycle as `TERMINATING`, post-EOP
  terminate with no extra payload/debug trace, ready-low `IDLE` pulse ignored
  during terminate work, multiple EOP-tagged flushing beats, incomplete-packet
  abort cleanup through IDLE/re-arm, outside-window terminating EOP sideband,
  and non-SOP/non-EOP flushing tail hits. These cases bind every payload to a
  normal/debug trace where a payload is expected and separately require the
  close-marker train.
- `CORNER_MTS_120` through `CORNER_MTS_130` now close the documented
  upgrade-readiness EDGE IDs. They prove stateful control-ready gaps across
  prepare/sync/flush/terminate, upstream `endofrun` driven synthetic terminal
  boundaries, EOP-alignment survival, inert CRCERR/frame-corrupt behavior
  during termination, command-accept versus work-completion timing, one
  terminal boundary per run stop, and `IDLE` acceptance only after terminal
  boundary work completes.

## PROF Reconciliation Notes

- `STRESS_MTS_001` through `STRESS_MTS_004` establish the first sustained
  throughput baselines: dense short-mode hits, dense ToT-mode hits,
  every-other-cycle hits, and repeated burst-of-eight microbursts. Each case
  requires the scoreboard to observe the input analysis-port stream, output
  payload stream, debug timestamp/burst stream, and normal/debug trace pairs
  for every accepted payload.
- `STRESS_MTS_005` through `STRESS_MTS_007` cover clean soak, periodic hiterr
  keep mode, and periodic hiterr discard mode. The keep-mode bring-up first
  exposed a testcase helper bug: the helper cleared CSR bit `0x2`
  (`force_stop`) instead of bit `0x10` (`discard_hiterr`), causing an exact
  16-hit discard deficit in a 128-hit stream. The helper was corrected before
  accepting evidence; the existing `STD_MTS_019_discard_hiterr_readback`
  control case also passed during review, so no RTL mismatch was accepted.
- `STRESS_MTS_008` and `STRESS_MTS_009` record the current sink contract under
  sustained traffic. With `aso_hit_type1_ready=1` and with it held low, the
  emitted payload and debug-trace counts match exactly because the current RTL
  ignores downstream backpressure.
- `STRESS_MTS_010` drives a dense backlog, enters `FLUSHING`, then accepts a
  final EOP-tagged hit and upstream `endofrun`. The accepted reference is 33
  payload beats, four empty close markers, 33 debug traces, and 33
  normal/debug trace pairs.
- `STRESS_MTS_011` through `STRESS_MTS_016` extend sustained mode evidence to
  256-hit and 512-hit windows. P011/P012/P014/P015 hold short, ToT, T-delay,
  and E-delay modes stable for 256 accepted hits, while P013/P016 toggle
  `derive_tot` or `delay_ts_field_use_t` at hit 256 and require all 512
  payloads to keep paired normal/debug trace evidence.
- `STRESS_MTS_017` through `STRESS_MTS_019` cover bypass mode under long-run
  conditions after a one-wrap lookback wait. P017 proves the padded white path,
  P018 proves bypass-on gray timestamp behavior with the expected delay-error
  sideband high after the wrap wait, and P019 toggles bypass between four
  packet boundaries while preserving per-packet math and trace pairing.
- `STRESS_MTS_020` rewrites `expected_latency` through phases `1`, `4096`, `2`,
  and `4096`. The scoreboard checks normal payload math, debug trace pairing,
  per-hit expected-latency metadata, and the error sideband for every phase.
- `STRESS_MTS_021` through `STRESS_MTS_030` add high-variance input-pattern
  evidence. P021-P027 and P030 use the profile-variance helper to check the
  input analysis-port sideband, SOP/EOP/error metadata, output route and SOP,
  payload math, normal/debug trace pairing, and trace math self-consistency for
  every accepted payload.
- `STRESS_MTS_021` intentionally allows delay-error sideband high when the
  route-round-robin timestamp quotient jumps fast enough to make
  `debug_delta` negative. This is not an RTL mismatch: the scoreboard requires
  the normal output error bit to match the debug-derived math error.
- `STRESS_MTS_022` and `STRESS_MTS_023` hold traffic on route 0 and route 3
  respectively, proving hot-spot traffic with exactly one output SOP per route
  after reset.
- `STRESS_MTS_024` sweeps payload channel values 0 through 31 under load, and
  `STRESS_MTS_025` sweeps ASIC IDs 0 through 15 while keeping sideband packet
  tracking active.
- `STRESS_MTS_026` drives SOP+EOP single-beat input packets, and
  `STRESS_MTS_027` drives four-beat input packets with SOP on the first beat
  and EOP on the last. The current output reference remains payload SOP plus
  no payload EOP outside the legal terminate close-marker path.
- `STRESS_MTS_028` injects every 16th beat as `hiterr` with discard enabled:
  the scoreboard observes 256 input beats, 240 payloads/debug traces, and 16
  discarded beats by counter check. `STRESS_MTS_029` repeats the pattern with
  discard disabled and observes all 256 payload/debug trace pairs.
- `STRESS_MTS_030` drives nonzero high mux bits in the 6-bit sideband channel
  under load. The hit0 input analysis port checks the full sideband value while
  output routing remains derived from the decoded quotient route.
- `STRESS_MTS_031` through `STRESS_MTS_034` add counter observability stress:
  monotonic discard counter polling under all-hiterr traffic, monotonic total
  counter polling under 1k accepted hits, mixed accept/reject counter soak, and
  coherent high-low-high total-count snapshots while traffic is active.
- `STRESS_MTS_035` and `STRESS_MTS_036` are reset-recovery stress cases. P035
  pulses CSR `soft_reset` between traffic phases and requires the total and
  discard counters, local timing epoch, normal payload stream, and debug trace
  history to restart cleanly. P036 repeats the same payload/debug evidence
  across global resets with reset-local synthetic timestamp epochs.
- `STRESS_MTS_037` and `STRESS_MTS_038` repeat the hardware bring-up control
  sequence 100 times with the canonical `RUN_PREPARE -> SYNC -> RUNNING`
  sequence and the direct-RUNNING shortcut respectively, proving control/CSR
  state does not leak outputs or counters during repeated bring-up.
- `STRESS_MTS_039` periodically asserts `force_stop` under traffic and proves
  the dropped beats are visible through input analysis-port evidence while
  every emitted payload still has normal/debug trace pairing.
- `STRESS_MTS_040` polls CSR every 32 cycles while traffic is active and
  requires 256 normal payloads, 256 debug timestamp/burst entries, 256
  `ts_delta` entries, and 256 normal/debug trace pairs.
- `STRESS_MTS_041` through `STRESS_MTS_050` cover overflow-window stress:
  single and repeated wrap events, symbols just below/equal/above
  `padding_upper`, mixed T/E adjustment eligibility, bypass-off/on long-run
  behavior, small and large `expected_latency`, and dense divider launch while
  `overflow_adjust_active` is asserted. The reference model uses
  `OVERFLOW_TIME_1N6=32767` and `padding_upper=22766`; the scoreboard requires
  normal payload math, debug timestamp/burst metadata, `ts_delta`, input
  analysis-port observations, and normal/debug trace pairing for every emitted
  payload.
- `STRESS_MTS_051` through `STRESS_MTS_060` cover sustained debug-stream
  evidence: exact `debug_ts`, `debug_burst`, and `ts_delta` counts; timestamp
  sign churn and zero-delta behavior; dense T/E delay-error pipeline
  alternation; expected-latency edge deltas around threshold 16; debug stream
  behavior through `FLUSHING`; and repeated RUNNING-exit cleanup. These cases
  require the normal output monitor, debug-path monitors, input analysis port,
  trace metadata, and scoreboard summary to agree before the test can pass.
- `STRESS_MTS_061` through `STRESS_MTS_070` cover repeated run-control cycles
  and CSR/control chatter. P061-P064 repeat empty, single-packet,
  multi-channel, and ready-low stop cycles; P065 verifies RUNNING aborts do not
  leak close markers; P066 alternates canonical standard starts with legacy
  direct `RUNNING` starts; P067-P069 rewrite CSR fields in IDLE, prepare, and
  flushing phases; and P070 injects illegal multi-hot control words before and
  during legal run sequences. Every payload-bearing case requires input
  analysis-port hits, normal output payloads, debug timestamp/burst/ts-delta
  observations, paired normal/debug traces, and trace math self-consistency.
  The counter checks intentionally distinguish standard starts, where
  `RUN_PREPARE -> SYNC` clears `total_hit_cnt`, from legacy direct starts,
  where the counter continues from the previous legal run.
- `STRESS_MTS_071` through `STRESS_MTS_080` cover termination and drain stress:
  shortest stop after one packet, dense burst stop, final-beat EOP, late
  flushing EOP, no-payload terminate then idle, multiple late EOPs, sink
  ready-low termination, per-route stop cycles, overflow-window stop, and heavy
  CSR polling during termination. Every payload-bearing case requires input
  analysis-port hits, normal output payloads, paired normal/debug traces, trace
  math self-consistency, close-marker masks, and counter checks. P074, P076,
  and P077 intentionally observe zero `debug_burst`/`ts_delta` entries because
  their payloads are accepted in `FLUSHING`; the normal/debug trace pairs still
  prove the dual monitor path.
- `STRESS_MTS_081` through `STRESS_MTS_090` cover parameter sweeps under load:
  divider pipeline depth 2 and 4 latency, single/two/four enabled-channel
  windows, remapped `HITERR_BIT_LOC`, custom default expected latency,
  `DEBUG=0`, `BANK=DOWN`, and inert padding/CRC/frame-corrupt generic
  combinations. P081/P082 require exact accepted-hit-to-observed-output
  latencies of 8 and 10 cycles. P086 requires the old hiterr bit to pass and
  the remapped bit to discard 16 of 128 hits. P087 requires CSR and trace
  metadata to report default latency 128. P090 requires all inert error-bit
  payloads to pass, then proves the legal four-marker terminate train after
  all enabled input lanes have been closed.
- `STRESS_MTS_091` through `STRESS_MTS_100` cover randomized stress with
  deterministic seeds: marker mixes, accept/reject mixes, delay-path mixes,
  ToT-mode mixes, force-stop pulses, soft-reset pulses, control chatter,
  randomized ASIC IDs, randomized payload channels, and expected-latency
  rewrites. Each payload-bearing case requires the normal output monitor, the
  debug timestamp/burst/ts-delta monitors, input analysis-port evidence,
  trace metadata, and paired normal/debug trace counts to agree before the
  case can pass. P096 initially exposed a UVM model error: after CSR
  `soft_reset`, expected timestamps must restart from the phase-local epoch
  just as the DUT resets local timing history. P097 initially exposed a UVM
  control-model error: legacy direct-RUNNING starts may carry the total counter
  across repeated starts, while standard `RUN_PREPARE -> SYNC` starts clear it.
  Both were harness reference fixes, not RTL changes.
- `STRESS_MTS_101` through `STRESS_MTS_110` replay the checked-in VHDL smoke
  vectors as long-running UVM stress references. P101/P102 repeat positive and
  EFlag-masked ToT vectors for 1000 hits, P103 repeats the negative-clamp plus
  saturation pair for 2000 payloads, P104/P105 prove standard bring-up and
  ready-low output behavior, P106/P107 prove the divider-pipeline latency
  variants, P108/P109 cover bypass and E-delay mode selections, and P110
  repeats all four smoke vectors across 32 CSR soft-reset cycles. Every case
  requires normal payload math, `debug_ts`, `debug_burst`, `ts_delta`, and
  paired normal/debug trace counts to agree before the scoreboard can pass.

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
| `DV_EDGE.md` documented E094/E095 terminate delay as `LPM_DIV_PIPELINE + 4`, but RTL emits close markers only after the full accepted payload path drains. | `CORNER_MTS_094_packaged_div_pipeline_delay` | No RTL change. The plan and checker now use the monitor-observable accepted-hit-to-first-empty-close-marker contract, `LPM_DIV_PIPELINE + 7`. |
| Counter preload before `run_start()` was cleared by the legal `RUN_PREPARE -> SYNC` sequence, so the rollover stimulus never reached the intended boundary. | `STD_MTS_106_total_counter_hi_rollover` | No carry RTL bug was accepted. The DV-only seed is applied after standard run bring-up, and default CSR writes to counter words remain inert when the generic is zero. |
| The VHDL debug report printed `total_pre` through a truncated integer conversion, which saturated the human trace near rollover. | `STD_MTS_106_total_counter_hi_rollover` | RTL report text now prints the full 48-bit counter in hex so rollover bring-up traces match CSR and scoreboard math. |
| `derive_tot` and `delay_ts_field_use_t` were read live after hit acceptance, so a CSR write could reinterpret an in-flight hit. | `CORNER_MTS_057_toggle_derive_tot_between_hits`, `CORNER_MTS_058_toggle_delay_field_between_hits` | RTL now latches these mode fields on accepted hits and carries them through the ToT, delay-error, `debug_ts`, and `debug_burst` paths; before/after `prove_delta` fails on the old RTL and passes on the fixed RTL. |
| `bypass_lapse` was read live after hit acceptance, so a CSR write could change the divider numerator source for an in-flight hit. | `CORNER_MTS_039_bypass_toggle_after_hit_accept` | RTL fix `6f4bf95` latches `bypass_lapse` on accepted hits, carries it through `hit_padding`, and uses the sampled field for divider numerator selection; before/after `prove_delta` fails on the old RTL and passes on the fixed RTL. |
| The hit0 input monitor sampled after the one-cycle driver deassert, so adjacent accepted hits could be missing from `hit0_history`. | `CORNER_MTS_039_bypass_toggle_after_hit_accept` | UVM fix `6f4bf95` samples hit0 accepts at the clock edge and records timestamps in the same monitor reporting domain as output/debug paths. E039 now requires `inputs=2 beats=2 payloads=2 dual_path_pairs=2`. |
| Direct payload latency checks used the old launch-edge hit0 timestamp convention. | `STD_MTS_111_compile_rtl_default_div_pipeline`, `STD_MTS_112_compile_packaged_div_pipeline` | The accepted-hit-to-observed-output reference is now 10 cycles for `LPM_DIV_PIPELINE=4` and 8 cycles for `LPM_DIV_PIPELINE=2`; terminate close-marker latency remains separately covered by E094/E095. |
| Initial output-marker harness attempts expected terminal close markers while an input packet was still open, using SOP-only or no-EOP payload traffic. | `CORNER_MTS_069_sop_and_eop_same_output_beat`, `CORNER_MTS_070_empty_zero_on_all_output_classes` | No RTL change was accepted. The sequences now legally close the input packet before requiring empty terminal markers, while preserving payload SOP/empty checks and normal/debug trace pairing. |
| Profile-variance helper forced no delay error even when a legal route timestamp jump made `debug_delta` negative. | `STRESS_MTS_021_round_robin_enabled_channels` | No RTL change was accepted. The helper now requires normal/debug trace math self-consistency for profile-variance cases while explicit delay-error cases still require exact expected values. |
| CSR `soft_reset` cleared visible counters without clearing local timing, datapath, output, and debug history. | `STRESS_MTS_035_soft_reset_every_10k_cycles` | RTL fix `b1d45ba` resets MTS/GTS counters, gates hit ready and normal/debug output, clears the datapath pipeline and route bookkeeping, and resets debug history. E084 now requires in-flight payload/debug flush; P035/P036 use reset-local timestamp epochs. |
| Sparse one-hit debug-stream stimulus expected per-hit `debug_burst` movement even though the RTL debug-burst process advances only during dense RUNNING cycles after warm-up. | `STRESS_MTS_054_alternating_increasing_decreasing_timestamps`, `STRESS_MTS_055_equal_timestamp_pairs` | No RTL change was accepted. The cases now drive dense streams and require exact debug-stream counts plus normal/debug trace math self-consistency. |
| Initial flushing debug-stream stimulus left the running input packet open by placing the first flushing EOP on a different sideband channel. | `STRESS_MTS_059_debug_streams_through_flushing` | No RTL change was accepted. The first flushing tail beat now closes the same input packet opened by the running SOP before upstream `endofrun` is sent. |
| Repeated RUNNING-exit cleanup checked debug sideband counters before the final debug pipeline sample settled. | `STRESS_MTS_060_debug_streams_clear_after_running` | No RTL change was accepted. The case now uses bounded waits for `debug_ts`, `debug_burst`, and `ts_delta` before checking exact per-iteration counts and idle quiescence. |
| Repeated standard-run stress initially expected `total_hit_cnt` to accumulate across `RUN_PREPARE -> SYNC`, but the documented standard sequence clears counters in RESET/SYNC. | `STRESS_MTS_062_hundred_single_packet_runs` | No RTL change was accepted. P062-P064 and P068-P070 now check per-run and final post-reset totals, while P066/P070 separately assert legacy direct-start accumulation. |
| A legacy direct `RUNNING` start was expected to clear counters like the standard sequence. | `STRESS_MTS_066_alternate_standard_and_legacy_starts` | No RTL change was accepted. The testcase now expects direct-start iterations to accumulate to two hits after the preceding standard run, proving the difference between canonical and backward-compatible bring-up. |
| An illegal multi-hot control word decoded to `ERROR`, after which `asi_ctrl_ready` stayed low forever and blocked later legal recovery commands. | `STRESS_MTS_070_interspersed_illegal_ctrl_words` | RTL now keeps `ERROR` observable but asserts control ready in that state so the next legal command can recover. The fixed RTL passed P070 and the current full 373-case rerun. |
| Dense terminate stress initially expected SOP only on the first global payload beat, but output SOP is generated by the first beat on each route lane. | `STRESS_MTS_072_terminate_after_dense_burst` | No RTL change was accepted. The case now expects SOP on the first payload per route lane and still requires normal/debug trace pairing plus close-marker evidence. |
| Overflow-window termination initially tried to stop after an overflow-corrected SOP-only payload, leaving the input packet open and preventing legal close markers. | `STRESS_MTS_079_terminate_near_overflow_window` | No RTL change was accepted. The stimulus now terminates after an overflow-corrected EOP hit, preserving overflow math checks before requiring terminal close markers. |
| Inert parameter termination initially opened an input packet on sideband channel 0 but placed the terminal EOP on sideband channel 31, leaving `packet_in_transaction` open and correctly suppressing close markers. | `STRESS_MTS_090_inert_parameter_sweep_compare` | No RTL change was accepted. P090 now opens and closes the same four enabled sideband lanes while preserving 64 payload math/debug trace checks, then requires four terminal close markers. Recorded as `BUG-013-H`. |
| Random soft-reset stress initially used a globally increasing reference timestamp index after CSR `soft_reset`, even though the DUT correctly restarts local timing and debug history. | `STRESS_MTS_096_random_soft_reset_pulses` | No RTL change was accepted. The randomized stress helper now uses phase-local timestamp epochs after each soft reset and still requires normal/debug trace pairing. |
| Random control-chatter stress initially assumed every direct RUNNING start reset the total counter like the canonical `RUN_PREPARE -> SYNC` sequence. | `STRESS_MTS_097_random_control_chatter` | No RTL change was accepted. The checker now models standard-start counter clears and direct-start counter carry separately, matching the documented bring-up compatibility contract. |
| Soft-reset smoke-loop checking enforced exact debug-stream counts before the passive debug monitors had been bounded-waited into the scoreboard. | `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` | No RTL change was accepted. P110 now waits for `debug_ts`, `debug_burst`, and `ts_delta` counts before exact per-iteration checks; recorded as `BUG-014-H`. |

## Submodule Freshness Check

The OPQ IP-core chain requested on 2026-05-09 was fetched again on
2026-05-10 with `--recurse-submodules`. The user-provided leading commits are
contained on the expected branches, while MTSP advances independently through
the current smoke-endurance PROF/STRESS DV checkpoint:

| Repository | Leading Commit | Branch |
|---|---|---|
| `packet_scheduler` | `245eb93` `[PATCH] Mirror OPQ handle CSR map in SVD` | `origin/codex/opq-feb-swb-debug-20260508` |
| `mu3e-ip-cores` | `c9ca241` `[PATCH] Advance packet scheduler SVD package pointer` | `codex/opq-feb-swb-parent-20260508`, `origin/codex/opq-feb-swb-parent-20260508` |
| `musip` | `d3f4c05` `[PATCH] Advance Mu3e IP cores OPQ SVD pointer` | `yifeng-ip_sim-2604`, `origin/yifeng-ip_sim-2604` |
| `mutrig_timestamp_processor` | local `master` with the P101-P110 smoke-endurance PROF/STRESS DV checkpoint | source for `origin/master` and parent/top pointer publication |

`/home/yifeng/packages/musip_2604/external` contains the parent chain:
`packet_scheduler 245eb93` plus the local MTSP smoke-endurance stress checkpoint.
The P101-P110 checkpoint is the source for the parent and top-level gitlink
commits.

## Evidence Commands

Focused B111-B130 regression:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<B111-B130 case_id> SEED=1
```

Result: `NEW_B111_B130_PASS`, then refreshed under the final full sweep.

Focused EDGE control-timing batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E001-E010 case_id> SEED=1
```

Result: `EDGE_E001_E010_BATCH_PASS count=10`. E001, E002, E004, E006,
E007, E009, and E010 each required at least one accepted payload plus a
normal/debug trace pair. E003 required one payload followed by exactly four
empty close markers. E005 required no accepted inputs or outputs after the
prepare-abort sequence. E008 required exactly four empty close markers and no
payload duplicates after repeated terminate commands.

Focused EDGE CSR/input-protocol batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E012-E017,E019-E030 case_id> SEED=1
```

Result: `EDGE_E012_E017_E019_E030_PASS`, then refreshed under the final full
sweep.

Focused EDGE overflow/bypass/latency batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E031-E040 case_id> SEED=1
```

Result: `EDGE_E031_E040_BATCH_PASS count=10`, then refreshed under the final
full sweep. E037 passed with 80 accepted inputs, 80 payloads, 80 debug traces,
and 80 normal/debug trace pairs. E039 passed with `inputs=2 beats=2 payloads=2
debug_ts=2 dual_path_pairs=2 traces=2`.

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

Focused EDGE reset/force-stop batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E081-E090 case_id> SEED=1
```

Result: all ten cases passed, then refreshed under the final full sweep.

Focused EDGE generic/configuration batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E091-E100 case_id> SEED=1
```

Result: all ten cases passed after reviewing and correcting the E094/E095
terminate-delay contract from `LPM_DIV_PIPELINE + 4` to the RTL-observable
`LPM_DIV_PIPELINE + 7`; refreshed under the final full sweep.

Focused EDGE ready/backpressure batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E101-E110 case_id> SEED=1
```

Result: all ten cases passed, then refreshed under the final full sweep. E105
reported 12 `MTSP_READY_X` monitor warnings and the scoreboard summary
`ready_x=12` while still proving one payload, one debug trace, and one
normal/debug trace pair.

Focused EDGE termination batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E111-E119 case_id> SEED=1
```

Result: all nine cases passed, then refreshed under the final full sweep. The
legacy EDGE text for E111-E119 was updated to the current explicit-upstream
`endofrun` close-marker contract.

Focused EDGE ready-X and upgrade-readiness batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E105,E120-E130 case_id> SEED=1
```

Result: `EDGE_E105_E120_E130_BATCH_PASS count=12`. E129 initially exposed a
test expectation overreach: the one-boundary requirement is exactly two late
payload EOPs plus four empty terminal close markers, not an all-lane SOP-mask
requirement when payload lanes already carried EOP. The assertion was narrowed
to the documented invariant and the full batch passed.

Focused counter rollover batch:

```bash
for case_id in STD_MTS_106_total_counter_hi_rollover CORNER_MTS_018_counter_read_on_low_word_rollover; do
  make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID="$case_id" SEED=1
done
```

Result: both cases passed after correcting the bring-up sequence to seed the
counter after `run_start()`. `STD_MTS_106` required one payload, one
normal/debug trace pair, and total count `0x0001_0000_0000`; `CORNER_MTS_018`
required the high-low-high snapshot to recover the same total.

Default-generic counter-write guard:

```bash
for case_id in STD_MTS_025_unsupported_write_addr3_inert STD_MTS_026_unsupported_write_addr4_inert; do
  make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID="$case_id" SEED=1
done
```

Result: both cases passed, proving CSR words 3 and 4 remain inert write targets
when `DV_COUNTER_SEED_ENABLE=0`.

Focused CSR mode-sampling batch:

```bash
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_057_toggle_derive_tot_between_hits SEED=1
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_058_toggle_delay_field_between_hits SEED=1
```

Result: the before RTL failed `CORNER_MTS_057` because the first accepted hit
was recomputed with the later ToT CSR setting and produced `ET_1N6=4` instead
of the sampled short-mode `ET_1N6=0`. The before RTL failed
`CORNER_MTS_058` because the first accepted hit inherited the later E-path
delay source and asserted the error sideband. After the RTL fix both cases pass
with two payloads, two debug traces, and two normal/debug trace pairs.

Focused bypass mode-sampling proof:

```bash
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_039_bypass_toggle_after_hit_accept SEED=1
```

Result: the before RTL failed because the first accepted bypass-on hit was
recomputed with the later bypass-off CSR setting and produced `TCC_8N/TCC_1N6 =
6555/2` instead of `2/0`. The after RTL passed with the first hit at `2/0`, the
second hit at `6555/2`, and two input-analysis-port hits plus two normal/debug
trace pairs.

Focused EDGE output-marker batch:

```bash
make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<E061-E070 case_id> SEED=1
```

Result: `EDGE_E061_E070_BATCH_PASS count=10`. `CORNER_MTS_069` and
`CORNER_MTS_070` were first reviewed for harness sequence sanity because the
initial stimulus left the input packet open; after correction, the batch passed
with payload marker checks, empty close-marker checks, and normal/debug trace
pairing where payloads exist.

Focused PROF/STRESS throughput and soak batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P001-P010 case_id> SEED=1
```

Result: `STRESS_P001_P010_BATCH_PASS count=10`. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1` and a required scoreboard analysis-port summary.
Representative summaries:
- P001 line-rate short mode: `inputs=64 beats=64 payloads=64 debug_ts=64
  debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`.
- P006 hiterr keep mode after the helper CSR-mask fix: `csr=7 inputs=128
  beats=128 payloads=128 debug_ts=128 debug_burst=128 ts_delta=128
  dual_path_pairs=128 traces=128`.
- P007 hiterr discard mode: `inputs=128 beats=112 payloads=112 debug_ts=112
  debug_burst=112 ts_delta=112 dual_path_pairs=112 traces=112`.
- P009 ready-low sustained output: `inputs=64 beats=64 payloads=64
  debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`.
- P010 flush after backlog: `inputs=33 beats=37 payloads=33 eops=4
  empty_eops=4 debug_ts=33 debug_burst=23 ts_delta=23 dual_path_pairs=33
  traces=33`.

Focused PROF/STRESS long-run mode batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P011-P020 case_id> SEED=1
```

Result: `STRESS_P011_P020_BATCH_PASS count=10`. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`, normal output monitoring, debug-path monitoring,
and a scoreboard analysis-port summary. Representative summaries:
- P011/P012/P014/P015 stable 256-hit mode runs: `inputs=256 beats=256
  payloads=256 debug_ts=256 debug_burst=256 ts_delta=256 dual_path_pairs=256
  traces=256`.
- P013 and P016 512-hit CSR-toggle runs: `inputs=512 beats=512 payloads=512
  debug_ts=512 debug_burst=512 ts_delta=512 dual_path_pairs=512 traces=512`.
- P017 and P018 bypass-off/on wrap-lookback runs: `inputs=64 beats=64
  payloads=64 debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64
  traces=64`. P018 intentionally expects the delay-error sideband high because
  bypass-on gray timestamps after the wrap wait produce `debug_delta=6610`
  against `expected_latency=2000`.
- P019 bypass toggled between four packets: `csr=10 inputs=32 beats=32
  payloads=32 debug_ts=32 debug_burst=32 ts_delta=32 dual_path_pairs=32
  traces=32`.
- P020 expected-latency rewrite phases: `csr=10 inputs=64 beats=64
  payloads=64 debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64
  traces=64 expected_latency=4096`. Trace metadata proves phases `1`, `4096`,
  `2`, and `4096`, with error high for phases `1` and `2` and low for the
  `4096` phases.

Focused PROF/STRESS high-variance input-pattern batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P021-P030 case_id> SEED=1
```

Result: `STRESS_P021_P030_BATCH_PASS count=10`. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`, input analysis-port monitoring, normal output
monitoring, debug-path monitoring, and a scoreboard summary. Representative
summaries:
- P021 balanced route-round-robin load: `inputs=128 beats=128 payloads=128
  debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128`.
- P022/P023 hot-spot route runs: `inputs=64 beats=64 payloads=64 debug_ts=64
  debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`.
- P024/P025 dense payload-channel and ASIC-ID sweeps: `inputs=128 beats=128
  payloads=128 debug_ts=128 debug_burst=128 ts_delta=128
  dual_path_pairs=128 traces=128`.
- P026/P027 packet-shape streams: `inputs=64 beats=64 payloads=64 debug_ts=64
  debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`.
- P028 periodic hiterr discard: `inputs=256 beats=240 payloads=240
  debug_ts=240 debug_burst=240 ts_delta=240 dual_path_pairs=240 traces=240`.
- P029 periodic hiterr keep mode: `csr=7 inputs=256 beats=256 payloads=256
  debug_ts=256 debug_burst=256 ts_delta=256 dual_path_pairs=256 traces=256`.
- P030 nonzero sideband mux bits: `inputs=64 beats=64 payloads=64
  debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`.

Focused PROF/STRESS counter/reset/control-poll batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P031-P040 case_id> SEED=1
```

Result: `STRESS_P031_P040_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case sweep. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1` and required scoreboard analysis-port summaries.
Representative summaries:
- P031 discard-counter monotonic all-hiterr run: `csr=14 inputs=1024 beats=0
  payloads=0 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0
  traces=0`.
- P032 total-counter monotonic 1k run: `csr=6 inputs=1024 beats=1024
  payloads=1024 debug_ts=1024 debug_burst=1024 ts_delta=1024
  dual_path_pairs=1024 traces=1024`.
- P033 mixed accept/reject counter soak: `csr=6 inputs=1024 beats=896
  payloads=896 debug_ts=896 debug_burst=896 ts_delta=896
  dual_path_pairs=896 traces=896`.
- P034 coherent high-low snapshot polling: `csr=54 inputs=512 beats=512
  payloads=512 debug_ts=512 debug_burst=512 ts_delta=512
  dual_path_pairs=512 traces=512`.
- P035 CSR soft-reset recovery: `csr=24 inputs=48 beats=48 payloads=48
  debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48 traces=48`.
- P036 global-reset recovery: `csr=21 inputs=48 beats=48 payloads=48
  debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48 traces=48`.
- P037/P038 repeated bring-up control sequences: each reports `csr=303` and
  zero accepted payload/debug traffic, proving control sequencing alone does
  not leak datapath output.
- P039 periodic force-stop pulse run: `csr=16 inputs=500 beats=495
  payloads=495 debug_ts=495 debug_burst=495 ts_delta=495
  dual_path_pairs=495 traces=495`.
- P040 CSR polling under load: `csr=54 inputs=256 beats=256 payloads=256
  debug_ts=256 debug_burst=256 ts_delta=256 dual_path_pairs=256 traces=256`.

Focused PROF/STRESS overflow-window batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P041-P050 case_id> SEED=1
```

Result: `STRESS_P041_P050_BATCH_PASS count=10`. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`, input analysis-port monitoring, normal output
monitoring, debug-path monitoring, and a scoreboard summary.
Representative summaries:
- P041/P042 single and repeated overflow runs: `csr=6 inputs=3 beats=3
  payloads=3 debug_ts=3 debug_burst=3 ts_delta=3 dual_path_pairs=3
  traces=3 expected_latency=2000`.
- P043/P044/P045 overflow threshold and mixed T/E eligibility cases:
  `csr=6 inputs=4 beats=4 payloads=4 debug_ts=4 debug_burst=4 ts_delta=4
  dual_path_pairs=4 traces=4 expected_latency=2000`.
- P046/P047 bypass-off/on overflow soaks: `csr=6 inputs=16 beats=16
  payloads=16 debug_ts=16 debug_burst=16 ts_delta=16 dual_path_pairs=16
  traces=16 expected_latency=2000`.
- P048 small-latency overflow: `csr=7 inputs=4 beats=4 payloads=4 debug_ts=4
  debug_burst=4 ts_delta=4 dual_path_pairs=4 traces=4 expected_latency=1`.
- P049 large-latency overflow: `csr=7 inputs=4 beats=4 payloads=4 debug_ts=4
  debug_burst=4 ts_delta=4 dual_path_pairs=4 traces=4
  expected_latency=65535`.
- P050 dense divider-launch overflow run: `csr=6 inputs=96 beats=96
  payloads=96 debug_ts=96 debug_burst=96 ts_delta=96 dual_path_pairs=96
  traces=96 expected_latency=2000`.

Focused PROF/STRESS debug-stream stress batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P051-P060 case_id> SEED=1
```

Result: `STRESS_P051_P060_BATCH_PASS count=10`. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`, input analysis-port monitoring, normal output
monitoring, debug-path monitoring, trace metadata checks, and a scoreboard
summary. Representative summaries:
- P051 debug timestamp every hit: `csr=6 inputs=128 beats=128 payloads=128
  debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128
  expected_latency=2000`.
- P052/P053 sustained warm-up debug streams: `csr=6 inputs=160 beats=160
  payloads=160 debug_ts=160 debug_burst=160 ts_delta=160
  dual_path_pairs=160 traces=160 expected_latency=2000`.
- P054/P055 dense alternating/equal timestamp streams: `csr=6 inputs=64
  beats=64 payloads=64 debug_ts=64 debug_burst=64 ts_delta=64
  dual_path_pairs=64 traces=64 expected_latency=2000`.
- P056/P057 T/E error-pipeline stress: `csr=7 inputs=96 beats=96
  payloads=96 debug_ts=96 debug_burst=96 ts_delta=96 dual_path_pairs=96
  traces=96 expected_latency=512`.
- P058 expected-latency edge distribution: `csr=7 inputs=72 beats=72
  payloads=72 debug_ts=72 debug_burst=72 ts_delta=72 dual_path_pairs=72
  traces=72 expected_latency=16`.
- P059 debug through flushing: `csr=6 inputs=40 beats=44 payloads=40 eops=4
  empty_eops=4 debug_ts=40 debug_burst=32 ts_delta=32 dual_path_pairs=40
  traces=40 expected_latency=2000`.
- P060 repeated RUNNING cleanup: `csr=18 inputs=32 beats=32 payloads=32
  debug_ts=32 debug_burst=32 ts_delta=32 dual_path_pairs=32 traces=32
  expected_latency=2000`.

Focused PROF/STRESS repeated run-control batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P061-P070 case_id> SEED=1
```

Result: `STRESS_P061_P070_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case rerun. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`; payload-bearing cases require input
analysis-port observations, normal output monitoring, debug-path monitoring,
trace metadata checks, and scoreboard summaries. Representative summaries:
- P061 empty standard runs: `csr=500 inputs=0 beats=400 payloads=0 eops=400
  empty_eops=400 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0
  traces=0 expected_latency=2000`.
- P062 single-packet repeated standard runs: `csr=504 inputs=100 beats=500
  payloads=100 eops=400 empty_eops=400 debug_ts=100 debug_burst=100
  ts_delta=100 dual_path_pairs=100 traces=100 expected_latency=2000`.
- P063 multi-channel repeated standard runs: `csr=504 inputs=400 beats=800
  payloads=400 eops=400 empty_eops=400 debug_ts=400 debug_burst=400
  ts_delta=400 dual_path_pairs=400 traces=400 expected_latency=2000`.
- P064 stop cycles with output ready low: `csr=504 inputs=100 beats=500
  payloads=100 eops=400 empty_eops=400 debug_ts=100 debug_burst=100
  ts_delta=100 dual_path_pairs=100 traces=100 expected_latency=2000`.
- P065 running abort cycles: `csr=303 inputs=0 beats=0 payloads=0 eops=0
  empty_eops=0 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0
  traces=0 expected_latency=2000`.
- P066 alternate standard/direct starts: `csr=504 inputs=100 beats=500
  payloads=100 eops=400 empty_eops=400 debug_ts=100 debug_burst=100
  ts_delta=100 dual_path_pairs=100 traces=100 expected_latency=2000`.
- P067 IDLE-only CSR rewrites: `csr=227 inputs=0 beats=0 payloads=0 eops=0
  empty_eops=0 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0
  traces=0 expected_latency=63`.
- P068 prepare-phase CSR rewrites: `csr=259 inputs=32 beats=160 payloads=32
  eops=128 empty_eops=128 debug_ts=32 debug_burst=32 ts_delta=32
  dual_path_pairs=32 traces=32 expected_latency=95`.
- P069 flushing-phase CSR rewrites: `csr=228 inputs=32 beats=160 payloads=32
  eops=128 empty_eops=128 debug_ts=32 debug_burst=32 ts_delta=32
  dual_path_pairs=32 traces=32 expected_latency=159`.
- P070 illegal control chatter: `csr=292 inputs=48 beats=240 payloads=48
  eops=192 empty_eops=192 debug_ts=48 debug_burst=48 ts_delta=48
  dual_path_pairs=48 traces=48 expected_latency=2000`.

Focused PROF/STRESS termination/drain batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P071-P080 case_id> SEED=1
```

Result: `STRESS_P071_P080_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case rerun. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`; payload-bearing cases require input
analysis-port observations, normal output monitoring, debug-path monitoring,
trace metadata checks, close-marker checks, and scoreboard summaries.
Representative summaries:
- P071 terminate after one packet: `csr=6 inputs=1 beats=5 payloads=1 eops=4
  empty_eops=4 debug_ts=1 debug_burst=1 ts_delta=1 dual_path_pairs=1
  traces=1 expected_latency=2000`.
- P072 dense burst then terminate: `csr=6 inputs=32 beats=36 payloads=32
  eops=4 empty_eops=4 debug_ts=32 debug_burst=32 ts_delta=32
  dual_path_pairs=32 traces=32 expected_latency=2000`.
- P073 final-input-EOP terminate: `csr=6 inputs=8 beats=12 payloads=8 eops=4
  empty_eops=4 debug_ts=8 debug_burst=8 ts_delta=8 dual_path_pairs=8
  traces=8 expected_latency=2000`.
- P074 late flushing EOP: `csr=6 inputs=4 beats=8 payloads=4 eops=4
  empty_eops=4 debug_ts=4 debug_burst=0 ts_delta=0 dual_path_pairs=4
  traces=4 expected_latency=2000`.
- P075 terminate without payload EOP then idle: `csr=5 inputs=0 beats=4
  payloads=0 eops=4 empty_eops=4 debug_ts=0 debug_burst=0 ts_delta=0
  dual_path_pairs=0 traces=0 expected_latency=2000`.
- P076 multiple late EOPs: `csr=6 inputs=4 beats=8 payloads=4 eops=4
  empty_eops=4 debug_ts=4 debug_burst=0 ts_delta=0 dual_path_pairs=4
  traces=4 expected_latency=2000`.
- P077 terminate with sink ready low: `csr=6 inputs=4 beats=8 payloads=4
  eops=4 empty_eops=4 debug_ts=4 debug_burst=0 ts_delta=0
  dual_path_pairs=4 traces=4 expected_latency=2000`.
- P078 per-enabled-channel termination: `csr=21 inputs=4 beats=20
  payloads=4 eops=16 empty_eops=16 debug_ts=4 debug_burst=4 ts_delta=4
  dual_path_pairs=4 traces=4 expected_latency=2000`.
- P079 overflow-window termination: `csr=6 inputs=1 beats=5 payloads=1
  eops=4 empty_eops=4 debug_ts=1 debug_burst=1 ts_delta=1
  dual_path_pairs=1 traces=1 expected_latency=2000`.
- P080 CSR polling during termination: `csr=86 inputs=16 beats=20
  payloads=16 eops=4 empty_eops=4 debug_ts=16 debug_burst=16 ts_delta=16
  dual_path_pairs=16 traces=16 expected_latency=2000`.

Focused PROF/STRESS parameter-sweep batch:

```bash
make -C tb/uvm -s run_after TEST=mtsp_doc_case_test CASE_ID=<P081-P090 case_id> SEED=1
```

Result: `STRESS_P081_P090_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case rerun. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`; payload-bearing cases require input
analysis-port observations, normal output monitoring, debug-path monitoring,
trace metadata checks, and scoreboard summaries.
Representative summaries:
- P081 divider pipeline 2 under load: latency checker
  `latency_samples=96 min_cycles=8 max_cycles=8`; scoreboard `csr=6
  inputs=96 beats=96 payloads=96 eops=0 empty_eops=0 debug_ts=96
  debug_burst=96 ts_delta=96 dual_path_pairs=96 traces=96
  expected_latency=2000`.
- P082 divider pipeline 4 under load: latency checker
  `latency_samples=96 min_cycles=10 max_cycles=10`; scoreboard `csr=6
  inputs=96 beats=96 payloads=96 eops=0 empty_eops=0 debug_ts=96
  debug_burst=96 ts_delta=96 dual_path_pairs=96 traces=96
  expected_latency=2000`.
- P083 single enabled-channel soak: `csr=6 inputs=128 beats=128
  payloads=128 eops=0 empty_eops=0 debug_ts=128 debug_burst=128
  ts_delta=128 dual_path_pairs=128 traces=128 expected_latency=2000`.
- P084 two enabled-channel soak: `csr=6 inputs=128 beats=128 payloads=128
  eops=0 empty_eops=0 debug_ts=128 debug_burst=128 ts_delta=128
  dual_path_pairs=128 traces=128 expected_latency=2000`.
- P085 four enabled-channel soak: `csr=6 inputs=256 beats=256 payloads=256
  eops=0 empty_eops=0 debug_ts=256 debug_burst=256 ts_delta=256
  dual_path_pairs=256 traces=256 expected_latency=2000`.
- P086 remapped hiterr soak: `csr=5 inputs=128 beats=112 payloads=112
  eops=0 empty_eops=0 debug_ts=112 debug_burst=112 ts_delta=112
  dual_path_pairs=112 traces=112 expected_latency=2000`.
- P087 custom default latency soak: `csr=7 inputs=64 beats=64 payloads=64
  eops=0 empty_eops=0 debug_ts=64 debug_burst=64 ts_delta=64
  dual_path_pairs=64 traces=64 expected_latency=128`.
- P088 DEBUG=0 soak: `csr=6 inputs=128 beats=128 payloads=128 eops=0
  empty_eops=0 debug_ts=128 debug_burst=128 ts_delta=128
  dual_path_pairs=128 traces=128 expected_latency=2000`.
- P089 BANK=DOWN compare: `csr=6 inputs=128 beats=128 payloads=128
  eops=0 empty_eops=0 debug_ts=128 debug_burst=128 ts_delta=128
  dual_path_pairs=128 traces=128 expected_latency=2000`.
- P090 inert parameter sweep compare: `csr=5 inputs=64 beats=68
  payloads=64 eops=4 empty_eops=4 debug_ts=64 debug_burst=64 ts_delta=64
  dual_path_pairs=64 traces=64 expected_latency=2000`.

Focused PROF/STRESS randomized entropy/control-noise batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<P091-P100 case_id> SEED=1
```

Result: `STRESS_P091_P100_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case rerun. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`; payload-bearing cases require input
analysis-port observations, normal output monitoring, debug-path monitoring,
trace metadata checks, and scoreboard summaries. Representative summaries:
- P091 random marker mix: `csr=6 inputs=96 beats=96 payloads=96 eops=0
  empty_eops=0 debug_ts=96 debug_burst=96 ts_delta=96 dual_path_pairs=96
  traces=96 expected_latency=2000`.
- P092 random accept/reject mix: `csr=22 inputs=128 beats=97 payloads=97
  eops=0 empty_eops=0 debug_ts=97 debug_burst=97 ts_delta=97
  dual_path_pairs=97 traces=97 expected_latency=2000`.
- P093 random delay-path mix: `csr=55 inputs=48 beats=48 payloads=48 eops=0
  empty_eops=0 debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48
  traces=48 expected_latency=512`.
- P094 random ToT-mode mix: `csr=86 inputs=80 beats=80 payloads=80 eops=0
  empty_eops=0 debug_ts=80 debug_burst=80 ts_delta=80 dual_path_pairs=80
  traces=80 expected_latency=2000`.
- P095 random force-stop pulses: `csr=34 inputs=96 beats=82 payloads=82
  eops=0 empty_eops=0 debug_ts=82 debug_burst=82 ts_delta=82
  dual_path_pairs=82 traces=82 expected_latency=2000`.
- P096 random soft-reset pulses: `csr=43 inputs=46 beats=46 payloads=46
  eops=0 empty_eops=0 debug_ts=46 debug_burst=46 ts_delta=46
  dual_path_pairs=46 traces=46 expected_latency=2000`.
- P097 random control chatter: `csr=196 inputs=32 beats=160 payloads=32
  eops=128 empty_eops=128 debug_ts=32 debug_burst=32 ts_delta=32
  dual_path_pairs=32 traces=32 expected_latency=2000`.
- P098 random ASIC IDs and P099 random payload channels: each reports
  `csr=6 inputs=192 beats=192 payloads=192 eops=0 empty_eops=0
  debug_ts=192 debug_burst=192 ts_delta=192 dual_path_pairs=192 traces=192
  expected_latency=2000`.
- P100 random expected-latency rewrites: `csr=14 inputs=64 beats=64
  payloads=64 eops=0 empty_eops=0 debug_ts=64 debug_burst=64 ts_delta=64
  dual_path_pairs=64 traces=64 expected_latency=3`.

Focused PROF/STRESS legacy smoke-vector endurance batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<P101-P110 case_id> SEED=1
```

Result: `STRESS_P101_P110_BATCH_PASS count=10`, then refreshed under the
final current-source 373-case rerun. Every case ran with
`MTSP_DEBUG_PATH_REQUIRED=1`; payload-bearing cases require input
analysis-port observations, normal output monitoring, debug-path monitoring,
trace metadata checks, and scoreboard summaries. Representative summaries:
- P101 positive smoke-vector replay: latency checker
  `latency_samples=1000 min_cycles=10 max_cycles=10`; scoreboard `csr=6
  inputs=1000 beats=1000 payloads=1000 eops=0 empty_eops=0
  debug_ts=1000 debug_burst=1000 ts_delta=1000 dual_path_pairs=1000
  traces=1000 expected_latency=2000`.
- P102 EFlag-zero smoke-vector replay: latency checker
  `latency_samples=1000 min_cycles=10 max_cycles=10`; scoreboard `csr=6
  inputs=1000 beats=1000 payloads=1000 eops=0 empty_eops=0
  debug_ts=1000 debug_burst=1000 ts_delta=1000 dual_path_pairs=1000
  traces=1000 expected_latency=2000`.
- P103 clamp/saturation smoke-vector replay: latency checker
  `latency_samples=2000 min_cycles=10 max_cycles=10`; scoreboard `csr=6
  inputs=2000 beats=2000 payloads=2000 eops=0 empty_eops=0
  debug_ts=2000 debug_burst=2000 ts_delta=2000 dual_path_pairs=2000
  traces=2000 expected_latency=2000`.
- P104/P105 standard-sequence and ready-low smoke checks: each reports
  `csr=6 inputs=4 beats=4 payloads=4 eops=0 empty_eops=0 debug_ts=4
  debug_burst=4 ts_delta=4 dual_path_pairs=4 traces=4
  expected_latency=2000` with 10-cycle payload latency.
- P106 divider pipeline 2 smoke check: latency checker
  `latency_samples=4 min_cycles=8 max_cycles=8`; scoreboard `csr=6
  inputs=4 beats=4 payloads=4 debug_ts=4 debug_burst=4 ts_delta=4
  dual_path_pairs=4 traces=4 expected_latency=2000`.
- P107/P108/P109 divider pipeline 4, bypass-on, and E-delay smoke checks:
  each reports four payload/debug/trace pairs and 10-cycle payload latency.
- P110 soft-reset-between-runs smoke check: 32 reset phases pass with
  per-phase latency `min_cycles=10 max_cycles=10`; final scoreboard `csr=259
  inputs=128 beats=128 payloads=128 eops=0 empty_eops=0 debug_ts=128
  debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128
  expected_latency=2000`.

RTL before/after bug proof:

```bash
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=STD_MTS_129_upgrade_case_idle_after_boundary_only SEED=1
```

Result: before RTL fails at 220 ns with `IDLE command must not be accepted
before close markers complete`; after RTL passes with
`beats=4 payloads=0 eops=4 empty_eops=4`.

Final explicit-case sweep:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1
```

Result: `FULL373_PASS cases=373 elapsed=659s` on the final current RTL source
after the smoke-endurance stress additions. The per-case artifact audit reports
`ARTIFACT_AUDIT cases=373 missing_logs=0 bad_or_incomplete_logs=0
missing_ucdb=0 ucdbs=374`. The explicit list has no missing UCDBs; the extra
UCDB in the directory is outside the audited dispatcher list.

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

`cov_report_total` writes `tb/uvm/cov_after/merged.txt` by merging every UCDB
in `cov_after`; this directory currently also contains one stale non-dispatch
`COMBO_MTSP_001_terminate_contract_test_s1.ucdb` file, so the accepted audit
coverage was recomputed from the explicit dispatcher list only:

```bash
/data1/questaone_sim/questasim/bin/vcover merge /tmp/mtsp_explicit_373.ucdb <373 dispatcher UCDBs>
/data1/questaone_sim/questasim/bin/vcover report -details -code bcesft /tmp/mtsp_explicit_373.ucdb
```

The merge used QuestaSim-64 `vcover` 2026.1_1 to match the UCDB generation
version; the older Quartus-bundled 2022.4 `vcover` rejected the files as newer
UCDBs. Filtered instance coverage summary: `71.70%`. The DUT instance summary is
statement `97.04%`, branch `95.49%`, condition `83.92%`, expression `100.00%`,
FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.82%`.
The merge log was checked for source mismatch and reported none; the only
reported warning was the local missing `vcovkill` helper.

Artifact check:

```text
ARTIFACT_AUDIT cases=373 missing_logs=0 bad_or_incomplete_logs=0 missing_ucdb=0 ucdbs=374
```

Additional checks through this PROF/STRESS smoke-endurance stress batch:

```bash
git diff --check -- BUG_HISTORY.md tb/uvm/Makefile tb/uvm/mtsp_cases.svh tb/REPORT/DV_EXECUTION_AUDIT.md
python3 /home/yifeng/.codex/skills/rtl-doc-style/scripts/rtl_doc_style_check.py .
python3 /home/yifeng/.codex/skills/dv-workflow/scripts/bug_history_format_check.py BUG_HISTORY.md
python3 /home/yifeng/.codex/skills/dv-workflow/scripts/dv_bucket_format_check.py tb
```

Results:
- `git diff --check -- BUG_HISTORY.md tb/uvm/Makefile tb/uvm/mtsp_cases.svh tb/REPORT/DV_EXECUTION_AUDIT.md`:
  pass.
- `rtl_doc_style_check.py .`: fail on the legacy `tb/` documentation layout,
  including missing `tb/README.md`, `tb/DV_REPORT.json`, and canonical
  companion/header/footer sections. This batch updated the execution audit but
  did not migrate the whole documentation tree.
- `bug_history_format_check.py BUG_HISTORY.md`: pass.
- `dv_bucket_format_check.py tb`: fail on 76 legacy bucket-format errors across
  `tb/DV_BASIC.md`, `tb/DV_EDGE.md`, `tb/DV_PROF.md`, and `tb/DV_ERROR.md`
  because those files still use the older bullet-list layout instead of the
  canonical table/header format. Recent batches corrected specific stale EDGE
  timing plus PROF termination/drain text inside the legacy bucket files, and
  this audit now records the smoke-endurance stress evidence separately.
- No RTL source changed in the P101-P110 batch. The last RTL-changing batch
  remains covered by the passing static screen transcript
  `/tmp/mtsp_static_p061_p070/questa_static_screen.log`.

Current evidenced explicit cases are the 373 handlers in
`tb/uvm/mtsp_cases.svh`. Each has a matching
`tb/uvm/logs/*_after_s1.log` and `tb/uvm/cov_after/*_s1.ucdb` artifact.

## Open Work

DV closure is not complete. The remaining work is to implement real stimuli for
the remaining 148 uncovered cases (20 PROF/STRESS and 128 ERROR/NEG), then
regenerate the ordered coverage/report dashboard from current artifacts instead
of relying on stale proxy rows. EDGE is now fully dispatched and evidenced;
PROF has 110 evidenced stress handlers.
