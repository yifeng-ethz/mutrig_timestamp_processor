# ⚠️ BASIC bucket

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
| ✅ | stmt | 95.70 | 95.0 |
| ✅ | branch | 92.21 | 90.0 |
| ℹ️ | cond | 81.03 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 77.77 | 90.0 |
| ⚠️ | toggle | 53.02 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `STD_MTS_001_powerup_reset_idle` | stmt=48.39, branch=30.31, cond=4.31, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.69 | [case](../cases/STD_MTS_001_powerup_reset_idle.md) |
| ✅ | 2 | `STD_MTS_002_reset_release_idle_quiet` | stmt=49.15, branch=31.88, cond=4.31, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=1.03 | [case](../cases/STD_MTS_002_reset_release_idle_quiet.md) |
| ✅ | 3 | `STD_MTS_003_direct_running_entry_allowed` | stmt=75.14, branch=54.33, cond=28.44, expr=100.00, fsm_state=50.00, fsm_trans=11.11, toggle=8.26 | [case](../cases/STD_MTS_003_direct_running_entry_allowed.md) |
| ✅ | 4 | `STD_MTS_004_run_prepare_enters_reset_sclr` | stmt=76.08, branch=58.26, cond=31.03, expr=100.00, fsm_state=75.00, fsm_trans=22.22, toggle=8.41 | [case](../cases/STD_MTS_004_run_prepare_enters_reset_sclr.md) |
| ✅ | 5 | `STD_MTS_005_sync_enters_reset_sync` | stmt=78.53, branch=62.59, cond=38.79, expr=100.00, fsm_state=75.00, fsm_trans=22.22, toggle=8.75 | [case](../cases/STD_MTS_005_sync_enters_reset_sync.md) |
| ✅ | 6 | `STD_MTS_006_running_from_sync` | stmt=80.41, branch=64.56, cond=40.51, expr=100.00, fsm_state=75.00, fsm_trans=33.33, toggle=9.31 | [case](../cases/STD_MTS_006_running_from_sync.md) |
| ✅ | 7 | `STD_MTS_007_terminating_enters_flushing` | stmt=81.35, branch=68.11, cond=43.96, expr=100.00, fsm_state=100.00, fsm_trans=44.44, toggle=9.55 | [case](../cases/STD_MTS_007_terminating_enters_flushing.md) |
| ✅ | 8 | `STD_MTS_008_idle_from_flushing` | stmt=85.12, branch=73.22, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=55.55, toggle=10.66 | [case](../cases/STD_MTS_008_idle_from_flushing.md) |
| ✅ | 9 | `STD_MTS_009_running_abort_to_idle` | stmt=85.31, branch=73.62, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.66 | [case](../cases/STD_MTS_009_running_abort_to_idle.md) |
| ✅ | 10 | `STD_MTS_010_global_reset_during_flushing` | stmt=85.31, branch=73.62, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.81 | [case](../cases/STD_MTS_010_global_reset_during_flushing.md) |
| ✅ | 11 | `STD_MTS_011_control_readback_after_reset` | stmt=85.31, branch=73.62, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.81 | [case](../cases/STD_MTS_011_control_readback_after_reset.md) |
| ✅ | 12 | `STD_MTS_012_discard_counter_default_zero` | stmt=85.31, branch=73.62, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.81 | [case](../cases/STD_MTS_012_discard_counter_default_zero.md) |
| ✅ | 13 | `STD_MTS_013_expected_latency_default_2000` | stmt=85.49, branch=74.01, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.94 | [case](../cases/STD_MTS_013_expected_latency_default_2000.md) |
| ✅ | 14 | `STD_MTS_014_total_counter_hi_default_zero` | stmt=85.49, branch=74.01, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.94 | [case](../cases/STD_MTS_014_total_counter_hi_default_zero.md) |
| ✅ | 15 | `STD_MTS_015_total_counter_lo_default_zero` | stmt=85.49, branch=74.01, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=10.94 | [case](../cases/STD_MTS_015_total_counter_lo_default_zero.md) |
| ✅ | 16 | `STD_MTS_016_force_stop_readback` | stmt=85.68, branch=74.40, cond=54.31, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=11.09 | [case](../cases/STD_MTS_016_force_stop_readback.md) |
| ✅ | 17 | `STD_MTS_017_soft_reset_self_clear` | stmt=88.70, branch=75.19, cond=65.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=11.20 | [case](../cases/STD_MTS_017_soft_reset_self_clear.md) |
| ✅ | 18 | `STD_MTS_018_bypass_lapse_readback` | stmt=88.70, branch=75.19, cond=65.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=11.35 | [case](../cases/STD_MTS_018_bypass_lapse_readback.md) |
| ✅ | 19 | `STD_MTS_019_discard_hiterr_readback` | stmt=88.88, branch=75.98, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.30 | [case](../cases/STD_MTS_019_discard_hiterr_readback.md) |
| ✅ | 20 | `STD_MTS_020_op_mode_bits_readback` | stmt=88.88, branch=75.98, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.53 | [case](../cases/STD_MTS_020_op_mode_bits_readback.md) |
| ✅ | 21 | `STD_MTS_021_expected_latency_zero_write` | stmt=89.83, branch=76.77, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.84 | [case](../cases/STD_MTS_021_expected_latency_zero_write.md) |
| ✅ | 22 | `STD_MTS_022_expected_latency_small_write` | stmt=89.83, branch=76.77, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.95 | [case](../cases/STD_MTS_022_expected_latency_small_write.md) |
| ✅ | 23 | `STD_MTS_023_expected_latency_maxword_write` | stmt=89.83, branch=76.77, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_023_expected_latency_maxword_write.md) |
| ✅ | 24 | `STD_MTS_024_unsupported_write_addr1_inert` | stmt=89.83, branch=77.16, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_024_unsupported_write_addr1_inert.md) |
| ✅ | 25 | `STD_MTS_025_unsupported_write_addr3_inert` | stmt=89.83, branch=77.95, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_025_unsupported_write_addr3_inert.md) |
| ✅ | 26 | `STD_MTS_026_unsupported_write_addr4_inert` | stmt=89.83, branch=78.74, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_026_unsupported_write_addr4_inert.md) |
| ✅ | 27 | `STD_MTS_027_unsupported_read_addr5_zero` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_027_unsupported_read_addr5_zero.md) |
| ✅ | 28 | `STD_MTS_028_csr_waitrequest_ack` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.66 | [case](../cases/STD_MTS_028_csr_waitrequest_ack.md) |
| ✅ | 29 | `STD_MTS_029_csr_burst_of_serial_accesses` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.85 | [case](../cases/STD_MTS_029_csr_burst_of_serial_accesses.md) |
| ✅ | 30 | `STD_MTS_030_total_counter_counts_all_valid` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_030_total_counter_counts_all_valid.md) |
| ✅ | 31 | `STD_MTS_031_running_accepts_clean_hit` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_031_running_accepts_clean_hit.md) |
| ✅ | 32 | `STD_MTS_032_idle_rejects_clean_hit` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_032_idle_rejects_clean_hit.md) |
| ✅ | 33 | `STD_MTS_033_reset_sclr_flush_accept` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_033_reset_sclr_flush_accept.md) |
| ✅ | 34 | `STD_MTS_034_reset_sync_blocks_hit` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_034_reset_sync_blocks_hit.md) |
| ✅ | 35 | `STD_MTS_035_flushing_accepts_hit` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_035_flushing_accepts_hit.md) |
| ✅ | 36 | `STD_MTS_036_hiterr_discard_enabled` | stmt=90.01, branch=79.13, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=19.90 | [case](../cases/STD_MTS_036_hiterr_discard_enabled.md) |
| ✅ | 37 | `STD_MTS_037_hiterr_discard_disabled` | stmt=90.58, branch=79.92, cond=68.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=20.36 | [case](../cases/STD_MTS_037_hiterr_discard_disabled.md) |
| ✅ | 38 | `STD_MTS_038_force_stop_blocks_acceptance` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=20.36 | [case](../cases/STD_MTS_038_force_stop_blocks_acceptance.md) |
| ✅ | 39 | `STD_MTS_039_rejected_hiterr_still_counts_total` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=20.36 | [case](../cases/STD_MTS_039_rejected_hiterr_still_counts_total.md) |
| ✅ | 40 | `STD_MTS_040_matched_sideband_and_data_fields` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_040_matched_sideband_and_data_fields.md) |
| ✅ | 41 | `STD_MTS_041_legacy_running_plus_one_hit` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_041_legacy_running_plus_one_hit.md) |
| ✅ | 42 | `STD_MTS_042_standard_prepare_sync_run` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_042_standard_prepare_sync_run.md) |
| ✅ | 43 | `STD_MTS_043_run_prepare_without_sync` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_043_run_prepare_without_sync.md) |
| ✅ | 44 | `STD_MTS_044_repeated_sync_pulses` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_044_repeated_sync_pulses.md) |
| ✅ | 45 | `STD_MTS_045_terminating_without_eop_then_idle` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_045_terminating_without_eop_then_idle.md) |
| ✅ | 46 | `STD_MTS_046_running_abort_no_flush` | stmt=90.58, branch=79.92, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.73 | [case](../cases/STD_MTS_046_running_abort_no_flush.md) |
| ✅ | 47 | `STD_MTS_047_link_test_word_is_nonfunctional_today` | stmt=90.77, branch=80.70, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.81 | [case](../cases/STD_MTS_047_link_test_word_is_nonfunctional_today.md) |
| ✅ | 48 | `STD_MTS_048_sync_test_word_is_nonfunctional_today` | stmt=90.96, branch=81.49, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.89 | [case](../cases/STD_MTS_048_sync_test_word_is_nonfunctional_today.md) |
| ✅ | 49 | `STD_MTS_049_reset_word_is_nonfunctional_today` | stmt=91.14, branch=81.88, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.94 | [case](../cases/STD_MTS_049_reset_word_is_nonfunctional_today.md) |
| ✅ | 50 | `STD_MTS_050_out_of_daq_word_is_nonfunctional_today` | stmt=91.33, branch=82.28, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.99 | [case](../cases/STD_MTS_050_out_of_daq_word_is_nonfunctional_today.md) |
| ✅ | 51 | `STD_MTS_051_tcc_uses_rom_decode` | stmt=91.71, branch=82.67, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=31.93 | [case](../cases/STD_MTS_051_tcc_uses_rom_decode.md) |
| ✅ | 52 | `STD_MTS_052_ecc_uses_second_rom_port` | stmt=92.09, branch=83.85, cond=69.82, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=32.47 | [case](../cases/STD_MTS_052_ecc_uses_second_rom_port.md) |
| ✅ | 53 | `STD_MTS_053_bypass_off_uses_white_timestamp` | stmt=93.03, branch=85.43, cond=72.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=39.23 | [case](../cases/STD_MTS_053_bypass_off_uses_white_timestamp.md) |
| ✅ | 54 | `STD_MTS_054_bypass_on_uses_gray_timestamp` | stmt=93.03, branch=85.43, cond=72.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.06 | [case](../cases/STD_MTS_054_bypass_on_uses_gray_timestamp.md) |
| ✅ | 55 | `STD_MTS_055_expected_latency_updates_padding_upper` | stmt=93.40, branch=86.61, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=42.74 | [case](../cases/STD_MTS_055_expected_latency_updates_padding_upper.md) |
| ✅ | 56 | `STD_MTS_056_no_adjust_below_upper_bound` | stmt=93.40, branch=86.61, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.06 | [case](../cases/STD_MTS_056_no_adjust_below_upper_bound.md) |
| ✅ | 57 | `STD_MTS_057_t_path_adjust_above_upper_bound` | stmt=93.40, branch=86.61, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.06 | [case](../cases/STD_MTS_057_t_path_adjust_above_upper_bound.md) |
| ✅ | 58 | `STD_MTS_058_e_path_adjust_above_upper_bound` | stmt=93.59, branch=87.00, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.06 | [case](../cases/STD_MTS_058_e_path_adjust_above_upper_bound.md) |
| ✅ | 59 | `STD_MTS_059_divider_quotient_populates_tcc8n` | stmt=93.59, branch=87.00, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_059_divider_quotient_populates_tcc8n.md) |
| ✅ | 60 | `STD_MTS_060_divider_remainder_populates_tcc1n6` | stmt=93.59, branch=87.00, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_060_divider_remainder_populates_tcc1n6.md) |
| ✅ | 61 | `STD_MTS_061_short_mode_zeroes_et` | stmt=93.59, branch=87.00, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_061_short_mode_zeroes_et.md) |
| ✅ | 62 | `STD_MTS_062_tot_mode_masks_eflag0` | stmt=93.78, branch=87.40, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_062_tot_mode_masks_eflag0.md) |
| ✅ | 63 | `STD_MTS_063_tot_mode_positive_delta` | stmt=93.78, branch=87.40, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_063_tot_mode_positive_delta.md) |
| ✅ | 64 | `STD_MTS_064_tot_mode_negative_delta_reference` | stmt=93.78, branch=87.40, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.16 | [case](../cases/STD_MTS_064_tot_mode_negative_delta_reference.md) |
| ✅ | 65 | `STD_MTS_065_tot_mode_saturates_above_511` | stmt=93.97, branch=87.79, cond=74.13, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.36 | [case](../cases/STD_MTS_065_tot_mode_saturates_above_511.md) |
| ✅ | 66 | `STD_MTS_066_delay_field_t_path` | stmt=93.97, branch=87.79, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=47.62 | [case](../cases/STD_MTS_066_delay_field_t_path.md) |
| ✅ | 67 | `STD_MTS_067_delay_field_e_path` | stmt=94.72, branch=88.58, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.24 | [case](../cases/STD_MTS_067_delay_field_e_path.md) |
| ✅ | 68 | `STD_MTS_068_tfine_passthrough` | stmt=94.72, branch=88.58, cond=75.00, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.24 | [case](../cases/STD_MTS_068_tfine_passthrough.md) |
| ✅ | 69 | `STD_MTS_069_asic_passthrough` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_069_asic_passthrough.md) |
| ✅ | 70 | `STD_MTS_070_channel_passthrough` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_070_channel_passthrough.md) |
| ✅ | 71 | `STD_MTS_071_sop_first_hit_channel0` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_071_sop_first_hit_channel0.md) |
| ✅ | 72 | `STD_MTS_072_sop_first_hit_channel1` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_072_sop_first_hit_channel1.md) |
| ✅ | 73 | `STD_MTS_073_sop_first_hit_channel2` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_073_sop_first_hit_channel2.md) |
| ✅ | 74 | `STD_MTS_074_sop_first_hit_channel3` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=48.89 | [case](../cases/STD_MTS_074_sop_first_hit_channel3.md) |
| ✅ | 75 | `STD_MTS_075_no_repeated_sop_same_channel` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.01 | [case](../cases/STD_MTS_075_no_repeated_sop_same_channel.md) |
| ✅ | 76 | `STD_MTS_076_reset_clears_startofrun_sent` | stmt=94.72, branch=88.97, cond=75.86, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.12 | [case](../cases/STD_MTS_076_reset_clears_startofrun_sent.md) |
| ✅ | 77 | `STD_MTS_077_terminating_input_eop_forwards_output_eop` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.27 | [case](../cases/STD_MTS_077_terminating_input_eop_forwards_output_eop.md) |
| ✅ | 78 | `STD_MTS_078_nonterminating_eop_not_forwarded` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.27 | [case](../cases/STD_MTS_078_nonterminating_eop_not_forwarded.md) |
| ✅ | 79 | `STD_MTS_079_empty_stays_zero` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_079_empty_stays_zero.md) |
| ✅ | 80 | `STD_MTS_080_output_valid_only_in_run_or_flush` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_080_output_valid_only_in_run_or_flush.md) |
| ✅ | 81 | `STD_MTS_081_route_lane0` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_081_route_lane0.md) |
| ✅ | 82 | `STD_MTS_082_route_lane1` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_082_route_lane1.md) |
| ✅ | 83 | `STD_MTS_083_route_lane2` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_083_route_lane2.md) |
| ✅ | 84 | `STD_MTS_084_route_lane3` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_084_route_lane3.md) |
| ✅ | 85 | `STD_MTS_085_error_low_in_range` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.32 | [case](../cases/STD_MTS_085_error_low_in_range.md) |
| ✅ | 86 | `STD_MTS_086_error_high_at_zero` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.43 | [case](../cases/STD_MTS_086_error_high_at_zero.md) |
| ✅ | 87 | `STD_MTS_087_error_high_for_negative` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.43 | [case](../cases/STD_MTS_087_error_high_for_negative.md) |
| ✅ | 88 | `STD_MTS_088_error_high_at_or_above_limit` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.43 | [case](../cases/STD_MTS_088_error_high_at_or_above_limit.md) |
| ✅ | 89 | `STD_MTS_089_debug_ts_valid_alignment` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.43 | [case](../cases/STD_MTS_089_debug_ts_valid_alignment.md) |
| ✅ | 90 | `STD_MTS_090_delay_field_changes_error_source` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.56 | [case](../cases/STD_MTS_090_delay_field_changes_error_source.md) |
| ✅ | 91 | `STD_MTS_091_debug_burst_only_running` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.56 | [case](../cases/STD_MTS_091_debug_burst_only_running.md) |
| ✅ | 92 | `STD_MTS_092_ts_delta_only_running` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.56 | [case](../cases/STD_MTS_092_ts_delta_only_running.md) |
| ✅ | 93 | `STD_MTS_093_first_running_hit_warms_history` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.56 | [case](../cases/STD_MTS_093_first_running_hit_warms_history.md) |
| ✅ | 94 | `STD_MTS_094_positive_timestamp_delta` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.61 | [case](../cases/STD_MTS_094_positive_timestamp_delta.md) |
| ✅ | 95 | `STD_MTS_095_negative_timestamp_delta` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.66 | [case](../cases/STD_MTS_095_negative_timestamp_delta.md) |
| ✅ | 96 | `STD_MTS_096_zero_timestamp_delta` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.76 | [case](../cases/STD_MTS_096_zero_timestamp_delta.md) |
| ✅ | 97 | `STD_MTS_097_positive_signmag_conversion` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.81 | [case](../cases/STD_MTS_097_positive_signmag_conversion.md) |
| ✅ | 98 | `STD_MTS_098_negative_signmag_conversion` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.87 | [case](../cases/STD_MTS_098_negative_signmag_conversion.md) |
| ✅ | 99 | `STD_MTS_099_arrival_delta_uses_gts` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.92 | [case](../cases/STD_MTS_099_arrival_delta_uses_gts.md) |
| ✅ | 100 | `STD_MTS_100_debug_streams_clear_outside_running` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.92 | [case](../cases/STD_MTS_100_debug_streams_clear_outside_running.md) |
| ✅ | 101 | `STD_MTS_101_replay_smoke_positive_et` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.92 | [case](../cases/STD_MTS_101_replay_smoke_positive_et.md) |
| ✅ | 102 | `STD_MTS_102_replay_smoke_eflag_zero` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=49.92 | [case](../cases/STD_MTS_102_replay_smoke_eflag_zero.md) |
| ✅ | 103 | `STD_MTS_103_replay_smoke_clamp_vector` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.23 | [case](../cases/STD_MTS_103_replay_smoke_clamp_vector.md) |
| ✅ | 104 | `STD_MTS_104_discard_counter_matches_rejections` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.28 | [case](../cases/STD_MTS_104_discard_counter_matches_rejections.md) |
| ✅ | 105 | `STD_MTS_105_total_counter_matches_all_valid` | stmt=94.91, branch=89.76, cond=78.44, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.28 | [case](../cases/STD_MTS_105_total_counter_matches_all_valid.md) |
| ✅ | 106 | `STD_MTS_106_total_counter_hi_rollover` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_106_total_counter_hi_rollover.md) |
| ✅ | 107 | `STD_MTS_107_soft_reset_clears_counters` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_107_soft_reset_clears_counters.md) |
| ✅ | 108 | `STD_MTS_108_sync_clears_counters` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_108_sync_clears_counters.md) |
| ✅ | 109 | `STD_MTS_109_running_status_bit_semantics` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_109_running_status_bit_semantics.md) |
| ✅ | 110 | `STD_MTS_110_force_stop_persists_until_cleared` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_110_force_stop_persists_until_cleared.md) |
| ✅ | 111 | `STD_MTS_111_compile_rtl_default_div_pipeline` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_111_compile_rtl_default_div_pipeline.md) |
| ✅ | 112 | `STD_MTS_112_compile_packaged_div_pipeline` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.81 | [case](../cases/STD_MTS_112_compile_packaged_div_pipeline.md) |
| ✅ | 113 | `STD_MTS_113_single_enabled_channel_window` | stmt=95.32, branch=91.79, cond=80.17, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.89 | [case](../cases/STD_MTS_113_single_enabled_channel_window.md) |
| ✅ | 114 | `STD_MTS_114_upper_enabled_window` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.89 | [case](../cases/STD_MTS_114_upper_enabled_window.md) |
| ✅ | 115 | `STD_MTS_115_remapped_hiterr_bit` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.94 | [case](../cases/STD_MTS_115_remapped_hiterr_bit.md) |
| ✅ | 116 | `STD_MTS_116_remapped_crcerr_still_inert` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.94 | [case](../cases/STD_MTS_116_remapped_crcerr_still_inert.md) |
| ✅ | 117 | `STD_MTS_117_remapped_frame_corrupt_still_inert` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_117_remapped_frame_corrupt_still_inert.md) |
| ✅ | 118 | `STD_MTS_118_changed_latency_generic_at_power_on` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_118_changed_latency_generic_at_power_on.md) |
| ✅ | 119 | `STD_MTS_119_bank_string_is_debug_only` | stmt=95.32, branch=91.79, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_119_bank_string_is_debug_only.md) |
| ✅ | 120 | `STD_MTS_120_debug_zero_is_functionally_equivalent` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_120_debug_zero_is_functionally_equivalent.md) |
| ✅ | 121 | `STD_MTS_121_preterminate_hit_still_drains` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_121_preterminate_hit_still_drains.md) |
| ✅ | 122 | `STD_MTS_122_terminating_eop_and_hit_emit_final_boundary` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_122_terminating_eop_and_hit_emit_final_boundary.md) |
| ✅ | 123 | `STD_MTS_123_flushing_accepts_more_hits_today` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_123_flushing_accepts_more_hits_today.md) |
| ✅ | 124 | `STD_MTS_124_flushing_quiet_without_hits` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_124_flushing_quiet_without_hits.md) |
| ✅ | 125 | `STD_MTS_125_ctrl_ready_high_through_terminate` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_125_ctrl_ready_high_through_terminate.md) |
| ✅ | 126 | `STD_MTS_126_ctrl_ready_high_through_prepare_and_sync` | stmt=95.32, branch=91.82, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STD_MTS_126_ctrl_ready_high_through_prepare_and_sync.md) |
| ✅ | 127 | `STD_MTS_127_upgrade_case_stateful_ready_on_terminate` | stmt=95.70, branch=92.21, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=52.99 | [case](../cases/STD_MTS_127_upgrade_case_stateful_ready_on_terminate.md) |
| ✅ | 128 | `STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits` | stmt=95.70, branch=92.21, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=52.99 | [case](../cases/STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits.md) |
| ✅ | 129 | `STD_MTS_129_upgrade_case_idle_after_boundary_only` | stmt=95.70, branch=92.21, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=52.99 | [case](../cases/STD_MTS_129_upgrade_case_idle_after_boundary_only.md) |
| ✅ | 130 | `STD_MTS_130_full_standard_sequence_baseline` | stmt=95.70, branch=92.21, cond=81.03, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=53.02 | [case](../cases/STD_MTS_130_full_standard_sequence_baseline.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
