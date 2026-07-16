# ⚠️ PROF bucket

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
| ⚠️ | stmt | 93.70 | 95.0 |
| ⚠️ | branch | 82.46 | 90.0 |
| ℹ️ | cond | 79.03 | - |
| ℹ️ | expr | 83.33 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 66.66 | 90.0 |
| ⚠️ | toggle | 50.91 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `STRESS_MTS_001_line_rate_short_mode` | stmt=79.33, branch=62.33, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=23.71 | [case](../cases/STRESS_MTS_001_line_rate_short_mode.md) |
| ✅ | 2 | `STRESS_MTS_002_line_rate_tot_mode` | stmt=79.58, branch=63.31, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=24.63 | [case](../cases/STRESS_MTS_002_line_rate_tot_mode.md) |
| ✅ | 3 | `STRESS_MTS_003_every_other_cycle_stream` | stmt=79.58, branch=63.31, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=25.30 | [case](../cases/STRESS_MTS_003_every_other_cycle_stream.md) |
| ✅ | 4 | `STRESS_MTS_004_burst_of_eight_pattern` | stmt=79.58, branch=63.31, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=25.30 | [case](../cases/STRESS_MTS_004_burst_of_eight_pattern.md) |
| ✅ | 5 | `STRESS_MTS_005_clean_hiterr_free_soak` | stmt=80.10, branch=63.96, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=26.19 | [case](../cases/STRESS_MTS_005_clean_hiterr_free_soak.md) |
| ✅ | 6 | `STRESS_MTS_006_mixed_hiterr_soak_keep_disabled` | stmt=80.10, branch=63.96, cond=38.70, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=26.62 | [case](../cases/STRESS_MTS_006_mixed_hiterr_soak_keep_disabled.md) |
| ✅ | 7 | `STRESS_MTS_007_mixed_hiterr_soak_discard_enabled` | stmt=80.23, branch=64.61, cond=42.74, expr=83.33, fsm_state=75.00, fsm_trans=22.22, toggle=26.83 | [case](../cases/STRESS_MTS_007_mixed_hiterr_soak_discard_enabled.md) |
| ✅ | 8 | `STRESS_MTS_008_sustained_output_ready_high` | stmt=80.23, branch=64.61, cond=42.74, expr=83.33, fsm_state=75.00, fsm_trans=22.22, toggle=26.83 | [case](../cases/STRESS_MTS_008_sustained_output_ready_high.md) |
| ✅ | 9 | `STRESS_MTS_009_sustained_output_ready_low` | stmt=80.23, branch=64.61, cond=42.74, expr=83.33, fsm_state=75.00, fsm_trans=22.22, toggle=26.86 | [case](../cases/STRESS_MTS_009_sustained_output_ready_low.md) |
| ✅ | 10 | `STRESS_MTS_010_flushing_after_large_backlog` | stmt=83.18, branch=71.75, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=27.50 | [case](../cases/STRESS_MTS_010_flushing_after_large_backlog.md) |
| ✅ | 11 | `STRESS_MTS_011_long_run_short_mode` | stmt=83.18, branch=71.75, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=28.20 | [case](../cases/STRESS_MTS_011_long_run_short_mode.md) |
| ✅ | 12 | `STRESS_MTS_012_long_run_tot_mode` | stmt=83.18, branch=71.75, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=28.20 | [case](../cases/STRESS_MTS_012_long_run_tot_mode.md) |
| ✅ | 13 | `STRESS_MTS_013_toggle_derive_tot_every_256_hits` | stmt=83.18, branch=71.75, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=28.95 | [case](../cases/STRESS_MTS_013_toggle_derive_tot_every_256_hits.md) |
| ✅ | 14 | `STRESS_MTS_014_long_run_delay_field_t` | stmt=83.18, branch=71.75, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=28.95 | [case](../cases/STRESS_MTS_014_long_run_delay_field_t.md) |
| ✅ | 15 | `STRESS_MTS_015_long_run_delay_field_e` | stmt=83.56, branch=72.40, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=29.36 | [case](../cases/STRESS_MTS_015_long_run_delay_field_e.md) |
| ✅ | 16 | `STRESS_MTS_016_toggle_delay_field_every_256_hits` | stmt=83.56, branch=72.40, cond=58.06, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=29.52 | [case](../cases/STRESS_MTS_016_toggle_delay_field_every_256_hits.md) |
| ✅ | 17 | `STRESS_MTS_017_long_run_bypass_off` | stmt=84.59, branch=74.02, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=35.84 | [case](../cases/STRESS_MTS_017_long_run_bypass_off.md) |
| ✅ | 18 | `STRESS_MTS_018_long_run_bypass_on` | stmt=84.72, branch=74.35, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=36.21 | [case](../cases/STRESS_MTS_018_long_run_bypass_on.md) |
| ✅ | 19 | `STRESS_MTS_019_toggle_bypass_between_packets` | stmt=84.72, branch=74.35, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=36.52 | [case](../cases/STRESS_MTS_019_toggle_bypass_between_packets.md) |
| ✅ | 20 | `STRESS_MTS_020_rewrite_expected_latency_mid_run` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.02 | [case](../cases/STRESS_MTS_020_rewrite_expected_latency_mid_run.md) |
| ✅ | 21 | `STRESS_MTS_021_round_robin_enabled_channels` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.21 | [case](../cases/STRESS_MTS_021_round_robin_enabled_channels.md) |
| ✅ | 22 | `STRESS_MTS_022_hotspot_channel0` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.21 | [case](../cases/STRESS_MTS_022_hotspot_channel0.md) |
| ✅ | 23 | `STRESS_MTS_023_hotspot_channel3` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.25 | [case](../cases/STRESS_MTS_023_hotspot_channel3.md) |
| ✅ | 24 | `STRESS_MTS_024_dense_payload_channel_sweep` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.25 | [case](../cases/STRESS_MTS_024_dense_payload_channel_sweep.md) |
| ✅ | 25 | `STRESS_MTS_025_dense_asic_id_sweep` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.74 | [case](../cases/STRESS_MTS_025_dense_asic_id_sweep.md) |
| ✅ | 26 | `STRESS_MTS_026_single_beat_packet_stream` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.75 | [case](../cases/STRESS_MTS_026_single_beat_packet_stream.md) |
| ✅ | 27 | `STRESS_MTS_027_multi_beat_packet_stream` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.80 | [case](../cases/STRESS_MTS_027_multi_beat_packet_stream.md) |
| ✅ | 28 | `STRESS_MTS_028_periodic_hiterr_every_16th` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.80 | [case](../cases/STRESS_MTS_028_periodic_hiterr_every_16th.md) |
| ✅ | 29 | `STRESS_MTS_029_periodic_hiterr_keep_mode` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.80 | [case](../cases/STRESS_MTS_029_periodic_hiterr_keep_mode.md) |
| ✅ | 30 | `STRESS_MTS_030_nonzero_mux_bits_under_load` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=37.80 | [case](../cases/STRESS_MTS_030_nonzero_mux_bits_under_load.md) |
| ✅ | 31 | `STRESS_MTS_031_discard_counter_monotonic_1k` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=38.04 | [case](../cases/STRESS_MTS_031_discard_counter_monotonic_1k.md) |
| ✅ | 32 | `STRESS_MTS_032_total_counter_monotonic_1k` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=38.50 | [case](../cases/STRESS_MTS_032_total_counter_monotonic_1k.md) |
| ✅ | 33 | `STRESS_MTS_033_mixed_accept_reject_counter_soak` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=38.50 | [case](../cases/STRESS_MTS_033_mixed_accept_reject_counter_soak.md) |
| ✅ | 34 | `STRESS_MTS_034_hi_lo_snapshot_polling` | stmt=85.23, branch=74.67, cond=60.48, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=38.56 | [case](../cases/STRESS_MTS_034_hi_lo_snapshot_polling.md) |
| ✅ | 35 | `STRESS_MTS_035_soft_reset_every_10k_cycles` | stmt=89.73, branch=75.32, cond=70.16, expr=83.33, fsm_state=100.00, fsm_trans=33.33, toggle=39.51 | [case](../cases/STRESS_MTS_035_soft_reset_every_10k_cycles.md) |
| ✅ | 36 | `STRESS_MTS_036_global_reset_periodic_recovery` | stmt=89.73, branch=75.32, cond=70.16, expr=83.33, fsm_state=100.00, fsm_trans=44.44, toggle=39.56 | [case](../cases/STRESS_MTS_036_global_reset_periodic_recovery.md) |
| ✅ | 37 | `STRESS_MTS_037_standard_run_sequence_repeated_100x` | stmt=89.98, branch=75.97, cond=70.16, expr=83.33, fsm_state=100.00, fsm_trans=44.44, toggle=39.56 | [case](../cases/STRESS_MTS_037_standard_run_sequence_repeated_100x.md) |
| ✅ | 38 | `STRESS_MTS_038_direct_running_sequence_repeated_100x` | stmt=90.24, branch=76.29, cond=70.96, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=39.56 | [case](../cases/STRESS_MTS_038_direct_running_sequence_repeated_100x.md) |
| ✅ | 39 | `STRESS_MTS_039_force_stop_pulse_every_100_hits` | stmt=90.37, branch=76.62, cond=71.77, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=39.59 | [case](../cases/STRESS_MTS_039_force_stop_pulse_every_100_hits.md) |
| ✅ | 40 | `STRESS_MTS_040_csr_poll_every_32_cycles` | stmt=90.50, branch=76.94, cond=71.77, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=39.59 | [case](../cases/STRESS_MTS_040_csr_poll_every_32_cycles.md) |
| ✅ | 41 | `STRESS_MTS_041_single_overflow_run` | stmt=90.88, branch=77.92, cond=73.38, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=42.61 | [case](../cases/STRESS_MTS_041_single_overflow_run.md) |
| ✅ | 42 | `STRESS_MTS_042_many_overflow_run` | stmt=92.42, branch=79.22, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=45.88 | [case](../cases/STRESS_MTS_042_many_overflow_run.md) |
| ✅ | 43 | `STRESS_MTS_043_hits_just_below_upper_across_overflow` | stmt=92.42, branch=79.22, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=45.88 | [case](../cases/STRESS_MTS_043_hits_just_below_upper_across_overflow.md) |
| ✅ | 44 | `STRESS_MTS_044_hits_just_above_upper_across_overflow` | stmt=92.42, branch=79.22, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=45.88 | [case](../cases/STRESS_MTS_044_hits_just_above_upper_across_overflow.md) |
| ✅ | 45 | `STRESS_MTS_045_mixed_t_and_e_adjust_eligibility` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.34 | [case](../cases/STRESS_MTS_045_mixed_t_and_e_adjust_eligibility.md) |
| ✅ | 46 | `STRESS_MTS_046_bypass_off_overflow_soak` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.34 | [case](../cases/STRESS_MTS_046_bypass_off_overflow_soak.md) |
| ✅ | 47 | `STRESS_MTS_047_bypass_on_overflow_soak` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.34 | [case](../cases/STRESS_MTS_047_bypass_on_overflow_soak.md) |
| ✅ | 48 | `STRESS_MTS_048_small_expected_latency_overflow` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.34 | [case](../cases/STRESS_MTS_048_small_expected_latency_overflow.md) |
| ✅ | 49 | `STRESS_MTS_049_large_expected_latency_overflow` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.84 | [case](../cases/STRESS_MTS_049_large_expected_latency_overflow.md) |
| ✅ | 50 | `STRESS_MTS_050_dense_divider_launch_overflow` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.84 | [case](../cases/STRESS_MTS_050_dense_divider_launch_overflow.md) |
| ✅ | 51 | `STRESS_MTS_051_debug_ts_every_hit` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.84 | [case](../cases/STRESS_MTS_051_debug_ts_every_hit.md) |
| ✅ | 52 | `STRESS_MTS_052_debug_burst_after_warmup` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.84 | [case](../cases/STRESS_MTS_052_debug_burst_after_warmup.md) |
| ✅ | 53 | `STRESS_MTS_053_ts_delta_after_warmup` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.84 | [case](../cases/STRESS_MTS_053_ts_delta_after_warmup.md) |
| ✅ | 54 | `STRESS_MTS_054_alternating_increasing_decreasing_timestamps` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.86 | [case](../cases/STRESS_MTS_054_alternating_increasing_decreasing_timestamps.md) |
| ✅ | 55 | `STRESS_MTS_055_equal_timestamp_pairs` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=47.86 | [case](../cases/STRESS_MTS_055_equal_timestamp_pairs.md) |
| ✅ | 56 | `STRESS_MTS_056_error_pipeline_t_path_under_load` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_056_error_pipeline_t_path_under_load.md) |
| ✅ | 57 | `STRESS_MTS_057_error_pipeline_e_path_under_load` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_057_error_pipeline_e_path_under_load.md) |
| ✅ | 58 | `STRESS_MTS_058_expected_latency_at_distribution_edge` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_058_expected_latency_at_distribution_edge.md) |
| ✅ | 59 | `STRESS_MTS_059_debug_streams_through_flushing` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_059_debug_streams_through_flushing.md) |
| ✅ | 60 | `STRESS_MTS_060_debug_streams_clear_after_running` | stmt=92.68, branch=79.87, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_060_debug_streams_clear_after_running.md) |
| ✅ | 61 | `STRESS_MTS_061_hundred_empty_standard_runs` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.77 | [case](../cases/STRESS_MTS_061_hundred_empty_standard_runs.md) |
| ✅ | 62 | `STRESS_MTS_062_hundred_single_packet_runs` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.77 | [case](../cases/STRESS_MTS_062_hundred_single_packet_runs.md) |
| ✅ | 63 | `STRESS_MTS_063_hundred_multi_channel_runs` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.77 | [case](../cases/STRESS_MTS_063_hundred_multi_channel_runs.md) |
| ✅ | 64 | `STRESS_MTS_064_hundred_stop_cycles_ready_low` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.77 | [case](../cases/STRESS_MTS_064_hundred_stop_cycles_ready_low.md) |
| ✅ | 65 | `STRESS_MTS_065_hundred_running_abort_cycles` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.77 | [case](../cases/STRESS_MTS_065_hundred_running_abort_cycles.md) |
| ✅ | 66 | `STRESS_MTS_066_alternate_standard_and_legacy_starts` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.80 | [case](../cases/STRESS_MTS_066_alternate_standard_and_legacy_starts.md) |
| ✅ | 67 | `STRESS_MTS_067_idleness_only_csr_rewrites` | stmt=92.93, branch=80.19, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.95 | [case](../cases/STRESS_MTS_067_idleness_only_csr_rewrites.md) |
| ✅ | 68 | `STRESS_MTS_068_prepare_phase_csr_rewrites` | stmt=93.06, branch=80.51, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.95 | [case](../cases/STRESS_MTS_068_prepare_phase_csr_rewrites.md) |
| ✅ | 69 | `STRESS_MTS_069_flushing_phase_csr_rewrites` | stmt=93.06, branch=80.51, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=48.95 | [case](../cases/STRESS_MTS_069_flushing_phase_csr_rewrites.md) |
| ✅ | 70 | `STRESS_MTS_070_interspersed_illegal_ctrl_words` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_070_interspersed_illegal_ctrl_words.md) |
| ✅ | 71 | `STRESS_MTS_071_terminate_after_single_packet` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_071_terminate_after_single_packet.md) |
| ✅ | 72 | `STRESS_MTS_072_terminate_after_dense_burst` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_072_terminate_after_dense_burst.md) |
| ✅ | 73 | `STRESS_MTS_073_terminate_with_eop_on_last_beat` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_073_terminate_with_eop_on_last_beat.md) |
| ✅ | 74 | `STRESS_MTS_074_terminate_with_late_eop` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_074_terminate_with_late_eop.md) |
| ✅ | 75 | `STRESS_MTS_075_terminate_without_eop_then_idle` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_075_terminate_without_eop_then_idle.md) |
| ✅ | 76 | `STRESS_MTS_076_multiple_late_eops` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_076_multiple_late_eops.md) |
| ✅ | 77 | `STRESS_MTS_077_terminate_with_ready_low` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_077_terminate_with_ready_low.md) |
| ✅ | 78 | `STRESS_MTS_078_terminate_per_enabled_channel` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_078_terminate_per_enabled_channel.md) |
| ✅ | 79 | `STRESS_MTS_079_terminate_near_overflow_window` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_079_terminate_near_overflow_window.md) |
| ✅ | 80 | `STRESS_MTS_080_terminate_during_heavy_csr_polling` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_080_terminate_during_heavy_csr_polling.md) |
| ✅ | 81 | `STRESS_MTS_081_div_pipeline_two_under_load` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_081_div_pipeline_two_under_load.md) |
| ✅ | 82 | `STRESS_MTS_082_div_pipeline_four_under_load` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_082_div_pipeline_four_under_load.md) |
| ✅ | 83 | `STRESS_MTS_083_single_enabled_channel_soak` | stmt=93.19, branch=81.49, cond=76.61, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.02 | [case](../cases/STRESS_MTS_083_single_enabled_channel_soak.md) |
| ✅ | 84 | `STRESS_MTS_084_two_enabled_channels_soak` | stmt=93.19, branch=81.81, cond=78.22, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.05 | [case](../cases/STRESS_MTS_084_two_enabled_channels_soak.md) |
| ✅ | 85 | `STRESS_MTS_085_four_enabled_channels_soak` | stmt=93.19, branch=81.81, cond=78.22, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.05 | [case](../cases/STRESS_MTS_085_four_enabled_channels_soak.md) |
| ✅ | 86 | `STRESS_MTS_086_remapped_hiterr_soak` | stmt=93.19, branch=81.81, cond=78.22, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.08 | [case](../cases/STRESS_MTS_086_remapped_hiterr_soak.md) |
| ✅ | 87 | `STRESS_MTS_087_custom_default_latency_soak` | stmt=93.19, branch=81.81, cond=78.22, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.08 | [case](../cases/STRESS_MTS_087_custom_default_latency_soak.md) |
| ✅ | 88 | `STRESS_MTS_088_debug_zero_soak` | stmt=93.19, branch=81.81, cond=78.22, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=49.08 | [case](../cases/STRESS_MTS_088_debug_zero_soak.md) |
| ✅ | 89 | `STRESS_MTS_089_bank_up_vs_down_compare` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.57 | [case](../cases/STRESS_MTS_089_bank_up_vs_down_compare.md) |
| ✅ | 90 | `STRESS_MTS_090_inert_parameter_sweep_compare` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.60 | [case](../cases/STRESS_MTS_090_inert_parameter_sweep_compare.md) |
| ✅ | 91 | `STRESS_MTS_091_random_marker_mix` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.60 | [case](../cases/STRESS_MTS_091_random_marker_mix.md) |
| ✅ | 92 | `STRESS_MTS_092_random_accept_reject_mix` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.62 | [case](../cases/STRESS_MTS_092_random_accept_reject_mix.md) |
| ✅ | 93 | `STRESS_MTS_093_random_delay_path_mix` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_093_random_delay_path_mix.md) |
| ✅ | 94 | `STRESS_MTS_094_random_tot_mode_mix` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_094_random_tot_mode_mix.md) |
| ✅ | 95 | `STRESS_MTS_095_random_force_stop_pulses` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_095_random_force_stop_pulses.md) |
| ✅ | 96 | `STRESS_MTS_096_random_soft_reset_pulses` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_096_random_soft_reset_pulses.md) |
| ✅ | 97 | `STRESS_MTS_097_random_control_chatter` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_097_random_control_chatter.md) |
| ✅ | 98 | `STRESS_MTS_098_random_asic_ids` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_098_random_asic_ids.md) |
| ✅ | 99 | `STRESS_MTS_099_random_payload_channels` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.63 | [case](../cases/STRESS_MTS_099_random_payload_channels.md) |
| ✅ | 100 | `STRESS_MTS_100_random_expected_latency_rewrites` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.71 | [case](../cases/STRESS_MTS_100_random_expected_latency_rewrites.md) |
| ✅ | 101 | `STRESS_MTS_101_repeat_smoke_positive_vector_1k` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.71 | [case](../cases/STRESS_MTS_101_repeat_smoke_positive_vector_1k.md) |
| ✅ | 102 | `STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.71 | [case](../cases/STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k.md) |
| ✅ | 103 | `STRESS_MTS_103_repeat_smoke_clamp_vector_1k` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_103_repeat_smoke_clamp_vector_1k.md) |
| ✅ | 104 | `STRESS_MTS_104_smoke_vectors_under_standard_sequence` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_104_smoke_vectors_under_standard_sequence.md) |
| ✅ | 105 | `STRESS_MTS_105_smoke_vectors_with_ready_low` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_105_smoke_vectors_with_ready_low.md) |
| ✅ | 106 | `STRESS_MTS_106_smoke_vectors_div_pipeline_two` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_106_smoke_vectors_div_pipeline_two.md) |
| ✅ | 107 | `STRESS_MTS_107_smoke_vectors_div_pipeline_four` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_107_smoke_vectors_div_pipeline_four.md) |
| ✅ | 108 | `STRESS_MTS_108_smoke_vectors_bypass_on` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_108_smoke_vectors_bypass_on.md) |
| ✅ | 109 | `STRESS_MTS_109_smoke_vectors_delay_field_e` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_109_smoke_vectors_delay_field_e.md) |
| ✅ | 110 | `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs.md) |
| ✅ | 111 | `STRESS_MTS_111_ready_high_baseline_log` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_111_ready_high_baseline_log.md) |
| ✅ | 112 | `STRESS_MTS_112_ready_low_baseline_log` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_112_ready_low_baseline_log.md) |
| ✅ | 113 | `STRESS_MTS_113_ready_toggle_1010` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_113_ready_toggle_1010.md) |
| ✅ | 114 | `STRESS_MTS_114_ready_low_on_sop_beats` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_114_ready_low_on_sop_beats.md) |
| ✅ | 115 | `STRESS_MTS_115_ready_low_on_eop_beats` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_115_ready_low_on_eop_beats.md) |
| ✅ | 116 | `STRESS_MTS_116_ready_low_during_dense_burst` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_116_ready_low_during_dense_burst.md) |
| ✅ | 117 | `STRESS_MTS_117_ready_low_in_flushing` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_117_ready_low_in_flushing.md) |
| ✅ | 118 | `STRESS_MTS_118_random_ready_toggle` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_118_random_ready_toggle.md) |
| ✅ | 119 | `STRESS_MTS_119_ready_low_across_resets` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_119_ready_low_across_resets.md) |
| ✅ | 120 | `STRESS_MTS_120_sink_pattern_equivalence_summary` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_120_sink_pattern_equivalence_summary.md) |
| ✅ | 121 | `STRESS_MTS_121_future_ready_occupancy_histogram` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_121_future_ready_occupancy_histogram.md) |
| ✅ | 122 | `STRESS_MTS_122_drain_latency_histogram` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_122_drain_latency_histogram.md) |
| ✅ | 123 | `STRESS_MTS_123_drain_latency_by_div_pipeline` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_123_drain_latency_by_div_pipeline.md) |
| ✅ | 124 | `STRESS_MTS_124_drain_latency_by_enabled_window` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_124_drain_latency_by_enabled_window.md) |
| ✅ | 125 | `STRESS_MTS_125_boundary_forwarding_rate` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_125_boundary_forwarding_rate.md) |
| ✅ | 126 | `STRESS_MTS_126_missing_boundary_rate_post_upgrade` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_126_missing_boundary_rate_post_upgrade.md) |
| ✅ | 127 | `STRESS_MTS_127_extra_boundary_rate_post_upgrade` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_127_extra_boundary_rate_post_upgrade.md) |
| ✅ | 128 | `STRESS_MTS_128_ready_statefulness_cost` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_128_ready_statefulness_cost.md) |
| ✅ | 129 | `STRESS_MTS_129_synthetic_boundary_no_real_eop` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_129_synthetic_boundary_no_real_eop.md) |
| ✅ | 130 | `STRESS_MTS_130_full_signoff_mixed_soak` | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | [case](../cases/STRESS_MTS_130_full_signoff_mixed_soak.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
