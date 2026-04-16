# DV Edge Cases — mutrig_timestamp_processor

**Purpose:** boundary and corner cases for `mts_processor`  
**Naming convention:** `CORNER_MTS_###_description`  
**Count target:** 130 substantive cases

## 1. Control-Timing Edges

- `E001 | CORNER_MTS_001_reset_release_with_ctrl_valid`: Deassert `i_rst` on the same cycle that `asi_ctrl_valid` pulses; verify reset wins cleanly and the first legal command after reset is the only one that takes effect. Catches reset/control races.
- `E002 | CORNER_MTS_002_running_and_first_hit_same_cycle`: Assert `RUNNING` and drive the first valid hit on the same cycle; verify whether acceptance begins immediately or one cycle later and freeze that behavior in the reference model. Covers start-edge timing.
- `E003 | CORNER_MTS_003_terminate_on_final_eop_cycle`: Assert `TERMINATING` on the same cycle as an accepted input EOP beat; verify one and only one delayed boundary is generated. Covers the stop-edge coincidence.
- `E004 | CORNER_MTS_004_idle_on_output_valid_cycle`: Assert `IDLE` on the same cycle a processed output would otherwise appear; verify whether the current RTL suppresses or emits that beat and capture the exact precedence. Covers output-vs-state races.
- `E005 | CORNER_MTS_005_prepare_then_immediate_idle`: Issue `RUN_PREPARE` and then `IDLE` one cycle later; verify `RESET/SCLR` aborts cleanly without stale ready behavior. Covers partial-sequence abort.
- `E006 | CORNER_MTS_006_sync_then_immediate_running`: Issue `SYNC` and then `RUNNING` on consecutive cycles; verify `reset_flow` transitions cleanly from `SYNC` to `DONE`. Covers the tight standard-sequence boundary.
- `E007 | CORNER_MTS_007_back_to_back_running_words`: Pulse `RUNNING` on consecutive cycles; verify the command decode does not corrupt processor state or counters. Covers repeated state assertions.
- `E008 | CORNER_MTS_008_back_to_back_terminating_words`: Pulse `TERMINATING` on consecutive cycles; verify `FLUSHING` is stable and the stop bookkeeping does not duplicate unexpectedly. Covers repeated stop commands.
- `E009 | CORNER_MTS_009_illegal_ctrl_word_while_active`: Drive a non-onehot control word while the datapath is active; verify `run_state_cmd=ERROR` and capture whether processor state remains unchanged. Documents illegal command containment.
- `E010 | CORNER_MTS_010_stale_ctrl_data_with_valid_gap`: Hold a prior command value on `asi_ctrl_data` while dropping `valid`; verify no re-decode occurs without a fresh valid pulse. Covers data-hold assumptions.

## 2. CSR Boundary Values

- `E011 | CORNER_MTS_011_expected_latency_zero`: Write `expected_latency=0` and immediately process a hit; verify the error window treats even zero-delta hits as faults per the strict comparison. Covers the absolute lower bound.
- `E012 | CORNER_MTS_012_expected_latency_one`: Write `expected_latency=1` and process hits around the threshold; verify only strictly positive sub-1 values clear the error flag. Covers the smallest nonzero bound.
- `E013 | CORNER_MTS_013_expected_latency_large_16bit_value`: Write a large but moderate value such as `0x0000FFFF`; verify padding and error-window math remain coherent. Covers a realistic large software setting.
- `E014 | CORNER_MTS_014_expected_latency_all_ones`: Write `0xFFFFFFFF`; verify the scoreboard models the resize and `padding_upper` math exactly and no hidden truncation goes unnoticed. Covers the absolute upper bound.
- `E015 | CORNER_MTS_015_reserved_opmode_bit28_only`: Write only `op_mode[28]=1`; verify the bit has no functional effect and does not read back as an implemented mode. Documents the reserved field boundary.
- `E016 | CORNER_MTS_016_multi_field_control_write`: Toggle `go`, `force_stop`, `soft_reset`, `bypass_lapse`, `discard_hiterr`, and op-mode bits in one write; verify all implemented fields settle correctly. Covers packed CSR updates.
- `E017 | CORNER_MTS_017_read_during_soft_reset_window`: Read CSR word `0x0` immediately after pulsing `soft_reset`; verify the self-clearing bit and counters present a deterministic state. Covers self-clear timing.
- `E018 | CORNER_MTS_018_counter_read_on_low_word_rollover`: Read total-hit high/low words across the exact low-word rollover boundary; verify the scoreboard can recover a coherent snapshot. Covers 48-bit readout edges.
- `E019 | CORNER_MTS_019_csr_access_in_flushing`: Perform reads and writes while `processor_state=FLUSHING`; verify the control plane remains functional and does not perturb marker generation. Covers stop-time software activity.
- `E020 | CORNER_MTS_020_polling_unsupported_addr7`: Repeatedly poll an unsupported CSR address; verify constant zero readback and no latent side effects. Covers out-of-range access stability.

## 3. Input-Protocol Boundaries

- `E021 | CORNER_MTS_021_plain_hit_no_markers`: Drive a valid beat with neither SOP nor EOP set; verify normal acceptance and no marker side effects. Covers the most basic input beat.
- `E022 | CORNER_MTS_022_sop_only_beat`: Drive a valid beat with only SOP set; verify packet tracking starts for the sideband channel and no output EOP is created. Covers packet-open boundaries.
- `E023 | CORNER_MTS_023_eop_only_beat`: Drive a valid beat with only EOP set; verify packet tracking closes if the sideband channel is currently in transaction and no false SOP appears. Covers packet-close boundaries.
- `E024 | CORNER_MTS_024_single_beat_packet`: Drive a valid beat with both SOP and EOP set; verify the packet tracker handles a one-beat packet cleanly. Covers the shortest legal packet shape.
- `E025 | CORNER_MTS_025_zero_gap_hits`: Drive accepted hits on consecutive cycles; verify the pipeline accepts them without overwriting stage-0 metadata. Covers line-rate ingress.
- `E026 | CORNER_MTS_026_one_cycle_gap_hits`: Drive accepted hits with a one-cycle bubble; verify history logic and output spacing remain deterministic. Covers minimally gapped ingress.
- `E027 | CORNER_MTS_027_long_gap_then_hit`: Leave the DUT idle in `RUNNING` for many cycles, then send a hit; verify no stale history or counters leak into the new transaction. Covers sparse traffic boundaries.
- `E028 | CORNER_MTS_028_max_payload_fields`: Drive payload `asic=15`, `channel=31`, and large raw T/E symbols; verify field extraction and packing at their max widths. Covers payload field limits.
- `E029 | CORNER_MTS_029_nonzero_mux_bits_in_sideband`: Drive nonzero upper mux bits in `asi_hit_type0_channel`; verify packet tracking uses the full sideband field and the scoreboard handles the distinction from payload channel. Covers the sideband envelope.
- `E030 | CORNER_MTS_030_sideband_channel_outside_enabled_window`: Drive sideband ASIC/channel values outside the enabled window; verify packet tracking and SOP generation do not accidentally index outside the configured range. Covers enabled-window edges.

## 4. Overflow-Window And Padding Edges

- `E031 | CORNER_MTS_031_t_gray_equal_padding_upper`: Drive a decoded T gray value exactly equal to `padding_upper`; verify no overflow subtraction occurs because the comparison is strict greater-than. Covers the threshold equality.
- `E032 | CORNER_MTS_032_t_gray_one_above_upper`: Drive a decoded T gray value one tick above `padding_upper` with adjust active; verify one overflow subtraction occurs. Covers the first correcting case.
- `E033 | CORNER_MTS_033_e_gray_equal_padding_upper`: Repeat the equality boundary for the E branch; verify no subtraction. Covers the E threshold equality.
- `E034 | CORNER_MTS_034_e_gray_one_above_upper`: Repeat the first-correcting case for the E branch; verify one subtraction. Covers the E threshold crossing.
- `E035 | CORNER_MTS_035_mts_counter_wrap_pulse`: Run the local MTS counter through the `32766 -> 4` wrap and verify `fpga_overflow_happened` pulses exactly at the transition. Covers the explicit wrap logic.
- `E036 | CORNER_MTS_036_overflow_lookback_expiry`: Observe the cycle where `fpga_overflow_lookback_cnt` reaches zero; verify `overflow_adjust_active` drops cleanly. Covers lookback expiration.
- `E037 | CORNER_MTS_037_lpm_multi_valid_masks_adjust`: Create an overflow while `lpm_multi_valid_cnt` is nonzero; verify `overflow_adjust_active` stays low. Covers the divider-launch mask.
- `E038 | CORNER_MTS_038_bypass_toggle_before_hit`: Toggle `bypass_lapse` one cycle before an accepted hit; verify the hit uses the new mode. Covers control-to-data setup timing.
- `E039 | CORNER_MTS_039_bypass_toggle_after_hit_accept`: Toggle `bypass_lapse` one cycle after a hit is accepted; verify the already accepted hit keeps the mode it latched. Covers in-flight stability.
- `E040 | CORNER_MTS_040_latency_write_at_overflow_boundary`: Rewrite `expected_latency` near an overflow event; verify only subsequent hits see the new `padding_upper`. Covers control updates near the wrap window.

## 5. Divide / Remainder / Route Edges

- `E041 | CORNER_MTS_041_remainder_zero_case`: Drive a hit that produces divide remainder 0; verify `tcc_1n6=0` and correct route-channel extraction. Covers the first remainder bin.
- `E042 | CORNER_MTS_042_remainder_one_case`: Drive a hit that produces divide remainder 1; verify `tcc_1n6=1`. Covers the second remainder bin.
- `E043 | CORNER_MTS_043_remainder_two_case`: Drive a hit that produces divide remainder 2; verify `tcc_1n6=2`. Covers the midpoint remainder bin.
- `E044 | CORNER_MTS_044_remainder_three_case`: Drive a hit that produces divide remainder 3; verify `tcc_1n6=3`. Covers the fourth remainder bin.
- `E045 | CORNER_MTS_045_remainder_four_case`: Drive a hit that produces divide remainder 4; verify `tcc_1n6=4`. Covers the last legal remainder bin.
- `E046 | CORNER_MTS_046_route_bits_00`: Drive a quotient with bits `[5:4]=00`; verify route channel `0`. Covers the first route-lane boundary.
- `E047 | CORNER_MTS_047_route_bits_01`: Drive a quotient with bits `[5:4]=01`; verify route channel `1`. Covers the second route-lane boundary.
- `E048 | CORNER_MTS_048_route_bits_10`: Drive a quotient with bits `[5:4]=10`; verify route channel `2`. Covers the third route-lane boundary.
- `E049 | CORNER_MTS_049_route_bits_11`: Drive a quotient with bits `[5:4]=11`; verify route channel `3`. Covers the fourth route-lane boundary.
- `E050 | CORNER_MTS_050_route_change_across_boundary`: Drive two hits whose quotients straddle a `[5:4]` boundary transition; verify output data and sideband route change together. Covers route-change coherence.

## 6. ET And Mode Edges

- `E051 | CORNER_MTS_051_short_mode_with_eflag_high`: In short mode (`derive_tot=0`), drive `EFlag=1`; verify ET still remains zero. Covers the mode/flag interaction boundary.
- `E052 | CORNER_MTS_052_tot_mode_eflag_zero_large_delta`: In ToT mode, drive a very large decoded delta with `EFlag=0`; verify ET still remains zero. Confirms the flag mask dominates magnitude.
- `E053 | CORNER_MTS_053_tot_mode_smallest_positive_delta`: Drive the smallest decoded positive delta; verify ET becomes `1`. Covers the first positive ToT value.
- `E054 | CORNER_MTS_054_tot_mode_largest_unsaturated_delta`: Drive the largest decoded positive delta below saturation; verify ET becomes `510`. Covers the last unsaturated ToT value.
- `E055 | CORNER_MTS_055_tot_mode_first_saturated_delta`: Drive the first decoded delta above the saturation threshold; verify ET becomes `511`. Covers the saturation edge.
- `E056 | CORNER_MTS_056_tot_mode_negative_delta_case`: Drive a decoded negative delta and verify the current clamp/reference behavior exactly. Covers the sign boundary that changed recently.
- `E057 | CORNER_MTS_057_toggle_derive_tot_between_hits`: Switch `derive_tot` between consecutive hits; verify each hit uses the mode sampled when it was accepted. Covers mode handoff timing.
- `E058 | CORNER_MTS_058_toggle_delay_field_between_hits`: Switch `delay_ts_field_use_t` between consecutive hits; verify the debug/error path follows the per-hit sampled mode. Covers mode handoff timing.
- `E059 | CORNER_MTS_059_toggle_eflag_between_hits`: Alternate `EFlag` on otherwise similar hits; verify ET toggles between masked and calculated behavior. Covers flag transitions.
- `E060 | CORNER_MTS_060_tfine_extremes`: Drive `TFine=0` and `TFine=31`; verify both extremes propagate unchanged. Covers the 5-bit field boundary.

## 7. Output-Marker Edges

- `E061 | CORNER_MTS_061_first_sop_channel0_after_reset`: After reset, drive the first accepted hit for enabled channel 0; verify SOP appears exactly once. Covers the SOP reset edge.
- `E062 | CORNER_MTS_062_first_sop_channel3_after_reset`: Repeat for enabled channel 3; verify SOP appears exactly once. Covers the upper enabled channel.
- `E063 | CORNER_MTS_063_first_hit_disabled_channel_no_sop`: Drive the first accepted hit for a payload channel outside the enabled window; verify no SOP is emitted because `startofrun_sent` only loops over enabled channels. Documents the configurable marker scope.
- `E064 | CORNER_MTS_064_interleaved_channels_no_repeat_sop`: Interleave hits from enabled and already-seen channels; verify SOP does not repeat for the already-seen channel. Covers mixed-channel marker persistence.
- `E065 | CORNER_MTS_065_single_terminating_eop_pulse`: Drive one accepted terminating EOP and verify exactly one delayed output EOP. Covers the happy-path boundary count.
- `E066 | CORNER_MTS_066_eop_pipe_without_valid_alignment`: Create a case where the delayed EOP pulse would arrive when `hit_out.valid=0`; verify whether the current RTL drops the boundary and tag the exact behavior. Covers the known alignment hazard.
- `E067 | CORNER_MTS_067_nonterminating_eop_is_local_only`: Drive ordinary EOPs in `RUNNING`; verify they do not become output EOPs. Covers marker isolation before termination.
- `E068 | CORNER_MTS_068_output_eop_with_ready_low`: Hold sink `ready=0` during the terminating output beat; verify the current RTL still emits the EOP. Documents the ignored-backpressure contract at the boundary.
- `E069 | CORNER_MTS_069_sop_and_eop_same_output_beat`: Explore whether a first-hit SOP and delayed terminating EOP can coincide on the same output beat; capture the exact reachable behavior. Covers rare marker overlap.
- `E070 | CORNER_MTS_070_empty_zero_on_all_output_classes`: Check `empty` on quiet, SOP, ordinary valid, and terminating EOP beats; expect zero throughout. Covers all marker classes.

## 8. Debug / Error Threshold Edges

- `E071 | CORNER_MTS_071_debug_ts_minus_one`: Craft a hit yielding `debug_ts=-1`; verify `aso_hit_type1_error=1`. Covers the first negative error.
- `E072 | CORNER_MTS_072_debug_ts_zero`: Craft a hit yielding `debug_ts=0`; verify `aso_hit_type1_error=1`. Covers the lower equality edge.
- `E073 | CORNER_MTS_073_debug_ts_plus_one`: Craft a hit yielding `debug_ts=+1` with a window above 1; verify `aso_hit_type1_error=0`. Covers the first clean positive case.
- `E074 | CORNER_MTS_074_debug_ts_expected_minus_one`: Craft a hit yielding `debug_ts=expected_latency-1`; verify `aso_hit_type1_error=0`. Covers the upper clean edge.
- `E075 | CORNER_MTS_075_debug_ts_expected_exact`: Craft a hit yielding `debug_ts=expected_latency`; verify `aso_hit_type1_error=1`. Covers the upper equality edge.
- `E076 | CORNER_MTS_076_debug_ts_expected_plus_one`: Craft a hit yielding `debug_ts=expected_latency+1`; verify `aso_hit_type1_error=1`. Covers the first high-window error.
- `E077 | CORNER_MTS_077_t_vs_e_path_error_flip`: Choose raw symbols that produce different T and E delay results; toggle the delay-field selection and verify the error flag flips accordingly. Covers path selection sensitivity.
- `E078 | CORNER_MTS_078_debug_burst_positive_trim_edge`: Drive a positive timestamp delta right at the trim boundary used for debug-burst packing; verify the high bits are captured correctly. Covers trimming edges.
- `E079 | CORNER_MTS_079_debug_burst_negative_trim_edge`: Do the same for a negative delta and verify sign handling remains correct. Covers trimming edges for the signed branch.
- `E080 | CORNER_MTS_080_ts_delta_zero_boundary`: Drive repeated equal timestamps and verify `ts_delta` encodes a clean zero. Covers the sign-conversion zero point.

## 9. Reset / Force-Stop Edges

- `E081 | CORNER_MTS_081_force_stop_same_cycle_as_valid`: Assert `force_stop` in the same cycle a valid hit arrives; verify the precedence between control update and acceptance is deterministic. Covers tight control/data timing.
- `E082 | CORNER_MTS_082_force_stop_clear_before_next_hit`: Clear `force_stop` one cycle before the next hit; verify acceptance resumes cleanly. Covers re-enable timing.
- `E083 | CORNER_MTS_083_soft_reset_while_running_idle_pipe`: Pulse `soft_reset` while `RUNNING` but with no in-flight beats; verify counters clear and operation resumes. Covers the simplest software reset.
- `E084 | CORNER_MTS_084_soft_reset_with_inflight_beats`: Pulse `soft_reset` while accepted beats are already in flight; verify counters clear and the model captures any remaining output beats. Covers reset/data overlap.
- `E085 | CORNER_MTS_085_soft_reset_in_flushing`: Pulse `soft_reset` in `FLUSHING`; verify it clears counters without generating spurious output markers. Covers stop-time software reset.
- `E086 | CORNER_MTS_086_global_reset_with_pending_term_eop`: Assert global reset while `terminating_eop_pipe` contains a pending pulse; verify the pulse is cleared. Covers asynchronous termination cleanup.
- `E087 | CORNER_MTS_087_global_reset_with_debug_history`: Assert global reset while debug-burst history registers are nonzero; verify subsequent debug outputs start from zero. Covers history cleanup.
- `E088 | CORNER_MTS_088_prepare_after_soft_reset`: Pulse `soft_reset`, then run the standard start sequence; verify the DUT can arm again cleanly. Covers reset recovery.
- `E089 | CORNER_MTS_089_sync_after_force_stop_cycle`: Set and clear `force_stop`, then execute `SYNC -> RUNNING`; verify no stale blockage remains. Covers control recovery.
- `E090 | CORNER_MTS_090_idle_during_sclr_flush`: Send `IDLE` while in `RESET/SCLR`; verify the DUT returns to `IDLE` without stale ready or marker behavior. Covers flush abort.

## 10. Generic / Configuration Edges

- `E091 | CORNER_MTS_091_single_channel_window_index0`: Build with only channel 0 enabled; verify the start-of-run bookkeeping arrays index correctly. Covers the lower loop bound.
- `E092 | CORNER_MTS_092_single_channel_window_index3`: Build with only channel 3 enabled; verify bookkeeping indexes correctly at the upper default bound. Covers the upper loop bound.
- `E093 | CORNER_MTS_093_middle_window_indexing`: Build with only channels 1 and 2 enabled; verify bookkeeping ignores channels 0 and 3. Covers a shifted window.
- `E094 | CORNER_MTS_094_packaged_div_pipeline_delay`: Build with `LPM_DIV_PIPELINE=2`; verify the terminating EOP delay becomes `6` cycles (`2 + 4`) and matches the scoreboard. Covers packaged-latency math.
- `E095 | CORNER_MTS_095_rtl_div_pipeline_delay`: Build with `LPM_DIV_PIPELINE=4`; verify the terminating EOP delay becomes `8` cycles (`4 + 4`). Covers RTL-default latency math.
- `E096 | CORNER_MTS_096_zero_default_latency_generic`: Build with `MUTRIG_BUFFER_EXPECTED_LATENCY_8N=0`; verify power-on CSR readback and error-window behavior follow that generic. Covers the extreme generic default.
- `E097 | CORNER_MTS_097_one_tick_default_latency_generic`: Build with `MUTRIG_BUFFER_EXPECTED_LATENCY_8N=1`; verify the narrow clean window behaves as expected. Covers the smallest positive generic default.
- `E098 | CORNER_MTS_098_remapped_hiterr_to_bit2`: Build with `HITERR_BIT_LOC=2`; verify only error bit 2 controls discard. Covers error-bit relocation.
- `E099 | CORNER_MTS_099_frame_corrupt_bit_still_inert`: Sweep `FRAME_CORRPT_BIT_LOC`; verify no current functional effect. Covers one inert generic explicitly.
- `E100 | CORNER_MTS_100_padding_eop_wait_still_inert`: Sweep `PADDING_EOP_WAIT_CYCLE`; verify no current functional effect. Covers the other inert generic explicitly.

## 11. Backpressure / Ready Edges

- `E101 | CORNER_MTS_101_output_ready_low_single_beat`: Hold `aso_hit_type1_ready=0` for a single-beat output; verify the current DUT still emits the beat. Documents the no-backpressure edge case.
- `E102 | CORNER_MTS_102_output_ready_low_multi_beat`: Hold `ready=0` across multiple output beats; verify the stream still advances. Documents sustained no-backpressure behavior.
- `E103 | CORNER_MTS_103_output_ready_toggle_every_cycle`: Toggle `ready` on every cycle; verify the emitted transaction log is unchanged. Proves current output independence.
- `E104 | CORNER_MTS_104_output_ready_low_on_eop`: Hold `ready=0` only on the terminating EOP beat; verify the current DUT still emits the boundary. Covers the most important ignored-ready beat.
- `E105 | CORNER_MTS_105_output_ready_unknown_monitor_trap`: Drive illegal ready values in simulation and ensure monitors/SVA flag the bench misuse without masking DUT behavior. Covers bench robustness.
- `E106 | CORNER_MTS_106_input_ready_high_in_flushing`: Verify `asi_hit_type0_ready=1` in `FLUSHING` with `force_stop=0`. Covers the implemented stop-state ready edge.
- `E107 | CORNER_MTS_107_input_ready_low_in_idle`: Verify `asi_hit_type0_ready=0` in `IDLE` even if the source wants to drive traffic. Covers idle gating.
- `E108 | CORNER_MTS_108_input_ready_high_in_reset_sclr`: Verify `asi_hit_type0_ready=1` specifically in `RESET/SCLR`. Covers flush-ready behavior.
- `E109 | CORNER_MTS_109_input_ready_low_in_reset_sync`: Verify `asi_hit_type0_ready=0` specifically in `RESET/SYNC`. Covers sync-hold behavior.
- `E110 | CORNER_MTS_110_output_quiet_outside_running_flush`: Verify no output beats are emitted in `IDLE` or `RESET` even if sink `ready` is high. Covers non-active-state quietness.

## 12. Termination Edges

- `E111 | CORNER_MTS_111_terminate_with_no_packet_open`: Enter `TERMINATING` when no packet is in transaction; verify no boundary appears unless a real terminating EOP is later accepted. Covers the empty-stop path.
- `E112 | CORNER_MTS_112_terminate_one_cycle_before_eop`: Assert `TERMINATING` one cycle before a final accepted EOP beat; verify the delayed boundary is still created. Covers a near-stop race.
- `E113 | CORNER_MTS_113_terminate_same_cycle_as_eop`: Assert `TERMINATING` on the same cycle as the accepted EOP beat; verify one delayed boundary is created. Covers a tighter race.
- `E114 | CORNER_MTS_114_terminate_one_cycle_after_eop`: Assert `TERMINATING` one cycle after an EOP beat that was accepted in `RUNNING`; verify no output boundary is created. Documents the exact boundary condition.
- `E115 | CORNER_MTS_115_idle_before_eop_delay_matures`: Send `IDLE` immediately after a terminating EOP is accepted; verify whether the current RTL suppresses the delayed boundary. Covers the known control race.
- `E116 | CORNER_MTS_116_multiple_eops_in_flushing`: Accept multiple EOP-tagged beats in `FLUSHING`; verify whether multiple delayed boundary pulses can occur and capture the exact current behavior. Covers duplicate-boundary exposure.
- `E117 | CORNER_MTS_117_packet_open_then_abort`: Accept SOP without a closing EOP, then force `IDLE`; verify packet bookkeeping clears on the next reset path. Covers incomplete-packet abort cleanup.
- `E118 | CORNER_MTS_118_terminating_eop_disabled_sideband_channel`: Accept a terminating EOP on a sideband channel outside the enabled window; verify bookkeeping and boundary expectations match the configured loops. Covers sideband-window mismatch.
- `E119 | CORNER_MTS_119_flushing_accepts_non_eop_hits`: Continue driving clean non-EOP hits in `FLUSHING`; verify the current RTL keeps accepting and emitting them. Documents the open-flush behavior precisely.
- `E120 | CORNER_MTS_120_upgrade_ready_should_wait_for_drain`: Mark the future case in which control ready must remain low across local drain work. This is a boundary-focused upgrade gate.

## 13. Upgrade-Readiness Edges

- `E121 | CORNER_MTS_121_prepare_ready_gap_upgrade`: Mark the future case in which `RUN_PREPARE` deasserts `asi_ctrl_ready` until the IP is actually prepared. Derived directly from the run-sequence plan.
- `E122 | CORNER_MTS_122_sync_ready_gap_upgrade`: Mark the future case in which `SYNC` deasserts `asi_ctrl_ready` until the local counters are armed. Derived directly from the run-sequence plan.
- `E123 | CORNER_MTS_123_flushing_ready_gap_upgrade`: Mark the future case in which `FLUSHING` deasserts `asi_ctrl_ready` until drain completion. Derived directly from the run-sequence plan.
- `E124 | CORNER_MTS_124_missing_synthetic_boundary_upgrade`: Mark the future case in which no real input EOP arrives during termination and the upgraded IP must still provide a deterministic downstream terminal boundary. Captures the stated upgrade target.
- `E125 | CORNER_MTS_125_eop_alignment_hole_upgrade`: Mark the future case in which a terminal boundary must not be lost merely because the delayed pulse misses a `hit_out.valid` beat. Captures the current hazard explicitly.
- `E126 | CORNER_MTS_126_crcerr_ignore_upgrade_gap`: Mark the upgrade discussion around CRCERR handling during termination; today it is inert and must remain documented. Keeps the plan honest about current scope.
- `E127 | CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap`: Mark the upgrade discussion around frame-corrupt handling during termination; today it is inert and must remain documented. Keeps the plan honest about current scope.
- `E128 | CORNER_MTS_128_accept_command_vs_complete_work_upgrade`: Mark the future distinction between “terminate command sampled” and “terminate work finished.” Captures the handshake semantics that do not exist yet.
- `E129 | CORNER_MTS_129_one_boundary_per_run_upgrade`: Mark the future requirement that exactly one terminal boundary exists per run stop, not per late EOP beat. Captures a likely post-patch invariant.
- `E130 | CORNER_MTS_130_idle_after_boundary_upgrade`: Mark the future requirement that `IDLE` is observed only after terminal boundary forwarding and local pipeline drain. Captures the final stop-sequence invariant.
