# DV Error And Negative Cases — mutrig_timestamp_processor

**Purpose:** fault, reset, and negative-protocol cases for `mts_processor`  
**Naming convention:** `NEG_MTS_###_description`  
**Count target:** 130 substantive cases

## 1. Illegal Run-Control Cases

- `X001 | NEG_MTS_001_all_zero_ctrl_word`: Drive control word `000000000`; expect `run_state_cmd=ERROR` and no silent legal-state interpretation. Covers the illegal-zero command.
- `X002 | NEG_MTS_002_multi_hot_ctrl_word`: Drive a multi-hot control word such as `000001100`; expect `run_state_cmd=ERROR` and no silent legal-state interpretation. Covers the illegal-multi-hot command.
- `X003 | NEG_MTS_003_illegal_ctrl_during_running`: Drive an illegal control word while traffic is flowing in `RUNNING`; verify later legal control commands still work. Covers hostile command injection in the active state.
- `X004 | NEG_MTS_004_illegal_ctrl_during_flushing`: Drive an illegal control word while in `FLUSHING`; verify the current processor state remains deterministic. Covers hostile command injection during stop drain.
- `X005 | NEG_MTS_005_ctrl_valid_high_data_changes`: Hold `asi_ctrl_valid=1` while changing `asi_ctrl_data`; require the driver/SVA layer to flag the protocol violation. Covers source misuse.
- `X006 | NEG_MTS_006_ctrl_data_unknown_injection`: Inject X/Z into `asi_ctrl_data` in simulation and require monitor/SVA detection. Covers robustness against undefined control stimulus.
- `X007 | NEG_MTS_007_running_without_sync_documented_nonstandard`: Jump directly to `RUNNING` without `RUN_PREPARE/SYNC`; tag it as a supported-but-nonstandard case so later regressions do not misclassify it. Covers a deliberate contract exception.
- `X008 | NEG_MTS_008_terminate_from_idle`: Send `TERMINATING` directly from `IDLE`; expect no fake boundary or output activity. Covers a nonsensical stop command.
- `X009 | NEG_MTS_009_link_test_during_running`: Send `LINK_TEST` during `RUNNING`; verify the unhandled command does not silently corrupt the processor state. Covers an unsupported in-run command.
- `X010 | NEG_MTS_010_always_ready_masks_incomplete_work`: Tag the current always-ready control sink as a negative control-plane contract because it acknowledges commands before work completion. Anchors the upgrade motivation.

## 2. CSR Misuse Cases

- `X011 | NEG_MTS_011_simultaneous_read_write_same_cycle`: Attempt simultaneous CSR read and write in one cycle; require the driver or SVA to flag the misuse. Covers AVMM protocol abuse.
- `X012 | NEG_MTS_012_write_unsupported_addr5`: Write an unsupported CSR address and verify no hidden DUT state changes. Covers out-of-range write misuse.
- `X013 | NEG_MTS_013_read_unsupported_addr6`: Read an unsupported CSR address and verify the DUT returns zero rather than stale data. Covers out-of-range read misuse.
- `X014 | NEG_MTS_014_reserved_opmode_bit28_write`: Write only reserved bit 28 and verify no functional state changes. Covers reserved-field misuse.
- `X015 | NEG_MTS_015_write_expected_latency_during_reset`: Attempt to write `expected_latency` while global reset is asserted; verify reset dominates. Covers control-plane activity during reset.
- `X016 | NEG_MTS_016_back_to_back_soft_reset_pulses`: Pulse `soft_reset` in consecutive cycles and verify the self-clearing logic does not wedge. Covers software abuse of the self-clear bit.
- `X017 | NEG_MTS_017_rapid_force_stop_toggle`: Toggle `force_stop` on consecutive cycles during traffic and verify the DUT remains deterministic. Covers software thrash on a critical control bit.
- `X018 | NEG_MTS_018_driver_ignores_waitrequest`: Intentionally build a bad CSR driver that samples read data without respecting `waitrequest`; require the bench to flag the misuse. Covers testbench robustness.
- `X019 | NEG_MTS_019_counter_reads_mid_reset`: Read counters during reset transitions and verify the scoreboard treats the transient explicitly rather than silently assuming old values. Covers observability during reset churn.
- `X020 | NEG_MTS_020_expected_latency_overflow_model`: Write a huge `expected_latency` that causes `padding_upper` model underflow/wrap effects; require exact reference-model matching. Covers numerically hostile software configuration.

## 3. Input-Error Cases

- `X021 | NEG_MTS_021_hiterr_rejected_running`: Drive a hiterr beat in `RUNNING` with discard enabled; expect discard counting and no output beat. Covers the primary error-discard path.
- `X022 | NEG_MTS_022_hiterr_kept_running`: Drive the same beat with discard disabled; expect it to propagate. Covers the override path.
- `X023 | NEG_MTS_023_crcerr_only_inert`: Drive only `CRCERR_BIT_LOC=1`; verify the current DUT ignores it. Documents today’s limited integrity checking.
- `X024 | NEG_MTS_024_frame_corrupt_only_inert`: Drive only `FRAME_CORRPT_BIT_LOC=1`; verify the current DUT ignores it. Documents today’s limited integrity checking.
- `X025 | NEG_MTS_025_combined_error_bits_only_hiterr_matters`: Drive all three error bits high and vary `HITERR_BIT_LOC`; verify only the mapped hiterr bit controls acceptance today. Covers combined-error behavior.
- `X026 | NEG_MTS_026_valid_beat_in_idle`: Drive valid input while `IDLE`; expect no output and deterministic counting. Covers illegal traffic in quiescent state.
- `X027 | NEG_MTS_027_valid_beat_in_reset_sync`: Drive valid input while `RESET/SYNC`; expect no acceptance and deterministic counting. Covers illegal traffic during synchronization.
- `X028 | NEG_MTS_028_valid_beat_under_force_stop`: Drive valid input with `force_stop=1`; expect rejection even though ready may remain high. Covers control-induced rejection.
- `X029 | NEG_MTS_029_sop_without_matching_eop_then_abort`: Start a packet and abort before EOP; verify the packet bookkeeping is explicitly tracked and later cleared. Covers malformed packet lifetime.
- `X030 | NEG_MTS_030_sideband_outside_enabled_window`: Drive a sideband channel outside the enabled window while payload remains legal; verify packet bookkeeping does not silently index outside range. Covers malformed sideband use.

## 4. Ready / Handshake Misuse

- `X031 | NEG_MTS_031_valid_while_input_ready_low_idle`: Force the source to drive `valid` in `IDLE` despite `ready=0`; require the scoreboard to classify the beat as rejected. Covers source misuse against the handshake.
- `X032 | NEG_MTS_032_valid_while_input_ready_low_sync`: Repeat in `RESET/SYNC`; require the scoreboard to classify the beat as rejected. Covers source misuse during synchronization.
- `X033 | NEG_MTS_033_source_drops_valid_too_early`: Intentionally violate the one-cycle valid contract in the source driver and require bench detection. Covers source protocol misuse.
- `X034 | NEG_MTS_034_output_ready_low_single_fault`: Hold output `ready=0` on a single valid beat and verify the current DUT still emits it; tag the result as a negative protocol finding rather than a scoreboard failure. Documents the ignored-ready source behavior.
- `X035 | NEG_MTS_035_output_ready_low_boundary_fault`: Hold output `ready=0` on the terminating EOP beat and verify the current DUT still emits it; tag it as the same negative protocol finding. Documents the ignored-ready boundary behavior.
- `X036 | NEG_MTS_036_output_ready_unknown_fault`: Inject X/Z on output `ready` in simulation and require the bench to flag the misuse explicitly. Covers sink-protocol robustness.
- `X037 | NEG_MTS_037_csr_driver_waitrequest_fault`: Build a bad CSR driver that changes address/data before `waitrequest` drops; require protocol assertions to fire. Covers bench-side CSR protocol abuse.
- `X038 | NEG_MTS_038_ctrl_driver_assumes_stateful_ready`: Build a run-control driver that waits for `ready` to deassert during prepare/sync/flush and verify the current DUT never does. Documents the present handshake mismatch.
- `X039 | NEG_MTS_039_hit_source_changes_payload_midbeat`: Intentionally change hit payload fields after asserting `valid`; require the driver/monitor layer to flag the misuse. Covers source data instability.
- `X040 | NEG_MTS_040_ctrl_valid_on_reset_edge`: Assert `ctrl_valid` exactly on the reset edge and verify the DUT stays in reset-defined state. Covers reset/handshake overlap misuse.

## 5. Timestamp / Window Fault Cases

- `X041 | NEG_MTS_041_negative_debug_ts_error`: Craft a hit that produces negative `debug_ts`; require `aso_hit_type1_error=1`. Covers the early-hit fault window.
- `X042 | NEG_MTS_042_zero_debug_ts_error`: Craft a hit that produces zero `debug_ts`; require `aso_hit_type1_error=1`. Covers the strict-lower-bound fault.
- `X043 | NEG_MTS_043_equal_expected_latency_error`: Craft a hit whose debug delay equals the programmed window; require `aso_hit_type1_error=1`. Covers the upper equality fault.
- `X044 | NEG_MTS_044_above_expected_latency_error`: Craft a hit above the programmed window; require `aso_hit_type1_error=1`. Covers the upper overflow fault.
- `X045 | NEG_MTS_045_zero_window_fault_everything`: Set `expected_latency=0` and verify even minimally delayed hits fault. Covers the degenerate configuration.
- `X046 | NEG_MTS_046_bypass_toggle_midstream_mismatch`: Toggle `bypass_lapse` at a hostile time and require exact per-hit reference modeling; any drift is a bug. Covers control/data race sensitivity.
- `X047 | NEG_MTS_047_padding_upper_regression_trap`: Build a case around `padding_upper` where one off-by-one bug would flip correction behavior; require exact match. Covers the most failure-prone padding edge.
- `X048 | NEG_MTS_048_quotient_remainder_mismatch_trap`: Build a case where quotient/remainder corruption would be obvious in packed output fields; require exact match. Covers the divide path.
- `X049 | NEG_MTS_049_route_channel_mismatch_trap`: Require `aso_hit_type1_channel` to match `tcc_8n[5:4]` exactly on every beat; any divergence is a failure. Covers the route-sideband contract.
- `X050 | NEG_MTS_050_tfine_corruption_trap`: Require `TFine` to pass through unchanged under hostile traffic; any divergence is a failure. Covers a simple but critical payload field.

## 6. ToT / ET Fault Cases

- `X051 | NEG_MTS_051_short_mode_nonzero_et_illegal`: In short mode, any nonzero ET is a failure. Covers accidental long-mode leakage.
- `X052 | NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal`: In ToT mode with `EFlag=0`, any nonzero ET is a failure. Covers missed mask behavior.
- `X053 | NEG_MTS_053_positive_delta_missing_et`: For a positive decoded delta, zero ET is a failure unless the reference model predicts clamp/mask. Covers lost-ToT bugs.
- `X054 | NEG_MTS_054_above_511_unsaturated_et`: For a delta above saturation, any ET other than 511 is a failure. Covers lost saturation.
- `X055 | NEG_MTS_055_negative_delta_wrong_clamp`: For the negative-delta reference vector, any behavior that deviates from the current agreed reference is a failure. Covers the area that changed recently.
- `X056 | NEG_MTS_056_stale_derive_tot_after_toggle`: Toggle `derive_tot` and require each accepted hit to use the correct sampled mode; stale mode usage is a failure. Covers control-to-data drift.
- `X057 | NEG_MTS_057_stale_delay_field_after_toggle`: Toggle the delay-field selector and require debug/error logic to follow immediately for newly accepted hits; stale usage is a failure. Covers control-to-debug drift.
- `X058 | NEG_MTS_058_eflag_pipeline_corruption`: Alternate `EFlag` values under load and require ET behavior to follow each hit’s flag exactly. Covers flag-data coupling.
- `X059 | NEG_MTS_059_legacy_positive_vector_regression`: Re-run the checked-in positive smoke vector and treat any mismatch as a failure. Keeps the current TB contract binding.
- `X060 | NEG_MTS_060_legacy_clamp_vector_regression`: Re-run the checked-in clamp/saturation smoke vector and treat any mismatch as a failure. Keeps the current TB contract binding.

## 7. Marker Fault Cases

- `X061 | NEG_MTS_061_missing_first_sop`: Require SOP on the first enabled-channel hit of a run; absence is a failure. Covers marker omission.
- `X062 | NEG_MTS_062_repeated_sop_same_channel`: Require no repeated SOP for the same enabled channel in one run; repetition is a failure. Covers marker duplication.
- `X063 | NEG_MTS_063_sop_on_disabled_channel`: Require no SOP for channels outside the enabled window; any assertion is a failure. Covers mis-scoped marker generation.
- `X064 | NEG_MTS_064_eop_outside_terminating_illegal`: Require no output EOP outside termination scenarios; any assertion is a failure. Covers boundary leakage.
- `X065 | NEG_MTS_065_missing_forwarded_terminating_eop`: Accept a terminating input EOP and require one delayed output EOP; absence is a failure. Covers the core current stop contract.
- `X066 | NEG_MTS_066_eop_pipe_alignment_hole`: Create the case where a delayed EOP pulse can miss `hit_out.valid`; if the boundary is lost, record it as a current design problem. Covers a known alignment weakness.
- `X067 | NEG_MTS_067_empty_nonzero_illegal`: Require `aso_hit_type1_empty` to stay zero in current RTL; any nonzero value is a failure. Covers accidental empty-beat behavior.
- `X068 | NEG_MTS_068_duplicate_output_eop`: Accept one terminating input EOP and require at most one output EOP; duplication is a failure. Covers boundary duplication.
- `X069 | NEG_MTS_069_output_valid_outside_active_states`: Require no output-valid beats outside `RUNNING` or `FLUSHING`; any beat is a failure. Covers state-gating regressions.
- `X070 | NEG_MTS_070_packet_tracker_not_cleared_by_reset`: Require reset to clear packet bookkeeping; any stale in-transaction state is a failure. Covers packet-state cleanup.

## 8. Reset / Recovery Fault Cases

- `X071 | NEG_MTS_071_global_reset_clears_inflight_valids`: Assert global reset with data in flight and require all stage valids to clear. Covers hard reset cleanup.
- `X072 | NEG_MTS_072_global_reset_clears_debug_history`: Assert global reset with debug history active and require subsequent debug outputs to restart from zero. Covers hard reset cleanup of side streams.
- `X073 | NEG_MTS_073_soft_reset_hangs_running_illegal`: Pulse `soft_reset` in `RUNNING` and require the DUT to continue operating afterward; any hang is a failure. Covers software reset recovery.
- `X074 | NEG_MTS_074_soft_reset_creates_phantom_eop`: Pulse `soft_reset` in `FLUSHING` and require no spurious output EOP. Covers reset/marker interaction.
- `X075 | NEG_MTS_075_prepare_after_aborted_packet`: Abort a packet with `IDLE`, then re-enter the standard start sequence; any stale SOP/EOP bookkeeping is a failure. Covers recovery from malformed stops.
- `X076 | NEG_MTS_076_force_stop_stuck_high`: Leave `force_stop` high for a long time and require no accidental acceptance; any accepted hit is a failure. Covers control override stability.
- `X077 | NEG_MTS_077_force_stop_clear_not_reopening`: Clear `force_stop` and require acceptance to resume immediately in `RUNNING`; failure to reopen is a bug. Covers override recovery.
- `X078 | NEG_MTS_078_reset_flow_stuck_sclr`: After `RUN_PREPARE -> SYNC -> RUNNING`, require `reset_flow` not to remain stuck in `SCLR`; any such stickiness is a failure. Covers state-machine advancement.
- `X079 | NEG_MTS_079_reset_flow_stuck_sync`: After `RUNNING`, require `reset_flow` not to remain stuck in `SYNC`; any such stickiness is a failure. Covers state-machine advancement.
- `X080 | NEG_MTS_080_direct_running_no_accept_illegal`: Use the legacy direct start and require clean acceptance; failure is a regression against the current contract. Covers backward-compatibility.

## 9. Generic / Build Fault Cases

- `X081 | NEG_MTS_081_pipeline_two_math_regression`: Compare `LPM_DIV_PIPELINE=2` against `4` and require identical math results aside from latency; any arithmetic difference is a failure. Covers packaged-build correctness.
- `X082 | NEG_MTS_082_remapped_hiterr_not_honored`: Remap `HITERR_BIT_LOC` and require the new bit to control discard; failure indicates the generic is not applied. Covers generic correctness.
- `X083 | NEG_MTS_083_default_latency_generic_not_reflected`: Change `MUTRIG_BUFFER_EXPECTED_LATENCY_8N` at build time and require power-on CSR readback to follow it; failure indicates generic-to-CSR breakage. Covers generic correctness.
- `X084 | NEG_MTS_084_debug_zero_changes_functionality`: Compare `DEBUG=0` and `DEBUG=1`; any functional difference is a failure. Covers debug-gating correctness.
- `X085 | NEG_MTS_085_bank_string_changes_functionality`: Compare `BANK` builds; any functional difference is a failure. Covers a nominally cosmetic generic.
- `X086 | NEG_MTS_086_padding_eop_wait_changes_behavior_today`: Sweep `PADDING_EOP_WAIT_CYCLE`; any current functional change is a failure because the generic is not wired. Covers inert-generic regression.
- `X087 | NEG_MTS_087_crcerr_bit_changes_behavior_today`: Sweep `CRCERR_BIT_LOC`; any current functional change is a failure because the bit is not consumed. Covers inert-generic regression.
- `X088 | NEG_MTS_088_frame_corrupt_bit_changes_behavior_today`: Sweep `FRAME_CORRPT_BIT_LOC`; any current functional change is a failure because the bit is not consumed. Covers inert-generic regression.
- `X089 | NEG_MTS_089_invalid_enabled_window_compile_guard`: Use an invalid enabled-channel window and require the build or configuration layer to reject it explicitly. Covers configuration sanity.
- `X090 | NEG_MTS_090_out_of_range_enabled_values`: Try out-of-range enabled-channel values and require compile-time or elaboration-time rejection. Covers configuration sanity.

## 10. Debug-Stream Fault Cases

- `X091 | NEG_MTS_091_debug_ts_without_processed_hit`: Require `debug_ts_valid` only when a processed hit is present; any free-running debug-ts beat is a failure. Covers side-stream ghost traffic.
- `X092 | NEG_MTS_092_stale_debug_ts_data`: Require `debug_ts_data` to update coherently when `debug_ts_valid` toggles; stale data is a failure. Covers side-stream data freshness.
- `X093 | NEG_MTS_093_debug_burst_on_first_hit_without_history`: Require the first hit after entering `RUNNING` not to produce a bogus stale-delta burst. Covers history warm-up faults.
- `X094 | NEG_MTS_094_ts_delta_without_burst_context`: Require `ts_delta_valid` to remain aligned to the same second-hit history conditions as `debug_burst_valid`; any mismatch is a failure. Covers debug-stream coherence.
- `X095 | NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree`: For the same hit pair, require both debug outputs to agree on sign; disagreement is a failure. Covers sign-conversion coherence.
- `X096 | NEG_MTS_096_arrival_delta_wrap_fault`: Drive a hostile arrival-timing pattern and require the scoreboard to detect any underflow-wrap bug in the arrival delta. Covers debug lower-byte correctness.
- `X097 | NEG_MTS_097_signmag_conversion_extreme_negative`: Craft the most negative representable sign-magnitude delta and require `ts_delta` conversion to match the helper function exactly. Covers conversion extremes.
- `X098 | NEG_MTS_098_delay_field_switch_no_debug_source_change`: Toggle the delay-field selector and require a corresponding change in debug-ts source; failure means stale path selection. Covers control/debug coupling.
- `X099 | NEG_MTS_099_debug_outputs_active_in_idle`: Require all debug-valid outputs low in `IDLE`; any activity is a failure. Covers quiescent-state cleanliness.
- `X100 | NEG_MTS_100_debug_outputs_active_in_reset`: Require all debug-valid outputs low during global reset; any activity is a failure. Covers reset-state cleanliness.

## 11. Counter-Coherency Fault Cases

- `X101 | NEG_MTS_101_discard_counter_on_clean_hit`: Require the discard counter not to increment on an accepted clean hit; any increment is a failure. Covers false discard counting.
- `X102 | NEG_MTS_102_missing_discard_increment`: Require the discard counter to increment on a rejected hiterr beat; absence is a failure. Covers missed discard counting.
- `X103 | NEG_MTS_103_missing_total_increment_on_reject`: Require the total counter to increment even on rejected beats; absence is a failure. Covers ingress-accounting regressions.
- `X104 | NEG_MTS_104_spurious_total_increment_without_valid`: Require the total counter not to increment without `asi_hit_type0_valid`; any increment is a failure. Covers false ingress accounting.
- `X105 | NEG_MTS_105_hi_lo_counter_snapshot_incoherent`: Poll high/low counters around rollover and treat incoherent snapshots as a failure unless the software read method accounts for them. Covers software-visible counting correctness.
- `X106 | NEG_MTS_106_soft_reset_counter_clear_failure`: Pulse `soft_reset` and require both counters to clear; any stale count is a failure. Covers software-reset accounting.
- `X107 | NEG_MTS_107_sync_counter_clear_failure`: Execute the standard prepare/sync sequence and require both counters to clear; any stale count is a failure. Covers run-sequence accounting.
- `X108 | NEG_MTS_108_running_status_high_outside_run`: Require CSR bit 0 low outside `RUNNING`; any high value is a failure. Covers control/status truthfulness.
- `X109 | NEG_MTS_109_running_status_low_inside_run`: Require CSR bit 0 high in `RUNNING`; any low value is a failure. Covers control/status truthfulness.
- `X110 | NEG_MTS_110_control_readback_mismatch`: Require `force_stop`, `soft_reset`, `bypass_lapse`, `discard_hiterr`, and op-mode fields to read back as implemented; mismatch is a failure. Covers software-visible control state.

## 12. Termination Failure Injections

- `X111 | NEG_MTS_111_terminate_without_real_eop_gap`: Enter `TERMINATING` and never provide a real EOP; tag the missing downstream boundary as the current architectural gap. Covers the key stop weakness.
- `X112 | NEG_MTS_112_idle_before_eop_delay_finishes`: Enter `TERMINATING`, accept EOP, then issue `IDLE` before the delayed pulse matures; tag any lost boundary explicitly. Covers control precedence over stop bookkeeping.
- `X113 | NEG_MTS_113_multiple_eops_multiple_boundaries`: Feed multiple EOP-tagged beats in `FLUSHING`; if multiple output boundaries occur, tag the result as a current design weakness. Covers over-generation of stop markers.
- `X114 | NEG_MTS_114_packet_crosses_terminate_edge`: Start a packet before `TERMINATING` and close it after the stop edge; require exactly one boundary and correct payload retention. Covers the core stop-crossing scenario.
- `X115 | NEG_MTS_115_disabled_sideband_boundary_loss`: Use a sideband channel outside the enabled window during a terminating EOP and tag any missing boundary/bookkeeping issue explicitly. Covers sideband/window stop mismatch.
- `X116 | NEG_MTS_116_terminate_ack_before_work_done`: Observe `asi_ctrl_ready` during termination and tag the fact that it acknowledges immediately, before drain completion. Covers the handshake design gap.
- `X117 | NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap`: Continue driving fresh hits in `FLUSHING` and tag the current acceptance as an upgrade-gap behavior rather than a clean architectural pass. Covers post-stop openness.
- `X118 | NEG_MTS_118_missing_boundary_with_packet_open`: Track a packet-in-transaction case and require a downstream terminal boundary; absence is a failure. Covers packet-aware stop correctness.
- `X119 | NEG_MTS_119_duplicate_boundary_per_run`: Require at most one terminal boundary per run stop; duplicates are failures or current-gap findings. Covers end-of-run uniqueness.
- `X120 | NEG_MTS_120_idle_before_pipeline_empty`: Force `IDLE` while in-flight data remains and require no silent data loss; any loss is a failure. Covers premature-stop cleanup.

## 13. Must-Fail-Today Upgrade Gates

- `X121 | NEG_MTS_121_prepare_ready_stateful_upgrade`: Define the post-upgrade expectation that `asi_ctrl_ready` deasserts during `RUN_PREPARE`; it should fail on current RTL. Creates an explicit future gate.
- `X122 | NEG_MTS_122_sync_ready_stateful_upgrade`: Define the post-upgrade expectation that `asi_ctrl_ready` deasserts during `SYNC`; it should fail on current RTL. Creates an explicit future gate.
- `X123 | NEG_MTS_123_flushing_ready_stateful_upgrade`: Define the post-upgrade expectation that `asi_ctrl_ready` deasserts during `FLUSHING`; it should fail on current RTL. Creates an explicit future gate.
- `X124 | NEG_MTS_124_terminate_ack_after_drain_upgrade`: Define the post-upgrade expectation that terminate acknowledgement waits for drain completion; it should fail on current RTL. Creates an explicit future gate.
- `X125 | NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade`: Define the post-upgrade expectation that a deterministic terminal boundary exists even without a real input EOP; it should fail on current RTL. Creates an explicit future gate.
- `X126 | NEG_MTS_126_no_fresh_accept_in_flushing_upgrade`: Define the post-upgrade expectation that fresh hits are no longer accepted in `FLUSHING`; it should fail on current RTL. Creates an explicit future gate.
- `X127 | NEG_MTS_127_exactly_one_boundary_per_stop_upgrade`: Define the post-upgrade expectation that each stop produces exactly one terminal boundary; it should fail on current RTL whenever multi-EOP stress can duplicate the boundary. Creates an explicit future gate.
- `X128 | NEG_MTS_128_idle_only_after_boundary_upgrade`: Define the post-upgrade expectation that `IDLE` is reached only after boundary forwarding; it should fail on current RTL. Creates an explicit future gate.
- `X129 | NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade`: Define the post-upgrade expectation that the control handshake reflects completed work, not just command sampling; it should fail on current RTL. Creates an explicit future gate.
- `X130 | NEG_MTS_130_full_run_sequence_upgrade_suite`: Bundle all termination-contract assertions from `RUN_SEQ_UPGRADE_PLAN.md` into one must-fail-today suite that becomes must-pass after the RTL repair. Creates the final upgrade signoff gate.
