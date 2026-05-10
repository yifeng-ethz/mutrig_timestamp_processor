# BUG_HISTORY.md - mutrig_timestamp_processor DV bug ledger

Class legend:
- `R` = RTL / DUT bug
- `H` = harness / testcase / reporting bug

Severity legend:
- `soft error` = the bad packet/data flushes through the stream and does not leave the later datapath stuck
- `hard stuck error` = the bug poisons later packet handling and typically needs a functional reset / fresh restart to recover
- `non-datapath-refactor` = observability, reporting, harness, or naming/accounting consistency work with no direct packet-contract effect

Encounterability legend:
- practical severity is `severity x encounterability`, so the index must say how likely a reader is to hit the bug in normal use rather than only when it first appeared in one simulation log
- nominal datapath operation = legal traffic, about `50%` link load, iid per-lane behavior, and no forced error injection or artificially pathological stalls
- nominal control-path operation = routine bring-up / CSR program / readback / clear-counter sequences
- `common (...)` = readily hit in nominal operation
- `occasional (...)` = hit in nominal operation without heroic setup, but not in every short run
- `rare (...)` = legal in nominal operation, but usually needs long runtime or unlucky alignment
- `corner-only (...)` = requires a legal but non-nominal stress or corner profile
- `directed-only (...)` = requires targeted error injection, formal/probe flow, reporting-only flow, or another non-operational stimulus
- detailed `min / p50 / max` first-hit sim-time studies may still appear inside individual bug sections when useful

Fix status detail contract for active entries and future updates:
- `state` = fixed / open / partial plus the current verification gate
- `mechanism` = how the implemented repair changes the RTL or harness behavior
- `before_fix_outcome` and `after_fix_outcome` = concise evidence showing what changed
- `potential_hazard` = whether the fix looks permanent or is still provisional / profile-limited
- `Claude Opus 4.7 xhigh review decision` = explicit review state; use `pending / not run` until that review has actually happened

Historical formal note:
- This IP ledger currently records RTL/DV simulation findings from the legacy VHDL smoke bench and the UVM documented-case harness.
- Formal/static signoff is tracked separately when a qverify/qstatic flow is run for this IP.

## Index

| bug_id | class | severity | encounterability | status | first seen | commit | summary |
|---|---|---|---|---|---|---|---|
| [BUG-001-R](#bug-001-r-wrap-window-timestamp-reconstruction-mismatch) | R | soft error | `corner-only (wrap-window timestamp traffic)` | fixed | exact integrated SciFi bench `INT_fe_scifi_v3-2026-04-17` | `0399f04` | Wrap correction used the wrong MuTRiG coarse-time period and left a residual timestamp error near coarse-counter wrap. |
| [BUG-002-R](#bug-002-r-timestamp-delay-error-sideband-could-attach-to-the-wrong-hit) | R | soft error | `directed-only (delay-error classification)` | fixed | `CORNER_MTS_127_delay_error_sideband_tracks_hit` | `497bf11` | Delay-error sideband could describe a neighboring hit instead of the visible output payload beat. |
| [BUG-003-R](#bug-003-r-debug-ts-could-emit-reset-or-sclr-flush-samples-with-no-normal-payload) | R | non-datapath-refactor | `directed-only (reset/debug observability)` | fixed | `STD_MTS_005_sync_enters_reset_sync` | `67ef6ac` | Debug timestamp valid could fire for reset/SCLR flush traffic with no normal `hit_type1` payload. |
| [BUG-004-R](#bug-004-r-hit-ready-datapath-sampling-and-counters-could-diverge-during-bring-up) | R | soft error | `common (routine bring-up)` | fixed | `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, `NEG_MTS_028_valid_beat_under_force_stop` | `67ef6ac` | Hit ready, datapath sampling, and CSR counters could disagree around stale ready/accept windows. |
| [BUG-005-R](#bug-005-r-control-commands-could-be-decoded-while-asi-ctrl-ready-0) | R | hard stuck error | `common (routine terminate-to-idle control)` | fixed | `STD_MTS_129_upgrade_case_idle_after_boundary_only` | `e61fc9f` | Control words could be decoded while `asi_ctrl_ready=0`, allowing premature IDLE acceptance before close markers. |
| [BUG-006-H](#bug-006-h-counter-debug-report-saturated-near-rollover) | H | non-datapath-refactor | `directed-only (rollover debug observability)` | fixed | `STD_MTS_106_total_counter_hi_rollover` | `94d6320` | Counter debug report text truncated `total_pre` through an integer conversion near rollover. |
| [BUG-007-R](#bug-007-r-csr-mode-fields-were-live-for-in-flight-hits) | R | soft error | `corner-only (CSR mode toggle while datapath pipeline is active)` | fixed | `CORNER_MTS_057_toggle_derive_tot_between_hits`, `CORNER_MTS_058_toggle_delay_field_between_hits` | `1e0d0cb` | CSR mode writes could reinterpret hits already accepted into the pipeline. |
| [BUG-008-R](#bug-008-r-bypass-lapse-was-live-for-in-flight-hits) | R | soft error | `corner-only (CSR bypass toggle while datapath pipeline is active)` | fixed | `CORNER_MTS_039_bypass_toggle_after_hit_accept` | `6f4bf95` | A CSR write to `bypass_lapse` could reinterpret the divider numerator source for a hit already accepted into the pipeline. |
| [BUG-009-H](#bug-009-h-hit0-monitor-sampled-after-one-cycle-valid-deassert) | H | non-datapath-refactor | `directed-only (adjacent accepted hit0 visibility)` | fixed | `CORNER_MTS_039_bypass_toggle_after_hit_accept` | `6f4bf95` | The hit0 monitor could miss a one-cycle accepted beat, weakening input-analysis-port evidence for dual normal/debug checks. |
| [BUG-010-H](#bug-010-h-profile-helper-forced-zero-delay-error-on-valid-route-jump) | H | non-datapath-refactor | `directed-only (profile route-jump delay sanity)` | fixed | `STRESS_MTS_021_round_robin_enabled_channels` | `39fa9c0` | Profile helper forced zero delay-error even when normal output and debug math correctly agreed on a negative-delta route jump. |
| [BUG-011-R](#bug-011-r-csr-soft-reset-left-timing-datapath-and-debug-history-live) | R | soft error | `occasional (routine CSR soft-reset recovery)` | fixed | `STRESS_MTS_035_soft_reset_every_10k_cycles` | `b1d45ba` | CSR soft reset cleared visible counters without clearing local timing, datapath, output, and debug history. |
| [BUG-012-R](#bug-012-r-illegal-run-control-error-state-could-wedge-ctrl-ready-low) | R | hard stuck error | `directed-only (illegal control injection)` | fixed | `STRESS_MTS_070_interspersed_illegal_ctrl_words` | `a975fe1` | An illegal run-control word decoded to `ERROR` and left `asi_ctrl_ready` low, blocking later legal recovery commands. |
| [BUG-013-H](#bug-013-h-inert-parameter-terminate-stimulus-left-input-packet-open) | H | non-datapath-refactor | `directed-only (parameter-sweep terminate stimulus)` | fixed | `STRESS_MTS_090_inert_parameter_sweep_compare` | `c2789b0` | P090 opened an input packet on one sideband channel and placed the terminal EOP on another, so the legal RTL drain held close markers off. |
| [BUG-014-H](#bug-014-h-soft-reset-smoke-loop-checked-debug-burst-before-monitor-settled) | H | non-datapath-refactor | `directed-only (soft-reset smoke-loop debug timing)` | fixed | `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` | `dedab24` | P110 enforced exact debug-stream counts before bounded waits let the passive debug monitors report the final sample. |
| [BUG-015-R](#bug-015-r-open-packet-could-block-terminal-close-markers-after-endofrun) | R | hard stuck error | `rare (routine stop while an input packet remains open or upstream EOP is missing)` | fixed | `NEG_MTS_118_missing_boundary_with_packet_open` | `pending-current-patch` | Stale open-packet bookkeeping could hold the terminal boundary generator busy forever after upstream end-of-run. |

## 2026-05-10

### BUG-015-R: Open packet could block terminal close markers after endofrun

- First seen:
  - UVM case `NEG_MTS_118_missing_boundary_with_packet_open`
  - The first focused X111-X120 batch stopped after one accepted open-packet payload and one paired normal/debug trace had already been observed
- Symptom:
  - X118 failed with `packet-open synthetic boundary timed out waiting for empty_eop_count=4, got 0`
  - the accepted payload path was healthy: the normal output and debug timestamp trace paired at `260001 ps`
  - after `TERMINATING` plus upstream `endofrun`, no terminal empty close-marker train appeared and control ready could not restore
- Root cause:
  - the termination marker busy equation treated any nonzero `packet_in_transaction` bit as pipeline work
  - if upstream end-of-run arrived while an input-side packet was still open, no later legal beat could clear that stale bookkeeping
  - the marker generator therefore stayed blocked even after all physical accepted-hit pipeline stages were empty
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL still lets real accepted-hit pipeline valids and pending output work block the terminal close-marker train
    - once upstream `endofrun` is observed, stale open-packet bookkeeping no longer contributes to the terminal marker busy predicate
    - the repair preserves packet-open blocking before end-of-run, while allowing a deterministic synthetic terminal boundary at the run stop
  - before_fix_outcome:
    - `NEG_MTS_118_missing_boundary_with_packet_open` timed out waiting for the four-lane terminal close-marker train
  - after_fix_outcome:
    - `NEG_MTS_118_missing_boundary_with_packet_open` passes with `csr=5 inputs=1 beats=5 payloads=1 eops=4 empty_eops=4 debug_ts=1 debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`
    - focused X111-X120 passes with `FOCUSED_NEG111_NEG120_PASS count=10`
    - focused X121-X130 passes with `FOCUSED_NEG121_NEG130_PASS count=10`
    - the ordered explicit-case rerun passes with `FULL_EXPLICIT_521_PASS cases=521 elapsed=914s`
    - the hard Questa static screen passes for `mts_processor.vhd` using `syn/quartus/mts_processor_static.f`
  - potential_hazard:
    - fixed for the current single-clock terminal-boundary contract. The design still depends on upstream `endofrun` as the terminal condition; missing both EOP and end-of-run remains an invalid run-stop sequence
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `ARTIFACT_AUDIT cases=521 missing_logs=0 bad_or_incomplete_logs=0 missing_ucdb=0`
  - the explicit-only coverage merge reported filtered instance coverage `71.66%`; DUT statement `97.61%`, branch `95.36%`, condition `84.95%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.93%`
  - the hard Questa static screen passed with lint `Error (0)`, CDC `Violations (0)`, and RDC `Violation (0)`
- Commit:
  - `pending-current-patch` (`[PATCH] Close MTSP termination negative evidence`)

### BUG-014-H: Soft-reset smoke loop checked debug burst before monitor settled

- First seen:
  - UVM case `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs`
  - The first focused P101-P110 batch stopped on iteration 0 after four normal outputs and four paired `debug_ts` traces had already been observed
- Symptom:
  - P110 failed at `292 ns` with `expected 4 new debug_burst samples, got 3 from base 0`
  - the normal payload path, `debug_ts` path, and delay-math trace pairing were already sane for the four smoke vectors
  - the failure was specific to the exact-count check running before the final passive `debug_burst` / `ts_delta` monitor sample had been bounded-waited
- Root cause:
  - the new soft-reset smoke-loop helper waited for input, output, and trace counts before checking exact debug-stream deltas
  - unlike the replay helper, it did not first call `wait_for_debug_ts_count`, `wait_for_debug_burst_count`, and `wait_for_ts_delta_count`
  - this made a monitor scheduling boundary look like a missing debug-burst event even though the RTL sideband was not lost
- Fix status:
  - state:
    - fixed
  - mechanism:
    - P110 now uses bounded waits for `debug_ts`, `debug_burst`, and `ts_delta` on every soft-reset iteration before enforcing exact per-iteration counts
    - the fix preserves the strict scoreboard requirement: each emitted payload must still have matching normal output, debug timestamp, debug burst, `ts_delta`, and dual-path trace evidence
  - before_fix_outcome:
    - `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` failed with three observed `debug_burst` samples when the fourth sample had not yet been waited into the scoreboard
  - after_fix_outcome:
    - `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` passes with `csr=259 inputs=128 beats=128 payloads=128 debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128`
    - the focused P101-P110 batch passes with `STRESS_P101_P110_BATCH_PASS count=10`
    - the ordered explicit-case rerun passes with `FULL373_PASS cases=373 elapsed=659s`
  - potential_hazard:
    - fixed for the soft-reset smoke-loop helper. The exact-count check remains intentionally strict after the bounded monitor waits, so future missing debug samples still fail the case
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `ARTIFACT_AUDIT cases=373 missing_logs=0 bad_or_incomplete_logs=0 missing_ucdb=0`
  - the explicit-only coverage merge reported filtered instance coverage `71.70%`; DUT statement `97.04%`, branch `95.49%`, condition `83.92%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.82%`
- Commit:
  - `dedab24` (`[PATCH] Add MTSP smoke endurance stress cases`)

### BUG-013-H: Inert parameter terminate stimulus left input packet open

- First seen:
  - UVM case `STRESS_MTS_090_inert_parameter_sweep_compare`
  - The first focused P081-P090 batch stopped after the 64 payload math/trace checks with `MTSP_TIMEOUT` waiting for `empty_eop_count=4`, while the scoreboard had not observed any close markers
- Symptom:
  - normal payload math and normal/debug trace pairing were already correct for all 64 inert-parameter payloads
  - after `TERMINATING` and upstream `endofrun`, the DUT did not emit the expected empty close-marker train
  - reviewing the RTL packet-drain condition showed `packet_in_transaction` could not clear because the test opened input sideband channel 0 with the first SOP but drove the final EOP on sideband channel 31
- Root cause:
  - the stress helper used `idx % 32` for the input sideband channel and only set one global SOP and one global EOP
  - that pattern is useful for payload channel coverage, but it is not a legal packet-close sequence for a testcase that requires terminate close markers from the RTL reference contract
- Fix status:
  - state:
    - fixed
  - mechanism:
    - P090 now uses a channel-override stress helper so payload math remains stress-indexed while packet sideband lanes stay within enabled channels 0 through 3
    - the stimulus opens all four enabled input lanes with SOP on the first four beats and closes those same lanes with EOP on the final four beats before `TERMINATING` and upstream `endofrun`
    - the checker still requires all 64 payload math/trace pairs, zero discards, and four empty close markers after termination
  - before_fix_outcome:
    - `STRESS_MTS_090_inert_parameter_sweep_compare` timed out at `4932 ns` waiting for `empty_eop_count=4`, got `0`
  - after_fix_outcome:
    - `STRESS_MTS_090_inert_parameter_sweep_compare` passes with `csr=5 inputs=64 beats=68 payloads=64 eops=4 empty_eops=4 debug_ts=64 debug_burst=64 ts_delta=64 dual_path_pairs=64 traces=64`
    - the focused P081-P090 batch passes with `STRESS_P081_P090_BATCH_PASS count=10`
    - the ordered documented-case rerun passes with `FULL_EXPLICIT_353_RERUN_PASS cases=353`
  - potential_hazard:
    - fixed for terminate-capable parameter-sweep stress. The generic stress helper still supports wide sideband-channel sweeps for non-terminate cases where no packet-close train is required
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `explicit_cases=353 missing_artifacts=0 failed_or_incomplete_logs=0`
  - the source-homogeneous explicit-only coverage merge reported filtered instance coverage `71.10%`; DUT statement `97.04%`, branch `95.49%`, condition `83.92%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.65%`
- Commit:
  - `c2789b0` (`[PATCH] Add MTSP parameter sweep stress cases`)

### BUG-012-R: Illegal run-control ERROR state could wedge ctrl ready low

- First seen:
  - UVM case `STRESS_MTS_070_interspersed_illegal_ctrl_words`
  - The first failing run stopped before payload traffic with `MTSP_CTRL_TIMEOUT` while waiting for a later legal `RUN_PREPARE`
- Symptom:
  - an injected multi-hot control word was accepted while the DUT was otherwise ready
  - the decoder correctly classified the unsupported word as `ERROR`, but the control-ready equation had no ready-high recovery condition for `run_state_cmd=ERROR`
  - all later legal control words were blocked because the UVM control driver waits for `asi_ctrl_ready=1` before completing the handshake
- Root cause:
  - `proc_run_control_mgmt_agent` preserved an observable `ERROR` command state for unsupported control words
  - `ctrl_ready_comb` only acknowledged the known legal state/processor-state combinations, so `run_state_cmd=ERROR` became a sticky ready-low state
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL still decodes unsupported run-control words to `ERROR`
    - `ctrl_ready_comb` now asserts ready when `run_state_cmd=ERROR`, allowing the next legal control word to replace the error command and recover the local agent
    - P070 keeps illegal multi-hot injections before and during legal sequences, then requires payload, debug, close-marker, and counter evidence after recovery
  - before_fix_outcome:
    - `STRESS_MTS_070_interspersed_illegal_ctrl_words` failed at `80148 ns` with `Timed out waiting for RUN_PREPARE ready after 10000 cycles`
  - after_fix_outcome:
    - `STRESS_MTS_070_interspersed_illegal_ctrl_words` passes with `csr=292 inputs=48 beats=240 payloads=48 eops=192 empty_eops=192 debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48 traces=48`
    - the final ordered documented-case rerun passes with `FULL_EXPLICIT_333_RERUN_PASS cases=333`
    - the hard Questa static screen passes for `mts_processor.vhd` using `syn/quartus/mts_processor_static.f`
  - potential_hazard:
    - fixed for the current single-clock run-control agent and illegal-word recovery contract; broader system policy for illegal control injection remains covered by the remaining ERROR/NEG plan work
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `explicit_cases=333 missing_artifacts=0 failed_or_incomplete_logs=0`
  - the source-homogeneous explicit-only coverage merge reported DUT statement `97.04%`, branch `95.49%`, condition `83.92%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `55.65%`
  - `rtl_style_check.py mts_processor.vhd` still fails on the legacy style baseline with 968 issues
- Commit:
  - `a975fe1` (`[PATCH] Recover MTSP illegal control state`)

### BUG-011-R: CSR soft reset left timing datapath and debug history live

- First seen:
  - UVM case `STRESS_MTS_035_soft_reset_every_10k_cycles`
  - Follow-up contract checks `CORNER_MTS_084_soft_reset_with_inflight_beats` and `STRESS_MTS_036_global_reset_periodic_recovery`
- Symptom:
  - P035 first stopped after a software reset with `debug_delta=10038 expected_latency=2000 math_error=1 hit_error=1` on the first post-reset payload
  - the normal output error bit and debug-derived delay math agreed, so the mismatch was a stale RTL timing context rather than a scoreboard-only false positive
  - E084 exposed that an in-flight accepted hit must be flushed by soft reset, not emitted after the counter clear
- Root cause:
  - `csr.soft_reset` cleared the visible total/discard counters but left the local MTS/GTS counters, accepted-hit pipeline, divider-output delay registers, route packet bookkeeping, and debug delta history live
  - hit input ready and normal output assembly were not explicitly gated during the active soft-reset cycle
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL now resets the local MTS/GTS counters on `csr.soft_reset`
    - hit input ready and `hit_in_ok` are held low while soft reset is active
    - the datapath pipeline, divider delay registers, route start/terminate bookkeeping, upstream end-of-run state, and debug timestamp/burst history are cleared or gated during soft reset
    - E084 now requires the in-flight payload/debug output to be flushed and then checks that the next post-reset hit restarts cleanly
    - P035 and P036 use reset-local synthetic timestamp epochs so the no-error reference matches the reset contract
  - before_fix_outcome:
    - `STRESS_MTS_035_soft_reset_every_10k_cycles` failed on the first payload after a CSR soft reset with stale long-gap delay math
    - the older E084 expectation would have allowed a flushed in-flight hit to appear after reset, which was inconsistent with the CSR reset contract
  - after_fix_outcome:
    - `CORNER_MTS_084_soft_reset_with_inflight_beats` passes with `csr=8 inputs=2 beats=1 payloads=1 debug_ts=1 debug_burst=1 ts_delta=1 dual_path_pairs=1 traces=1`
    - `STRESS_MTS_035_soft_reset_every_10k_cycles` passes with `csr=24 inputs=48 beats=48 payloads=48 debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48 traces=48`
    - `STRESS_MTS_036_global_reset_periodic_recovery` passes with `csr=21 inputs=48 beats=48 payloads=48 debug_ts=48 debug_burst=48 ts_delta=48 dual_path_pairs=48 traces=48`
    - the final ordered documented-case rerun passes with `FULL_EXPLICIT_303_RERUN_PASS cases=303`
  - potential_hazard:
    - fixed for the current single-clock CSR soft-reset implementation and documented reset-recovery bring-up sequence; CDC/static signoff remains tracked separately
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `explicit_cases=303 missing_artifacts=0 failed_or_incomplete_logs=0`
  - the source-homogeneous explicit-only coverage merge reported DUT statement `95.94%`, branch `94.65%`, condition `82.14%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `54.33%`
  - the legacy VHDL smoke bench `./tb/run_mts_processor_tb.sh` passed
  - `rtl_style_check.py mts_processor.vhd` still fails on the legacy style baseline with 968 issues
- Commit:
  - `b1d45ba` (`[PATCH] Reset MTSP soft-reset datapath state`)

### BUG-010-H: Profile helper forced zero delay-error on valid route jump

- First seen:
  - UVM case `STRESS_MTS_021_round_robin_enabled_channels`
- Symptom:
  - the first P021 bring-up stopped at payload index 1 with `expected error=0, got math_error=1 hit_error=1 debug_delta=-3 expected_latency=2000`
  - the scoreboard trace showed that the normal output error bit and the debug-derived math error agreed; the failing assertion was the profile helper's hard-coded no-error expectation
- Root cause:
  - the high-variance profile helper reused a zero-delay-error assertion even for route-round-robin traffic
  - that stimulus can legally jump from quotient route 0 to route 1 on adjacent accepted hits, so the selected timestamp can be later than the output observation point and produce a mathematically valid negative `debug_delta`
- Fix status:
  - state:
    - fixed
  - mechanism:
    - the profile payload checker still verifies payload math, output route, SOP/EOP/empty, and normal/debug trace pairing
    - for profile-variance cases it now requires `trace.math_error` and `trace.hit1_error` to match instead of forcing both low
    - explicit delay-threshold cases continue to use `expect_trace_error_at` with an exact expected value
  - before_fix_outcome:
    - `STRESS_MTS_021_round_robin_enabled_channels` failed at the first adjacent route jump even though normal and debug paths agreed on the delay error
  - after_fix_outcome:
    - `STRESS_MTS_021_round_robin_enabled_channels` passes with `inputs=128 beats=128 payloads=128 debug_ts=128 debug_burst=128 ts_delta=128 dual_path_pairs=128 traces=128`
    - the focused `STRESS_MTS_021` through `STRESS_MTS_030` batch passes with no UVM errors or fatals
  - potential_hazard:
    - fixed for the profile-variance reference helper; this does not weaken explicit no-error, equality, or out-of-window delay cases because those still assert exact delay-error values
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `explicit_cases=293 missing_artifacts=0`
  - the explicit-only coverage merge reported DUT statement `95.81%`, branch `94.60%`, condition `79.79%`, expression `100.00%`, FSM state `100.00%`, FSM transition `77.77%`, and toggle `53.23%`
- Commit:
  - `39fa9c0` (`[PATCH] Add MTSP high-variance stress cases`)

### BUG-009-H: hit0 monitor sampled after one-cycle valid deassert

- First seen:
  - UVM case `CORNER_MTS_039_bypass_toggle_after_hit_accept` after the RTL bypass fix was applied and the case required `hit0_history` to show both accepted inputs
- Symptom:
  - the DUT accepted two adjacent hit0 beats and produced two normal payloads plus two debug trace pairs
  - the scoreboard summary still reported `inputs=1 beats=2 payloads=2 dual_path_pairs=2`
  - after adding the required input-analysis-port wait, the case failed with `timed out waiting for input_count=2, got 1`
- Root cause:
  - `mtsp_hit0_monitor` used the same `#1ps` post-edge sampling as DUT-output monitors
  - the hit0 driver deasserts a one-cycle `valid` with a nonblocking assignment on the accepted clock edge, so the delayed monitor sample could see `valid=0` after a real accepted transfer
- Fix status:
  - state:
    - fixed
  - mechanism:
    - the hit0 monitor now samples the accepted ready/valid handshake on the clock edge before the driver deassert lands
    - the monitor records hit0 timestamps in the same `+1ps` reporting domain as the normal-output and debug monitors so latency checks compare like-for-like observation times
    - direct payload latency checks were reconciled to the actual accepted-hit-to-observed-output path: `10` cycles for `LPM_DIV_PIPELINE=4` and `8` cycles for `LPM_DIV_PIPELINE=2`
  - before_fix_outcome:
    - `CORNER_MTS_039_bypass_toggle_after_hit_accept` showed `inputs=1` despite two accepted DUT hits and two paired normal/debug outputs
    - after the input-count guard was added, E039 failed until the monitor timing was fixed
    - the first full sweep stopped at `STD_MTS_111_compile_rtl_default_div_pipeline` because the old launch-edge latency expectation was one cycle too long
  - after_fix_outcome:
    - E039 passes with `inputs=2 beats=2 payloads=2 debug_ts=2 dual_path_pairs=2 traces=2`
    - B111 passes with `latency_cycles=10`; B112 passes with `latency_cycles=8`
    - the final explicit sweep passes with `FULL_EXPLICIT_SWEEP_PASS count=241`
  - potential_hazard:
    - fixed for the current one-cycle hit0 driver and single-clock monitor contract; output and debug monitors intentionally keep post-edge sampling because those signals are DUT-driven
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the artifact audit passed with `explicit_cases=241 missing_artifacts=0`
  - the explicit-only coverage merge reported filtered instance coverage `65.86%`
  - the legacy VHDL smoke bench `./tb/run_mts_processor_tb.sh` passed
- Commit:
  - `6f4bf95` (`[PATCH] Sample MTSP bypass mode per hit`)

### BUG-008-R: bypass_lapse was live for in-flight hits

- First seen:
  - UVM case `CORNER_MTS_039_bypass_toggle_after_hit_accept`
- Symptom:
  - the first hit was accepted while `bypass_lapse=1`
  - the test then wrote `bypass_lapse=0` before the accepted hit reached the divider-numerator selection stage
  - the before-fix RTL emitted `TCC_8N/TCC_1N6=6555/2` for the first hit instead of preserving the sampled bypass-on result `2/0`
- Root cause:
  - `csr.bypass_lapse` was read live in the `hit_padding -> hit_prediv` stage
  - unlike `derive_tot` and `delay_ts_field_use_t`, the bypass control bit was not carried with the accepted hit, so a later CSR write could change math for in-flight data
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL now latches `bypass_lapse` on `asi_hit_type0_accept && hit_in_ok`
    - the sampled field is carried through `hit_in` and `hit_padding`
    - divider numerator source selection now uses `hit_padding.bypass_lapse`, and VHDL debug reports print the sampled value at the padding checkpoint
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_039_bypass_toggle_after_hit_accept SEED=1` fails on the before RTL
    - the before run reports `expected TCC_8N=2 got 6555` for the first accepted hit
  - after_fix_outcome:
    - the same `prove_delta` command passes on the after RTL
    - the VHDL trace shows the first hit padding checkpoint with `bypass='1'` and the second with `bypass='0'`
    - the normal/debug trace pair evidence shows first hit `2/0` and second hit `6555/2`
  - potential_hazard:
    - fixed for the current single-clock CSR/data pipeline; `expected_latency` remains a live delay-threshold CSR by the documented E040 contract, not a timestamp-padding control
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the focused `CORNER_MTS_031` through `CORNER_MTS_040` batch passed with the required normal/debug scoreboard summaries
  - the final explicit sweep passed with `FULL_EXPLICIT_SWEEP_PASS count=241`
  - the artifact audit passed with `explicit_cases=241 missing_artifacts=0`
- Commit:
  - `6f4bf95` (`[PATCH] Sample MTSP bypass mode per hit`)

### BUG-007-R: CSR mode fields were live for in-flight hits

- First seen:
  - UVM case `CORNER_MTS_057_toggle_derive_tot_between_hits`
  - UVM case `CORNER_MTS_058_toggle_delay_field_between_hits`
- Symptom:
  - the before-fix E057 run accepted one hit in short mode, wrote `derive_tot=1`, and then produced `ET_1N6=4` for that first in-flight hit instead of the sampled short-mode value `0`
  - the before-fix E058 run accepted one hit with the T delay source, wrote the E delay source, and then asserted `aso_hit_type1_error` for the first in-flight hit even though its sampled T-path delay was inside the expected-latency window
- Root cause:
  - `csr.derive_tot` was read live in the ToT calculation stage instead of being carried with the accepted hit
  - `csr.delay_ts_field_use_t` was read live in the delay-error, `debug_ts`, and `debug_burst` stages instead of being carried with the accepted hit
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL now latches `derive_tot` and `delay_ts_field_use_t` on `asi_hit_type0_accept && hit_in_ok`
    - those sampled fields are carried through `hit_in`, `hit_padding`, `hit_prediv`, `hit_totcalc`, and the divider pipeline so normal payload and debug sideband math use the same per-hit mode decision
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_057_toggle_derive_tot_between_hits SEED=1` fails on the before RTL with `expected ET_1N6=0 got 4`
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_058_toggle_delay_field_between_hits SEED=1` fails on the before RTL with `expected hit_type1 error=0 got 1`
  - after_fix_outcome:
    - both `prove_delta` commands pass on the after RTL
    - each case produces two payloads, two debug traces, and two normal/debug trace pairs with `debug_path_required=1`
    - E057 proves the first hit remains short-mode `ET_1N6=0` and the second hit uses ToT `ET_1N6=4`
    - E058 proves the first hit remains T-delay clean and the second hit uses E-delay error classification
  - potential_hazard:
    - fixed for the current single-clock `derive_tot` and `delay_ts_field_use_t` pipeline contract; other runtime mode fields such as `bypass_lapse` remain covered by separate EDGE work
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the sampled-mode batch advanced documented evidence to 221 explicit cases and filtered merged coverage to `66.26%`
  - `FULL_EXPLICIT_SWEEP_PASS count=221`
  - the artifact audit passed with `explicit_cases=221 missing_artifacts=0`
- Commit:
  - `1e0d0cb` (`[PATCH] Sample MTSP CSR modes per hit`)

### BUG-006-H: Counter debug report saturated near rollover

- First seen:
  - UVM case `STD_MTS_106_total_counter_hi_rollover` during the rollover seed/readout bring-up batch
- Symptom:
  - the rollover case passed CSR and scoreboard math, but the VHDL note reported `total_pre=2147483647` after seeding the total counter to `0x0000_ffff_ffff`
  - the human debug trace was therefore misleading at the exact checkpoint that future hardware bring-up will use to correlate counter rollover
- Root cause:
  - the debug report converted `debug_msg.total_hit_cnt(30 downto 0)` through `to_integer`, dropping the upper counter bits before printing
  - the issue affected report text only; the CSR high/low readout, counter carry, normal output payload, and debug sideband pairing remained correct
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL debug report text now prints `debug_msg.total_hit_cnt` as a full 48-bit hexadecimal value with `to_hstring`
  - before_fix_outcome:
    - focused B106 rollover run printed `total_pre=2147483647` at the accepted rollover hit
  - after_fix_outcome:
    - focused B106/E018 rollover recheck passed and printed `total_pre=0x0000FFFFFFFF`
    - `STD_MTS_106_total_counter_hi_rollover` passed with one payload, one debug trace pair, and final total count `0x0001_0000_0000`
    - `CORNER_MTS_018_counter_read_on_low_word_rollover` passed with high-low-high recovery to `0x0001_0000_0000`
  - potential_hazard:
    - fixed for current DEBUG report text; it does not change packet or CSR behavior
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the same rollover batch advanced documented evidence to 219 explicit cases and filtered merged coverage to `66.51%`
  - `STD_MTS_025_unsupported_write_addr3_inert` and `STD_MTS_026_unsupported_write_addr4_inert` passed with the default generic, proving counter seed writes remain disabled in normal packaged builds
- Commit:
  - `94d6320` (`[PATCH] Add MTSP counter rollover coverage`)

## 2026-05-09

### BUG-005-R: Control commands could be decoded while `asi_ctrl_ready=0`

- First seen:
  - UVM case `STD_MTS_129_upgrade_case_idle_after_boundary_only` during the delivered terminate-boundary upgrade sequence
- Symptom:
  - an `IDLE` command driven while `asi_ctrl_ready=0` during `FLUSHING` could be accepted before the empty close-marker train completed
  - the before-fix run failed at 220 ns with `IDLE command must not be accepted before close markers complete`
  - the terminal boundary evidence was skipped even though the control driver was using the ready/valid handshake contract
- Root cause:
  - `proc_run_control_mgmt_agent` decoded `asi_ctrl_valid` without also checking `ctrl_ready_comb`
  - a control word held valid while ready was low could update `run_state_cmd` before the DUT had finished terminate drain and close-marker generation
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL now decodes run-control commands only when `asi_ctrl_valid = '1' and ctrl_ready_comb = '1'`
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=STD_MTS_129_upgrade_case_idle_after_boundary_only SEED=1` fails on the before RTL
  - after_fix_outcome:
    - the same `prove_delta` command passes on the after RTL with `inputs=0 beats=4 payloads=0 eops=4 empty_eops=4 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0 traces=0`
    - final explicit documented-case sequence passed with `FINAL_ALL_133_EXPLICIT_CASES_PASS`
    - `make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1` passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8 debug_ts=2 dual_path_pairs=2 traces=2`
    - `make -C tb/uvm cov_report_total RTL_VARIANT=after` completed with filtered merged coverage `64.44%`
    - `./tb/run_mts_processor_tb.sh` passed the legacy VHDL testbench
  - potential_hazard:
    - fixed for the legal stateful terminate/endofrun/close-marker/IDLE contract now covered by `STD_MTS_125` through `STD_MTS_130`
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - `STD_MTS_008_idle_from_flushing` and `STD_MTS_045_terminating_without_eop_then_idle` were reconciled to the same stateful contract: assert upstream `endofrun`, wait for close markers, then send `IDLE`
  - `DEBUG=0` suppresses VHDL report text only; the current debug sideband outputs remain paired with normal payload evidence and are still required by the UVM scoreboard
- Commit:
  - `e61fc9f22e83` (`[FIX] Gate MTSP control commands on ready`)

### BUG-004-R: Hit ready, datapath sampling, and counters could diverge during bring-up

- First seen:
  - UVM cases `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop`
- Symptom:
  - the first standard-sequence hit after `RUN_PREPARE -> SYNC -> RUNNING` could be transformed or counted inconsistently depending on the stale ready phase observed by the driver and monitors
  - force-stop needed to keep the input ready contract observable while dropping the current beat from the transform path
  - total/discard counter readback and transformed payload evidence could disagree around bring-up edges
- Root cause:
  - `asi_hit_type0_ready_i` was registered from the previous processor phase, so the externally visible accept window could lag the current FSM state
  - the datapath sampled `valid && hit_in_ok` rather than the same ready/valid acceptance event observed at the Avalon-ST boundary
  - reset-flow state could remain at `SYNC` long enough to clear counters after the first standard-sequence acceptance
  - the UVM `run_start()` helper treated the command handshake as sufficient evidence of `RUNNING`, and the CSR driver could sample read data before the acknowledged transaction had settled
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL derives the input ready window combinationally from current state, reset flow, and upstream end-of-run state
    - datapath and packet bookkeeping sample only `asi_hit_type0_accept && hit_in_ok`
    - the UVM CSR driver drives requests on `negedge`, waits for positive-edge acknowledgement, and samples after a small settle delay
  - before_fix_outcome:
    - first-hit transform, total counter, and discard counter evidence could diverge around bring-up and force-stop edges
  - after_fix_outcome:
    - all 42 then-explicit documented-case handlers passed with `make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1`
    - `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop` cross-check ready, total/discard counters, and no-output behavior under accepted drop conditions
  - potential_hazard:
    - fixed for the current single-clock UVM and legacy VHDL simulation scope
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - `make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1` passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8 debug_ts=2 dual_path_pairs=2 traces=2`
  - `./tb/run_mts_processor_tb.sh` passed the legacy VHDL testbench
- Commit:
  - `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)

### BUG-003-R: debug_ts could emit reset or SCLR flush samples with no normal payload

- First seen:
  - UVM case `STD_MTS_005_sync_enters_reset_sync` after enabling the debug monitor path as a required cross-check against normal `hit_type1` output
- Symptom:
  - the scoreboard observed `debug_ts_valid=1` while no normal `hit_type1` payload beat was emitted, creating an unpaired debug transaction during reset/SCLR or reset-to-SYNC bring-up traffic
- Root cause:
  - the internal debug timestamp path was driven from the divider pipeline without checking that the processor was in an active output state
  - the external debug sideband register forwarded internal debug valid without the same state and drop-policy gating used by the normal output path
- Fix status:
  - state:
    - fixed
  - mechanism:
    - `proc_debug_ts` clears internal debug data/valid unless reset is deasserted, the processor is in `RUNNING` or `FLUSHING`, and the divider stage holds a valid hit
    - `proc_debug_ts_comb` resets and forwards debug sideband data only when the normal output state and delay-error drop policy allow an observable hit sideband
  - before_fix_outcome:
    - reset/SCLR traffic could produce debug-only samples
  - after_fix_outcome:
    - all 42 then-explicit documented-case handlers passed
    - `STD_MTS_002_reset_release_idle_quiet`, `STD_MTS_005_sync_enters_reset_sync`, and `STD_MTS_010_global_reset_during_flushing` require zero unpaired normal/debug activity through reset and bring-up boundaries
  - potential_hazard:
    - fixed for current exposed debug sideband contract
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the UVM scoreboard requires normal/debug pair agreement, so future debug-only samples remain a closure blocker rather than a tolerated artifact
- Commit:
  - `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)

### BUG-002-R: Timestamp-delay error sideband could attach to the wrong hit

- First seen:
  - UVM case `CORNER_MTS_127_delay_error_sideband_tracks_hit`, comparing the `before` RTL against the UVM debug/normal dual-path scoreboard
- Symptom:
  - a forced timestamp-delay error with `EXPECTED_LATENCY=0` did not assert `aso_hit_type1_error` on the corresponding output beat
  - the following restored-clean hit could inherit or mask the stale classification depending on traffic spacing
- Root cause:
  - the visible `hit_type1` payload came from the registered `hit_out` path
  - the delay-error sideband was derived from the separate `debug_ts` valid path
  - mixed clean/error traffic therefore allowed the sideband classification to describe the neighboring hit instead of the beat on the normal output path
- Fix status:
  - state:
    - fixed
  - mechanism:
    - delay-error sideband is aligned with the visible output payload beat
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_127_delay_error_sideband_tracks_hit SEED=1` fails on the before RTL with `MTSP_DELAY_MATH` / `MTSP_CASE`
  - after_fix_outcome:
    - current RTL passes with `inputs=2 beats=2 payloads=2 debug_ts=2 debug_burst=2 ts_delta=2 dual_path_pairs=2 traces=2`
    - additional green guards were `STD_MTS_001_powerup_reset_idle`, `STD_MTS_031_running_accepts_clean_hit`, `COMBO_MTSP_001_terminate_contract_test`, and `./tb/run_mts_processor_tb.sh`
  - potential_hazard:
    - fixed for the current normal/debug paired output path
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the UVM environment has analysis ports for CSR writes, accepted hit0, normal hit1, and debug streams
  - the scoreboard recomputes the delay-error decision from `debug_ts` and `EXPECTED_LATENCY` and requires it to match `aso_hit_type1_error` per payload beat
- Commit:
  - `497bf11` (`[FIX] Align delay error sideband with hit`)

## 2026-04-18

### BUG-001-R: Wrap-window timestamp reconstruction mismatch

- First seen:
  - exact integrated SciFi bench `firmware_builds/tb_int/INT_fe_scifi_v3-2026-04-17`
  - saturated short-mode traces `ts_sat_exact14` and `ts_sat_exact15`
- Symptom:
  - `mts_processor` emitted wrong `tcc_8n` and non-zero `tcc_1n6` around the MuTRiG coarse-counter wrap
  - `aso_hit_type1_error` was raised and pre-RBCAM drops occurred even though the injected hit true timestamp was still within the expected 2000-cycle latency window
- Root cause:
  - the per-hit overflow-adjust decision missed the first hit that used the newly valid overflow-product pipeline result
  - the wrap correction subtracted `32766` ticks instead of the true `32767` MuTRiG coarse-time period, leaving a residual `+1` 1.6 ns remainder after wrap
- Fix status:
  - state:
    - fixed
  - mechanism:
    - wrap-window timestamp reconstruction now uses the true MuTRiG coarse-time period and catches the first hit after the overflow-product pipeline becomes valid
  - before_fix_outcome:
    - original failing wrap samples were `hit_id=2891` and `hit_id=2895`
  - after_fix_outcome:
    - exact true-time trace after the fix is in `REPORT/ts_sat_exact16/emulator_timestamp_trace.csv`
    - after the fix those hits decode with `tcc8n_act=tcc8n_exp=5549`, `tcc1n6=0`, `err_act=0`
  - potential_hazard:
    - fixed for the exact SciFi wrap-window reproduction
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the remaining `debug_ts` delta offset in the exact bench is a monitor phase issue, not a recovered-hit timestamp mismatch
  - the exact-bench integration copy under `firmware_builds/scifi_datapath_system_v3/synthesis/submodules/mts_processor.vhd` was patched locally in the superproject for system-level verification alongside this IP fix
- Commit:
  - `0399f04` (`mts_processor: fix wrap-window timestamp reconstruction`)
