# ⚠️ EDGE bucket

**Planned:** `131` &nbsp; **Evidenced:** `131` &nbsp; **Status:** ⚠️

## Merged code coverage (this bucket)

<!-- column legend:
  metric          = code-coverage category (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle)
  merged_pct      = bucket-local ordered-merge percentage across all evidenced cases
  target          = workflow coverage target (blank = no hard target for that category)
  status          = target check vs merged_pct
-->

| status | metric | merged_pct | target |
|:---:|---|---|---|
| ⚠️ | stmt | 93.10 | 95.0 |
| ⚠️ | branch | 84.51 | 90.0 |
| ℹ️ | cond | 80.64 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ✅ | fsm_trans | 100.00 | 90.0 |
| ⚠️ | toggle | 46.73 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `CORNER_MTS_001_reset_release_with_ctrl_valid` | stmt=74.32, branch=51.94, cond=25.80, expr=83.33, fsm_state=50.00, fsm_trans=11.11, toggle=6.64 | [case](../cases/CORNER_MTS_001_reset_release_with_ctrl_valid.md) |
| ✅ | 2 | `CORNER_MTS_002_running_and_first_hit_same_cycle` | stmt=74.32, branch=51.94, cond=25.80, expr=83.33, fsm_state=50.00, fsm_trans=11.11, toggle=6.67 | [case](../cases/CORNER_MTS_002_running_and_first_hit_same_cycle.md) |
| ✅ | 3 | `CORNER_MTS_003_terminate_on_final_eop_cycle` | stmt=79.71, branch=65.90, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=44.44, toggle=8.43 | [case](../cases/CORNER_MTS_003_terminate_on_final_eop_cycle.md) |
| ✅ | 4 | `CORNER_MTS_004_idle_on_output_valid_cycle` | stmt=79.97, branch=66.55, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=8.61 | [case](../cases/CORNER_MTS_004_idle_on_output_valid_cycle.md) |
| ✅ | 5 | `CORNER_MTS_005_prepare_then_immediate_idle` | stmt=80.48, branch=67.53, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=8.70 | [case](../cases/CORNER_MTS_005_prepare_then_immediate_idle.md) |
| ✅ | 6 | `CORNER_MTS_006_sync_then_immediate_running` | stmt=81.38, branch=68.50, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=8.84 | [case](../cases/CORNER_MTS_006_sync_then_immediate_running.md) |
| ✅ | 7 | `CORNER_MTS_007_back_to_back_running_words` | stmt=81.38, branch=68.50, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=9.16 | [case](../cases/CORNER_MTS_007_back_to_back_running_words.md) |
| ✅ | 8 | `CORNER_MTS_008_back_to_back_terminating_words` | stmt=81.64, branch=69.15, cond=52.41, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=9.16 | [case](../cases/CORNER_MTS_008_back_to_back_terminating_words.md) |
| ✅ | 9 | `CORNER_MTS_009_illegal_ctrl_word_while_active` | stmt=81.77, branch=70.12, cond=52.41, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=9.20 | [case](../cases/CORNER_MTS_009_illegal_ctrl_word_while_active.md) |
| ✅ | 10 | `CORNER_MTS_010_stale_ctrl_data_with_valid_gap` | stmt=81.77, branch=70.12, cond=52.41, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=9.20 | [case](../cases/CORNER_MTS_010_stale_ctrl_data_with_valid_gap.md) |
| ✅ | 11 | `CORNER_MTS_011_expected_latency_zero` | stmt=82.54, branch=71.10, cond=52.41, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.04 | [case](../cases/CORNER_MTS_011_expected_latency_zero.md) |
| ✅ | 12 | `CORNER_MTS_012_expected_latency_one` | stmt=82.67, branch=71.75, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=14.89 | [case](../cases/CORNER_MTS_012_expected_latency_one.md) |
| ✅ | 13 | `CORNER_MTS_013_expected_latency_large_16bit_value` | stmt=82.67, branch=71.75, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=16.79 | [case](../cases/CORNER_MTS_013_expected_latency_large_16bit_value.md) |
| ✅ | 14 | `CORNER_MTS_014_expected_latency_all_ones` | stmt=82.67, branch=71.75, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=18.56 | [case](../cases/CORNER_MTS_014_expected_latency_all_ones.md) |
| ✅ | 15 | `CORNER_MTS_015_reserved_opmode_bit28_only` | stmt=83.82, branch=72.07, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=18.56 | [case](../cases/CORNER_MTS_015_reserved_opmode_bit28_only.md) |
| ✅ | 16 | `CORNER_MTS_016_multi_field_control_write` | stmt=88.44, branch=73.05, cond=58.87, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=18.71 | [case](../cases/CORNER_MTS_016_multi_field_control_write.md) |
| ✅ | 17 | `CORNER_MTS_017_read_during_soft_reset_window` | stmt=88.57, branch=73.37, cond=63.70, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=18.78 | [case](../cases/CORNER_MTS_017_read_during_soft_reset_window.md) |
| ✅ | 18 | `CORNER_MTS_018_counter_read_on_low_word_rollover` | stmt=88.88, branch=75.80, cond=65.32, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.26 | [case](../cases/CORNER_MTS_018_counter_read_on_low_word_rollover.md) |
| ✅ | 19 | `CORNER_MTS_019_csr_access_in_flushing` | stmt=88.88, branch=75.80, cond=65.32, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.26 | [case](../cases/CORNER_MTS_019_csr_access_in_flushing.md) |
| ✅ | 20 | `CORNER_MTS_020_polling_unsupported_addr7` | stmt=89.01, branch=76.12, cond=65.32, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.26 | [case](../cases/CORNER_MTS_020_polling_unsupported_addr7.md) |
| ✅ | 21 | `CORNER_MTS_021_plain_hit_no_markers` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.26 | [case](../cases/CORNER_MTS_021_plain_hit_no_markers.md) |
| ✅ | 22 | `CORNER_MTS_022_sop_only_beat` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.26 | [case](../cases/CORNER_MTS_022_sop_only_beat.md) |
| ✅ | 23 | `CORNER_MTS_023_eop_only_beat` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.63 | [case](../cases/CORNER_MTS_023_eop_only_beat.md) |
| ✅ | 24 | `CORNER_MTS_024_single_beat_packet` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.63 | [case](../cases/CORNER_MTS_024_single_beat_packet.md) |
| ✅ | 25 | `CORNER_MTS_025_zero_gap_hits` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.91 | [case](../cases/CORNER_MTS_025_zero_gap_hits.md) |
| ✅ | 26 | `CORNER_MTS_026_one_cycle_gap_hits` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=20.91 | [case](../cases/CORNER_MTS_026_one_cycle_gap_hits.md) |
| ✅ | 27 | `CORNER_MTS_027_long_gap_then_hit` | stmt=89.01, branch=76.45, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=21.48 | [case](../cases/CORNER_MTS_027_long_gap_then_hit.md) |
| ✅ | 28 | `CORNER_MTS_028_max_payload_fields` | stmt=89.39, branch=76.77, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=25.43 | [case](../cases/CORNER_MTS_028_max_payload_fields.md) |
| ✅ | 29 | `CORNER_MTS_029_nonzero_mux_bits_in_sideband` | stmt=89.39, branch=76.77, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=25.51 | [case](../cases/CORNER_MTS_029_nonzero_mux_bits_in_sideband.md) |
| ✅ | 30 | `CORNER_MTS_030_sideband_channel_outside_enabled_window` | stmt=89.52, branch=77.74, cond=69.35, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=25.68 | [case](../cases/CORNER_MTS_030_sideband_channel_outside_enabled_window.md) |
| ✅ | 31 | `CORNER_MTS_031_t_gray_equal_padding_upper` | stmt=90.16, branch=79.03, cond=71.77, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=34.04 | [case](../cases/CORNER_MTS_031_t_gray_equal_padding_upper.md) |
| ✅ | 32 | `CORNER_MTS_032_t_gray_one_above_upper` | stmt=90.42, branch=79.67, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=35.27 | [case](../cases/CORNER_MTS_032_t_gray_one_above_upper.md) |
| ✅ | 33 | `CORNER_MTS_033_e_gray_equal_padding_upper` | stmt=90.80, branch=80.64, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=37.30 | [case](../cases/CORNER_MTS_033_e_gray_equal_padding_upper.md) |
| ✅ | 34 | `CORNER_MTS_034_e_gray_one_above_upper` | stmt=90.80, branch=80.96, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=37.30 | [case](../cases/CORNER_MTS_034_e_gray_one_above_upper.md) |
| ✅ | 35 | `CORNER_MTS_035_mts_counter_wrap_pulse` | stmt=90.80, branch=80.96, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.52 | [case](../cases/CORNER_MTS_035_mts_counter_wrap_pulse.md) |
| ✅ | 36 | `CORNER_MTS_036_overflow_lookback_expiry` | stmt=90.80, branch=80.96, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.46 | [case](../cases/CORNER_MTS_036_overflow_lookback_expiry.md) |
| ✅ | 37 | `CORNER_MTS_037_lpm_multi_valid_masks_adjust` | stmt=90.80, branch=80.96, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.26 | [case](../cases/CORNER_MTS_037_lpm_multi_valid_masks_adjust.md) |
| ✅ | 38 | `CORNER_MTS_038_bypass_toggle_before_hit` | stmt=90.80, branch=80.96, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.32 | [case](../cases/CORNER_MTS_038_bypass_toggle_before_hit.md) |
| ✅ | 39 | `CORNER_MTS_039_bypass_toggle_after_hit_accept` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_039_bypass_toggle_after_hit_accept.md) |
| ✅ | 40 | `CORNER_MTS_040_latency_write_at_overflow_boundary` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_040_latency_write_at_overflow_boundary.md) |
| ✅ | 41 | `CORNER_MTS_041_remainder_zero_case` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_041_remainder_zero_case.md) |
| ✅ | 42 | `CORNER_MTS_042_remainder_one_case` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_042_remainder_one_case.md) |
| ✅ | 43 | `CORNER_MTS_043_remainder_two_case` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_043_remainder_two_case.md) |
| ✅ | 44 | `CORNER_MTS_044_remainder_three_case` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_044_remainder_three_case.md) |
| ✅ | 45 | `CORNER_MTS_045_remainder_four_case` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_045_remainder_four_case.md) |
| ✅ | 46 | `CORNER_MTS_046_route_bits_00` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.47 | [case](../cases/CORNER_MTS_046_route_bits_00.md) |
| ✅ | 47 | `CORNER_MTS_047_route_bits_01` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.59 | [case](../cases/CORNER_MTS_047_route_bits_01.md) |
| ✅ | 48 | `CORNER_MTS_048_route_bits_10` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.59 | [case](../cases/CORNER_MTS_048_route_bits_10.md) |
| ✅ | 49 | `CORNER_MTS_049_route_bits_11` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.59 | [case](../cases/CORNER_MTS_049_route_bits_11.md) |
| ✅ | 50 | `CORNER_MTS_050_route_change_across_boundary` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.94 | [case](../cases/CORNER_MTS_050_route_change_across_boundary.md) |
| ✅ | 51 | `CORNER_MTS_051_short_mode_with_eflag_high` | stmt=90.80, branch=80.96, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.94 | [case](../cases/CORNER_MTS_051_short_mode_with_eflag_high.md) |
| ✅ | 52 | `CORNER_MTS_052_tot_mode_eflag_zero_large_delta` | stmt=90.93, branch=81.29, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.00 | [case](../cases/CORNER_MTS_052_tot_mode_eflag_zero_large_delta.md) |
| ✅ | 53 | `CORNER_MTS_053_tot_mode_smallest_positive_delta` | stmt=90.93, branch=81.29, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.00 | [case](../cases/CORNER_MTS_053_tot_mode_smallest_positive_delta.md) |
| ✅ | 54 | `CORNER_MTS_054_tot_mode_largest_unsaturated_delta` | stmt=90.93, branch=81.29, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.00 | [case](../cases/CORNER_MTS_054_tot_mode_largest_unsaturated_delta.md) |
| ✅ | 55 | `CORNER_MTS_055_tot_mode_first_saturated_delta` | stmt=90.93, branch=81.29, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.00 | [case](../cases/CORNER_MTS_055_tot_mode_first_saturated_delta.md) |
| ✅ | 56 | `CORNER_MTS_056_tot_mode_negative_delta_case` | stmt=91.06, branch=81.61, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.00 | [case](../cases/CORNER_MTS_056_tot_mode_negative_delta_case.md) |
| ✅ | 57 | `CORNER_MTS_057_toggle_derive_tot_between_hits` | stmt=91.06, branch=81.61, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.03 | [case](../cases/CORNER_MTS_057_toggle_derive_tot_between_hits.md) |
| ✅ | 58 | `CORNER_MTS_058_toggle_delay_field_between_hits` | stmt=91.95, branch=82.90, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_058_toggle_delay_field_between_hits.md) |
| ✅ | 59 | `CORNER_MTS_059_toggle_eflag_between_hits` | stmt=91.95, branch=82.90, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_059_toggle_eflag_between_hits.md) |
| ✅ | 60 | `CORNER_MTS_060_tfine_extremes` | stmt=91.95, branch=82.90, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_060_tfine_extremes.md) |
| ✅ | 61 | `CORNER_MTS_061_first_sop_channel0_after_reset` | stmt=91.95, branch=82.90, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_061_first_sop_channel0_after_reset.md) |
| ✅ | 62 | `CORNER_MTS_062_first_sop_channel3_after_reset` | stmt=91.95, branch=82.90, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_062_first_sop_channel3_after_reset.md) |
| ✅ | 63 | `CORNER_MTS_063_first_hit_disabled_channel_no_sop` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/CORNER_MTS_063_first_hit_disabled_channel_no_sop.md) |
| ✅ | 64 | `CORNER_MTS_064_interleaved_channels_no_repeat_sop` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.76 | [case](../cases/CORNER_MTS_064_interleaved_channels_no_repeat_sop.md) |
| ✅ | 65 | `CORNER_MTS_065_single_terminating_eop_pulse` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.76 | [case](../cases/CORNER_MTS_065_single_terminating_eop_pulse.md) |
| ✅ | 66 | `CORNER_MTS_066_eop_pipe_without_valid_alignment` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.76 | [case](../cases/CORNER_MTS_066_eop_pipe_without_valid_alignment.md) |
| ✅ | 67 | `CORNER_MTS_067_nonterminating_eop_is_local_only` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.76 | [case](../cases/CORNER_MTS_067_nonterminating_eop_is_local_only.md) |
| ✅ | 68 | `CORNER_MTS_068_output_eop_with_ready_low` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.79 | [case](../cases/CORNER_MTS_068_output_eop_with_ready_low.md) |
| ✅ | 69 | `CORNER_MTS_069_sop_and_eop_same_output_beat` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.79 | [case](../cases/CORNER_MTS_069_sop_and_eop_same_output_beat.md) |
| ✅ | 70 | `CORNER_MTS_070_empty_zero_on_all_output_classes` | stmt=91.95, branch=82.90, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.82 | [case](../cases/CORNER_MTS_070_empty_zero_on_all_output_classes.md) |
| ✅ | 71 | `CORNER_MTS_071_debug_ts_minus_one` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_071_debug_ts_minus_one.md) |
| ✅ | 72 | `CORNER_MTS_072_debug_ts_zero` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_072_debug_ts_zero.md) |
| ✅ | 73 | `CORNER_MTS_073_debug_ts_plus_one` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_073_debug_ts_plus_one.md) |
| ✅ | 74 | `CORNER_MTS_074_debug_ts_expected_minus_one` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_074_debug_ts_expected_minus_one.md) |
| ✅ | 75 | `CORNER_MTS_075_debug_ts_expected_exact` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_075_debug_ts_expected_exact.md) |
| ✅ | 76 | `CORNER_MTS_076_debug_ts_expected_plus_one` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.96 | [case](../cases/CORNER_MTS_076_debug_ts_expected_plus_one.md) |
| ✅ | 77 | `CORNER_MTS_077_t_vs_e_path_error_flip` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.05 | [case](../cases/CORNER_MTS_077_t_vs_e_path_error_flip.md) |
| ✅ | 78 | `CORNER_MTS_078_debug_burst_positive_trim_edge` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/CORNER_MTS_078_debug_burst_positive_trim_edge.md) |
| ✅ | 79 | `CORNER_MTS_079_debug_burst_negative_trim_edge` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/CORNER_MTS_079_debug_burst_negative_trim_edge.md) |
| ✅ | 80 | `CORNER_MTS_080_ts_delta_zero_boundary` | stmt=92.08, branch=83.22, cond=76.61, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_080_ts_delta_zero_boundary.md) |
| ✅ | 81 | `CORNER_MTS_081_force_stop_same_cycle_as_valid` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_081_force_stop_same_cycle_as_valid.md) |
| ✅ | 82 | `CORNER_MTS_082_force_stop_clear_before_next_hit` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_082_force_stop_clear_before_next_hit.md) |
| ✅ | 83 | `CORNER_MTS_083_soft_reset_while_running_idle_pipe` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_083_soft_reset_while_running_idle_pipe.md) |
| ✅ | 84 | `CORNER_MTS_084_soft_reset_with_inflight_beats` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_084_soft_reset_with_inflight_beats.md) |
| ✅ | 85 | `CORNER_MTS_085_soft_reset_in_flushing` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.11 | [case](../cases/CORNER_MTS_085_soft_reset_in_flushing.md) |
| ✅ | 86 | `CORNER_MTS_086_global_reset_with_pending_term_eop` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.14 | [case](../cases/CORNER_MTS_086_global_reset_with_pending_term_eop.md) |
| ✅ | 87 | `CORNER_MTS_087_global_reset_with_debug_history` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.17 | [case](../cases/CORNER_MTS_087_global_reset_with_debug_history.md) |
| ✅ | 88 | `CORNER_MTS_088_prepare_after_soft_reset` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.17 | [case](../cases/CORNER_MTS_088_prepare_after_soft_reset.md) |
| ✅ | 89 | `CORNER_MTS_089_sync_after_force_stop_cycle` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.19 | [case](../cases/CORNER_MTS_089_sync_after_force_stop_cycle.md) |
| ✅ | 90 | `CORNER_MTS_090_idle_during_sclr_flush` | stmt=92.08, branch=83.22, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.19 | [case](../cases/CORNER_MTS_090_idle_during_sclr_flush.md) |
| ✅ | 91 | `CORNER_MTS_091_single_channel_window_index0` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_091_single_channel_window_index0.md) |
| ✅ | 92 | `CORNER_MTS_092_single_channel_window_index3` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_092_single_channel_window_index3.md) |
| ✅ | 93 | `CORNER_MTS_093_middle_window_indexing` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_093_middle_window_indexing.md) |
| ✅ | 94 | `CORNER_MTS_094_packaged_div_pipeline_delay` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_094_packaged_div_pipeline_delay.md) |
| ✅ | 95 | `CORNER_MTS_095_rtl_div_pipeline_delay` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_095_rtl_div_pipeline_delay.md) |
| ✅ | 96 | `CORNER_MTS_096_zero_default_latency_generic` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_096_zero_default_latency_generic.md) |
| ✅ | 97 | `CORNER_MTS_097_one_tick_default_latency_generic` | stmt=92.33, branch=83.54, cond=78.22, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.40 | [case](../cases/CORNER_MTS_097_one_tick_default_latency_generic.md) |
| ✅ | 98 | `CORNER_MTS_098_remapped_hiterr_to_bit2` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.46 | [case](../cases/CORNER_MTS_098_remapped_hiterr_to_bit2.md) |
| ✅ | 99 | `CORNER_MTS_099_frame_corrupt_bit_still_inert` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.46 | [case](../cases/CORNER_MTS_099_frame_corrupt_bit_still_inert.md) |
| ✅ | 100 | `CORNER_MTS_100_padding_eop_wait_still_inert` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.46 | [case](../cases/CORNER_MTS_100_padding_eop_wait_still_inert.md) |
| ✅ | 101 | `CORNER_MTS_101_output_ready_low_single_beat` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.46 | [case](../cases/CORNER_MTS_101_output_ready_low_single_beat.md) |
| ✅ | 102 | `CORNER_MTS_102_output_ready_low_multi_beat` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_102_output_ready_low_multi_beat.md) |
| ✅ | 103 | `CORNER_MTS_103_output_ready_toggle_every_cycle` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_103_output_ready_toggle_every_cycle.md) |
| ✅ | 104 | `CORNER_MTS_104_output_ready_low_on_eop` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_104_output_ready_low_on_eop.md) |
| ✅ | 105 | `CORNER_MTS_105_output_ready_unknown_monitor_trap` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_105_output_ready_unknown_monitor_trap.md) |
| ✅ | 106 | `CORNER_MTS_106_input_ready_high_in_flushing` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_106_input_ready_high_in_flushing.md) |
| ✅ | 107 | `CORNER_MTS_107_input_ready_low_in_idle` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_107_input_ready_low_in_idle.md) |
| ✅ | 108 | `CORNER_MTS_108_input_ready_high_in_reset_sclr` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_108_input_ready_high_in_reset_sclr.md) |
| ✅ | 109 | `CORNER_MTS_109_input_ready_low_in_reset_sync` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_109_input_ready_low_in_reset_sync.md) |
| ✅ | 110 | `CORNER_MTS_110_output_quiet_outside_running_flush` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_110_output_quiet_outside_running_flush.md) |
| ✅ | 111 | `CORNER_MTS_111_terminate_with_no_packet_open` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_111_terminate_with_no_packet_open.md) |
| ✅ | 112 | `CORNER_MTS_112_terminate_one_cycle_before_eop` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_112_terminate_one_cycle_before_eop.md) |
| ✅ | 113 | `CORNER_MTS_113_terminate_same_cycle_as_eop` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_113_terminate_same_cycle_as_eop.md) |
| ✅ | 114 | `CORNER_MTS_114_terminate_one_cycle_after_eop` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_114_terminate_one_cycle_after_eop.md) |
| ✅ | 115 | `CORNER_MTS_115_idle_before_eop_delay_matures` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_115_idle_before_eop_delay_matures.md) |
| ✅ | 116 | `CORNER_MTS_116_multiple_eops_in_flushing` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_116_multiple_eops_in_flushing.md) |
| ✅ | 117 | `CORNER_MTS_117_packet_open_then_abort` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_117_packet_open_then_abort.md) |
| ✅ | 118 | `CORNER_MTS_118_terminating_eop_disabled_sideband_channel` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_118_terminating_eop_disabled_sideband_channel.md) |
| ✅ | 119 | `CORNER_MTS_119_flushing_accepts_non_eop_hits` | stmt=92.33, branch=83.54, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.54 | [case](../cases/CORNER_MTS_119_flushing_accepts_non_eop_hits.md) |
| ✅ | 120 | `CORNER_MTS_120_upgrade_ready_should_wait_for_drain` | stmt=92.59, branch=83.87, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_120_upgrade_ready_should_wait_for_drain.md) |
| ✅ | 121 | `CORNER_MTS_121_prepare_ready_gap_upgrade` | stmt=92.59, branch=83.87, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_121_prepare_ready_gap_upgrade.md) |
| ✅ | 122 | `CORNER_MTS_122_sync_ready_gap_upgrade` | stmt=92.59, branch=83.87, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_122_sync_ready_gap_upgrade.md) |
| ✅ | 123 | `CORNER_MTS_123_flushing_ready_gap_upgrade` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_123_flushing_ready_gap_upgrade.md) |
| ✅ | 124 | `CORNER_MTS_124_missing_synthetic_boundary_upgrade` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_124_missing_synthetic_boundary_upgrade.md) |
| ✅ | 125 | `CORNER_MTS_125_eop_alignment_hole_upgrade` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.54 | [case](../cases/CORNER_MTS_125_eop_alignment_hole_upgrade.md) |
| ✅ | 126 | `CORNER_MTS_126_crcerr_ignore_upgrade_gap` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.57 | [case](../cases/CORNER_MTS_126_crcerr_ignore_upgrade_gap.md) |
| ✅ | 127 | `CORNER_MTS_127_delay_error_sideband_tracks_hit` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.73 | [case](../cases/CORNER_MTS_127_delay_error_sideband_tracks_hit.md) |
| ✅ | 128 | `CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap` | stmt=92.84, branch=84.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=46.73 | [case](../cases/CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap.md) |
| ✅ | 129 | `CORNER_MTS_128_accept_command_vs_complete_work_upgrade` | stmt=93.10, branch=84.51, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=100.00, toggle=46.73 | [case](../cases/CORNER_MTS_128_accept_command_vs_complete_work_upgrade.md) |
| ✅ | 130 | `CORNER_MTS_129_one_boundary_per_run_upgrade` | stmt=93.10, branch=84.51, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=100.00, toggle=46.73 | [case](../cases/CORNER_MTS_129_one_boundary_per_run_upgrade.md) |
| ✅ | 131 | `CORNER_MTS_130_idle_after_boundary_upgrade` | stmt=93.10, branch=84.51, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=100.00, toggle=46.73 | [case](../cases/CORNER_MTS_130_idle_after_boundary_upgrade.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
