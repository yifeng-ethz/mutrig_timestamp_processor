# DV Basic Cases — mutrig_timestamp_processor

**Purpose:** baseline functional cases for `mts_processor`  
**Naming convention:** `STD_MTS_###_description`  
**Count target:** 130 substantive cases grounded in `mts_processor.vhd`, `mts_processor_hw.tcl`, `mts_processor_tb.vhd`, and `RUN_SEQ_UPGRADE_PLAN.md`

## 1. Reset And Bring-Up

- `B001 | STD_MTS_001_powerup_reset_idle`: Hold `i_rst=1` with all interfaces quiet; expect `run_state_cmd=IDLE`, `processor_state=IDLE`, `asi_hit_type0_ready=0`, all output valids low, and counters cleared. Proves safe power-up.
- `B002 | STD_MTS_002_reset_release_idle_quiet`: Release `i_rst` without sending control words; expect the DUT to remain quiescent in `IDLE` and not emit stale `hit_type1`, `debug_ts`, `debug_burst`, or `ts_delta`. Catches reset-release garbage.
- `B003 | STD_MTS_003_direct_running_entry_allowed`: Send only the `RUNNING` control word after reset; expect the current RTL to enter `RUNNING` directly because `csr.go` defaults high. Locks down the legacy nonstandard fast-entry path.
- `B004 | STD_MTS_004_run_prepare_enters_reset_sclr`: From `IDLE`, send `RUN_PREPARE`; expect `processor_state=RESET`, `reset_flow=SCLR`, and `asi_hit_type0_ready=1` for flush acceptance. Verifies the standard first step.
- `B005 | STD_MTS_005_sync_enters_reset_sync`: Follow `RUN_PREPARE` with `SYNC`; expect `reset_flow=SYNC`, input ready low, and the local counters held/reset. Verifies the second step of the standard sequence.
- `B006 | STD_MTS_006_running_from_sync`: After `SYNC`, send `RUNNING`; expect `processor_state=RUNNING`, acceptance of fresh hits, and counter advancement. Confirms the legal arm-to-run transition.
- `B007 | STD_MTS_007_terminating_enters_flushing`: From `RUNNING`, send `TERMINATING`; expect `processor_state=FLUSHING` and continued input readiness under the current contract. Proves the explicit stop-state entry.
- `B008 | STD_MTS_008_idle_from_flushing`: From `FLUSHING`, send `IDLE`; expect quiescent outputs and no lingering debug activity. Verifies orderly return to idle.
- `B009 | STD_MTS_009_running_abort_to_idle`: From `RUNNING`, send `IDLE` directly; expect output silence and no further hit acceptance. Covers the direct abort path implemented in the FSM.
- `B010 | STD_MTS_010_global_reset_during_flushing`: Assert `i_rst` while the DUT is in `FLUSHING`; expect all pipeline valids, marker pipes, and debug histories to clear immediately. Catches stuck in-flight state.

## 2. CSR Defaults And Control Bits

- `B011 | STD_MTS_011_control_readback_after_reset`: Read CSR word `0x0` after reset; expect bit 0 to read `0` because it reports live RUNNING state even though internal `csr.go` reset value is `1`. Locks down the status-vs-storage quirk.
- `B012 | STD_MTS_012_discard_counter_default_zero`: Read CSR word `0x4` after reset; expect the discarded-hit counter to be zero. Verifies clean debug state.
- `B013 | STD_MTS_013_expected_latency_default_2000`: Read CSR word `0x8` after reset; expect `2000` per the generic default. Confirms the software-visible power-on window.
- `B014 | STD_MTS_014_total_counter_hi_default_zero`: Read CSR word `0xC` after reset; expect the upper hit-count word to be zero. Guards reset-map correctness.
- `B015 | STD_MTS_015_total_counter_lo_default_zero`: Read CSR word `0x10` after reset; expect the lower hit-count word to be zero. Guards reset-map correctness.
- `B016 | STD_MTS_016_force_stop_readback`: Write CSR bit 1 high, then read word `0x0`; expect `force_stop=1` to persist until cleared. Verifies direct software control of the acceptance override.
- `B017 | STD_MTS_017_soft_reset_self_clear`: Write CSR bit 2 high and poll back; expect the bit to pulse and then self-clear. Confirms the self-clearing implementation in `proc_avmm_csr`.
- `B018 | STD_MTS_018_bypass_lapse_readback`: Write CSR bit 3 high and low; expect readback to match and subsequent datapath behavior to switch between padded and bypassed timestamping. Proves the mode latch.
- `B019 | STD_MTS_019_discard_hiterr_readback`: Write CSR bit 4 high and low; expect readback to match and hit acceptance policy to track it. Proves the error-discard policy latch.
- `B020 | STD_MTS_020_op_mode_bits_readback`: Write `op_mode[30:28]` with `derive_tot`, `delay_ts_field_use_t`, and reserved bit 28 variations; expect bits 30 and 29 to read back and bit 28 to remain functionally inert. Documents the actual implemented subset.

## 3. CSR Semantics And Counter Behavior

- `B021 | STD_MTS_021_expected_latency_zero_write`: Write `0` to CSR word `0x8`; expect readback `0` and a correspondingly strict error window for subsequent hits. Covers the lower bound.
- `B022 | STD_MTS_022_expected_latency_small_write`: Write a small nonzero value to CSR word `0x8`; expect readback to match and the error threshold to shift accordingly. Proves mid-run configurability.
- `B023 | STD_MTS_023_expected_latency_maxword_write`: Write `0xFFFFFFFF` to CSR word `0x8`; expect exact readback and a reference-model update of `expected_latency_1n6` and `padding_upper`. Covers the upper software range.
- `B024 | STD_MTS_024_unsupported_write_addr1_inert`: Attempt a write to CSR word `0x4`; expect no hidden state change because address 1 has no write side effects. Locks down the sparse CSR map.
- `B025 | STD_MTS_025_unsupported_write_addr3_inert`: Attempt a write to CSR word `0xC`; expect no change to counters or control fields. Guards against accidental write aliases.
- `B026 | STD_MTS_026_unsupported_write_addr4_inert`: Attempt a write to CSR word `0x10`; expect the lower total-count register to remain read-only. Guards against accidental write aliases.
- `B027 | STD_MTS_027_unsupported_read_addr5_zero`: Read an unsupported address such as word `0x14`; expect `readdata=0` with a clean acknowledgement. Defines the out-of-range software contract.
- `B028 | STD_MTS_028_csr_waitrequest_ack`: Issue ordinary reads and writes and confirm `waitrequest` drops only for accepted accesses. Verifies the simple AVMM handshake used by the current RTL.
- `B029 | STD_MTS_029_csr_burst_of_serial_accesses`: Execute a tight sequence of read and write transactions; expect no field corruption and deterministic final state. Exercises the lightweight CSR agent.
- `B030 | STD_MTS_030_total_counter_counts_all_valid`: Drive accepted and rejected valid beats; expect the total-hit counter to increment on every valid input beat as documented in `proc_discard_hit_cnt`. Confirms the intended accounting policy.

## 4. Input Acceptance And Discard Paths

- `B031 | STD_MTS_031_running_accepts_clean_hit`: In `RUNNING` with `force_stop=0` and `discard_hiterr=1`, drive a clean valid beat; expect it to be accepted and eventually emitted as `hit_type1`. Establishes the base datapath contract.
- `B032 | STD_MTS_032_idle_rejects_clean_hit`: In `IDLE`, drive a valid beat; expect no `hit_type1` output, discard counting, and total counting. Proves that `IDLE` is not an acceptance state.
- `B033 | STD_MTS_033_reset_sclr_flush_accept`: In `RESET/SCLR`, drive a valid beat; expect `asi_hit_type0_ready=1` and the beat to be accepted for flush behavior because `processor_allow_input=1` in this substate. Covers the flush-only ingress path.
- `B034 | STD_MTS_034_reset_sync_blocks_hit`: In `RESET/SYNC`, drive a valid beat; expect no acceptance because ready is low and `processor_allow_input=0`. Proves the synchronizing hold phase.
- `B035 | STD_MTS_035_flushing_accepts_hit`: In `FLUSHING`, drive a valid beat; expect acceptance and output under the current RTL contract. Documents the present post-terminate drain semantics.
- `B036 | STD_MTS_036_hiterr_discard_enabled`: In `RUNNING` with `discard_hiterr=1`, drive `error(HITERR_BIT_LOC)=1`; expect discard counting and no output beat. Verifies the default error policy.
- `B037 | STD_MTS_037_hiterr_discard_disabled`: In `RUNNING` with `discard_hiterr=0`, drive the same errored beat; expect it to be accepted and processed. Verifies policy override behavior.
- `B038 | STD_MTS_038_force_stop_blocks_acceptance`: Assert `force_stop=1` in `RUNNING` and drive clean valid beats; expect `asi_hit_type0_ready` to stay high yet `hit_in_ok` to go low, causing rejection. Captures the current acceptance-vs-ready split.
- `B039 | STD_MTS_039_rejected_hiterr_still_counts_total`: Drive a rejected hiterr beat and confirm the total counter increments while the discard counter increments too. Proves counter partitioning.
- `B040 | STD_MTS_040_matched_sideband_and_data_fields`: Drive a beat with matched sideband ASIC and payload channel fields; expect output `asic` and `channel` to follow the payload fields while packet bookkeeping follows the sideband channel. Documents the two-channel domains explicitly.

## 5. Run-Control Sequence Baselines

- `B041 | STD_MTS_041_legacy_running_plus_one_hit`: Recreate the direct-to-`RUNNING` startup used by the legacy smoke TB and send one hit; expect one processed output. Preserves existing smoke semantics.
- `B042 | STD_MTS_042_standard_prepare_sync_run`: Execute the full `RUN_PREPARE -> SYNC -> RUNNING` sequence and send one hit; expect the same functional output as the legacy path. Establishes the standard-sequence baseline.
- `B043 | STD_MTS_043_run_prepare_without_sync`: Send `RUN_PREPARE` and hold there; expect `RESET/SCLR` behavior with no normal RUNNING output. Documents partial-sequence behavior.
- `B044 | STD_MTS_044_repeated_sync_pulses`: Send repeated `SYNC` commands before `RUNNING`; expect the DUT to remain in the reset-sync hold state without emitting output. Covers control chatter in the arming phase.
- `B045 | STD_MTS_045_terminating_without_eop_then_idle`: Enter `FLUSHING` with no accepted terminal EOP and then send `IDLE`; expect no output boundary under the current contract. Ties directly to the upgrade gap called out in the plan.
- `B046 | STD_MTS_046_running_abort_no_flush`: From `RUNNING`, send `IDLE` without `TERMINATING`; expect immediate state drop and no further acceptance. Covers the explicit abort branch.
- `B047 | STD_MTS_047_link_test_word_is_nonfunctional_today`: Drive the `LINK_TEST` control word; expect `run_state_cmd` to decode but no dedicated processor-state behavior. Documents current no-op semantics.
- `B048 | STD_MTS_048_sync_test_word_is_nonfunctional_today`: Drive the `SYNC_TEST` control word; expect no dedicated processor-state behavior beyond the decoded command value. Documents current no-op semantics.
- `B049 | STD_MTS_049_reset_word_is_nonfunctional_today`: Drive the `RESET` control word from `IDLE`; expect no dedicated processor-state branch. Documents the decoded-but-unhandled command.
- `B050 | STD_MTS_050_out_of_daq_word_is_nonfunctional_today`: Drive the `OUT_OF_DAQ` control word; expect no datapath-specific action beyond the decoded command. Documents the current implementation boundary.

## 6. Timestamp Decode And Padding Basics

- `B051 | STD_MTS_051_tcc_uses_rom_decode`: Drive a hit with a known raw `TCC`; expect the scoreboard to match the DUT’s `dual_port_rom` lookup before division. Grounds the decode model in the actual ROM.
- `B052 | STD_MTS_052_ecc_uses_second_rom_port`: Drive a hit with a known raw `ECC`; expect the second ROM port to be used concurrently and mirrored by the scoreboard. Confirms the dual-port decode behavior.
- `B053 | STD_MTS_053_bypass_off_uses_white_timestamp`: With `bypass_lapse=0`, expect the divider numerators to come from the padded 50-bit white timestamp path. Covers the normal operating mode.
- `B054 | STD_MTS_054_bypass_on_uses_gray_timestamp`: With `bypass_lapse=1`, expect the divider numerators to be loaded directly from decoded gray values. Covers the debug bypass mode.
- `B055 | STD_MTS_055_expected_latency_updates_padding_upper`: Rewrite `expected_latency`; expect subsequent hits to observe the new `padding_upper` boundary. Proves the software-controlled window.
- `B056 | STD_MTS_056_no_adjust_below_upper_bound`: Choose a decoded timestamp below `padding_upper`; expect no overflow subtraction in the white-timestamp model. Covers the normal non-wrap path.
- `B057 | STD_MTS_057_t_path_adjust_above_upper_bound`: Choose a T-path hit above `padding_upper` while the overflow-adjust latch is active; expect one overflow subtraction. Covers the T correction path.
- `B058 | STD_MTS_058_e_path_adjust_above_upper_bound`: Choose an E-path hit above `padding_upper` while the overflow-adjust latch is active; expect one overflow subtraction on the E branch. Covers the E correction path.
- `B059 | STD_MTS_059_divider_quotient_populates_tcc8n`: Drive a deterministic hit and confirm `hit_type1.tcc_8n` matches the quotient of the selected white timestamp divided by 5. Locks down the primary transform.
- `B060 | STD_MTS_060_divider_remainder_populates_tcc1n6`: For the same style of hit, confirm `hit_type1.tcc_1n6` matches the remainder in the legal range 0..4. Locks down the sub-tick field.

## 7. ET / Op-Mode Basics

- `B061 | STD_MTS_061_short_mode_zeroes_et`: With `derive_tot=0`, drive an `EFlag=1` hit and expect `ET_1n6=0`. Proves that short-mode ignores ToT generation.
- `B062 | STD_MTS_062_tot_mode_masks_eflag0`: With `derive_tot=1` and `EFlag=0`, expect `ET_1n6=0` regardless of decoded E/T delta. Proves the explicit EFlag mask.
- `B063 | STD_MTS_063_tot_mode_positive_delta`: With `derive_tot=1` and a decoded positive delta, expect a positive nonzero `ET_1n6`. Establishes the basic long-mode ToT path.
- `B064 | STD_MTS_064_tot_mode_negative_delta_reference`: With `derive_tot=1` and a crafted decoded negative delta, expect the current reference-model clamp behavior defined by the RTL plus the checked-in smoke TB. Keeps the plan aligned to today’s implementation rather than intuition.
- `B065 | STD_MTS_065_tot_mode_saturates_above_511`: With `derive_tot=1` and a decoded delta above 511, expect `ET_1n6=511`. Confirms saturation behavior.
- `B066 | STD_MTS_066_delay_field_t_path`: With `delay_ts_field_use_t=1`, expect `debug_ts`, `debug_burst`, and `aso_hit_type1_error` to use the T quotient path. Covers the default delay-field selection.
- `B067 | STD_MTS_067_delay_field_e_path`: With `delay_ts_field_use_t=0`, expect those same observables to use the E quotient path. Covers the alternate path.
- `B068 | STD_MTS_068_tfine_passthrough`: Drive distinct `TFine` values and expect them to emerge unchanged in `hit_type1`. Guards the fine-time pipeline.
- `B069 | STD_MTS_069_asic_passthrough`: Drive distinct payload ASIC IDs and expect them to emerge unchanged in `aso_hit_type1_data[38:35]`. Guards ASIC identity propagation.
- `B070 | STD_MTS_070_channel_passthrough`: Drive distinct payload channel values and expect them to emerge unchanged in `aso_hit_type1_data[34:30]`. Guards channel identity propagation.

## 8. Output Marker Basics

- `B071 | STD_MTS_071_sop_first_hit_channel0`: In a default enabled-window build, drive the first accepted hit for channel 0 in a run; expect `startofpacket=1` on that output beat. Proves per-channel start-of-run marking.
- `B072 | STD_MTS_072_sop_first_hit_channel1`: Repeat for channel 1; expect one SOP. Covers the second enabled channel.
- `B073 | STD_MTS_073_sop_first_hit_channel2`: Repeat for channel 2; expect one SOP. Covers the third enabled channel.
- `B074 | STD_MTS_074_sop_first_hit_channel3`: Repeat for channel 3; expect one SOP. Covers the fourth enabled channel.
- `B075 | STD_MTS_075_no_repeated_sop_same_channel`: Drive a second accepted hit for a previously seen enabled channel in the same run; expect no repeated SOP. Verifies `startofrun_sent` persistence.
- `B076 | STD_MTS_076_reset_clears_startofrun_sent`: Enter `RESET` and start a new run; expect SOP eligibility to return for each enabled channel. Verifies reset cleanup.
- `B077 | STD_MTS_077_terminating_input_eop_forwards_output_eop`: In `TERMINATING`, accept an input beat with `endofpacket=1`; expect one delayed output `endofpacket`. Proves the explicit termination-EOP pipeline.
- `B078 | STD_MTS_078_nonterminating_eop_not_forwarded`: Accept an input beat with `endofpacket=1` while still in `RUNNING`; expect no output EOP. Documents the current “termination-only” EOP forwarding.
- `B079 | STD_MTS_079_empty_stays_zero`: Observe normal hit traffic and confirm `aso_hit_type1_empty` remains `0`. Locks down the current constant-zero contract.
- `B080 | STD_MTS_080_output_valid_only_in_run_or_flush`: Drive accepted hits across `IDLE`, `RESET`, `RUNNING`, and `FLUSHING`; expect `aso_hit_type1_valid` only in `RUNNING` or `FLUSHING` when `hit_out.valid=1`. Verifies the source gating.

## 9. Output Routing And Error Basics

- `B081 | STD_MTS_081_route_lane0`: Craft a quotient whose bits `[5:4]` are `00`; expect output route channel `0000`. Verifies lane-0 routing.
- `B082 | STD_MTS_082_route_lane1`: Craft a quotient whose bits `[5:4]` are `01`; expect output route channel `0001`. Verifies lane-1 routing.
- `B083 | STD_MTS_083_route_lane2`: Craft a quotient whose bits `[5:4]` are `10`; expect output route channel `0010`. Verifies lane-2 routing.
- `B084 | STD_MTS_084_route_lane3`: Craft a quotient whose bits `[5:4]` are `11`; expect output route channel `0011`. Verifies lane-3 routing.
- `B085 | STD_MTS_085_error_low_in_range`: Drive a hit whose `debug_ts` is positive and strictly below `expected_latency`; expect `aso_hit_type1_error=0`. Proves the clean window.
- `B086 | STD_MTS_086_error_high_at_zero`: Drive a hit whose selected timestamp yields `debug_ts=0`; expect `aso_hit_type1_error=1`. Covers the lower edge of the strict inequality.
- `B087 | STD_MTS_087_error_high_for_negative`: Drive a hit whose selected timestamp appears ahead of the GTS counter; expect `aso_hit_type1_error=1`. Covers the negative window.
- `B088 | STD_MTS_088_error_high_at_or_above_limit`: Drive a hit with `debug_ts >= expected_latency`; expect `aso_hit_type1_error=1`. Covers the upper edge.
- `B089 | STD_MTS_089_debug_ts_valid_alignment`: Confirm `aso_debug_ts_valid` aligns with the processed-hit pipeline stage rather than the raw input beat. Locks down debug timing.
- `B090 | STD_MTS_090_delay_field_changes_error_source`: Toggle `delay_ts_field_use_t` between runs and confirm the error decision follows the selected timestamp source. Verifies the selected-path dependency.

## 10. Debug-Burst And Delta Basics

- `B091 | STD_MTS_091_debug_burst_only_running`: Observe the DUT in `IDLE`, `RESET`, and `RUNNING`; expect `aso_debug_burst_valid` only in `RUNNING`. Locks down the state gate.
- `B092 | STD_MTS_092_ts_delta_only_running`: Make the same observation for `aso_ts_delta_valid`; expect activity only in `RUNNING`. Locks down the state gate.
- `B093 | STD_MTS_093_first_running_hit_warms_history`: Send the first processed hit after entering `RUNNING`; expect history seeding without stale delta leakage. Proves clean startup for the delta logic.
- `B094 | STD_MTS_094_positive_timestamp_delta`: Send two accepted hits with increasing selected timestamps; expect a positive sign in `debug_burst` and positive `ts_delta`. Proves the positive branch.
- `B095 | STD_MTS_095_negative_timestamp_delta`: Send two accepted hits with decreasing selected timestamps; expect a negative sign and negative `ts_delta`. Proves the negative branch.
- `B096 | STD_MTS_096_zero_timestamp_delta`: Send two accepted hits with equal selected timestamps; expect a zero-like delta presentation. Covers the no-change branch.
- `B097 | STD_MTS_097_positive_signmag_conversion`: Check that positive sign-magnitude `delta_timestamp` is converted to positive two’s complement in `aso_ts_delta_data`. Locks down helper-function semantics.
- `B098 | STD_MTS_098_negative_signmag_conversion`: Check the same for a negative sign-magnitude value. Locks down helper-function semantics.
- `B099 | STD_MTS_099_arrival_delta_uses_gts`: Confirm that the lower debug-burst byte reflects inter-arrival time in GTS cycles, not the decoded hit timestamp. Prevents model confusion.
- `B100 | STD_MTS_100_debug_streams_clear_outside_running`: Leave `RUNNING` and confirm debug-valid signals and stored outputs clear promptly. Guards stale history after stop.

## 11. Legacy Smoke And Counter Checks

- `B101 | STD_MTS_101_replay_smoke_positive_et`: Reproduce the checked-in smoke vector that expects a positive `ET_1n6` result after writing `0x40000001`. Keeps the new harness anchored to the existing bench.
- `B102 | STD_MTS_102_replay_smoke_eflag_zero`: Reproduce the smoke vector with `EFlag=0` and expect `ET_1n6=0`. Preserves the current directed check.
- `B103 | STD_MTS_103_replay_smoke_clamp_vector`: Reproduce the smoke vector that expects the clamp/saturation path. Preserves the current directed check.
- `B104 | STD_MTS_104_discard_counter_matches_rejections`: Drive a known mix of rejected hits and confirm the CSR discard counter matches exactly. Validates software observability of discard policy.
- `B105 | STD_MTS_105_total_counter_matches_all_valid`: Drive a known mix of accepted and rejected hits and confirm the total counter matches all valid inputs. Validates software observability of ingress load.
- `B106 | STD_MTS_106_total_counter_hi_rollover`: Run long enough to wrap the low 32-bit total counter and confirm the high word increments. Covers the 48-bit accounting path.
- `B107 | STD_MTS_107_soft_reset_clears_counters`: Pulse `soft_reset` after traffic and confirm both counters clear without requiring global reset. Verifies the intended software reset path.
- `B108 | STD_MTS_108_sync_clears_counters`: Use the standard `RUN_PREPARE -> SYNC` path after traffic and confirm the counters clear through `reset_flow=SYNC`. Verifies the run-sequence reset path.
- `B109 | STD_MTS_109_running_status_bit_semantics`: Read CSR word `0x0` in `RUNNING` and outside `RUNNING`; expect bit 0 to mirror `processor_state==RUNNING` exactly. Documents the live-status semantics.
- `B110 | STD_MTS_110_force_stop_persists_until_cleared`: Set `force_stop`, verify blocked acceptance, then clear it and confirm acceptance resumes. Proves stable software override behavior.

## 12. Parameter And Generic Baselines

- `B111 | STD_MTS_111_compile_rtl_default_div_pipeline`: Build and run with the RTL default `LPM_DIV_PIPELINE=4`; expect the reference latency and the correct math. Establishes the source-file baseline.
- `B112 | STD_MTS_112_compile_packaged_div_pipeline`: Build and run with the packaged default `LPM_DIV_PIPELINE=2`; expect the same math with a shorter pipeline delay. Covers the packaging-visible configuration.
- `B113 | STD_MTS_113_single_enabled_channel_window`: Build with `ENABLED_CHANNEL_LO=0` and `ENABLED_CHANNEL_HI=0`; expect SOP bookkeeping only for channel 0. Covers the smallest enabled window.
- `B114 | STD_MTS_114_upper_enabled_window`: Build with `ENABLED_CHANNEL_LO=2` and `ENABLED_CHANNEL_HI=3`; expect SOP bookkeeping only for channels 2 and 3. Covers an offset window.
- `B115 | STD_MTS_115_remapped_hiterr_bit`: Build with a remapped `HITERR_BIT_LOC` and drive the matching error bit; expect discard behavior to follow the remap. Proves that only the configured bit matters.
- `B116 | STD_MTS_116_remapped_crcerr_still_inert`: Build with a remapped `CRCERR_BIT_LOC`; expect no functional change because the current RTL does not consume that bit. Documents a deliberate no-effect parameter.
- `B117 | STD_MTS_117_remapped_frame_corrupt_still_inert`: Build with a remapped `FRAME_CORRPT_BIT_LOC`; expect no functional change. Documents another deliberate no-effect parameter.
- `B118 | STD_MTS_118_changed_latency_generic_at_power_on`: Build with a nondefault `MUTRIG_BUFFER_EXPECTED_LATENCY_8N`; expect the power-on CSR default to follow that generic. Covers generic-to-CSR propagation.
- `B119 | STD_MTS_119_bank_string_is_debug_only`: Build with `BANK="DOWN"` and compare against `BANK="UP"`; expect only debug report text to differ. Documents the nonfunctional generic.
- `B120 | STD_MTS_120_debug_zero_is_functionally_equivalent`: Build with `DEBUG=0`; expect report suppression but identical functional outputs and counters. Guards against accidental debug dependency.

## 13. Termination And Upgrade-Gating Basics

- `B121 | STD_MTS_121_preterminate_hit_still_drains`: Accept a hit immediately before `TERMINATING`; expect it to continue through the pipeline and emerge during `FLUSHING`. Proves current drain behavior.
- `B122 | STD_MTS_122_terminating_eop_and_hit_emit_final_boundary`: In `TERMINATING`, accept a hit carrying `endofpacket=1`; expect one final output beat with `endofpacket=1`. Proves the happy-path stop contract currently implemented.
- `B123 | STD_MTS_123_flushing_accepts_more_hits_today`: Continue driving clean hits in `FLUSHING`; expect them to be accepted under the current RTL. Documents the present post-stop openness.
- `B124 | STD_MTS_124_flushing_quiet_without_hits`: Enter `FLUSHING` and stop all input traffic; expect no spontaneous output. Proves that flush does not invent traffic on its own.
- `B125 | STD_MTS_125_ctrl_ready_high_through_terminate`: Observe `asi_ctrl_ready` across `RUNNING -> TERMINATING`; expect it to stay high continuously today. Documents the current handshake fact.
- `B126 | STD_MTS_126_ctrl_ready_high_through_prepare_and_sync`: Observe `asi_ctrl_ready` in `RUN_PREPARE` and `SYNC`; expect it to stay high continuously today. Documents the current handshake fact.
- `B127 | STD_MTS_127_upgrade_case_stateful_ready_on_terminate`: Mark the future case in which `asi_ctrl_ready` must remain low until local drain work finishes. This is a post-patch acceptance test derived from `RUN_SEQ_UPGRADE_PLAN.md`.
- `B128 | STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits`: Mark the future case in which the terminate boundary must still be observable even when no fresh post-edge hits are accepted. This is the key packet-boundary upgrade target.
- `B129 | STD_MTS_129_upgrade_case_idle_after_boundary_only`: Mark the future case in which `IDLE` is not acknowledged until the terminal boundary and local pipeline drain are complete. This is the key handshake upgrade target.
- `B130 | STD_MTS_130_full_standard_sequence_baseline`: Use `RUN_PREPARE -> SYNC -> RUNNING -> TERMINATING -> IDLE` with one packet per enabled channel as the canonical baseline scenario for the later UVM harness. This is the primary signoff narrative for the IP.
