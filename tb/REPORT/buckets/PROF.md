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
| ✅ | stmt | 95.29 | 95.0 |
| ⚠️ | branch | 87.45 | 90.0 |
| ℹ️ | cond | 79.31 | - |
| ℹ️ | expr | 50.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 66.66 | 90.0 |
| ⚠️ | toggle | 53.45 | 80.0 |

## Ordered merge trace

<!-- each row is the merged coverage total after that case was added to the bucket in case-id order. -->

| status | step | case_id | merged_total (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) | detail |
|:---:|---:|---|---|---|
| ✅ | 1 | `STRESS_MTS_001_line_rate_short_mode` | stmt=79.84, branch=64.56, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=27.10 | [case](../cases/STRESS_MTS_001_line_rate_short_mode.md) |
| ✅ | 2 | `STRESS_MTS_002_line_rate_tot_mode` | stmt=80.22, branch=65.74, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=28.52 | [case](../cases/STRESS_MTS_002_line_rate_tot_mode.md) |
| ✅ | 3 | `STRESS_MTS_003_every_other_cycle_stream` | stmt=80.22, branch=65.74, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=29.03 | [case](../cases/STRESS_MTS_003_every_other_cycle_stream.md) |
| ✅ | 4 | `STRESS_MTS_004_burst_of_eight_pattern` | stmt=80.22, branch=65.74, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=29.03 | [case](../cases/STRESS_MTS_004_burst_of_eight_pattern.md) |
| ✅ | 5 | `STRESS_MTS_005_clean_hiterr_free_soak` | stmt=80.97, branch=66.53, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=30.14 | [case](../cases/STRESS_MTS_005_clean_hiterr_free_soak.md) |
| ✅ | 6 | `STRESS_MTS_006_mixed_hiterr_soak_keep_disabled` | stmt=80.97, branch=66.53, cond=38.79, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=30.82 | [case](../cases/STRESS_MTS_006_mixed_hiterr_soak_keep_disabled.md) |
| ✅ | 7 | `STRESS_MTS_007_mixed_hiterr_soak_discard_enabled` | stmt=81.16, branch=67.32, cond=42.24, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=31.18 | [case](../cases/STRESS_MTS_007_mixed_hiterr_soak_discard_enabled.md) |
| ✅ | 8 | `STRESS_MTS_008_sustained_output_ready_high` | stmt=81.16, branch=67.32, cond=42.24, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=31.18 | [case](../cases/STRESS_MTS_008_sustained_output_ready_high.md) |
| ✅ | 9 | `STRESS_MTS_009_sustained_output_ready_low` | stmt=81.16, branch=67.32, cond=42.24, expr=50.00, fsm_state=75.00, fsm_trans=22.22, toggle=31.23 | [case](../cases/STRESS_MTS_009_sustained_output_ready_low.md) |
| ✅ | 10 | `STRESS_MTS_010_flushing_after_large_backlog` | stmt=85.49, branch=75.98, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=32.05 | [case](../cases/STRESS_MTS_010_flushing_after_large_backlog.md) |
| ✅ | 11 | `STRESS_MTS_011_long_run_short_mode` | stmt=85.49, branch=75.98, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=32.36 | [case](../cases/STRESS_MTS_011_long_run_short_mode.md) |
| ✅ | 12 | `STRESS_MTS_012_long_run_tot_mode` | stmt=85.49, branch=75.98, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=32.36 | [case](../cases/STRESS_MTS_012_long_run_tot_mode.md) |
| ✅ | 13 | `STRESS_MTS_013_toggle_derive_tot_every_256_hits` | stmt=85.49, branch=75.98, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=32.78 | [case](../cases/STRESS_MTS_013_toggle_derive_tot_every_256_hits.md) |
| ✅ | 14 | `STRESS_MTS_014_long_run_delay_field_t` | stmt=85.49, branch=75.98, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=32.78 | [case](../cases/STRESS_MTS_014_long_run_delay_field_t.md) |
| ✅ | 15 | `STRESS_MTS_015_long_run_delay_field_e` | stmt=86.06, branch=76.77, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=33.47 | [case](../cases/STRESS_MTS_015_long_run_delay_field_e.md) |
| ✅ | 16 | `STRESS_MTS_016_toggle_delay_field_every_256_hits` | stmt=86.06, branch=76.77, cond=58.62, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=33.63 | [case](../cases/STRESS_MTS_016_toggle_delay_field_every_256_hits.md) |
| ✅ | 17 | `STRESS_MTS_017_long_run_bypass_off` | stmt=87.38, branch=78.74, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=39.08 | [case](../cases/STRESS_MTS_017_long_run_bypass_off.md) |
| ✅ | 18 | `STRESS_MTS_018_long_run_bypass_on` | stmt=87.57, branch=79.13, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=39.49 | [case](../cases/STRESS_MTS_018_long_run_bypass_on.md) |
| ✅ | 19 | `STRESS_MTS_019_toggle_bypass_between_packets` | stmt=87.57, branch=79.13, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=39.67 | [case](../cases/STRESS_MTS_019_toggle_bypass_between_packets.md) |
| ✅ | 20 | `STRESS_MTS_020_rewrite_expected_latency_mid_run` | stmt=88.32, branch=79.52, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=40.52 | [case](../cases/STRESS_MTS_020_rewrite_expected_latency_mid_run.md) |
| ✅ | 21 | `STRESS_MTS_021_round_robin_enabled_channels` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=41.01 | [case](../cases/STRESS_MTS_021_round_robin_enabled_channels.md) |
| ✅ | 22 | `STRESS_MTS_022_hotspot_channel0` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=41.01 | [case](../cases/STRESS_MTS_022_hotspot_channel0.md) |
| ✅ | 23 | `STRESS_MTS_023_hotspot_channel3` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=41.01 | [case](../cases/STRESS_MTS_023_hotspot_channel3.md) |
| ✅ | 24 | `STRESS_MTS_024_dense_payload_channel_sweep` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=41.01 | [case](../cases/STRESS_MTS_024_dense_payload_channel_sweep.md) |
| ✅ | 25 | `STRESS_MTS_025_dense_asic_id_sweep` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.25 | [case](../cases/STRESS_MTS_025_dense_asic_id_sweep.md) |
| ✅ | 26 | `STRESS_MTS_026_single_beat_packet_stream` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.25 | [case](../cases/STRESS_MTS_026_single_beat_packet_stream.md) |
| ✅ | 27 | `STRESS_MTS_027_multi_beat_packet_stream` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.33 | [case](../cases/STRESS_MTS_027_multi_beat_packet_stream.md) |
| ✅ | 28 | `STRESS_MTS_028_periodic_hiterr_every_16th` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.33 | [case](../cases/STRESS_MTS_028_periodic_hiterr_every_16th.md) |
| ✅ | 29 | `STRESS_MTS_029_periodic_hiterr_keep_mode` | stmt=88.51, branch=79.92, cond=61.20, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.33 | [case](../cases/STRESS_MTS_029_periodic_hiterr_keep_mode.md) |
| ✅ | 30 | `STRESS_MTS_030_nonzero_mux_bits_under_load` | stmt=88.51, branch=80.31, cond=62.06, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.38 | [case](../cases/STRESS_MTS_030_nonzero_mux_bits_under_load.md) |
| ✅ | 31 | `STRESS_MTS_031_discard_counter_monotonic_1k` | stmt=88.51, branch=80.31, cond=62.06, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.79 | [case](../cases/STRESS_MTS_031_discard_counter_monotonic_1k.md) |
| ✅ | 32 | `STRESS_MTS_032_total_counter_monotonic_1k` | stmt=88.51, branch=80.31, cond=62.06, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.79 | [case](../cases/STRESS_MTS_032_total_counter_monotonic_1k.md) |
| ✅ | 33 | `STRESS_MTS_033_mixed_accept_reject_counter_soak` | stmt=88.51, branch=80.31, cond=62.06, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.79 | [case](../cases/STRESS_MTS_033_mixed_accept_reject_counter_soak.md) |
| ✅ | 34 | `STRESS_MTS_034_hi_lo_snapshot_polling` | stmt=88.51, branch=80.31, cond=62.06, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=42.90 | [case](../cases/STRESS_MTS_034_hi_lo_snapshot_polling.md) |
| ✅ | 35 | `STRESS_MTS_035_soft_reset_every_10k_cycles` | stmt=91.52, branch=81.10, cond=73.27, expr=50.00, fsm_state=100.00, fsm_trans=33.33, toggle=44.08 | [case](../cases/STRESS_MTS_035_soft_reset_every_10k_cycles.md) |
| ✅ | 36 | `STRESS_MTS_036_global_reset_periodic_recovery` | stmt=91.52, branch=81.10, cond=73.27, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=44.14 | [case](../cases/STRESS_MTS_036_global_reset_periodic_recovery.md) |
| ✅ | 37 | `STRESS_MTS_037_standard_run_sequence_repeated_100x` | stmt=91.90, branch=81.88, cond=73.27, expr=50.00, fsm_state=100.00, fsm_trans=44.44, toggle=44.14 | [case](../cases/STRESS_MTS_037_standard_run_sequence_repeated_100x.md) |
| ✅ | 38 | `STRESS_MTS_038_direct_running_sequence_repeated_100x` | stmt=92.27, branch=82.28, cond=74.13, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=44.14 | [case](../cases/STRESS_MTS_038_direct_running_sequence_repeated_100x.md) |
| ✅ | 39 | `STRESS_MTS_039_force_stop_pulse_every_100_hits` | stmt=92.46, branch=82.67, cond=75.00, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=44.19 | [case](../cases/STRESS_MTS_039_force_stop_pulse_every_100_hits.md) |
| ✅ | 40 | `STRESS_MTS_040_csr_poll_every_32_cycles` | stmt=92.65, branch=83.07, cond=75.00, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=44.19 | [case](../cases/STRESS_MTS_040_csr_poll_every_32_cycles.md) |
| ✅ | 41 | `STRESS_MTS_041_single_overflow_run` | stmt=93.03, branch=83.85, cond=76.72, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=46.74 | [case](../cases/STRESS_MTS_041_single_overflow_run.md) |
| ✅ | 42 | `STRESS_MTS_042_many_overflow_run` | stmt=94.16, branch=84.64, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=48.52 | [case](../cases/STRESS_MTS_042_many_overflow_run.md) |
| ✅ | 43 | `STRESS_MTS_043_hits_just_below_upper_across_overflow` | stmt=94.16, branch=84.64, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=48.63 | [case](../cases/STRESS_MTS_043_hits_just_below_upper_across_overflow.md) |
| ✅ | 44 | `STRESS_MTS_044_hits_just_above_upper_across_overflow` | stmt=94.16, branch=84.64, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=48.63 | [case](../cases/STRESS_MTS_044_hits_just_above_upper_across_overflow.md) |
| ✅ | 45 | `STRESS_MTS_045_mixed_t_and_e_adjust_eligibility` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=50.80 | [case](../cases/STRESS_MTS_045_mixed_t_and_e_adjust_eligibility.md) |
| ✅ | 46 | `STRESS_MTS_046_bypass_off_overflow_soak` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=50.80 | [case](../cases/STRESS_MTS_046_bypass_off_overflow_soak.md) |
| ✅ | 47 | `STRESS_MTS_047_bypass_on_overflow_soak` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=50.80 | [case](../cases/STRESS_MTS_047_bypass_on_overflow_soak.md) |
| ✅ | 48 | `STRESS_MTS_048_small_expected_latency_overflow` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=50.80 | [case](../cases/STRESS_MTS_048_small_expected_latency_overflow.md) |
| ✅ | 49 | `STRESS_MTS_049_large_expected_latency_overflow` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_049_large_expected_latency_overflow.md) |
| ✅ | 50 | `STRESS_MTS_050_dense_divider_launch_overflow` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_050_dense_divider_launch_overflow.md) |
| ✅ | 51 | `STRESS_MTS_051_debug_ts_every_hit` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_051_debug_ts_every_hit.md) |
| ✅ | 52 | `STRESS_MTS_052_debug_burst_after_warmup` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_052_debug_burst_after_warmup.md) |
| ✅ | 53 | `STRESS_MTS_053_ts_delta_after_warmup` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_053_ts_delta_after_warmup.md) |
| ✅ | 54 | `STRESS_MTS_054_alternating_increasing_decreasing_timestamps` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_054_alternating_increasing_decreasing_timestamps.md) |
| ✅ | 55 | `STRESS_MTS_055_equal_timestamp_pairs` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.65 | [case](../cases/STRESS_MTS_055_equal_timestamp_pairs.md) |
| ✅ | 56 | `STRESS_MTS_056_error_pipeline_t_path_under_load` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=51.98 | [case](../cases/STRESS_MTS_056_error_pipeline_t_path_under_load.md) |
| ✅ | 57 | `STRESS_MTS_057_error_pipeline_e_path_under_load` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=52.24 | [case](../cases/STRESS_MTS_057_error_pipeline_e_path_under_load.md) |
| ✅ | 58 | `STRESS_MTS_058_expected_latency_at_distribution_edge` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=52.24 | [case](../cases/STRESS_MTS_058_expected_latency_at_distribution_edge.md) |
| ✅ | 59 | `STRESS_MTS_059_debug_streams_through_flushing` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=52.24 | [case](../cases/STRESS_MTS_059_debug_streams_through_flushing.md) |
| ✅ | 60 | `STRESS_MTS_060_debug_streams_clear_after_running` | stmt=94.53, branch=85.43, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=55.55, toggle=52.24 | [case](../cases/STRESS_MTS_060_debug_streams_clear_after_running.md) |
| ✅ | 61 | `STRESS_MTS_061_hundred_empty_standard_runs` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.50 | [case](../cases/STRESS_MTS_061_hundred_empty_standard_runs.md) |
| ✅ | 62 | `STRESS_MTS_062_hundred_single_packet_runs` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.50 | [case](../cases/STRESS_MTS_062_hundred_single_packet_runs.md) |
| ✅ | 63 | `STRESS_MTS_063_hundred_multi_channel_runs` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.50 | [case](../cases/STRESS_MTS_063_hundred_multi_channel_runs.md) |
| ✅ | 64 | `STRESS_MTS_064_hundred_stop_cycles_ready_low` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.50 | [case](../cases/STRESS_MTS_064_hundred_stop_cycles_ready_low.md) |
| ✅ | 65 | `STRESS_MTS_065_hundred_running_abort_cycles` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.50 | [case](../cases/STRESS_MTS_065_hundred_running_abort_cycles.md) |
| ✅ | 66 | `STRESS_MTS_066_alternate_standard_and_legacy_starts` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.52 | [case](../cases/STRESS_MTS_066_alternate_standard_and_legacy_starts.md) |
| ✅ | 67 | `STRESS_MTS_067_idleness_only_csr_rewrites` | stmt=94.91, branch=85.82, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.78 | [case](../cases/STRESS_MTS_067_idleness_only_csr_rewrites.md) |
| ✅ | 68 | `STRESS_MTS_068_prepare_phase_csr_rewrites` | stmt=95.10, branch=86.22, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.78 | [case](../cases/STRESS_MTS_068_prepare_phase_csr_rewrites.md) |
| ✅ | 69 | `STRESS_MTS_069_flushing_phase_csr_rewrites` | stmt=95.10, branch=86.22, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.78 | [case](../cases/STRESS_MTS_069_flushing_phase_csr_rewrites.md) |
| ✅ | 70 | `STRESS_MTS_070_interspersed_illegal_ctrl_words` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_070_interspersed_illegal_ctrl_words.md) |
| ✅ | 71 | `STRESS_MTS_071_terminate_after_single_packet` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_071_terminate_after_single_packet.md) |
| ✅ | 72 | `STRESS_MTS_072_terminate_after_dense_burst` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_072_terminate_after_dense_burst.md) |
| ✅ | 73 | `STRESS_MTS_073_terminate_with_eop_on_last_beat` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_073_terminate_with_eop_on_last_beat.md) |
| ✅ | 74 | `STRESS_MTS_074_terminate_with_late_eop` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_074_terminate_with_late_eop.md) |
| ✅ | 75 | `STRESS_MTS_075_terminate_without_eop_then_idle` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_075_terminate_without_eop_then_idle.md) |
| ✅ | 76 | `STRESS_MTS_076_multiple_late_eops` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_076_multiple_late_eops.md) |
| ✅ | 77 | `STRESS_MTS_077_terminate_with_ready_low` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_077_terminate_with_ready_low.md) |
| ✅ | 78 | `STRESS_MTS_078_terminate_per_enabled_channel` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_078_terminate_per_enabled_channel.md) |
| ✅ | 79 | `STRESS_MTS_079_terminate_near_overflow_window` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_079_terminate_near_overflow_window.md) |
| ✅ | 80 | `STRESS_MTS_080_terminate_during_heavy_csr_polling` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_080_terminate_during_heavy_csr_polling.md) |
| ✅ | 81 | `STRESS_MTS_081_div_pipeline_two_under_load` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_081_div_pipeline_two_under_load.md) |
| ✅ | 82 | `STRESS_MTS_082_div_pipeline_four_under_load` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_082_div_pipeline_four_under_load.md) |
| ✅ | 83 | `STRESS_MTS_083_single_enabled_channel_soak` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_083_single_enabled_channel_soak.md) |
| ✅ | 84 | `STRESS_MTS_084_two_enabled_channels_soak` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_084_two_enabled_channels_soak.md) |
| ✅ | 85 | `STRESS_MTS_085_four_enabled_channels_soak` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.86 | [case](../cases/STRESS_MTS_085_four_enabled_channels_soak.md) |
| ✅ | 86 | `STRESS_MTS_086_remapped_hiterr_soak` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.91 | [case](../cases/STRESS_MTS_086_remapped_hiterr_soak.md) |
| ✅ | 87 | `STRESS_MTS_087_custom_default_latency_soak` | stmt=95.29, branch=87.40, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.91 | [case](../cases/STRESS_MTS_087_custom_default_latency_soak.md) |
| ✅ | 88 | `STRESS_MTS_088_debug_zero_soak` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.91 | [case](../cases/STRESS_MTS_088_debug_zero_soak.md) |
| ✅ | 89 | `STRESS_MTS_089_bank_up_vs_down_compare` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.91 | [case](../cases/STRESS_MTS_089_bank_up_vs_down_compare.md) |
| ✅ | 90 | `STRESS_MTS_090_inert_parameter_sweep_compare` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.96 | [case](../cases/STRESS_MTS_090_inert_parameter_sweep_compare.md) |
| ✅ | 91 | `STRESS_MTS_091_random_marker_mix` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.96 | [case](../cases/STRESS_MTS_091_random_marker_mix.md) |
| ✅ | 92 | `STRESS_MTS_092_random_accept_reject_mix` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=52.99 | [case](../cases/STRESS_MTS_092_random_accept_reject_mix.md) |
| ✅ | 93 | `STRESS_MTS_093_random_delay_path_mix` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.04 | [case](../cases/STRESS_MTS_093_random_delay_path_mix.md) |
| ✅ | 94 | `STRESS_MTS_094_random_tot_mode_mix` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.04 | [case](../cases/STRESS_MTS_094_random_tot_mode_mix.md) |
| ✅ | 95 | `STRESS_MTS_095_random_force_stop_pulses` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.04 | [case](../cases/STRESS_MTS_095_random_force_stop_pulses.md) |
| ✅ | 96 | `STRESS_MTS_096_random_soft_reset_pulses` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.04 | [case](../cases/STRESS_MTS_096_random_soft_reset_pulses.md) |
| ✅ | 97 | `STRESS_MTS_097_random_control_chatter` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.07 | [case](../cases/STRESS_MTS_097_random_control_chatter.md) |
| ✅ | 98 | `STRESS_MTS_098_random_asic_ids` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.07 | [case](../cases/STRESS_MTS_098_random_asic_ids.md) |
| ✅ | 99 | `STRESS_MTS_099_random_payload_channels` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.07 | [case](../cases/STRESS_MTS_099_random_payload_channels.md) |
| ✅ | 100 | `STRESS_MTS_100_random_expected_latency_rewrites` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.20 | [case](../cases/STRESS_MTS_100_random_expected_latency_rewrites.md) |
| ✅ | 101 | `STRESS_MTS_101_repeat_smoke_positive_vector_1k` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.20 | [case](../cases/STRESS_MTS_101_repeat_smoke_positive_vector_1k.md) |
| ✅ | 102 | `STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k` | stmt=95.29, branch=87.45, cond=78.44, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.20 | [case](../cases/STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k.md) |
| ✅ | 103 | `STRESS_MTS_103_repeat_smoke_clamp_vector_1k` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_103_repeat_smoke_clamp_vector_1k.md) |
| ✅ | 104 | `STRESS_MTS_104_smoke_vectors_under_standard_sequence` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_104_smoke_vectors_under_standard_sequence.md) |
| ✅ | 105 | `STRESS_MTS_105_smoke_vectors_with_ready_low` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_105_smoke_vectors_with_ready_low.md) |
| ✅ | 106 | `STRESS_MTS_106_smoke_vectors_div_pipeline_two` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_106_smoke_vectors_div_pipeline_two.md) |
| ✅ | 107 | `STRESS_MTS_107_smoke_vectors_div_pipeline_four` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_107_smoke_vectors_div_pipeline_four.md) |
| ✅ | 108 | `STRESS_MTS_108_smoke_vectors_bypass_on` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_108_smoke_vectors_bypass_on.md) |
| ✅ | 109 | `STRESS_MTS_109_smoke_vectors_delay_field_e` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_109_smoke_vectors_delay_field_e.md) |
| ✅ | 110 | `STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs.md) |
| ✅ | 111 | `STRESS_MTS_111_ready_high_baseline_log` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_111_ready_high_baseline_log.md) |
| ✅ | 112 | `STRESS_MTS_112_ready_low_baseline_log` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_112_ready_low_baseline_log.md) |
| ✅ | 113 | `STRESS_MTS_113_ready_toggle_1010` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_113_ready_toggle_1010.md) |
| ✅ | 114 | `STRESS_MTS_114_ready_low_on_sop_beats` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_114_ready_low_on_sop_beats.md) |
| ✅ | 115 | `STRESS_MTS_115_ready_low_on_eop_beats` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_115_ready_low_on_eop_beats.md) |
| ✅ | 116 | `STRESS_MTS_116_ready_low_during_dense_burst` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_116_ready_low_during_dense_burst.md) |
| ✅ | 117 | `STRESS_MTS_117_ready_low_in_flushing` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_117_ready_low_in_flushing.md) |
| ✅ | 118 | `STRESS_MTS_118_random_ready_toggle` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_118_random_ready_toggle.md) |
| ✅ | 119 | `STRESS_MTS_119_ready_low_across_resets` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_119_ready_low_across_resets.md) |
| ✅ | 120 | `STRESS_MTS_120_sink_pattern_equivalence_summary` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_120_sink_pattern_equivalence_summary.md) |
| ✅ | 121 | `STRESS_MTS_121_future_ready_occupancy_histogram` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_121_future_ready_occupancy_histogram.md) |
| ✅ | 122 | `STRESS_MTS_122_drain_latency_histogram` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_122_drain_latency_histogram.md) |
| ✅ | 123 | `STRESS_MTS_123_drain_latency_by_div_pipeline` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_123_drain_latency_by_div_pipeline.md) |
| ✅ | 124 | `STRESS_MTS_124_drain_latency_by_enabled_window` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_124_drain_latency_by_enabled_window.md) |
| ✅ | 125 | `STRESS_MTS_125_boundary_forwarding_rate` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_125_boundary_forwarding_rate.md) |
| ✅ | 126 | `STRESS_MTS_126_missing_boundary_rate_post_upgrade` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_126_missing_boundary_rate_post_upgrade.md) |
| ✅ | 127 | `STRESS_MTS_127_extra_boundary_rate_post_upgrade` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_127_extra_boundary_rate_post_upgrade.md) |
| ✅ | 128 | `STRESS_MTS_128_ready_statefulness_cost` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_128_ready_statefulness_cost.md) |
| ✅ | 129 | `STRESS_MTS_129_synthetic_boundary_no_real_eop` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_129_synthetic_boundary_no_real_eop.md) |
| ✅ | 130 | `STRESS_MTS_130_full_signoff_mixed_soak` | stmt=95.29, branch=87.45, cond=79.31, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.45 | [case](../cases/STRESS_MTS_130_full_signoff_mixed_soak.md) |

---
_Back to [dashboard](../../DV_REPORT.md)_
