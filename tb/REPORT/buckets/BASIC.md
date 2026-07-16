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
| ⚠️ | stmt | 93.23 | 95.0 |
| ⚠️ | branch | 85.80 | 90.0 |
| ℹ️ | cond | 80.64 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 77.77 | 90.0 |
| ⚠️ | toggle | 44.66 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `STD_MTS_001_powerup_reset_idle` | stmt=51.86, branch=29.54, cond=3.22, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.57 | [case](../cases/STD_MTS_001_powerup_reset_idle.md) |
| ✅ | 2 | `STD_MTS_002_reset_release_idle_quiet` | stmt=52.37, branch=30.84, cond=3.22, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.80 | [case](../cases/STD_MTS_002_reset_release_idle_quiet.md) |
| ✅ | 3 | `STD_MTS_003_direct_running_entry_allowed` | stmt=75.86, branch=53.24, cond=26.61, expr=83.33, fsm_state=50.00, fsm_trans=11.11, toggle=7.76 | [case](../cases/STD_MTS_003_direct_running_entry_allowed.md) |
| ✅ | 4 | `STD_MTS_004_run_prepare_enters_reset_sclr` | stmt=76.63, branch=56.49, cond=29.03, expr=83.33, fsm_state=75.00, fsm_trans=22.22, toggle=7.87 | [case](../cases/STD_MTS_004_run_prepare_enters_reset_sclr.md) |
| ✅ | 5 | `STD_MTS_005_sync_enters_reset_sync` | stmt=78.43, branch=60.38, cond=36.29, expr=83.33, fsm_state=75.00, fsm_trans=22.22, toggle=8.22 | [case](../cases/STD_MTS_005_sync_enters_reset_sync.md) |
| ✅ | 6 | `STD_MTS_006_running_from_sync` | stmt=79.71, branch=62.33, cond=37.90, expr=83.33, fsm_state=75.00, fsm_trans=33.33, toggle=8.91 | [case](../cases/STD_MTS_006_running_from_sync.md) |
| ✅ | 7 | `STD_MTS_007_terminating_enters_flushing` | stmt=80.35, branch=65.25, cond=41.12, expr=83.33, fsm_state=100.00, fsm_trans=44.44, toggle=9.11 | [case](../cases/STD_MTS_007_terminating_enters_flushing.md) |
| ✅ | 8 | `STD_MTS_008_idle_from_flushing` | stmt=82.92, branch=69.48, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=9.99 | [case](../cases/STD_MTS_008_idle_from_flushing.md) |
| ✅ | 9 | `STD_MTS_009_running_abort_to_idle` | stmt=83.05, branch=69.80, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=9.99 | [case](../cases/STD_MTS_009_running_abort_to_idle.md) |
| ✅ | 10 | `STD_MTS_010_global_reset_during_flushing` | stmt=83.05, branch=69.80, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.14 | [case](../cases/STD_MTS_010_global_reset_during_flushing.md) |
| ✅ | 11 | `STD_MTS_011_control_readback_after_reset` | stmt=83.05, branch=69.80, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.14 | [case](../cases/STD_MTS_011_control_readback_after_reset.md) |
| ✅ | 12 | `STD_MTS_012_discard_counter_default_zero` | stmt=83.05, branch=69.80, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.14 | [case](../cases/STD_MTS_012_discard_counter_default_zero.md) |
| ✅ | 13 | `STD_MTS_013_expected_latency_default_2000` | stmt=83.18, branch=70.12, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.22 | [case](../cases/STD_MTS_013_expected_latency_default_2000.md) |
| ✅ | 14 | `STD_MTS_014_total_counter_hi_default_zero` | stmt=83.18, branch=70.12, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.22 | [case](../cases/STD_MTS_014_total_counter_hi_default_zero.md) |
| ✅ | 15 | `STD_MTS_015_total_counter_lo_default_zero` | stmt=83.18, branch=70.12, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.22 | [case](../cases/STD_MTS_015_total_counter_lo_default_zero.md) |
| ✅ | 16 | `STD_MTS_016_force_stop_readback` | stmt=83.31, branch=70.45, cond=50.80, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.31 | [case](../cases/STD_MTS_016_force_stop_readback.md) |
| ✅ | 17 | `STD_MTS_017_soft_reset_self_clear` | stmt=87.80, branch=71.10, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.37 | [case](../cases/STD_MTS_017_soft_reset_self_clear.md) |
| ✅ | 18 | `STD_MTS_018_bypass_lapse_readback` | stmt=87.80, branch=71.10, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=10.46 | [case](../cases/STD_MTS_018_bypass_lapse_readback.md) |
| ✅ | 19 | `STD_MTS_019_discard_hiterr_readback` | stmt=87.93, branch=71.75, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=13.01 | [case](../cases/STD_MTS_019_discard_hiterr_readback.md) |
| ✅ | 20 | `STD_MTS_020_op_mode_bits_readback` | stmt=87.93, branch=71.75, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=13.24 | [case](../cases/STD_MTS_020_op_mode_bits_readback.md) |
| ✅ | 21 | `STD_MTS_021_expected_latency_zero_write` | stmt=88.57, branch=72.40, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=13.42 | [case](../cases/STD_MTS_021_expected_latency_zero_write.md) |
| ✅ | 22 | `STD_MTS_022_expected_latency_small_write` | stmt=88.57, branch=72.40, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=13.48 | [case](../cases/STD_MTS_022_expected_latency_small_write.md) |
| ✅ | 23 | `STD_MTS_023_expected_latency_maxword_write` | stmt=88.57, branch=72.40, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_023_expected_latency_maxword_write.md) |
| ✅ | 24 | `STD_MTS_024_unsupported_write_addr1_inert` | stmt=88.57, branch=72.72, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_024_unsupported_write_addr1_inert.md) |
| ✅ | 25 | `STD_MTS_025_unsupported_write_addr3_inert` | stmt=88.57, branch=73.37, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_025_unsupported_write_addr3_inert.md) |
| ✅ | 26 | `STD_MTS_026_unsupported_write_addr4_inert` | stmt=88.57, branch=74.02, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_026_unsupported_write_addr4_inert.md) |
| ✅ | 27 | `STD_MTS_027_unsupported_read_addr5_zero` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_027_unsupported_read_addr5_zero.md) |
| ✅ | 28 | `STD_MTS_028_csr_waitrequest_ack` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.62 | [case](../cases/STD_MTS_028_csr_waitrequest_ack.md) |
| ✅ | 29 | `STD_MTS_029_csr_burst_of_serial_accesses` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.73 | [case](../cases/STD_MTS_029_csr_burst_of_serial_accesses.md) |
| ✅ | 30 | `STD_MTS_030_total_counter_counts_all_valid` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_030_total_counter_counts_all_valid.md) |
| ✅ | 31 | `STD_MTS_031_running_accepts_clean_hit` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_031_running_accepts_clean_hit.md) |
| ✅ | 32 | `STD_MTS_032_idle_rejects_clean_hit` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_032_idle_rejects_clean_hit.md) |
| ✅ | 33 | `STD_MTS_033_reset_sclr_flush_accept` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_033_reset_sclr_flush_accept.md) |
| ✅ | 34 | `STD_MTS_034_reset_sync_blocks_hit` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_034_reset_sync_blocks_hit.md) |
| ✅ | 35 | `STD_MTS_035_flushing_accepts_hit` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_035_flushing_accepts_hit.md) |
| ✅ | 36 | `STD_MTS_036_hiterr_discard_enabled` | stmt=88.70, branch=74.35, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=15.79 | [case](../cases/STD_MTS_036_hiterr_discard_enabled.md) |
| ✅ | 37 | `STD_MTS_037_hiterr_discard_disabled` | stmt=89.08, branch=75.00, cond=63.70, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=16.06 | [case](../cases/STD_MTS_037_hiterr_discard_disabled.md) |
| ✅ | 38 | `STD_MTS_038_force_stop_blocks_acceptance` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=16.06 | [case](../cases/STD_MTS_038_force_stop_blocks_acceptance.md) |
| ✅ | 39 | `STD_MTS_039_rejected_hiterr_still_counts_total` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=16.06 | [case](../cases/STD_MTS_039_rejected_hiterr_still_counts_total.md) |
| ✅ | 40 | `STD_MTS_040_matched_sideband_and_data_fields` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_040_matched_sideband_and_data_fields.md) |
| ✅ | 41 | `STD_MTS_041_legacy_running_plus_one_hit` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_041_legacy_running_plus_one_hit.md) |
| ✅ | 42 | `STD_MTS_042_standard_prepare_sync_run` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_042_standard_prepare_sync_run.md) |
| ✅ | 43 | `STD_MTS_043_run_prepare_without_sync` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_043_run_prepare_without_sync.md) |
| ✅ | 44 | `STD_MTS_044_repeated_sync_pulses` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_044_repeated_sync_pulses.md) |
| ✅ | 45 | `STD_MTS_045_terminating_without_eop_then_idle` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_045_terminating_without_eop_then_idle.md) |
| ✅ | 46 | `STD_MTS_046_running_abort_no_flush` | stmt=89.08, branch=75.00, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.68 | [case](../cases/STD_MTS_046_running_abort_no_flush.md) |
| ✅ | 47 | `STD_MTS_047_link_test_word_is_nonfunctional_today` | stmt=89.21, branch=75.64, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.73 | [case](../cases/STD_MTS_047_link_test_word_is_nonfunctional_today.md) |
| ✅ | 48 | `STD_MTS_048_sync_test_word_is_nonfunctional_today` | stmt=89.34, branch=76.29, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.78 | [case](../cases/STD_MTS_048_sync_test_word_is_nonfunctional_today.md) |
| ✅ | 49 | `STD_MTS_049_reset_word_is_nonfunctional_today` | stmt=89.47, branch=76.62, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.81 | [case](../cases/STD_MTS_049_reset_word_is_nonfunctional_today.md) |
| ✅ | 50 | `STD_MTS_050_out_of_daq_word_is_nonfunctional_today` | stmt=89.60, branch=76.94, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=18.84 | [case](../cases/STD_MTS_050_out_of_daq_word_is_nonfunctional_today.md) |
| ✅ | 51 | `STD_MTS_051_tcc_uses_rom_decode` | stmt=89.98, branch=77.27, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=20.31 | [case](../cases/STD_MTS_051_tcc_uses_rom_decode.md) |
| ✅ | 52 | `STD_MTS_052_ecc_uses_second_rom_port` | stmt=90.24, branch=78.24, cond=64.51, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=20.91 | [case](../cases/STD_MTS_052_ecc_uses_second_rom_port.md) |
| ✅ | 53 | `STD_MTS_053_bypass_off_uses_white_timestamp` | stmt=90.88, branch=79.54, cond=66.93, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=29.85 | [case](../cases/STD_MTS_053_bypass_off_uses_white_timestamp.md) |
| ✅ | 54 | `STD_MTS_054_bypass_on_uses_gray_timestamp` | stmt=90.88, branch=79.54, cond=66.93, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=30.46 | [case](../cases/STD_MTS_054_bypass_on_uses_gray_timestamp.md) |
| ✅ | 55 | `STD_MTS_055_expected_latency_updates_padding_upper` | stmt=91.14, branch=80.51, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=34.08 | [case](../cases/STD_MTS_055_expected_latency_updates_padding_upper.md) |
| ✅ | 56 | `STD_MTS_056_no_adjust_below_upper_bound` | stmt=91.14, branch=80.51, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=35.96 | [case](../cases/STD_MTS_056_no_adjust_below_upper_bound.md) |
| ✅ | 57 | `STD_MTS_057_t_path_adjust_above_upper_bound` | stmt=91.14, branch=80.51, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=35.96 | [case](../cases/STD_MTS_057_t_path_adjust_above_upper_bound.md) |
| ✅ | 58 | `STD_MTS_058_e_path_adjust_above_upper_bound` | stmt=91.27, branch=80.84, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.63 | [case](../cases/STD_MTS_058_e_path_adjust_above_upper_bound.md) |
| ✅ | 59 | `STD_MTS_059_divider_quotient_populates_tcc8n` | stmt=91.27, branch=80.84, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_059_divider_quotient_populates_tcc8n.md) |
| ✅ | 60 | `STD_MTS_060_divider_remainder_populates_tcc1n6` | stmt=91.27, branch=80.84, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_060_divider_remainder_populates_tcc1n6.md) |
| ✅ | 61 | `STD_MTS_061_short_mode_zeroes_et` | stmt=91.27, branch=80.84, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_061_short_mode_zeroes_et.md) |
| ✅ | 62 | `STD_MTS_062_tot_mode_masks_eflag0` | stmt=91.39, branch=81.16, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_062_tot_mode_masks_eflag0.md) |
| ✅ | 63 | `STD_MTS_063_tot_mode_positive_delta` | stmt=91.39, branch=81.16, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_063_tot_mode_positive_delta.md) |
| ✅ | 64 | `STD_MTS_064_tot_mode_negative_delta_reference` | stmt=91.39, branch=81.16, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=36.69 | [case](../cases/STD_MTS_064_tot_mode_negative_delta_reference.md) |
| ✅ | 65 | `STD_MTS_065_tot_mode_saturates_above_511` | stmt=91.52, branch=81.49, cond=70.16, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=38.69 | [case](../cases/STD_MTS_065_tot_mode_saturates_above_511.md) |
| ✅ | 66 | `STD_MTS_066_delay_field_t_path` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=39.04 | [case](../cases/STD_MTS_066_delay_field_t_path.md) |
| ✅ | 67 | `STD_MTS_067_delay_field_e_path` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=39.77 | [case](../cases/STD_MTS_067_delay_field_e_path.md) |
| ✅ | 68 | `STD_MTS_068_tfine_passthrough` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=39.77 | [case](../cases/STD_MTS_068_tfine_passthrough.md) |
| ✅ | 69 | `STD_MTS_069_asic_passthrough` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.00 | [case](../cases/STD_MTS_069_asic_passthrough.md) |
| ✅ | 70 | `STD_MTS_070_channel_passthrough` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.00 | [case](../cases/STD_MTS_070_channel_passthrough.md) |
| ✅ | 71 | `STD_MTS_071_sop_first_hit_channel0` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.00 | [case](../cases/STD_MTS_071_sop_first_hit_channel0.md) |
| ✅ | 72 | `STD_MTS_072_sop_first_hit_channel1` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.09 | [case](../cases/STD_MTS_072_sop_first_hit_channel1.md) |
| ✅ | 73 | `STD_MTS_073_sop_first_hit_channel2` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.21 | [case](../cases/STD_MTS_073_sop_first_hit_channel2.md) |
| ✅ | 74 | `STD_MTS_074_sop_first_hit_channel3` | stmt=91.52, branch=81.49, cond=70.96, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.21 | [case](../cases/STD_MTS_074_sop_first_hit_channel3.md) |
| ✅ | 75 | `STD_MTS_075_no_repeated_sop_same_channel` | stmt=91.52, branch=81.49, cond=71.77, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.33 | [case](../cases/STD_MTS_075_no_repeated_sop_same_channel.md) |
| ✅ | 76 | `STD_MTS_076_reset_clears_startofrun_sent` | stmt=91.52, branch=81.49, cond=71.77, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=40.42 | [case](../cases/STD_MTS_076_reset_clears_startofrun_sent.md) |
| ✅ | 77 | `STD_MTS_077_terminating_input_eop_forwards_output_eop` | stmt=91.65, branch=82.14, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.11 | [case](../cases/STD_MTS_077_terminating_input_eop_forwards_output_eop.md) |
| ✅ | 78 | `STD_MTS_078_nonterminating_eop_not_forwarded` | stmt=91.65, branch=82.14, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.11 | [case](../cases/STD_MTS_078_nonterminating_eop_not_forwarded.md) |
| ✅ | 79 | `STD_MTS_079_empty_stays_zero` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.30 | [case](../cases/STD_MTS_079_empty_stays_zero.md) |
| ✅ | 80 | `STD_MTS_080_output_valid_only_in_run_or_flush` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_080_output_valid_only_in_run_or_flush.md) |
| ✅ | 81 | `STD_MTS_081_route_lane0` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_081_route_lane0.md) |
| ✅ | 82 | `STD_MTS_082_route_lane1` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_082_route_lane1.md) |
| ✅ | 83 | `STD_MTS_083_route_lane2` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_083_route_lane2.md) |
| ✅ | 84 | `STD_MTS_084_route_lane3` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_084_route_lane3.md) |
| ✅ | 85 | `STD_MTS_085_error_low_in_range` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_085_error_low_in_range.md) |
| ✅ | 86 | `STD_MTS_086_error_high_at_zero` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_086_error_high_at_zero.md) |
| ✅ | 87 | `STD_MTS_087_error_high_for_negative` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_087_error_high_for_negative.md) |
| ✅ | 88 | `STD_MTS_088_error_high_at_or_above_limit` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_088_error_high_at_or_above_limit.md) |
| ✅ | 89 | `STD_MTS_089_debug_ts_valid_alignment` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.33 | [case](../cases/STD_MTS_089_debug_ts_valid_alignment.md) |
| ✅ | 90 | `STD_MTS_090_delay_field_changes_error_source` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.45 | [case](../cases/STD_MTS_090_delay_field_changes_error_source.md) |
| ✅ | 91 | `STD_MTS_091_debug_burst_only_running` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.45 | [case](../cases/STD_MTS_091_debug_burst_only_running.md) |
| ✅ | 92 | `STD_MTS_092_ts_delta_only_running` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.45 | [case](../cases/STD_MTS_092_ts_delta_only_running.md) |
| ✅ | 93 | `STD_MTS_093_first_running_hit_warms_history` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.45 | [case](../cases/STD_MTS_093_first_running_hit_warms_history.md) |
| ✅ | 94 | `STD_MTS_094_positive_timestamp_delta` | stmt=92.04, branch=82.46, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.47 | [case](../cases/STD_MTS_094_positive_timestamp_delta.md) |
| ✅ | 95 | `STD_MTS_095_negative_timestamp_delta` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.61 | [case](../cases/STD_MTS_095_negative_timestamp_delta.md) |
| ✅ | 96 | `STD_MTS_096_zero_timestamp_delta` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.64 | [case](../cases/STD_MTS_096_zero_timestamp_delta.md) |
| ✅ | 97 | `STD_MTS_097_positive_signmag_conversion` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.67 | [case](../cases/STD_MTS_097_positive_signmag_conversion.md) |
| ✅ | 98 | `STD_MTS_098_negative_signmag_conversion` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.71 | [case](../cases/STD_MTS_098_negative_signmag_conversion.md) |
| ✅ | 99 | `STD_MTS_099_arrival_delta_uses_gts` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.73 | [case](../cases/STD_MTS_099_arrival_delta_uses_gts.md) |
| ✅ | 100 | `STD_MTS_100_debug_streams_clear_outside_running` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.73 | [case](../cases/STD_MTS_100_debug_streams_clear_outside_running.md) |
| ✅ | 101 | `STD_MTS_101_replay_smoke_positive_et` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.73 | [case](../cases/STD_MTS_101_replay_smoke_positive_et.md) |
| ✅ | 102 | `STD_MTS_102_replay_smoke_eflag_zero` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.73 | [case](../cases/STD_MTS_102_replay_smoke_eflag_zero.md) |
| ✅ | 103 | `STD_MTS_103_replay_smoke_clamp_vector` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.91 | [case](../cases/STD_MTS_103_replay_smoke_clamp_vector.md) |
| ✅ | 104 | `STD_MTS_104_discard_counter_matches_rejections` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.94 | [case](../cases/STD_MTS_104_discard_counter_matches_rejections.md) |
| ✅ | 105 | `STD_MTS_105_total_counter_matches_all_valid` | stmt=92.16, branch=82.79, cond=74.19, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=41.94 | [case](../cases/STD_MTS_105_total_counter_matches_all_valid.md) |
| ✅ | 106 | `STD_MTS_106_total_counter_hi_rollover` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_106_total_counter_hi_rollover.md) |
| ✅ | 107 | `STD_MTS_107_soft_reset_clears_counters` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_107_soft_reset_clears_counters.md) |
| ✅ | 108 | `STD_MTS_108_sync_clears_counters` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_108_sync_clears_counters.md) |
| ✅ | 109 | `STD_MTS_109_running_status_bit_semantics` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_109_running_status_bit_semantics.md) |
| ✅ | 110 | `STD_MTS_110_force_stop_persists_until_cleared` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_110_force_stop_persists_until_cleared.md) |
| ✅ | 111 | `STD_MTS_111_compile_rtl_default_div_pipeline` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_111_compile_rtl_default_div_pipeline.md) |
| ✅ | 112 | `STD_MTS_112_compile_packaged_div_pipeline` | stmt=92.46, branch=84.51, cond=75.80, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.43 | [case](../cases/STD_MTS_112_compile_packaged_div_pipeline.md) |
| ✅ | 113 | `STD_MTS_113_single_enabled_channel_window` | stmt=92.46, branch=84.83, cond=79.03, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.52 | [case](../cases/STD_MTS_113_single_enabled_channel_window.md) |
| ✅ | 114 | `STD_MTS_114_upper_enabled_window` | stmt=92.46, branch=84.83, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.58 | [case](../cases/STD_MTS_114_upper_enabled_window.md) |
| ✅ | 115 | `STD_MTS_115_remapped_hiterr_bit` | stmt=92.46, branch=84.83, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.61 | [case](../cases/STD_MTS_115_remapped_hiterr_bit.md) |
| ✅ | 116 | `STD_MTS_116_remapped_crcerr_still_inert` | stmt=92.46, branch=84.83, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.61 | [case](../cases/STD_MTS_116_remapped_crcerr_still_inert.md) |
| ✅ | 117 | `STD_MTS_117_remapped_frame_corrupt_still_inert` | stmt=92.46, branch=84.83, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.64 | [case](../cases/STD_MTS_117_remapped_frame_corrupt_still_inert.md) |
| ✅ | 118 | `STD_MTS_118_changed_latency_generic_at_power_on` | stmt=92.46, branch=84.83, cond=79.83, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=43.64 | [case](../cases/STD_MTS_118_changed_latency_generic_at_power_on.md) |
| ✅ | 119 | `STD_MTS_119_bank_string_is_debug_only` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_119_bank_string_is_debug_only.md) |
| ✅ | 120 | `STD_MTS_120_debug_zero_is_functionally_equivalent` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_120_debug_zero_is_functionally_equivalent.md) |
| ✅ | 121 | `STD_MTS_121_preterminate_hit_still_drains` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_121_preterminate_hit_still_drains.md) |
| ✅ | 122 | `STD_MTS_122_terminating_eop_and_hit_emit_final_boundary` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_122_terminating_eop_and_hit_emit_final_boundary.md) |
| ✅ | 123 | `STD_MTS_123_flushing_accepts_more_hits_today` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_123_flushing_accepts_more_hits_today.md) |
| ✅ | 124 | `STD_MTS_124_flushing_quiet_without_hits` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_124_flushing_quiet_without_hits.md) |
| ✅ | 125 | `STD_MTS_125_ctrl_ready_high_through_terminate` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_125_ctrl_ready_high_through_terminate.md) |
| ✅ | 126 | `STD_MTS_126_ctrl_ready_high_through_prepare_and_sync` | stmt=92.97, branch=85.48, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=44.58 | [case](../cases/STD_MTS_126_ctrl_ready_high_through_prepare_and_sync.md) |
| ✅ | 127 | `STD_MTS_127_upgrade_case_stateful_ready_on_terminate` | stmt=93.23, branch=85.80, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=44.58 | [case](../cases/STD_MTS_127_upgrade_case_stateful_ready_on_terminate.md) |
| ✅ | 128 | `STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits` | stmt=93.23, branch=85.80, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=44.58 | [case](../cases/STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits.md) |
| ✅ | 129 | `STD_MTS_129_upgrade_case_idle_after_boundary_only` | stmt=93.23, branch=85.80, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=44.58 | [case](../cases/STD_MTS_129_upgrade_case_idle_after_boundary_only.md) |
| ✅ | 130 | `STD_MTS_130_full_standard_sequence_baseline` | stmt=93.23, branch=85.80, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=44.66 | [case](../cases/STD_MTS_130_full_standard_sequence_baseline.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
