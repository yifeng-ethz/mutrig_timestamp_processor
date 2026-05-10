# DV Execution Audit - mutrig_timestamp_processor

Date: 2026-05-10, refreshed through 2026-05-10 16:01 CEST

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
entropy/control-noise batch, the PROF/STRESS legacy smoke-vector endurance
batch, the PROF/STRESS post-upgrade drain/ready/boundary signoff batch, the
initial ERROR/NEG illegal-control/protocol batch, and the ERROR/NEG CSR-misuse
batch, the ERROR/NEG input-error batch, the ERROR/NEG
ready/handshake/protocol-source batch, the ERROR/NEG timestamp/window fault
batch, the ERROR/NEG ToT/ET fault batch, and the ERROR/NEG
marker/boundary fault batch, the ERROR/NEG reset/recovery fault batch, the
ERROR/NEG generic/build fault batch, the ERROR/NEG debug-stream fault batch,
and the ERROR/NEG counter-coherency/status batch.
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
The X031-X040 refresh stopped on a stale X038 plan expectation, reviewed the
run-control ready equation in RTL, and accepted the current stateful ready
contract only after the UVM and `DV_ERROR.md` wording were corrected. No RTL
fault was accepted in the X031-X040 batch.
The X041-X050 refresh reused calibrated timestamp/window and payload-field
reference helpers as explicit ERROR/NEG handlers, then passed focused and full
ordered sweeps without any new math, delay, route, or TFine mismatch.
The X051-X060 refresh reused ToT, EFlag, sampled-mode, and legacy smoke-vector
reference helpers as explicit ERROR/NEG handlers, then passed focused and full
ordered sweeps without any new ET, clamp, or sampled-control mismatch.
The X061-X070 refresh brought marker, terminal-boundary, active-state, and
packet-tracker reset checks into the ERROR/NEG bucket. X063 initially exposed a
plan/harness context mismatch, so the RTL was reviewed before acceptance:
output route markers are keyed by decoded route lane, while open-packet
tracking is keyed by enabled input sideband. No RTL fault was accepted.
The X071-X080 refresh added hard-reset, soft-reset, force-stop recovery,
reset-flow advancement, and legacy direct-start compatibility checks. X076
required a plan wording correction after RTL review: held `force_stop` attempts
are counted and discarded without payload output, which is the delivered
contract already covered by the existing force-stop cases.
The X081-X090 refresh added generic/build negative evidence for divider
pipeline depth, error-bit remapping, default latency, debug/report-only
parameters, inert packaged generics, and enabled-channel window guards. X089 and
X090 split the evidence intentionally: invalid or out-of-range channel windows
are rejected by direct `_hw.tcl` validation checks, while legal boundary-window
UVM companion runs provide log, UCDB, and normal/debug scoreboard continuity.
No RTL bug was accepted in this batch.
The X091-X100 refresh added debug-stream fault evidence for ghost debug traffic,
stale debug data, first-hit history warm-up, `debug_burst` and `ts_delta`
alignment, sign agreement, arrival-delta source math, extreme negative
sign-magnitude conversion, delay-source switching, and idle/reset debug
quiescence. X097 initially stopped on a reference expectation mismatch; RTL
review showed `DELTA_TIMESTAMP_WIDTH=12` and `debug_burst` exports the trimmed
high slice, so the stimulus was corrected to drive `-2044` before accepting
evidence. No RTL bug was accepted in this batch.
The X101-X110 refresh added counter and status fault evidence for clean-hit
discard stability, hiterr reject accounting, no-valid quiescence, high/low
counter snapshot coherency, soft-reset and sync counter clears, running-status
readback, and packed control readback. X105 initially stopped before the
rollover math check because the new NEG wrapper did not inherit the
`DV_COUNTER_SEED_ENABLE` generic used by the standard/corner rollover aliases;
the Makefile now maps X105 to that DV-only generic, and no RTL bug was
accepted.
The X111-X130 refresh completed the ERROR/NEG termination and upgrade-contract
section. X118 stopped on a real RTL liveness bug before evidence was accepted:
an open input packet could hold terminal close markers off forever after
upstream end-of-run. `BUG-015-R` fixes that busy predicate, and the rerun
requires terminal boundary, ready recovery, payload/debug trace pairing, and
static-screen evidence. X126 retains its future no-fresh-accept name but now
explicitly records current delivered RTL behavior: fresh `FLUSHING` payloads
are accepted and the normal/debug trace classifies one clean payload plus one
delay-error-marked payload with no math mismatch.

## Current Coverage Of Documented Cases

| Bucket | Documented Cases | Explicit UVM Handlers | Current Log + UCDB Evidence |
|---|---:|---:|---:|
| BASIC | 130 | 130 | 130 |
| EDGE | 131 | 131 | 131 |
| PROF | 130 | 130 | 130 |
| ERROR | 130 | 130 | 130 |
| Total | 521 | 521 | 521 |

Notes:
- Unimplemented `mtsp_doc_case_test` case IDs fail with
  `No explicit UVM stimulus handler`.
- The old generic smoke fallback is no longer counted as evidence.
- `DV_EDGE.md` currently contains a duplicate short ID `E127`; this remains an
  audit finding.
- `DV_PROF.md` has explicit UVM handlers for P001 through P130.
- `DV_ERROR.md` has explicit UVM handlers for X001 through X130.
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
| An illegal multi-hot control word decoded to `ERROR`, after which `asi_ctrl_ready` stayed low forever and blocked later legal recovery commands. | `STRESS_MTS_070_interspersed_illegal_ctrl_words` | RTL now keeps `ERROR` observable but asserts control ready in that state so the next legal command can recover. The fixed RTL passed P070 and the current explicit artifact set. |
| Dense terminate stress initially expected SOP only on the first global payload beat, but output SOP is generated by the first beat on each route lane. | `STRESS_MTS_072_terminate_after_dense_burst` | No RTL change was accepted. The case now expects SOP on the first payload per route lane and still requires normal/debug trace pairing plus close-marker evidence. |
| Overflow-window termination initially tried to stop after an overflow-corrected SOP-only payload, leaving the input packet open and preventing legal close markers. | `STRESS_MTS_079_terminate_near_overflow_window` | No RTL change was accepted. The stimulus now terminates after an overflow-corrected EOP hit, preserving overflow math checks before requiring terminal close markers. |
| Inert parameter termination initially opened an input packet on sideband channel 0 but placed the terminal EOP on sideband channel 31, leaving `packet_in_transaction` open and correctly suppressing close markers. | `STRESS_MTS_090_inert_parameter_sweep_compare` | No RTL change was accepted. P090 now opens and closes the same four enabled sideband lanes while preserving 64 payload math/debug trace checks, then requires four terminal close markers. Recorded as `BUG-013-H`. |
| Random soft-reset stress initially used a globally increasing reference timestamp index after CSR `soft_reset`, even though the DUT correctly restarts local timing and debug history. | `STRESS_MTS_096_random_soft_reset_pulses` | No RTL change was accepted. The randomized stress helper now uses phase-local timestamp epochs after each soft reset and still requires normal/debug trace pairing. |
| Random control-chatter stress initially assumed every direct RUNNING start reset the total counter like the canonical `RUN_PREPARE -> SYNC` sequence. | `STRESS_MTS_097_random_control_chatter` | No RTL change was accepted. The checker now models standard-start counter clears and direct-start counter carry separately, matching the documented bring-up compatibility contract. |
| Soft-reset smoke-loop checking enforced exact debug-stream counts before the passive debug monitors had been bounded-waited into the scoreboard. | `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` | No RTL change was accepted. P110 now waits for `debug_ts`, `debug_burst`, and `ts_delta` counts before exact per-iteration checks; recorded as `BUG-014-H`. |
| `DV_ERROR.md` X038 still described the older expectation that `ctrl_ready` would not deassert during prepare/sync/flush. | `NEG_MTS_038_ctrl_driver_assumes_stateful_ready` | No RTL change was accepted. RTL review showed `ctrl_ready_comb` is already stateful for `RUN_PREPARE`, `SYNC`, and `TERMINATING`, so the plan and testcase now require ready-low and bounded ready-restore evidence before legal recovery traffic is accepted. |
| `DV_ERROR.md` X063 described "no SOP" for a disabled input channel and the first NEG wrapper reused a CORNER helper whose disabled sideband depended on a Makefile generic override. | `NEG_MTS_063_sop_on_disabled_channel` | No RTL change was accepted. RTL review showed route-lane SOP is generated from decoded output route, while input packet tracking only records enabled sideband lanes. X063 now drives default-window-disabled sideband 5, requires the route-lane SOP and normal/debug trace pair, then proves termination emits one close-marker train because disabled input bookkeeping did not hold a packet open. |
| `DV_ERROR.md` X076 described force-stop as allowing no accepted hits, but delivered RTL counts ready-valid attempts and discards them while `force_stop` blocks payload output. | `NEG_MTS_076_force_stop_stuck_high` | No RTL change was accepted. The case now holds `force_stop`, drives four attempts, requires `beats=0` and `payloads=0`, and records the expected discard behavior. The plan text now distinguishes input-side attempts from emitted payloads. |
| Invalid enabled-channel window configurations cannot also produce normal pass UCDB artifacts. | `NEG_MTS_089_invalid_enabled_window_compile_guard`, `NEG_MTS_090_out_of_range_enabled_values` | No RTL change was accepted. The package validation callback is checked directly by `hw_tcl_validate_check`, and legal boundary-window UVM companion cases still require log, UCDB, and normal/debug scoreboard evidence. |
| Initial X097 debug-burst expectation used too small a negative delta for the 12-bit trim check. | `NEG_MTS_097_signmag_conversion_extreme_negative` | No RTL change was accepted. RTL review showed `DELTA_TIMESTAMP_WIDTH=12` and `aso_debug_burst_data(15 downto 8)` takes bits `[11:4]`, so the stimulus now drives `-2044`, requires trimmed high byte `0xff`, and still checks exact `ts_delta=-2044`. |
| X105 NEG wrapper initially lacked the DV-only counter seed generic used by the rollover alias. | `NEG_MTS_105_hi_lo_counter_snapshot_incoherent` | No RTL change was accepted. The Makefile maps X105 to `DV_COUNTER_SEED_ENABLE=1`, matching the STD/CORNER rollover cases; focused X101-X110 and full 501-case sweeps pass. |
| An open input packet could keep terminal close markers blocked forever after upstream end-of-run. | `NEG_MTS_118_missing_boundary_with_packet_open` | RTL fix `BUG-015-R` removes stale open-packet bookkeeping from the terminal-marker busy predicate after upstream `endofrun`, while still waiting for real pipeline work to drain. Focused X111-X130, the full 521-case sweep, and the hard Questa static screen pass. |

## Submodule Freshness Check

The OPQ IP-core chain requested on 2026-05-09 was fetched again on
2026-05-10. The user-provided leading commits are contained on the expected
branches. The parent and top branches are already ahead of those OPQ commits at
the prior MTSP checkpoints, and this batch advances MTSP independently through
the current termination/upgrade ERROR/NEG checkpoint:

| Repository | Leading Commit | Branch |
|---|---|---|
| `packet_scheduler` | `245eb93` `[PATCH] Mirror OPQ handle CSR map in SVD` | `origin/codex/opq-feb-swb-debug-20260508` |
| `mu3e-ip-cores` | `c9ca241` `[PATCH] Advance packet scheduler SVD package pointer` | contained by `codex/opq-feb-swb-parent-20260508`; current head before this batch `584023e` |
| `musip` | `d3f4c05` `[PATCH] Advance Mu3e IP cores OPQ SVD pointer` | contained by `yifeng-ip_sim-2604`; current head before this batch `9f262a7` |
| `mutrig_timestamp_processor` | local `master` with the X111-X130 termination/upgrade ERROR/NEG checkpoint | source for `origin/master` and parent/top pointer publication |

`/home/yifeng/packages/musip_2604/external` contains the parent chain:
`packet_scheduler 245eb93` plus the local MTSP ERROR/NEG checkpoints. The
X111-X130 checkpoint is the source for the next parent and top-level gitlink
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
final current-source 383-case sweep. Every case ran with
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
final current-source 383-case rerun. Every case ran with
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
final current-source 383-case rerun. Every case ran with
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
final current-source 383-case rerun. Every case ran with
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
final current-source 383-case rerun. Every case ran with
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
final current-source 383-case rerun. Every case ran with
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

Focused PROF/STRESS sink-ready equivalence batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<P111-P120 case_id> SEED=1
```

Result: `FOCUSED_P111_P120_PASS count=10`, then refreshed under the final
current-source 383-case rerun. The harness now samples ordinary sink `ready`
on every normal output observation, in addition to the existing ready-X,
normal-output, debug, and paired trace analysis ports. The new cases enforce:
- P111/P112 ready-high and ready-low baselines: each reports `csr=6 inputs=64
  beats=64 payloads=64 eops=0 empty_eops=0 debug_ts=64 debug_burst=64
  ts_delta=64 ready_x=0 dual_path_pairs=64 traces=64` and 10-cycle latency.
- P113 toggle 1010: same 64-payload normal/debug counts, with sampled ready
  evidence `high=32 low=32`.
- P114 SOP-ready-low window: same 64-payload normal/debug counts, with at
  least one SOP output sampled while ready was low.
- P115 EOP-ready-low termination: `csr=6 inputs=8 beats=12 payloads=8 eops=4
  empty_eops=4 debug_ts=8 debug_burst=8 ts_delta=8 ready_x=0
  dual_path_pairs=8 traces=8`, with the four close EOP markers sampled
  ready-low.
- P116 dense burst ready-low: `csr=6 inputs=128 beats=128 payloads=128
  debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128`
  and all 128 normal outputs sampled ready-low.
- P117 ready-low in `FLUSHING`: `csr=6 inputs=8 beats=12 payloads=8 eops=4
  empty_eops=4 debug_ts=8 debug_burst=0 ts_delta=0 ready_x=0
  dual_path_pairs=8 traces=8`. This matches the documented RTL contract:
  `debug_ts` pairs with flushing payloads, while `debug_burst` and `ts_delta`
  are RUNNING-only.
- P118 random ready toggle: `csr=6 inputs=128 beats=128 payloads=128
  debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128`,
  with sampled ready evidence `high=64 low=64`.
- P119 ready-low across reset: `csr=6 inputs=64 beats=64 payloads=64
  debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`,
  with ready held low through reset and all outputs sampled low.
- P120 equivalence summary: four phases compare ready-high, ready-low,
  toggle, and random sink patterns. The case requires exact equality for
  normal output fields, paired normal/debug trace metadata, `debug_ts`,
  `debug_burst`, and `ts_delta`; final scoreboard is `csr=24 inputs=128
  beats=128 payloads=128 eops=0 empty_eops=0 debug_ts=128 debug_burst=128
  ts_delta=128 ready_x=0 dual_path_pairs=128 traces=128`.

Focused PROF/STRESS post-upgrade drain/ready/boundary signoff batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<P121-P130 case_id> SEED=1
```

Result: `FOCUSED_P121_P130_PASS count=10`. This batch adds explicit metric
cases for terminate ready-low occupancy, drain latency, enabled-window drain
latency, boundary forwarding rates, no-real-EOP synthetic boundaries,
duplicate-boundary suppression, ready-statefulness throughput cost, and a
mixed signoff soak. Key evidence:
- P121 ready occupancy: 16 samples, ready-low min/max `5/8` cycles, 64 close
  markers, no payload/debug drift.
- P122 drain histogram: 32 samples, latency min/max `6/13` cycles,
  `inputs=118 beats=246 payloads=118 eops=128 empty_eops=128 debug_ts=118
  debug_burst=0 ts_delta=0 dual_path_pairs=118 traces=118`.
- P123 drain-by-div-pipeline metric: 16 samples on the current configured
  pipeline, latency min/max `6/13` cycles, `inputs=57 beats=121 payloads=57
  eops=64 empty_eops=64 debug_ts=57 dual_path_pairs=57 traces=57`.
- P124 enabled-window metric: lane windows 1, 2, and 4 observed
  `latency_cycles=13` with beat deltas 5, 6, and 8 respectively, and final
  scoreboard `inputs=7 beats=19 payloads=7 eops=12 empty_eops=12
  debug_ts=7 dual_path_pairs=7 traces=7`.
- P125 boundary forwarding rate: 1000 stop samples, forwarding rate
  `10000/10000`, `inputs=1000 beats=5000 payloads=1000 eops=4000
  empty_eops=4000 debug_ts=1000 dual_path_pairs=1000 traces=1000`.
- P126/P129 no-real-EOP synthetic boundary: 64 and 128 samples respectively,
  missing-boundary rate `0`, no payload/debug drift, and exactly four empty
  close markers per stop.
- P127 duplicate-boundary suppression: 64 samples with two late EOP payloads
  per stop, extra-boundary rate `0`, `debug_ts=128 debug_burst=0 ts_delta=0
  dual_path_pairs=128 traces=128`.
- P128 ready-statefulness cost: two 128-hit line-rate phases, zero measured
  throughput cost, `inputs=256 beats=260 payloads=256 eops=4 empty_eops=4
  debug_ts=256 debug_burst=256 ts_delta=256 dual_path_pairs=256 traces=256`.
- P130 mixed signoff soak includes overflow smoke, ready-toggle smoke,
  drain histogram, synthetic-boundary, duplicate-boundary, and ready-cost
  phases; final scoreboard `inputs=120 beats=236 payloads=120 eops=116
  empty_eops=116 debug_ts=120 debug_burst=83 ts_delta=83
  dual_path_pairs=120 traces=120`.

Focused ERROR/NEG illegal-control/protocol batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X001-X010 case_id> SEED=1
```

Result: `FOCUSED_NEG001_NEG010_PASS count=10`, followed by a full current-source
`FULL_EXPLICIT_403_PASS cases=403 elapsed=704s`. Key evidence:
- X001/X002 all-zero and multi-hot control words drive `run_state_cmd_code=9`
  (`ERROR`), do not enter a silent legal state, then recover through legal
  control and emit one payload with paired normal/debug trace evidence.
- X003 injects the illegal multi-hot word while already running; CSR running
  status remains set, legal traffic still drains, and the recovery trace reports
  `debug_delta=25` with `math_error=0`.
- X004 injects illegal control while `FLUSHING` holds control ready low; the
  command is intentionally ignored (`run_state_cmd_code=4`, `TERMINATING`),
  the retained payload decodes to `tcc8n=0`, `tcc1n6=1`, `et=0`, and four empty
  close markers drain before ready returns.
- X005/X006 force source-side control misuse through UVM HDL paths: data changes
  while valid is held high, and X/Z data is injected. Both cases observe the
  forced misuse, reset cleanly, and report no normal/debug output activity.
- X007 documents direct `RUNNING` as supported but nonstandard; X008 proves
  `TERMINATING` from `IDLE` emits no fake boundary; X009 contains `LINK_TEST`
  during `RUNNING` and still emits a sane paired trace; X010 regresses the
  former always-ready control gap and requires terminate ready to wait for the
  close-marker drain.

Mismatch reviews in this batch:
- Direct VPI reads of the VHDL enum `run_state_cmd` reported `0` even when the
  decoder source showed `when others => ERROR`; RTL now exposes
  `run_state_cmd_code` and `processor_state_code` as numeric debug mirrors for
  deterministic DV checkpointing.
- The initial X004 expectation incorrectly required `ERROR` while ready was
  low; the corrected contract proves ready-gated ignore during `FLUSHING`.
- The X004 retained-payload expectation was corrected to the same raw timestamp
  decode used by the smoke vectors; this was a reference-model tuple mismatch,
  not an RTL datapath fault.

Focused ERROR/NEG CSR-misuse batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X011-X020 case_id> SEED=1
```

Result: `FOCUSED_NEG011_NEG020_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_413_PASS cases=413 elapsed=726s`. Key evidence:
- X011 drives simultaneous CSR read/write through the normal CSR driver path.
  The CSR monitor publishes `fault_kind=read_write_same_cycle`; the scoreboard
  requires `csr_protocol_faults=1 csr_rw_faults=1`, and RTL write priority
  updates `expected_latency` to `321`.
- X012/X013 prove unsupported CSR address 5 writes are inert and unsupported
  address 6 reads return zero; both are backed by CSR analysis-port counts.
- X014 reuses the reserved-opmode hit path and reports one paired normal/debug
  trace with `debug_delta=12`, `math_error=0`, and no payload error.
- X015 asserts global reset while forcing an `expected_latency` write, then
  idles the forced SV interface variables under reset before release. The
  reviewed RTL reset branch dominates, and the post-reset readback is `2000`.
- X016 and X017 abuse back-to-back `soft_reset` and rapid `force_stop` toggles
  during traffic; both recover and emit paired normal/debug trace evidence.
- X018 intentionally samples CSR read data before `waitrequest` completion. The
  bad driver reports through an analysis port and the scoreboard requires
  `csr_protocol_faults=1 csr_waitrequest_sample_faults=1`.
- X019 reads counters immediately across a reset transition and requires zeroed
  total/discard state. X020 writes `expected_latency=0xffffffff` and proves the
  huge-latency model with paired trace math and `math_error=0`.

Mismatch review in this batch:
- X015 initially failed with post-reset `expected_latency=9999`. Reviewing
  `proc_avmm_csr` showed the RTL reset branch was correct; the failure came
  from forced SV interface variables retaining the forced write value until the
  idle driver next updated them. The stimulus now drives an idle CSR cycle under
  reset before releasing the force, and no RTL bug was accepted.

Focused ERROR/NEG input-error batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X022-X027,X029-X030 case_id> SEED=1
```

Result: `FOCUSED_NEG022_NEG030_PASS count=8`, followed by a full
current-harness `FULL_EXPLICIT_421_PASS cases=421 elapsed=739s`. Key evidence:
- X022 disables hiterr discard and proves a hiterr beat still propagates with
  paired normal/debug trace evidence.
- X023/X024 drive only `CRCERR_BIT_LOC` and only `FRAME_CORRPT_BIT_LOC` in
  `RUNNING`; both are accepted, report one paired trace, and leave discard
  count at zero.
- X025 drives CRCERR+frame-corrupt without hiterr and then all error bits with
  hiterr. Only the hiterr-containing beat is rejected while discard is enabled;
  the same all-error beat propagates once discard is disabled.
- X026/X027 drive valid input while `IDLE` and `RESET/SYNC` hold input ready
  low; hit0 monitor counts remain unchanged and no output/debug samples appear.
- X029 starts a packet without matching EOP, aborts to `IDLE`, restarts, and
  proves the stale open-packet state does not create a later terminal payload.
- X030 drives an outside-enabled-window sideband and proves payload/trace
  correctness plus close-marker drain behavior.

No RTL or harness bug was accepted in this batch. The direct X023-X025 checks
were added to bind the negative plan text to RUNNING-state hit-error behavior
instead of relying only on existing edge aliases.

Focused ERROR/NEG ready/handshake/protocol-source batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X031-X040 case_id> SEED=1
```

Result: `FOCUSED_NEG031_NEG040_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_431_PASS cases=431 elapsed=756s`. Key evidence:
- X031/X032 drive `valid` while hit0 `ready=0` in IDLE and RESET/SYNC. The
  hit0 monitor reports the rejected source attempt through `fault_ap`; the
  scoreboard requires `hit0_ready_low_rejects` to increment and proves no
  accepted input, output payload, EOP, or debug trace was created.
- X033 drops `valid` before ready is restored. The monitor reports
  `valid_drop_before_ready` on the hit0 fault analysis path, and the scoreboard
  requires both the aggregate protocol-fault and valid-drop counters to move.
- X034/X035 hold downstream hit1 `ready=0` during payload and terminal
  close-marker emission. These cases document the current RTL behavior that
  downstream ready is sampled by the monitor but not used to throttle output;
  normal/debug trace-pair evidence is still required for payload traffic.
- X036 reuses the ready-X monitor trap, requiring the ready analysis port and
  scoreboard summary to expose X/Z sink misuse during a real transfer.
- X037 uses a deliberate bad CSR sequence that changes address/data while
  `waitrequest=1`. The CSR driver reports `bus_change_waitrequest` through the
  protocol analysis path and the scoreboard requires
  `csr_bus_change_faults=1`.
- X038 was reviewed against the RTL ready equation after the original stale
  plan wording failed. The accepted testcase now proves ready-low and bounded
  ready-restore for `RUN_PREPARE`, `SYNC`, and `TERMINATING`, then sends legal
  recovery traffic and terminal close markers.
- X039 forces a hit-source payload change while `valid=1` and `ready=0`. The
  hit0 fault analysis path reports `payload_change_before_ready`, and the
  scoreboard requires no payload/debug output from the bad source attempt.
- X040 asserts `ctrl_valid` on the reset edge and reuses the reset/handshake
  overlap evidence from the EDGE reset case.

Representative scoreboard summaries:

```text
NEG_MTS_031: hit0_ready_low_rejects=1 hit0_protocol_faults=1 hit0_valid_drop_faults=1
NEG_MTS_037: csr_protocol_faults=1 csr_bus_change_faults=1
NEG_MTS_039: hit0_ready_low_rejects=15 hit0_protocol_faults=14 hit0_payload_change_faults=14
```

No RTL bug was accepted in this batch. The X038 mismatch was a stale
verification-plan statement, not a delivered RTL failure, so no new
`BUG_HISTORY.md` entry was added.

Focused ERROR/NEG timestamp/window batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X041-X050 case_id> SEED=1
```

Result: `FOCUSED_NEG041_NEG050_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_441_PASS cases=441 elapsed=773s`. Key evidence:
- X041/X042/X043/X044 use the calibrated debug-delay helper to hit
  `debug_delta=-1`, `0`, `expected_latency`, and `expected_latency+1`. Each
  case requires normal/debug trace agreement and `hit_type1.error=1`.
- X045 writes `expected_latency=0` and proves a minimally delayed hit faults
  under the degenerate window.
- X046 toggles `bypass_lapse` after one hit is accepted, requiring the first hit
  to keep its sampled bypass-on math and the second hit to use the new
  bypass-off mode, with two paired normal/debug traces.
- X047 reuses the one-above-padding-upper overflow edge and requires exact
  corrected quotient/remainder math.
- X048 drives the divide remainder-four case and checks the packed quotient and
  remainder fields.
- X049 crosses route 0 to route 1 at the quotient boundary and checks sideband
  route agreement with payload/debug trace metadata.
- X050 checks TFine pass-through on a real payload with one normal/debug trace.

Representative timestamp/window summaries:

```text
NEG_MTS_041: debug_delta=-1 expected_latency=4 error=1 traces=3
NEG_MTS_043: debug_delta=4 expected_latency=4 error=1 traces=3
NEG_MTS_046: inputs=2 beats=2 dual_path_pairs=2 traces=2
NEG_MTS_049: route0/route1 boundary produced two paired traces
NEG_MTS_050: inputs=1 beats=1 dual_path_pairs=1 traces=1
```

No RTL or harness bug was accepted in this batch. The cases are explicit NEG
dispatch aliases to existing calibrated reference-model helpers, so the ERROR
bucket now carries its own log and UCDB evidence for these math traps.

Focused ERROR/NEG ToT/ET batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X051-X060 case_id> SEED=1
```

Result: `FOCUSED_NEG051_NEG060_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_451_PASS cases=451 elapsed=787s`. Key evidence:
- X051/X052 prove ET remains zero in short mode and in ToT mode when `EFlag=0`,
  even when the source fields could otherwise imply a nonzero ET.
- X053 requires the smallest positive ToT delta to produce ET=1.
- X054 requires a delta beyond the 9-bit ET range to saturate at 511.
- X055 requires the agreed negative-delta clamp behavior.
- X056/X057 toggle `derive_tot` and the delay-field selector after one accepted
  hit. The scoreboard requires each accepted hit to use its sampled mode, with
  two paired normal/debug traces.
- X058 alternates `EFlag` values in ToT mode and requires ET behavior to follow
  the per-hit flag.
- X059/X060 replay the checked-in legacy positive and clamp/saturation vectors
  through explicit NEG case IDs.

Representative ToT/ET summaries:

```text
NEG_MTS_051: inputs=1 beats=1 dual_path_pairs=1 traces=1 ET=0
NEG_MTS_054: inputs=1 beats=1 dual_path_pairs=1 traces=1 ET=511
NEG_MTS_056: inputs=2 beats=2 dual_path_pairs=2 traces=2 sampled derive_tot
NEG_MTS_057: inputs=2 beats=2 dual_path_pairs=2 traces=2 sampled delay field
NEG_MTS_060: inputs=2 beats=2 dual_path_pairs=2 traces=2 clamp/saturation vector
```

No RTL or harness bug was accepted in this batch. The cases are explicit NEG
dispatch aliases to existing ToT and smoke-vector reference helpers, so the
ERROR bucket now carries its own log and UCDB evidence for these ET traps.

Focused ERROR/NEG marker/boundary batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X061-X070 case_id> SEED=1
```

Result: `FOCUSED_NEG061_NEG070_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_461_PASS cases=461 elapsed=799s`. Key evidence:
- X061/X062 require first-route SOP emission and no repeated SOP on the same
  route lane, with normal/debug trace pairs on every payload.
- X063 drives input sideband 5 under the default enabled window 0..3. RTL review
  confirmed route-lane SOP is independent of the input enabled-window tracker;
  the case requires one payload, one paired trace, and one four-lane terminal
  close-marker train after upstream `endofrun`.
- X064 proves a nonterminating input EOP stays local and does not leak an output
  EOP.
- X065/X068 require exactly one terminal close-marker train for the stop
  contract and reject missing or duplicate boundary markers.
- X066 proves the current synthetic close-marker path can operate without a
  payload-valid alignment dependency.
- X067 checks payload beats keep `empty=0`; terminal empty markers remain
  covered by the boundary cases.
- X069 intentionally injects ready-low source misuse before valid RUNNING and
  FLUSHING payloads, and requires the hit0 fault analysis path plus paired
  payload/debug traces.
- X070 opens input packet bookkeeping, resets, and then proves no stale
  packet-tracker state blocks recovery.

Representative marker/boundary summaries:

```text
NEG_MTS_061: inputs=1 beats=1 payloads=1 dual_path_pairs=1 traces=1
NEG_MTS_063: inputs=1 beats=5 payloads=1 eops=4 empty_eops=4 dual_path_pairs=1 traces=1
NEG_MTS_066: inputs=0 beats=4 payloads=0 eops=4 empty_eops=4 traces=0
NEG_MTS_069: hit0_protocol_faults=2 hit0_valid_drop_faults=2 beats=2 dual_path_pairs=2 traces=2
NEG_MTS_070: csr=5 inputs=1 beats=0 stale packet tracker cleared by reset
```

No RTL bug was accepted in this batch. The pre-acceptance X063 mismatch was
resolved by reviewing `proc_payload2avst`: output SOP follows the route lane,
while `packet_in_transaction` only tracks enabled input sidebands. The
documented X063 wording and new NEG wrapper now match that contract, so no
`BUG_HISTORY.md` entry was added.

Focused ERROR/NEG reset/recovery batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X071-X080 case_id> SEED=1
```

Result: `FOCUSED_NEG071_NEG080_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_471_PASS cases=471 elapsed=820s`. Key evidence:
- X071 accepts one hit, asserts global reset while the hit is still in flight,
  requires no payload/debug trace from the flushed hit, then proves recovery
  with one paired normal/debug trace.
- X072 builds debug history, asserts global reset, and requires the first
  post-reset hit to restart the debug-delta stream from zero-history semantics.
- X073 pulses CSR `soft_reset` in `RUNNING`, requires counters and local state
  to clear, then proves a post-reset payload/debug pair can still flow.
- X074 enters `FLUSHING`, pulses CSR `soft_reset`, checks no phantom EOP before
  explicit upstream `endofrun`, then requires the legal four-lane close-marker
  train.
- X075 opens and aborts a packet with `IDLE`, then re-enters the standard start
  path and proves no stale packet bookkeeping corrupts terminal markers.
- X076 holds `force_stop` high across four input attempts and requires zero
  emitted payloads while the attempts are counted and discarded.
- X077 clears `force_stop` and requires immediate payload/debug recovery.
- X078/X079 prove reset-flow advancement by accepting a checked payload after
  the standard `RUN_PREPARE -> SYNC -> RUNNING` path.
- X080 preserves the documented legacy direct `RUNNING` start compatibility
  with one checked payload/debug pair.

Representative reset/recovery summaries:

```text
NEG_MTS_071: inputs=2 beats=1 payloads=1 dual_path_pairs=1 traces=1
NEG_MTS_072: inputs=3 beats=3 debug_ts=3 debug_burst=3 ts_delta=3 traces=3
NEG_MTS_074: inputs=0 beats=4 payloads=0 eops=4 empty_eops=4 traces=0
NEG_MTS_076: inputs=4 beats=0 payloads=0 eops=0 empty_eops=0 traces=0
NEG_MTS_080: inputs=1 beats=1 dual_path_pairs=1 traces=1
```

No RTL bug was accepted in this batch. The only wording correction was X076:
`force_stop` blocks payload output while ready-valid attempts are counted and
discarded, matching existing STD/CORNER force-stop evidence.

Focused ERROR/NEG generic/build batch:

```bash
make -C tb/uvm -s hw_tcl_validate_check
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X081-X090 case_id> SEED=1
```

Results: `HW_TCL_VALIDATE_CHECK_PASS cases=3` and
`FOCUSED_NEG081_NEG090_PASS count=10`, followed by a full current-harness
`FULL_EXPLICIT_481_PASS cases=481 elapsed=865s`. Key evidence:
- X081 compiles with `LPM_DIV_PIPELINE=2` and proves the stressed divider path
  still matches the reference timestamp and delay-error math.
- X082 remaps `HITERR_BIT_LOC=2` and proves discard behavior follows the
  configured bit rather than a hard-coded legacy location.
- X083 compiles with `MUTRIG_BUFFER_EXPECTED_LATENCY_8N=128`, requires CSR
  reset metadata to report `expected_latency=128`, and preserves payload/debug
  pairing.
- X084 and X085 prove `DEBUG=0` and `BANK=DOWN` do not change functional
  payload, debug sideband, or trace-pair evidence.
- X086 through X088 prove today that `PADDING_EOP_WAIT_CYCLE`, `CRCERR_BIT_LOC`,
  and `FRAME_CORRPT_BIT_LOC` are inert for functional behavior except where
  explicitly documented.
- X089 and X090 check invalid channel-window package guards with the direct
  `_hw.tcl` validation callback, then run legal boundary-window UVM companions
  so each documented ID still has log, UCDB, and normal/debug scoreboard
  artifacts.

Representative generic/build summaries:

```text
NEG_MTS_081: inputs=96 beats=96 payloads=96 debug_ts=96 debug_burst=96 ts_delta=96 dual_path_pairs=96 traces=96 expected_latency=2000
NEG_MTS_082: inputs=128 beats=112 payloads=112 debug_ts=112 debug_burst=112 ts_delta=112 dual_path_pairs=112 traces=112
NEG_MTS_083: inputs=64 beats=64 payloads=64 debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64 expected_latency=128
NEG_MTS_084: inputs=128 beats=128 payloads=128 debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128
NEG_MTS_086: inputs=0 beats=4 payloads=0 eops=4 empty_eops=4 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0 traces=0
NEG_MTS_089: inputs=3 beats=11 payloads=3 eops=8 empty_eops=8 debug_ts=3 debug_burst=2 ts_delta=2 dual_path_pairs=3 traces=3
NEG_MTS_090: inputs=3 beats=11 payloads=3 eops=8 empty_eops=8 debug_ts=3 debug_burst=2 ts_delta=2 dual_path_pairs=3 traces=3
```

No RTL bug was accepted in this batch. The invalid-window evidence is
package-level validation evidence by design; the UVM companions use valid
generic windows so the normal/debug scoreboard can still produce highest-level
runtime artifacts for the documented case IDs.

Focused ERROR/NEG debug-stream fault batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X091-X100 case_id> SEED=1
```

Result: `FOCUSED_NEG091_NEG100_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_491_PASS cases=491 elapsed=879s`. Every case ran
with `MTSP_DEBUG_PATH_REQUIRED=1`, input and normal-output monitoring,
debug-path monitoring, paired trace metadata, and scoreboard analysis-port
summaries.
Key evidence:
- X091 rejects an unprocessed IDLE hit while holding `debug_ts` and trace
  counts steady, then recovers with one processed payload and one paired trace:
  `hit0_ready_low_rejects=1 hit0_protocol_faults=1 inputs=1 beats=1
  debug_ts=1 dual_path_pairs=1 traces=1`.
- X092 proves `debug_ts` data is not stale across exact deltas 3 and 5:
  `inputs=6 beats=6 payloads=6 debug_ts=6 debug_burst=5 ts_delta=5
  dual_path_pairs=6 traces=6`.
- X093 proves first-hit history warm-up still reports one payload, one
  `debug_ts`, one `debug_burst`, one `ts_delta`, and one paired trace.
- X094 aligns `debug_burst` and `ts_delta` observations by timestamp for the
  same two processed hits: `inputs=2 beats=2 debug_ts=2 debug_burst=2
  ts_delta=2 dual_path_pairs=2 traces=2`.
- X095 checks sign agreement between `debug_burst` trimmed timestamp high byte
  and `ts_delta` polarity for positive and negative timestamp pairs:
  `inputs=4 beats=4 payloads=4 debug_burst=4 ts_delta=4`.
- X096 reuses the GTS arrival-delta reference and requires the normal/debug
  trace pair to agree with the lower-byte arrival delta source.
- X097 drives the corrected extreme-negative timestamp delta `-2044`, requires
  `debug_burst` timestamp high byte `0xff`, and requires exact
  `ts_delta=-2044`.
- X098 reuses the T/E delay-source switching reference and requires the debug
  metadata to follow the selected delay source: `csr=6 inputs=2 beats=2
  debug_ts=2 debug_burst=1 ts_delta=1 dual_path_pairs=2 traces=2`.
- X099 and X100 require debug outputs to remain quiescent in IDLE and across
  global reset while preserving the accepted pre-reset debug history counts.

Mismatch review in this batch:
- The first X097 attempt used `-508` and expected `debug_burst` high byte
  `0xff`; the run stopped with `got 0x9f`. RTL review found the correct
  contract: `DELTA_TIMESTAMP_WIDTH=12`, `debug_burst` exports
  `delta_timestamp(delta_timestamp'high downto delta_timestamp'high-7)`, and
  `ts_delta` exports the full sign-magnitude conversion. The stimulus now uses
  `-2044`, which exercises trimmed high byte `0xff`, while still checking exact
  `ts_delta=-2044`. This was a pre-acceptance reference-stimulus correction,
  not an RTL bug.

Focused ERROR/NEG counter-coherency/status batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X101-X110 case_id> SEED=1
```

Result: `FOCUSED_NEG101_NEG110_PASS count=10`, followed by a full
current-harness `FULL_EXPLICIT_501_PASS cases=501 elapsed=884s`. Every case ran
with `MTSP_DEBUG_PATH_REQUIRED=1`, input and normal-output monitoring,
debug-path monitoring, paired trace metadata, and scoreboard analysis-port
summaries.
Key evidence:
- X101 proves a clean accepted hit increments total count without moving the
  discard counter: `csr=5 inputs=1 beats=1 payloads=1 debug_ts=1
  debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`.
- X102 rejects one hiterr beat, keeps output quiet, increments discard, then
  recovers with one checked payload: `csr=6 inputs=2 beats=1 payloads=1
  debug_ts=1 debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`.
- X103 requires hiterr rejects to increment total count and the clean recovery
  hit to advance total to two: `csr=7 inputs=2 beats=1 payloads=1 debug_ts=1
  debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`.
- X104 holds valid low for 32 RUNNING cycles and requires total, discard,
  output, debug, and trace counts to remain fixed before clean recovery:
  `csr=7 inputs=1 beats=1 payloads=1 debug_ts=1 debug_burst=1 ts_delta=1
  dual_path_pairs=1 traces=1`.
- X105 aliases the high-low-high rollover snapshot case with the DV-only
  counter seed generic enabled: `csr=11 inputs=1 beats=1 payloads=1
  debug_ts=1 debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`.
- X106/X107 prove CSR `soft_reset` and the legal `IDLE -> RUN_PREPARE -> SYNC`
  sequence clear total/discard counters after a real payload/debug trace pair.
- X108/X109 prove running-status readback low outside RUNNING and high inside
  RUNNING while still carrying one paired payload/debug trace.
- X110 proves packed control readback masks, soft-reset self-clear/default
  restoration, discard_hiterr clear/restore, and recovery traffic. Its single
  post-control payload produces one paired normal/debug trace; `debug_burst`
  and `ts_delta` remain zero because there is no second timestamp delta sample:
  `csr=10 inputs=1 beats=1 payloads=1 debug_ts=1 debug_burst=0 ts_delta=0
  dual_path_pairs=1 traces=1`.

Mismatch review in this batch:
- X105 initially failed at seed readback because the new NEG case ID did not
  inherit `DV_COUNTER_SEED_ENABLE=1`. The failure was reviewed against the
  existing counter-seed rollover cases and the RTL counter read path; the
  Makefile now maps X105 to the same DV-only generic as `STD_MTS_106` and
  `CORNER_MTS_018`. No RTL bug was accepted, and the focused X101-X110 batch
  plus the full 501-case sweep pass after the harness build-selection fix.

Focused ERROR/NEG termination and upgrade-contract batch:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<X111-X130 case_id> SEED=1
```

Results:
- `FOCUSED_NEG111_NEG120_PASS count=10`
- `FOCUSED_NEG121_NEG130_PASS count=10`
- current-harness `FULL_EXPLICIT_521_PASS cases=521 elapsed=914s`

Key evidence:
- X111 proves upstream end-of-run without a real input EOP still produces the
  four terminal close markers: `csr=5 inputs=0 beats=4 payloads=0 eops=4
  empty_eops=4 debug_ts=0 dual_path_pairs=0 traces=0`.
- X114 proves a packet opened before `TERMINATING` and closed in `FLUSHING`
  keeps both payloads, emits one four-lane close-marker train, and reports two
  paired normal/debug traces.
- X117 and X126 record the delivered current behavior for fresh `FLUSHING`
  payloads: two accepted payloads, two dual-path traces, first trace clean,
  second trace delay-error-marked with `math_error=1 hit_error=1`, and no
  `MTSP_DELAY_MATH` mismatch.
- X118 is the `BUG-015-R` regression. Before the RTL fix it timed out waiting
  for `empty_eop_count=4`; after the fix it passes with `csr=5 inputs=1
  beats=5 payloads=1 eops=4 empty_eops=4 debug_ts=1 debug_burst=1 ts_delta=1
  dual_path_pairs=1 traces=1`.
- X121-X125 and X127-X130 preserve the stateful-ready, synthetic-boundary,
  exact-boundary, idle-after-boundary, completion-handshake, and mixed-soak
  upgrade contracts as passing regression gates.

Mismatch review in this batch:
- X118 exposed a real RTL liveness bug. Reviewing `mts_processor.vhd` showed
  that `packet_in_transaction` contributed to the terminal-marker busy
  predicate even after upstream `endofrun`; with a packet left open, no legal
  later beat could clear the bookkeeping, so close markers and control-ready
  recovery were permanently blocked. The RTL now ignores stale open-packet
  bookkeeping only after upstream `endofrun`, while still waiting for actual
  accepted-hit pipeline work to drain.
- X126 and the mixed-soak X130 logs include intentional delay-error-marked
  payloads. The scoreboard recomputes delay math from the debug timestamp and
  raises `MTSP_DELAY_MATH` on disagreement; these runs had `UVM_ERROR: 0`, and
  the X126 helper now asserts the expected clean/error classification
  explicitly.

RTL before/after bug proof:

```bash
make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=STD_MTS_129_upgrade_case_idle_after_boundary_only SEED=1
```

Result: before RTL fails at 220 ns with `IDLE command must not be accepted
before close markers complete`; after RTL passes with
`beats=4 payloads=0 eops=4 empty_eops=4`.

Latest full explicit-case sweep and current artifact set:

```bash
make -C tb/uvm -s run TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1
```

Result: `FULL_EXPLICIT_521_PASS cases=521 elapsed=914s` on the final current
UVM harness after the termination/upgrade-contract dispatcher bring-up. The per-case artifact
audit now reports
`ARTIFACT_AUDIT cases=521 missing_logs=0
bad_or_incomplete_logs=0 missing_ucdb=0`.

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
/data1/questaone_sim/questasim/bin/vcover merge /tmp/mtsp_explicit_521.ucdb <521 dispatcher UCDBs>
/data1/questaone_sim/questasim/bin/vcover report -details -code bcesft /tmp/mtsp_explicit_521.ucdb
```

The merge used QuestaSim-64 `vcover` 2026.1_1 to match the UCDB generation
version; the older Quartus-bundled 2022.4 `vcover` rejected the files as newer
UCDBs. Filtered instance coverage summary: `71.66%`. The DUT instance summary is
statement `97.61%`, branch `95.36%`, condition `84.95%`, expression `100.00%`,
FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.93%`.
The merge log was checked for source mismatch and reported none; the only
reported warning was the local missing `vcovkill` helper.

Artifact check:

```text
ARTIFACT_AUDIT cases=521 missing_logs=0 bad_or_incomplete_logs=0 missing_ucdb=0
```

Additional checks through this ERROR/NEG termination/upgrade batch:

```bash
git diff --check
python3 /home/yifeng/.codex/skills/rtl-writing/scripts/rtl_style_check.py mts_processor.vhd
python3 /home/yifeng/.codex/skills/rtl-linter-and-checker/scripts/questa_static_screen.py --top mts_processor --filelist syn/quartus/mts_processor_static.f --work-dir /tmp/mtsp_static_neg111_neg130 mts_processor.vhd
/home/yifeng/.codex/skills/ip-packaging/scripts/lint_csr_header.py mts_processor_hw.tcl
make -C tb/uvm -s hw_tcl_validate_check
python3 /home/yifeng/.codex/skills/rtl-doc-style/scripts/rtl_doc_style_check.py .
python3 /home/yifeng/.codex/skills/dv-workflow/scripts/bug_history_format_check.py BUG_HISTORY.md
python3 /home/yifeng/.codex/skills/dv-workflow/scripts/dv_bucket_format_check.py tb
```

Results:
- `git diff --check`: pass.
- `rtl_style_check.py mts_processor.vhd`: fail on the legacy VHDL style
  baseline with 968 existing tab/naming/alignment issues. The current functional
  fix intentionally did not combine with a whole-file style migration.
- `questa_static_screen.py`: pass at
  `/tmp/mtsp_static_neg111_neg130/questa_static_screen.log`, with lint
  `Error (0)`, CDC `Violations (0)`, and RDC `Violation (0)`.
- `lint_csr_header.py mts_processor_hw.tcl`: fail on the existing legacy
  identity-header profile: HDL parameter flags, display hints, and META header
  text are not yet migrated to the current common-header convention. This patch
  only bumps the compatible IP version surfaces from `26.0.12.0510` to
  `26.0.13.0510`.
- `make -C tb/uvm -s hw_tcl_validate_check`: pass with
  `HW_TCL_VALIDATE_CHECK_PASS cases=3`.
- `rtl_doc_style_check.py .`: fail on the legacy `tb/` documentation layout,
  including missing `tb/README.md`, `tb/DV_REPORT.json`, and canonical
  companion/header/footer sections. This batch updated the execution audit but
  did not migrate the whole documentation tree.
- `bug_history_format_check.py BUG_HISTORY.md`: pass.
- `dv_bucket_format_check.py tb`: fail on 76 legacy bucket-format errors across
  `tb/DV_BASIC.md`, `tb/DV_EDGE.md`, `tb/DV_PROF.md`, and `tb/DV_ERROR.md`
  because those files still use the older bullet-list layout instead of the
  canonical table/header format. Recent batches corrected specific stale EDGE
  timing, PROF termination/drain, initial ERROR/NEG control text, CSR misuse
  text, input-error text, X038 ready-handshake wording, and X076 force-stop
  wording inside the legacy bucket files, and this audit now records the
  sink-ready, drain/ready/boundary, illegal-control, CSR-misuse, input-error,
  ready/handshake, timestamp/window, ToT/ET, marker/boundary,
  reset/recovery, generic/build, debug-stream, and counter/status fault
  evidence separately.
- RTL changed in this batch to fix `BUG-015-R`, and `BUG_HISTORY.md` records
  the open-packet terminal-boundary failure and repair. The first ERROR/NEG
  batch also exposed numeric run-control and processor-state debug mirrors for
  deterministic DV checkpointing. The P117 debug-burst/ts-delta check, the
  P121-P130 packet-close timing assumptions, the X001-X010 control
  expectations, the X011-X020 CSR
  misuse expectations, the X022-X030 input-error expectations, the
  X031-X040 ready/handshake expectations, the X041-X050 timestamp/window
  expectations, the X051-X060 ToT/ET expectations, the X061-X070
  marker/boundary expectations, the X071-X080 reset/recovery expectations, the
  X081-X090 generic/build expectations, the X091-X100 debug-stream
  expectations, and the X101-X110 counter/status expectations were aligned to
  the existing RTL
  contract after reviewing normal/debug, hit0 fault, ready,
  terminal-boundary, reset, force-stop, package-validation, debug-burst
  timestamp slicing, counter seed generic selection, and CSR
  analysis-port evidence. The current RTL static screen was rerun after
  `BUG-015-R` and passed.

Current evidenced explicit cases are the 521 handlers in
`tb/uvm/mtsp_cases.svh`. Each has a matching
`tb/uvm/logs/*_after_s1.log` and `tb/uvm/cov_after/*_s1.ucdb` artifact.

## Open Work

All documented BASIC, EDGE, PROF, and ERROR cases now have explicit UVM
handlers and current log/UCDB artifacts. DV closure is still not complete until
the generator-owned `tb/DV_REPORT.md`, `tb/DV_COV.md`, and any dashboard JSON
are regenerated from the 521-case artifact set and the remaining legacy bucket
format issues are migrated or explicitly waived.
