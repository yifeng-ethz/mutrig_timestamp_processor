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
| ⚠️ | stmt | 93.99 | 95.0 |
| ⚠️ | branch | 86.77 | 90.0 |
| ℹ️ | cond | 84.67 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 88.88 | 90.0 |
| ⚠️ | toggle | 49.40 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `NEG_MTS_001_all_zero_ctrl_word` | stmt=76.89, branch=60.06, cond=35.48, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=6.81 | [case](../cases/NEG_MTS_001_all_zero_ctrl_word.md) |
| ✅ | 2 | `NEG_MTS_002_multi_hot_ctrl_word` | stmt=76.89, branch=60.06, cond=35.48, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=6.84 | [case](../cases/NEG_MTS_002_multi_hot_ctrl_word.md) |
| ✅ | 3 | `NEG_MTS_003_illegal_ctrl_during_running` | stmt=76.89, branch=60.06, cond=35.48, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=7.22 | [case](../cases/NEG_MTS_003_illegal_ctrl_during_running.md) |
| ✅ | 4 | `NEG_MTS_004_illegal_ctrl_during_flushing` | stmt=80.23, branch=67.85, cond=50.80, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.31 | [case](../cases/NEG_MTS_004_illegal_ctrl_during_flushing.md) |
| ✅ | 5 | `NEG_MTS_005_ctrl_valid_high_data_changes` | stmt=80.48, branch=68.18, cond=51.61, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.34 | [case](../cases/NEG_MTS_005_ctrl_valid_high_data_changes.md) |
| ✅ | 6 | `NEG_MTS_006_ctrl_data_unknown_injection` | stmt=80.48, branch=68.18, cond=51.61, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=8.34 | [case](../cases/NEG_MTS_006_ctrl_data_unknown_injection.md) |
| ✅ | 7 | `NEG_MTS_007_running_without_sync_documented_nonstandard` | stmt=82.02, branch=69.15, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=9.52 | [case](../cases/NEG_MTS_007_running_without_sync_documented_nonstandard.md) |
| ✅ | 8 | `NEG_MTS_008_terminate_from_idle` | stmt=82.41, branch=70.12, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=9.61 | [case](../cases/NEG_MTS_008_terminate_from_idle.md) |
| ✅ | 9 | `NEG_MTS_009_link_test_during_running` | stmt=82.54, branch=70.77, cond=54.03, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=9.70 | [case](../cases/NEG_MTS_009_link_test_during_running.md) |
| ✅ | 10 | `NEG_MTS_010_always_ready_masks_incomplete_work` | stmt=82.92, branch=71.42, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=9.70 | [case](../cases/NEG_MTS_010_always_ready_masks_incomplete_work.md) |
| ✅ | 11 | `NEG_MTS_011_simultaneous_read_write_same_cycle` | stmt=83.56, branch=72.07, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=9.99 | [case](../cases/NEG_MTS_011_simultaneous_read_write_same_cycle.md) |
| ✅ | 12 | `NEG_MTS_012_write_unsupported_addr5` | stmt=83.69, branch=72.40, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=10.75 | [case](../cases/NEG_MTS_012_write_unsupported_addr5.md) |
| ✅ | 13 | `NEG_MTS_013_read_unsupported_addr6` | stmt=83.82, branch=72.72, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=10.75 | [case](../cases/NEG_MTS_013_read_unsupported_addr6.md) |
| ✅ | 14 | `NEG_MTS_014_reserved_opmode_bit28_write` | stmt=83.82, branch=72.72, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=12.24 | [case](../cases/NEG_MTS_014_reserved_opmode_bit28_write.md) |
| ✅ | 15 | `NEG_MTS_015_write_expected_latency_during_reset` | stmt=83.82, branch=72.72, cond=54.83, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=12.66 | [case](../cases/NEG_MTS_015_write_expected_latency_during_reset.md) |
| ✅ | 16 | `NEG_MTS_016_back_to_back_soft_reset_pulses` | stmt=89.21, branch=74.35, cond=66.12, expr=83.33, fsm_state=100.00, fsm_trans=77.77, toggle=13.24 | [case](../cases/NEG_MTS_016_back_to_back_soft_reset_pulses.md) |
| ✅ | 17 | `NEG_MTS_017_rapid_force_stop_toggle` | stmt=89.47, branch=75.32, cond=68.54, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=13.65 | [case](../cases/NEG_MTS_017_rapid_force_stop_toggle.md) |
| ✅ | 18 | `NEG_MTS_018_driver_ignores_waitrequest` | stmt=89.47, branch=75.32, cond=68.54, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=13.65 | [case](../cases/NEG_MTS_018_driver_ignores_waitrequest.md) |
| ✅ | 19 | `NEG_MTS_019_counter_reads_mid_reset` | stmt=89.47, branch=75.32, cond=68.54, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=13.65 | [case](../cases/NEG_MTS_019_counter_reads_mid_reset.md) |
| ✅ | 20 | `NEG_MTS_020_expected_latency_overflow_model` | stmt=89.47, branch=75.32, cond=68.54, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=15.13 | [case](../cases/NEG_MTS_020_expected_latency_overflow_model.md) |
| ✅ | 21 | `NEG_MTS_021_hiterr_rejected_running` | stmt=89.47, branch=75.32, cond=69.35, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=15.16 | [case](../cases/NEG_MTS_021_hiterr_rejected_running.md) |
| ✅ | 22 | `NEG_MTS_022_hiterr_kept_running` | stmt=89.85, branch=75.97, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=15.77 | [case](../cases/NEG_MTS_022_hiterr_kept_running.md) |
| ✅ | 23 | `NEG_MTS_023_crcerr_only_inert` | stmt=89.85, branch=75.97, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=15.80 | [case](../cases/NEG_MTS_023_crcerr_only_inert.md) |
| ✅ | 24 | `NEG_MTS_024_frame_corrupt_only_inert` | stmt=89.85, branch=75.97, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=15.83 | [case](../cases/NEG_MTS_024_frame_corrupt_only_inert.md) |
| ✅ | 25 | `NEG_MTS_025_combined_error_bits_only_hiterr_matters` | stmt=89.85, branch=76.29, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.17 | [case](../cases/NEG_MTS_025_combined_error_bits_only_hiterr_matters.md) |
| ✅ | 26 | `NEG_MTS_026_valid_beat_in_idle` | stmt=89.85, branch=76.29, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.17 | [case](../cases/NEG_MTS_026_valid_beat_in_idle.md) |
| ✅ | 27 | `NEG_MTS_027_valid_beat_in_reset_sync` | stmt=89.85, branch=76.29, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.17 | [case](../cases/NEG_MTS_027_valid_beat_in_reset_sync.md) |
| ✅ | 28 | `NEG_MTS_028_valid_beat_under_force_stop` | stmt=89.85, branch=76.29, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.17 | [case](../cases/NEG_MTS_028_valid_beat_under_force_stop.md) |
| ✅ | 29 | `NEG_MTS_029_sop_without_matching_eop_then_abort` | stmt=89.85, branch=76.29, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.17 | [case](../cases/NEG_MTS_029_sop_without_matching_eop_then_abort.md) |
| ✅ | 30 | `NEG_MTS_030_sideband_outside_enabled_window` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.51 | [case](../cases/NEG_MTS_030_sideband_outside_enabled_window.md) |
| ✅ | 31 | `NEG_MTS_031_valid_while_input_ready_low_idle` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.51 | [case](../cases/NEG_MTS_031_valid_while_input_ready_low_idle.md) |
| ✅ | 32 | `NEG_MTS_032_valid_while_input_ready_low_sync` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.51 | [case](../cases/NEG_MTS_032_valid_while_input_ready_low_sync.md) |
| ✅ | 33 | `NEG_MTS_033_source_drops_valid_too_early` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.51 | [case](../cases/NEG_MTS_033_source_drops_valid_too_early.md) |
| ✅ | 34 | `NEG_MTS_034_output_ready_low_single_fault` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.57 | [case](../cases/NEG_MTS_034_output_ready_low_single_fault.md) |
| ✅ | 35 | `NEG_MTS_035_output_ready_low_boundary_fault` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.57 | [case](../cases/NEG_MTS_035_output_ready_low_boundary_fault.md) |
| ✅ | 36 | `NEG_MTS_036_output_ready_unknown_fault` | stmt=89.85, branch=76.62, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.57 | [case](../cases/NEG_MTS_036_output_ready_unknown_fault.md) |
| ✅ | 37 | `NEG_MTS_037_csr_driver_waitrequest_fault` | stmt=89.85, branch=77.27, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.57 | [case](../cases/NEG_MTS_037_csr_driver_waitrequest_fault.md) |
| ✅ | 38 | `NEG_MTS_038_ctrl_driver_assumes_stateful_ready` | stmt=89.85, branch=77.27, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.57 | [case](../cases/NEG_MTS_038_ctrl_driver_assumes_stateful_ready.md) |
| ✅ | 39 | `NEG_MTS_039_hit_source_changes_payload_midbeat` | stmt=89.85, branch=77.27, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.64 | [case](../cases/NEG_MTS_039_hit_source_changes_payload_midbeat.md) |
| ✅ | 40 | `NEG_MTS_040_ctrl_valid_on_reset_edge` | stmt=89.85, branch=77.27, cond=72.58, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=23.64 | [case](../cases/NEG_MTS_040_ctrl_valid_on_reset_edge.md) |
| ✅ | 41 | `NEG_MTS_041_negative_debug_ts_error` | stmt=90.62, branch=78.89, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=30.33 | [case](../cases/NEG_MTS_041_negative_debug_ts_error.md) |
| ✅ | 42 | `NEG_MTS_042_zero_debug_ts_error` | stmt=90.62, branch=78.89, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=30.58 | [case](../cases/NEG_MTS_042_zero_debug_ts_error.md) |
| ✅ | 43 | `NEG_MTS_043_equal_expected_latency_error` | stmt=90.62, branch=78.89, cond=73.38, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=30.58 | [case](../cases/NEG_MTS_043_equal_expected_latency_error.md) |
| ✅ | 44 | `NEG_MTS_044_above_expected_latency_error` | stmt=90.62, branch=78.89, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=31.14 | [case](../cases/NEG_MTS_044_above_expected_latency_error.md) |
| ✅ | 45 | `NEG_MTS_045_zero_window_fault_everything` | stmt=90.62, branch=78.89, cond=77.41, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=31.15 | [case](../cases/NEG_MTS_045_zero_window_fault_everything.md) |
| ✅ | 46 | `NEG_MTS_046_bypass_toggle_midstream_mismatch` | stmt=91.27, branch=80.19, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=37.12 | [case](../cases/NEG_MTS_046_bypass_toggle_midstream_mismatch.md) |
| ✅ | 47 | `NEG_MTS_047_padding_upper_regression_trap` | stmt=91.52, branch=80.84, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=37.92 | [case](../cases/NEG_MTS_047_padding_upper_regression_trap.md) |
| ✅ | 48 | `NEG_MTS_048_quotient_remainder_mismatch_trap` | stmt=91.52, branch=80.84, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=38.10 | [case](../cases/NEG_MTS_048_quotient_remainder_mismatch_trap.md) |
| ✅ | 49 | `NEG_MTS_049_route_channel_mismatch_trap` | stmt=91.52, branch=80.84, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=38.81 | [case](../cases/NEG_MTS_049_route_channel_mismatch_trap.md) |
| ✅ | 50 | `NEG_MTS_050_tfine_corruption_trap` | stmt=91.52, branch=80.84, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=38.81 | [case](../cases/NEG_MTS_050_tfine_corruption_trap.md) |
| ✅ | 51 | `NEG_MTS_051_short_mode_nonzero_et_illegal` | stmt=91.52, branch=80.84, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=38.81 | [case](../cases/NEG_MTS_051_short_mode_nonzero_et_illegal.md) |
| ✅ | 52 | `NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal` | stmt=91.65, branch=81.49, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=38.95 | [case](../cases/NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal.md) |
| ✅ | 53 | `NEG_MTS_053_positive_delta_missing_et` | stmt=91.91, branch=82.14, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=39.16 | [case](../cases/NEG_MTS_053_positive_delta_missing_et.md) |
| ✅ | 54 | `NEG_MTS_054_above_511_unsaturated_et` | stmt=92.04, branch=82.46, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=40.86 | [case](../cases/NEG_MTS_054_above_511_unsaturated_et.md) |
| ✅ | 55 | `NEG_MTS_055_negative_delta_wrong_clamp` | stmt=92.16, branch=82.79, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=40.86 | [case](../cases/NEG_MTS_055_negative_delta_wrong_clamp.md) |
| ✅ | 56 | `NEG_MTS_056_stale_derive_tot_after_toggle` | stmt=92.16, branch=82.79, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=40.89 | [case](../cases/NEG_MTS_056_stale_derive_tot_after_toggle.md) |
| ✅ | 57 | `NEG_MTS_057_stale_delay_field_after_toggle` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.12 | [case](../cases/NEG_MTS_057_stale_delay_field_after_toggle.md) |
| ✅ | 58 | `NEG_MTS_058_eflag_pipeline_corruption` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.12 | [case](../cases/NEG_MTS_058_eflag_pipeline_corruption.md) |
| ✅ | 59 | `NEG_MTS_059_legacy_positive_vector_regression` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.12 | [case](../cases/NEG_MTS_059_legacy_positive_vector_regression.md) |
| ✅ | 60 | `NEG_MTS_060_legacy_clamp_vector_regression` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_060_legacy_clamp_vector_regression.md) |
| ✅ | 61 | `NEG_MTS_061_missing_first_sop` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_061_missing_first_sop.md) |
| ✅ | 62 | `NEG_MTS_062_repeated_sop_same_channel` | stmt=92.68, branch=83.44, cond=81.45, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_062_repeated_sop_same_channel.md) |
| ✅ | 63 | `NEG_MTS_063_sop_on_disabled_channel` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_063_sop_on_disabled_channel.md) |
| ✅ | 64 | `NEG_MTS_064_eop_outside_terminating_illegal` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_064_eop_outside_terminating_illegal.md) |
| ✅ | 65 | `NEG_MTS_065_missing_forwarded_terminating_eop` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_065_missing_forwarded_terminating_eop.md) |
| ✅ | 66 | `NEG_MTS_066_eop_pipe_alignment_hole` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.17 | [case](../cases/NEG_MTS_066_eop_pipe_alignment_hole.md) |
| ✅ | 67 | `NEG_MTS_067_empty_nonzero_illegal` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.18 | [case](../cases/NEG_MTS_067_empty_nonzero_illegal.md) |
| ✅ | 68 | `NEG_MTS_068_duplicate_output_eop` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.18 | [case](../cases/NEG_MTS_068_duplicate_output_eop.md) |
| ✅ | 69 | `NEG_MTS_069_output_valid_outside_active_states` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.18 | [case](../cases/NEG_MTS_069_output_valid_outside_active_states.md) |
| ✅ | 70 | `NEG_MTS_070_packet_tracker_not_cleared_by_reset` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.18 | [case](../cases/NEG_MTS_070_packet_tracker_not_cleared_by_reset.md) |
| ✅ | 71 | `NEG_MTS_071_global_reset_clears_inflight_valids` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.18 | [case](../cases/NEG_MTS_071_global_reset_clears_inflight_valids.md) |
| ✅ | 72 | `NEG_MTS_072_global_reset_clears_debug_history` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.21 | [case](../cases/NEG_MTS_072_global_reset_clears_debug_history.md) |
| ✅ | 73 | `NEG_MTS_073_soft_reset_hangs_running_illegal` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.21 | [case](../cases/NEG_MTS_073_soft_reset_hangs_running_illegal.md) |
| ✅ | 74 | `NEG_MTS_074_soft_reset_creates_phantom_eop` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.21 | [case](../cases/NEG_MTS_074_soft_reset_creates_phantom_eop.md) |
| ✅ | 75 | `NEG_MTS_075_prepare_after_aborted_packet` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.21 | [case](../cases/NEG_MTS_075_prepare_after_aborted_packet.md) |
| ✅ | 76 | `NEG_MTS_076_force_stop_stuck_high` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.27 | [case](../cases/NEG_MTS_076_force_stop_stuck_high.md) |
| ✅ | 77 | `NEG_MTS_077_force_stop_clear_not_reopening` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.27 | [case](../cases/NEG_MTS_077_force_stop_clear_not_reopening.md) |
| ✅ | 78 | `NEG_MTS_078_reset_flow_stuck_sclr` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.27 | [case](../cases/NEG_MTS_078_reset_flow_stuck_sclr.md) |
| ✅ | 79 | `NEG_MTS_079_reset_flow_stuck_sync` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.27 | [case](../cases/NEG_MTS_079_reset_flow_stuck_sync.md) |
| ✅ | 80 | `NEG_MTS_080_direct_running_no_accept_illegal` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=41.27 | [case](../cases/NEG_MTS_080_direct_running_no_accept_illegal.md) |
| ✅ | 81 | `NEG_MTS_081_pipeline_two_math_regression` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=43.56 | [case](../cases/NEG_MTS_081_pipeline_two_math_regression.md) |
| ✅ | 82 | `NEG_MTS_082_remapped_hiterr_not_honored` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=43.71 | [case](../cases/NEG_MTS_082_remapped_hiterr_not_honored.md) |
| ✅ | 83 | `NEG_MTS_083_default_latency_generic_not_reflected` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=43.71 | [case](../cases/NEG_MTS_083_default_latency_generic_not_reflected.md) |
| ✅ | 84 | `NEG_MTS_084_debug_zero_changes_functionality` | stmt=92.68, branch=83.44, cond=82.25, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=43.85 | [case](../cases/NEG_MTS_084_debug_zero_changes_functionality.md) |
| ✅ | 85 | `NEG_MTS_085_bank_string_changes_functionality` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.34 | [case](../cases/NEG_MTS_085_bank_string_changes_functionality.md) |
| ✅ | 86 | `NEG_MTS_086_padding_eop_wait_changes_behavior_today` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.34 | [case](../cases/NEG_MTS_086_padding_eop_wait_changes_behavior_today.md) |
| ✅ | 87 | `NEG_MTS_087_crcerr_bit_changes_behavior_today` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.34 | [case](../cases/NEG_MTS_087_crcerr_bit_changes_behavior_today.md) |
| ✅ | 88 | `NEG_MTS_088_frame_corrupt_bit_changes_behavior_today` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.34 | [case](../cases/NEG_MTS_088_frame_corrupt_bit_changes_behavior_today.md) |
| ✅ | 89 | `NEG_MTS_089_invalid_enabled_window_compile_guard` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_089_invalid_enabled_window_compile_guard.md) |
| ✅ | 90 | `NEG_MTS_090_out_of_range_enabled_values` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_090_out_of_range_enabled_values.md) |
| ✅ | 91 | `NEG_MTS_091_debug_ts_without_processed_hit` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_091_debug_ts_without_processed_hit.md) |
| ✅ | 92 | `NEG_MTS_092_stale_debug_ts_data` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_092_stale_debug_ts_data.md) |
| ✅ | 93 | `NEG_MTS_093_debug_burst_on_first_hit_without_history` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_093_debug_burst_on_first_hit_without_history.md) |
| ✅ | 94 | `NEG_MTS_094_ts_delta_without_burst_context` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_094_ts_delta_without_burst_context.md) |
| ✅ | 95 | `NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree.md) |
| ✅ | 96 | `NEG_MTS_096_arrival_delta_wrap_fault` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=45.50 | [case](../cases/NEG_MTS_096_arrival_delta_wrap_fault.md) |
| ✅ | 97 | `NEG_MTS_097_signmag_conversion_extreme_negative` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_097_signmag_conversion_extreme_negative.md) |
| ✅ | 98 | `NEG_MTS_098_delay_field_switch_no_debug_source_change` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_098_delay_field_switch_no_debug_source_change.md) |
| ✅ | 99 | `NEG_MTS_099_debug_outputs_active_in_idle` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_099_debug_outputs_active_in_idle.md) |
| ✅ | 100 | `NEG_MTS_100_debug_outputs_active_in_reset` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_100_debug_outputs_active_in_reset.md) |
| ✅ | 101 | `NEG_MTS_101_discard_counter_on_clean_hit` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_101_discard_counter_on_clean_hit.md) |
| ✅ | 102 | `NEG_MTS_102_missing_discard_increment` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_102_missing_discard_increment.md) |
| ✅ | 103 | `NEG_MTS_103_missing_total_increment_on_reject` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_103_missing_total_increment_on_reject.md) |
| ✅ | 104 | `NEG_MTS_104_spurious_total_increment_without_valid` | stmt=93.19, branch=84.09, cond=83.06, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=46.72 | [case](../cases/NEG_MTS_104_spurious_total_increment_without_valid.md) |
| ✅ | 105 | `NEG_MTS_105_hi_lo_counter_snapshot_incoherent` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.02 | [case](../cases/NEG_MTS_105_hi_lo_counter_snapshot_incoherent.md) |
| ✅ | 106 | `NEG_MTS_106_soft_reset_counter_clear_failure` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.02 | [case](../cases/NEG_MTS_106_soft_reset_counter_clear_failure.md) |
| ✅ | 107 | `NEG_MTS_107_sync_counter_clear_failure` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.02 | [case](../cases/NEG_MTS_107_sync_counter_clear_failure.md) |
| ✅ | 108 | `NEG_MTS_108_running_status_high_outside_run` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.02 | [case](../cases/NEG_MTS_108_running_status_high_outside_run.md) |
| ✅ | 109 | `NEG_MTS_109_running_status_low_inside_run` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.02 | [case](../cases/NEG_MTS_109_running_status_low_inside_run.md) |
| ✅ | 110 | `NEG_MTS_110_control_readback_mismatch` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.05 | [case](../cases/NEG_MTS_110_control_readback_mismatch.md) |
| ✅ | 111 | `NEG_MTS_111_terminate_without_real_eop_gap` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.05 | [case](../cases/NEG_MTS_111_terminate_without_real_eop_gap.md) |
| ✅ | 112 | `NEG_MTS_112_idle_before_eop_delay_finishes` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.05 | [case](../cases/NEG_MTS_112_idle_before_eop_delay_finishes.md) |
| ✅ | 113 | `NEG_MTS_113_multiple_eops_multiple_boundaries` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_113_multiple_eops_multiple_boundaries.md) |
| ✅ | 114 | `NEG_MTS_114_packet_crosses_terminate_edge` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_114_packet_crosses_terminate_edge.md) |
| ✅ | 115 | `NEG_MTS_115_disabled_sideband_boundary_loss` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_115_disabled_sideband_boundary_loss.md) |
| ✅ | 116 | `NEG_MTS_116_terminate_ack_before_work_done` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_116_terminate_ack_before_work_done.md) |
| ✅ | 117 | `NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap.md) |
| ✅ | 118 | `NEG_MTS_118_missing_boundary_with_packet_open` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_118_missing_boundary_with_packet_open.md) |
| ✅ | 119 | `NEG_MTS_119_duplicate_boundary_per_run` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_119_duplicate_boundary_per_run.md) |
| ✅ | 120 | `NEG_MTS_120_idle_before_pipeline_empty` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_120_idle_before_pipeline_empty.md) |
| ✅ | 121 | `NEG_MTS_121_prepare_ready_stateful_upgrade` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_121_prepare_ready_stateful_upgrade.md) |
| ✅ | 122 | `NEG_MTS_122_sync_ready_stateful_upgrade` | stmt=93.48, branch=86.12, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=48.08 | [case](../cases/NEG_MTS_122_sync_ready_stateful_upgrade.md) |
| ✅ | 123 | `NEG_MTS_123_flushing_ready_stateful_upgrade` | stmt=93.74, branch=86.45, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_123_flushing_ready_stateful_upgrade.md) |
| ✅ | 124 | `NEG_MTS_124_terminate_ack_after_drain_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_124_terminate_ack_after_drain_upgrade.md) |
| ✅ | 125 | `NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade.md) |
| ✅ | 126 | `NEG_MTS_126_no_fresh_accept_in_flushing_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_126_no_fresh_accept_in_flushing_upgrade.md) |
| ✅ | 127 | `NEG_MTS_127_exactly_one_boundary_per_stop_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_127_exactly_one_boundary_per_stop_upgrade.md) |
| ✅ | 128 | `NEG_MTS_128_idle_only_after_boundary_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_128_idle_only_after_boundary_upgrade.md) |
| ✅ | 129 | `NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=48.08 | [case](../cases/NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade.md) |
| ✅ | 130 | `NEG_MTS_130_full_run_sequence_upgrade_suite` | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=49.40 | [case](../cases/NEG_MTS_130_full_run_sequence_upgrade_suite.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
