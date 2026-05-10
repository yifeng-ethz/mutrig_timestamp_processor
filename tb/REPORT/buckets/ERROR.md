# ⚠️ ERROR bucket

**Planned:** `130` &nbsp; **Evidenced:** `130` &nbsp; **Status:** ⚠️

## Merged code coverage (this bucket)

<!-- column legend:
  metric          = code-coverage category (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle)
  merged_pct      = bucket-local ordered-merge percentage across all evidenced cases
  target          = workflow coverage target (blank = no hard target for that category)
  status          = target check vs merged_pct
-->

| status | metric | merged_pct | target |
|:---:|---|---|---|
| ✅ | stmt | 95.58 | 95.0 |
| ✅ | branch | 91.89 | 90.0 |
| ℹ️ | cond | 82.30 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 66.66 | 90.0 |
| ⚠️ | toggle | 53.12 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `NEG_MTS_001_all_zero_ctrl_word` | stmt=77.96, branch=62.89, cond=38.93, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=7.52 | [case](../cases/NEG_MTS_001_all_zero_ctrl_word.md) |
| ✅ | 2 | `NEG_MTS_002_multi_hot_ctrl_word` | stmt=77.96, branch=62.89, cond=38.93, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=7.57 | [case](../cases/NEG_MTS_002_multi_hot_ctrl_word.md) |
| ✅ | 3 | `NEG_MTS_003_illegal_ctrl_during_running` | stmt=77.96, branch=62.89, cond=38.93, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=7.82 | [case](../cases/NEG_MTS_003_illegal_ctrl_during_running.md) |
| ✅ | 4 | `NEG_MTS_004_illegal_ctrl_during_flushing` | stmt=82.77, branch=72.26, cond=55.75, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.88 | [case](../cases/NEG_MTS_004_illegal_ctrl_during_flushing.md) |
| ✅ | 5 | `NEG_MTS_005_ctrl_valid_high_data_changes` | stmt=83.14, branch=72.65, cond=56.63, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.91 | [case](../cases/NEG_MTS_005_ctrl_valid_high_data_changes.md) |
| ✅ | 6 | `NEG_MTS_006_ctrl_data_unknown_injection` | stmt=83.14, branch=72.65, cond=56.63, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.91 | [case](../cases/NEG_MTS_006_ctrl_data_unknown_injection.md) |
| ✅ | 7 | `NEG_MTS_007_running_without_sync_documented_nonstandard` | stmt=83.51, branch=73.04, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=9.58 | [case](../cases/NEG_MTS_007_running_without_sync_documented_nonstandard.md) |
| ✅ | 8 | `NEG_MTS_008_terminate_from_idle` | stmt=84.07, branch=74.21, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=9.75 | [case](../cases/NEG_MTS_008_terminate_from_idle.md) |
| ✅ | 9 | `NEG_MTS_009_link_test_during_running` | stmt=84.25, branch=75.00, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=9.83 | [case](../cases/NEG_MTS_009_link_test_during_running.md) |
| ✅ | 10 | `NEG_MTS_010_always_ready_masks_incomplete_work` | stmt=84.25, branch=75.00, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=9.83 | [case](../cases/NEG_MTS_010_always_ready_masks_incomplete_work.md) |
| ✅ | 11 | `NEG_MTS_011_simultaneous_read_write_same_cycle` | stmt=85.37, branch=76.17, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=10.40 | [case](../cases/NEG_MTS_011_simultaneous_read_write_same_cycle.md) |
| ✅ | 12 | `NEG_MTS_012_write_unsupported_addr5` | stmt=85.55, branch=76.56, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=11.64 | [case](../cases/NEG_MTS_012_write_unsupported_addr5.md) |
| ✅ | 13 | `NEG_MTS_013_read_unsupported_addr6` | stmt=85.74, branch=76.95, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=11.64 | [case](../cases/NEG_MTS_013_read_unsupported_addr6.md) |
| ✅ | 14 | `NEG_MTS_014_reserved_opmode_bit28_write` | stmt=87.22, branch=77.34, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=14.07 | [case](../cases/NEG_MTS_014_reserved_opmode_bit28_write.md) |
| ✅ | 15 | `NEG_MTS_015_write_expected_latency_during_reset` | stmt=87.22, branch=77.34, cond=57.52, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=14.77 | [case](../cases/NEG_MTS_015_write_expected_latency_during_reset.md) |
| ✅ | 16 | `NEG_MTS_016_back_to_back_soft_reset_pulses` | stmt=90.37, branch=78.12, cond=69.02, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=15.09 | [case](../cases/NEG_MTS_016_back_to_back_soft_reset_pulses.md) |
| ✅ | 17 | `NEG_MTS_017_rapid_force_stop_toggle` | stmt=90.74, branch=79.29, cond=71.68, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=15.39 | [case](../cases/NEG_MTS_017_rapid_force_stop_toggle.md) |
| ✅ | 18 | `NEG_MTS_018_driver_ignores_waitrequest` | stmt=90.74, branch=79.29, cond=71.68, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=15.39 | [case](../cases/NEG_MTS_018_driver_ignores_waitrequest.md) |
| ✅ | 19 | `NEG_MTS_019_counter_reads_mid_reset` | stmt=90.74, branch=79.29, cond=71.68, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.39 | [case](../cases/NEG_MTS_019_counter_reads_mid_reset.md) |
| ✅ | 20 | `NEG_MTS_020_expected_latency_overflow_model` | stmt=90.74, branch=79.29, cond=71.68, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=17.82 | [case](../cases/NEG_MTS_020_expected_latency_overflow_model.md) |
| ✅ | 21 | `NEG_MTS_021_hiterr_rejected_running` | stmt=90.74, branch=79.29, cond=72.56, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=17.87 | [case](../cases/NEG_MTS_021_hiterr_rejected_running.md) |
| ✅ | 22 | `NEG_MTS_022_hiterr_kept_running` | stmt=91.29, branch=80.46, cond=73.45, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.86 | [case](../cases/NEG_MTS_022_hiterr_kept_running.md) |
| ✅ | 23 | `NEG_MTS_023_crcerr_only_inert` | stmt=91.29, branch=80.46, cond=73.45, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.91 | [case](../cases/NEG_MTS_023_crcerr_only_inert.md) |
| ✅ | 24 | `NEG_MTS_024_frame_corrupt_only_inert` | stmt=91.29, branch=80.46, cond=73.45, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.96 | [case](../cases/NEG_MTS_024_frame_corrupt_only_inert.md) |
| ✅ | 25 | `NEG_MTS_025_combined_error_bits_only_hiterr_matters` | stmt=91.48, branch=81.25, cond=73.45, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=27.20 | [case](../cases/NEG_MTS_025_combined_error_bits_only_hiterr_matters.md) |
| ✅ | 26 | `NEG_MTS_026_valid_beat_in_idle` | stmt=91.48, branch=81.25, cond=73.45, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=27.20 | [case](../cases/NEG_MTS_026_valid_beat_in_idle.md) |
| ✅ | 27 | `NEG_MTS_027_valid_beat_in_reset_sync` | stmt=91.48, branch=81.25, cond=73.45, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=27.20 | [case](../cases/NEG_MTS_027_valid_beat_in_reset_sync.md) |
| ✅ | 28 | `NEG_MTS_028_valid_beat_under_force_stop` | stmt=91.48, branch=81.25, cond=73.45, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=27.20 | [case](../cases/NEG_MTS_028_valid_beat_under_force_stop.md) |
| ✅ | 29 | `NEG_MTS_029_sop_without_matching_eop_then_abort` | stmt=91.66, branch=81.64, cond=73.45, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=27.20 | [case](../cases/NEG_MTS_029_sop_without_matching_eop_then_abort.md) |
| ✅ | 30 | `NEG_MTS_030_sideband_outside_enabled_window` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.09 | [case](../cases/NEG_MTS_030_sideband_outside_enabled_window.md) |
| ✅ | 31 | `NEG_MTS_031_valid_while_input_ready_low_idle` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.09 | [case](../cases/NEG_MTS_031_valid_while_input_ready_low_idle.md) |
| ✅ | 32 | `NEG_MTS_032_valid_while_input_ready_low_sync` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.09 | [case](../cases/NEG_MTS_032_valid_while_input_ready_low_sync.md) |
| ✅ | 33 | `NEG_MTS_033_source_drops_valid_too_early` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.09 | [case](../cases/NEG_MTS_033_source_drops_valid_too_early.md) |
| ✅ | 34 | `NEG_MTS_034_output_ready_low_single_fault` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.17 | [case](../cases/NEG_MTS_034_output_ready_low_single_fault.md) |
| ✅ | 35 | `NEG_MTS_035_output_ready_low_boundary_fault` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.17 | [case](../cases/NEG_MTS_035_output_ready_low_boundary_fault.md) |
| ✅ | 36 | `NEG_MTS_036_output_ready_unknown_fault` | stmt=91.66, branch=82.03, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.17 | [case](../cases/NEG_MTS_036_output_ready_unknown_fault.md) |
| ✅ | 37 | `NEG_MTS_037_csr_driver_waitrequest_fault` | stmt=91.66, branch=82.81, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.17 | [case](../cases/NEG_MTS_037_csr_driver_waitrequest_fault.md) |
| ✅ | 38 | `NEG_MTS_038_ctrl_driver_assumes_stateful_ready` | stmt=91.66, branch=82.81, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.22 | [case](../cases/NEG_MTS_038_ctrl_driver_assumes_stateful_ready.md) |
| ✅ | 39 | `NEG_MTS_039_hit_source_changes_payload_midbeat` | stmt=91.66, branch=82.81, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.27 | [case](../cases/NEG_MTS_039_hit_source_changes_payload_midbeat.md) |
| ✅ | 40 | `NEG_MTS_040_ctrl_valid_on_reset_edge` | stmt=91.66, branch=82.81, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.29 | [case](../cases/NEG_MTS_040_ctrl_valid_on_reset_edge.md) |
| ✅ | 41 | `NEG_MTS_041_negative_debug_ts_error` | stmt=92.22, branch=83.98, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=32.47 | [case](../cases/NEG_MTS_041_negative_debug_ts_error.md) |
| ✅ | 42 | `NEG_MTS_042_zero_debug_ts_error` | stmt=92.22, branch=83.98, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=33.96 | [case](../cases/NEG_MTS_042_zero_debug_ts_error.md) |
| ✅ | 43 | `NEG_MTS_043_equal_expected_latency_error` | stmt=92.22, branch=83.98, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=34.16 | [case](../cases/NEG_MTS_043_equal_expected_latency_error.md) |
| ✅ | 44 | `NEG_MTS_044_above_expected_latency_error` | stmt=92.22, branch=83.98, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=34.98 | [case](../cases/NEG_MTS_044_above_expected_latency_error.md) |
| ✅ | 45 | `NEG_MTS_045_zero_window_fault_everything` | stmt=92.22, branch=83.98, cond=74.33, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=34.98 | [case](../cases/NEG_MTS_045_zero_window_fault_everything.md) |
| ✅ | 46 | `NEG_MTS_046_bypass_toggle_midstream_mismatch` | stmt=93.14, branch=85.54, cond=76.99, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.36 | [case](../cases/NEG_MTS_046_bypass_toggle_midstream_mismatch.md) |
| ✅ | 47 | `NEG_MTS_047_padding_upper_regression_trap` | stmt=93.51, branch=86.32, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.53 | [case](../cases/NEG_MTS_047_padding_upper_regression_trap.md) |
| ✅ | 48 | `NEG_MTS_048_quotient_remainder_mismatch_trap` | stmt=93.51, branch=86.32, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.80 | [case](../cases/NEG_MTS_048_quotient_remainder_mismatch_trap.md) |
| ✅ | 49 | `NEG_MTS_049_route_channel_mismatch_trap` | stmt=93.51, branch=86.32, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.60 | [case](../cases/NEG_MTS_049_route_channel_mismatch_trap.md) |
| ✅ | 50 | `NEG_MTS_050_tfine_corruption_trap` | stmt=93.51, branch=86.32, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.60 | [case](../cases/NEG_MTS_050_tfine_corruption_trap.md) |
| ✅ | 51 | `NEG_MTS_051_short_mode_nonzero_et_illegal` | stmt=93.51, branch=86.32, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.60 | [case](../cases/NEG_MTS_051_short_mode_nonzero_et_illegal.md) |
| ✅ | 52 | `NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal` | stmt=93.70, branch=87.10, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.82 | [case](../cases/NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal.md) |
| ✅ | 53 | `NEG_MTS_053_positive_delta_missing_et` | stmt=94.07, branch=87.89, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.14 | [case](../cases/NEG_MTS_053_positive_delta_missing_et.md) |
| ✅ | 54 | `NEG_MTS_054_above_511_unsaturated_et` | stmt=94.25, branch=88.28, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.72 | [case](../cases/NEG_MTS_054_above_511_unsaturated_et.md) |
| ✅ | 55 | `NEG_MTS_055_negative_delta_wrong_clamp` | stmt=94.44, branch=88.67, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.72 | [case](../cases/NEG_MTS_055_negative_delta_wrong_clamp.md) |
| ✅ | 56 | `NEG_MTS_056_stale_derive_tot_after_toggle` | stmt=94.44, branch=88.67, cond=78.76, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.75 | [case](../cases/NEG_MTS_056_stale_derive_tot_after_toggle.md) |
| ✅ | 57 | `NEG_MTS_057_stale_delay_field_after_toggle` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.77 | [case](../cases/NEG_MTS_057_stale_delay_field_after_toggle.md) |
| ✅ | 58 | `NEG_MTS_058_eflag_pipeline_corruption` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.77 | [case](../cases/NEG_MTS_058_eflag_pipeline_corruption.md) |
| ✅ | 59 | `NEG_MTS_059_legacy_positive_vector_regression` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=45.77 | [case](../cases/NEG_MTS_059_legacy_positive_vector_regression.md) |
| ✅ | 60 | `NEG_MTS_060_legacy_clamp_vector_regression` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.05 | [case](../cases/NEG_MTS_060_legacy_clamp_vector_regression.md) |
| ✅ | 61 | `NEG_MTS_061_missing_first_sop` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.05 | [case](../cases/NEG_MTS_061_missing_first_sop.md) |
| ✅ | 62 | `NEG_MTS_062_repeated_sop_same_channel` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/NEG_MTS_062_repeated_sop_same_channel.md) |
| ✅ | 63 | `NEG_MTS_063_sop_on_disabled_channel` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/NEG_MTS_063_sop_on_disabled_channel.md) |
| ✅ | 64 | `NEG_MTS_064_eop_outside_terminating_illegal` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/NEG_MTS_064_eop_outside_terminating_illegal.md) |
| ✅ | 65 | `NEG_MTS_065_missing_forwarded_terminating_eop` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/NEG_MTS_065_missing_forwarded_terminating_eop.md) |
| ✅ | 66 | `NEG_MTS_066_eop_pipe_alignment_hole` | stmt=94.44, branch=88.67, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.07 | [case](../cases/NEG_MTS_066_eop_pipe_alignment_hole.md) |
| ✅ | 67 | `NEG_MTS_067_empty_nonzero_illegal` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.10 | [case](../cases/NEG_MTS_067_empty_nonzero_illegal.md) |
| ✅ | 68 | `NEG_MTS_068_duplicate_output_eop` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.10 | [case](../cases/NEG_MTS_068_duplicate_output_eop.md) |
| ✅ | 69 | `NEG_MTS_069_output_valid_outside_active_states` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.10 | [case](../cases/NEG_MTS_069_output_valid_outside_active_states.md) |
| ✅ | 70 | `NEG_MTS_070_packet_tracker_not_cleared_by_reset` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.10 | [case](../cases/NEG_MTS_070_packet_tracker_not_cleared_by_reset.md) |
| ✅ | 71 | `NEG_MTS_071_global_reset_clears_inflight_valids` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.10 | [case](../cases/NEG_MTS_071_global_reset_clears_inflight_valids.md) |
| ✅ | 72 | `NEG_MTS_072_global_reset_clears_debug_history` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.22 | [case](../cases/NEG_MTS_072_global_reset_clears_debug_history.md) |
| ✅ | 73 | `NEG_MTS_073_soft_reset_hangs_running_illegal` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.22 | [case](../cases/NEG_MTS_073_soft_reset_hangs_running_illegal.md) |
| ✅ | 74 | `NEG_MTS_074_soft_reset_creates_phantom_eop` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.22 | [case](../cases/NEG_MTS_074_soft_reset_creates_phantom_eop.md) |
| ✅ | 75 | `NEG_MTS_075_prepare_after_aborted_packet` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.22 | [case](../cases/NEG_MTS_075_prepare_after_aborted_packet.md) |
| ✅ | 76 | `NEG_MTS_076_force_stop_stuck_high` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.35 | [case](../cases/NEG_MTS_076_force_stop_stuck_high.md) |
| ✅ | 77 | `NEG_MTS_077_force_stop_clear_not_reopening` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.35 | [case](../cases/NEG_MTS_077_force_stop_clear_not_reopening.md) |
| ✅ | 78 | `NEG_MTS_078_reset_flow_stuck_sclr` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.35 | [case](../cases/NEG_MTS_078_reset_flow_stuck_sclr.md) |
| ✅ | 79 | `NEG_MTS_079_reset_flow_stuck_sync` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.35 | [case](../cases/NEG_MTS_079_reset_flow_stuck_sync.md) |
| ✅ | 80 | `NEG_MTS_080_direct_running_no_accept_illegal` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=46.35 | [case](../cases/NEG_MTS_080_direct_running_no_accept_illegal.md) |
| ✅ | 81 | `NEG_MTS_081_pipeline_two_math_regression` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.36 | [case](../cases/NEG_MTS_081_pipeline_two_math_regression.md) |
| ✅ | 82 | `NEG_MTS_082_remapped_hiterr_not_honored` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.59 | [case](../cases/NEG_MTS_082_remapped_hiterr_not_honored.md) |
| ✅ | 83 | `NEG_MTS_083_default_latency_generic_not_reflected` | stmt=95.18, branch=89.45, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.59 | [case](../cases/NEG_MTS_083_default_latency_generic_not_reflected.md) |
| ✅ | 84 | `NEG_MTS_084_debug_zero_changes_functionality` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.66 | [case](../cases/NEG_MTS_084_debug_zero_changes_functionality.md) |
| ✅ | 85 | `NEG_MTS_085_bank_string_changes_functionality` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.66 | [case](../cases/NEG_MTS_085_bank_string_changes_functionality.md) |
| ✅ | 86 | `NEG_MTS_086_padding_eop_wait_changes_behavior_today` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.66 | [case](../cases/NEG_MTS_086_padding_eop_wait_changes_behavior_today.md) |
| ✅ | 87 | `NEG_MTS_087_crcerr_bit_changes_behavior_today` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.66 | [case](../cases/NEG_MTS_087_crcerr_bit_changes_behavior_today.md) |
| ✅ | 88 | `NEG_MTS_088_frame_corrupt_bit_changes_behavior_today` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.66 | [case](../cases/NEG_MTS_088_frame_corrupt_bit_changes_behavior_today.md) |
| ✅ | 89 | `NEG_MTS_089_invalid_enabled_window_compile_guard` | stmt=95.18, branch=89.49, cond=79.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.86 | [case](../cases/NEG_MTS_089_invalid_enabled_window_compile_guard.md) |
| ✅ | 90 | `NEG_MTS_090_out_of_range_enabled_values` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.86 | [case](../cases/NEG_MTS_090_out_of_range_enabled_values.md) |
| ✅ | 91 | `NEG_MTS_091_debug_ts_without_processed_hit` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.86 | [case](../cases/NEG_MTS_091_debug_ts_without_processed_hit.md) |
| ✅ | 92 | `NEG_MTS_092_stale_debug_ts_data` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.91 | [case](../cases/NEG_MTS_092_stale_debug_ts_data.md) |
| ✅ | 93 | `NEG_MTS_093_debug_burst_on_first_hit_without_history` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.91 | [case](../cases/NEG_MTS_093_debug_burst_on_first_hit_without_history.md) |
| ✅ | 94 | `NEG_MTS_094_ts_delta_without_burst_context` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.91 | [case](../cases/NEG_MTS_094_ts_delta_without_burst_context.md) |
| ✅ | 95 | `NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.91 | [case](../cases/NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree.md) |
| ✅ | 96 | `NEG_MTS_096_arrival_delta_wrap_fault` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.91 | [case](../cases/NEG_MTS_096_arrival_delta_wrap_fault.md) |
| ✅ | 97 | `NEG_MTS_097_signmag_conversion_extreme_negative` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_097_signmag_conversion_extreme_negative.md) |
| ✅ | 98 | `NEG_MTS_098_delay_field_switch_no_debug_source_change` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_098_delay_field_switch_no_debug_source_change.md) |
| ✅ | 99 | `NEG_MTS_099_debug_outputs_active_in_idle` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_099_debug_outputs_active_in_idle.md) |
| ✅ | 100 | `NEG_MTS_100_debug_outputs_active_in_reset` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_100_debug_outputs_active_in_reset.md) |
| ✅ | 101 | `NEG_MTS_101_discard_counter_on_clean_hit` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_101_discard_counter_on_clean_hit.md) |
| ✅ | 102 | `NEG_MTS_102_missing_discard_increment` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_102_missing_discard_increment.md) |
| ✅ | 103 | `NEG_MTS_103_missing_total_increment_on_reject` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_103_missing_total_increment_on_reject.md) |
| ✅ | 104 | `NEG_MTS_104_spurious_total_increment_without_valid` | stmt=95.18, branch=89.49, cond=80.53, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.25 | [case](../cases/NEG_MTS_104_spurious_total_increment_without_valid.md) |
| ✅ | 105 | `NEG_MTS_105_hi_lo_counter_snapshot_incoherent` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.39 | [case](../cases/NEG_MTS_105_hi_lo_counter_snapshot_incoherent.md) |
| ✅ | 106 | `NEG_MTS_106_soft_reset_counter_clear_failure` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.39 | [case](../cases/NEG_MTS_106_soft_reset_counter_clear_failure.md) |
| ✅ | 107 | `NEG_MTS_107_sync_counter_clear_failure` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.39 | [case](../cases/NEG_MTS_107_sync_counter_clear_failure.md) |
| ✅ | 108 | `NEG_MTS_108_running_status_high_outside_run` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.39 | [case](../cases/NEG_MTS_108_running_status_high_outside_run.md) |
| ✅ | 109 | `NEG_MTS_109_running_status_low_inside_run` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.39 | [case](../cases/NEG_MTS_109_running_status_low_inside_run.md) |
| ✅ | 110 | `NEG_MTS_110_control_readback_mismatch` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.43 | [case](../cases/NEG_MTS_110_control_readback_mismatch.md) |
| ✅ | 111 | `NEG_MTS_111_terminate_without_real_eop_gap` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.43 | [case](../cases/NEG_MTS_111_terminate_without_real_eop_gap.md) |
| ✅ | 112 | `NEG_MTS_112_idle_before_eop_delay_finishes` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.43 | [case](../cases/NEG_MTS_112_idle_before_eop_delay_finishes.md) |
| ✅ | 113 | `NEG_MTS_113_multiple_eops_multiple_boundaries` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_113_multiple_eops_multiple_boundaries.md) |
| ✅ | 114 | `NEG_MTS_114_packet_crosses_terminate_edge` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_114_packet_crosses_terminate_edge.md) |
| ✅ | 115 | `NEG_MTS_115_disabled_sideband_boundary_loss` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_115_disabled_sideband_boundary_loss.md) |
| ✅ | 116 | `NEG_MTS_116_terminate_ack_before_work_done` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_116_terminate_ack_before_work_done.md) |
| ✅ | 117 | `NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap.md) |
| ✅ | 118 | `NEG_MTS_118_missing_boundary_with_packet_open` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_118_missing_boundary_with_packet_open.md) |
| ✅ | 119 | `NEG_MTS_119_duplicate_boundary_per_run` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_119_duplicate_boundary_per_run.md) |
| ✅ | 120 | `NEG_MTS_120_idle_before_pipeline_empty` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_120_idle_before_pipeline_empty.md) |
| ✅ | 121 | `NEG_MTS_121_prepare_ready_stateful_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_121_prepare_ready_stateful_upgrade.md) |
| ✅ | 122 | `NEG_MTS_122_sync_ready_stateful_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_122_sync_ready_stateful_upgrade.md) |
| ✅ | 123 | `NEG_MTS_123_flushing_ready_stateful_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_123_flushing_ready_stateful_upgrade.md) |
| ✅ | 124 | `NEG_MTS_124_terminate_ack_after_drain_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_124_terminate_ack_after_drain_upgrade.md) |
| ✅ | 125 | `NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade.md) |
| ✅ | 126 | `NEG_MTS_126_no_fresh_accept_in_flushing_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_126_no_fresh_accept_in_flushing_upgrade.md) |
| ✅ | 127 | `NEG_MTS_127_exactly_one_boundary_per_stop_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_127_exactly_one_boundary_per_stop_upgrade.md) |
| ✅ | 128 | `NEG_MTS_128_idle_only_after_boundary_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_128_idle_only_after_boundary_upgrade.md) |
| ✅ | 129 | `NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=51.46 | [case](../cases/NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade.md) |
| ✅ | 130 | `NEG_MTS_130_full_run_sequence_upgrade_suite` | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.12 | [case](../cases/NEG_MTS_130_full_run_sequence_upgrade_suite.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
