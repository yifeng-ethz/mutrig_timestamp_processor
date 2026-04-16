# DV Performance And Soak Cases — mutrig_timestamp_processor

**Purpose:** stress, throughput, and soak cases for `mts_processor`  
**Naming convention:** `STRESS_MTS_###_description`  
**Count target:** 130 substantive cases

## 1. Sustained Throughput

- `P001 | STRESS_MTS_001_line_rate_short_mode`: Run in `RUNNING` with `derive_tot=0` and drive one accepted hit every cycle; verify no stage metadata corruption and full output observability. Establishes the line-rate short-mode baseline.
- `P002 | STRESS_MTS_002_line_rate_tot_mode`: Repeat at one hit per cycle with `derive_tot=1`; verify ET derivation keeps up without losing payload fidelity. Establishes the line-rate ToT-mode baseline.
- `P003 | STRESS_MTS_003_every_other_cycle_stream`: Drive a hit every other cycle for a long run; verify counters, markers, and debug streams remain coherent. Covers a lightly gapped sustained load.
- `P004 | STRESS_MTS_004_burst_of_eight_pattern`: Drive eight consecutive hits followed by a short bubble, repeating for a long run; verify no stage-0 overwrite or stale history. Covers periodic microbursts.
- `P005 | STRESS_MTS_005_clean_hiterr_free_soak`: Run a long soak with only clean hits and discard enabled; expect discard count to remain zero. Provides a clean-stress baseline.
- `P006 | STRESS_MTS_006_mixed_hiterr_soak_keep_disabled`: Run a long soak with periodic hiterr beats and `discard_hiterr=0`; expect full throughput with correct error-bit accounting. Covers stress with accepted errored traffic.
- `P007 | STRESS_MTS_007_mixed_hiterr_soak_discard_enabled`: Repeat with `discard_hiterr=1`; expect the accepted/discarded split to remain exact under load. Covers the rejection path at scale.
- `P008 | STRESS_MTS_008_sustained_output_ready_high`: Hold output `ready=1` throughout a long run; archive the reference throughput trace. Establishes the clean sink baseline.
- `P009 | STRESS_MTS_009_sustained_output_ready_low`: Hold output `ready=0` throughout a long run; verify the emitted transaction log matches the `ready=1` baseline because the current RTL ignores backpressure. Documents a critical current-contract fact.
- `P010 | STRESS_MTS_010_flushing_after_large_backlog`: Drive a dense run, then enter `FLUSHING`; verify the pipeline drains deterministically without hanging. Establishes the basic drain-stress story.

## 2. Long-Run Mode Stress

- `P011 | STRESS_MTS_011_long_run_short_mode`: Hold `derive_tot=0` for a long run and verify ET remains zero throughout. Covers the simplest stable mode.
- `P012 | STRESS_MTS_012_long_run_tot_mode`: Hold `derive_tot=1` for a long run with mixed positive and clamped ET outcomes. Covers sustained long-mode behavior.
- `P013 | STRESS_MTS_013_toggle_derive_tot_every_256_hits`: Toggle `derive_tot` every 256 accepted hits; verify each interval behaves with its programmed mode and no stale ET leakage crosses boundaries. Covers slow mode thrashing.
- `P014 | STRESS_MTS_014_long_run_delay_field_t`: Hold `delay_ts_field_use_t=1` for a long run; verify debug and error signals use the T path consistently. Covers sustained default timing selection.
- `P015 | STRESS_MTS_015_long_run_delay_field_e`: Hold `delay_ts_field_use_t=0` for a long run; verify debug and error signals use the E path consistently. Covers sustained alternate timing selection.
- `P016 | STRESS_MTS_016_toggle_delay_field_every_256_hits`: Toggle the delay-field selection periodically; verify debug and error observables follow without stale bleed-through. Covers slow timing-source thrashing.
- `P017 | STRESS_MTS_017_long_run_bypass_off`: Hold `bypass_lapse=0` for a long run; verify the white-timestamp model stays coherent across many accepted hits. Covers the normal padded path at scale.
- `P018 | STRESS_MTS_018_long_run_bypass_on`: Hold `bypass_lapse=1` for a long run; verify the gray-timestamp bypass path stays coherent across many accepted hits. Covers the debug path at scale.
- `P019 | STRESS_MTS_019_toggle_bypass_between_packets`: Toggle `bypass_lapse` between packet boundaries during a long run; verify per-packet coherency. Covers deliberate pacing between modes.
- `P020 | STRESS_MTS_020_rewrite_expected_latency_mid_run`: Rewrite `expected_latency` at regular intervals during a long run; verify the error classifier tracks the current setting. Covers dynamic window tuning under load.

## 3. High-Variance Input Patterns

- `P021 | STRESS_MTS_021_round_robin_enabled_channels`: Cycle traffic across enabled channels 0 through 3 for a long run; verify SOP bookkeeping, counters, and output routing remain coherent. Covers balanced multi-channel load.
- `P022 | STRESS_MTS_022_hotspot_channel0`: Drive a long run entirely on payload channel 0; verify SOP occurs once and no channel-local state leaks. Covers hot-spot behavior at the low end.
- `P023 | STRESS_MTS_023_hotspot_channel3`: Drive a long run entirely on payload channel 3; verify identical stability at the upper default enabled channel. Covers hot-spot behavior at the high end.
- `P024 | STRESS_MTS_024_dense_payload_channel_sweep`: Sweep payload channel values 0..31 repeatedly under load while sideband ASIC stays legal; verify payload packing remains correct. Covers wide channel-field variation.
- `P025 | STRESS_MTS_025_dense_asic_id_sweep`: Sweep ASIC IDs 0..15 under load while payload channels are held fixed; verify output ASIC packing and sideband packet tracking coexist. Covers wide sideband variation.
- `P026 | STRESS_MTS_026_single_beat_packet_stream`: Drive a long stream of SOP+EOP single-beat packets; verify packet bookkeeping stays balanced. Covers the smallest packet form at scale.
- `P027 | STRESS_MTS_027_multi_beat_packet_stream`: Drive longer packet sequences with SOP at the start and EOP at the end; verify bookkeeping stays balanced. Covers in-transaction longevity.
- `P028 | STRESS_MTS_028_periodic_hiterr_every_16th`: Insert a hiterr beat every 16th valid beat with discard enabled; verify discard and total counts stay exact through the pattern. Covers periodic rejection under load.
- `P029 | STRESS_MTS_029_periodic_hiterr_keep_mode`: Repeat the same pattern with discard disabled; verify output throughput remains uninterrupted. Covers periodic accepted errors under load.
- `P030 | STRESS_MTS_030_nonzero_mux_bits_under_load`: Exercise nonzero sideband mux bits throughout a long run; verify monitors and packet bookkeeping remain stable. Covers full sideband-space operation.

## 4. Counter And Polling Soaks

- `P031 | STRESS_MTS_031_discard_counter_monotonic_1k`: Accumulate more than 1000 discarded beats and verify the discard counter stays monotonic with no missed increments. Covers discard counter robustness.
- `P032 | STRESS_MTS_032_total_counter_monotonic_1k`: Accumulate more than 1000 valid beats and verify the total counter stays monotonic. Covers total counter robustness.
- `P033 | STRESS_MTS_033_mixed_accept_reject_counter_soak`: Run a long mixed-accept/reject pattern and verify both counters track their intended subsets. Covers the common mixed-use case.
- `P034 | STRESS_MTS_034_hi_lo_snapshot_polling`: Poll `total_hit_cnt_hi` and `total_hit_cnt_lo` during heavy traffic using a coherent read sequence; verify software reconstruction remains valid. Covers high-rate observability.
- `P035 | STRESS_MTS_035_soft_reset_every_10k_cycles`: Pulse `soft_reset` every 10k cycles during a long simulation; verify counters restart cleanly and no state accumulates. Covers software reset endurance.
- `P036 | STRESS_MTS_036_global_reset_periodic_recovery`: Assert and release global reset periodically during a long simulation; verify the DUT always recovers to a clean baseline. Covers hard reset endurance.
- `P037 | STRESS_MTS_037_standard_run_sequence_repeated_100x`: Repeat the standard run-control sequence 100 times without traffic; verify no stale state accumulates. Covers control-only endurance.
- `P038 | STRESS_MTS_038_direct_running_sequence_repeated_100x`: Repeat the legacy direct-to-`RUNNING` sequence 100 times; verify no stale state accumulates. Covers the nonstandard path at scale.
- `P039 | STRESS_MTS_039_force_stop_pulse_every_100_hits`: Pulse `force_stop` every 100 hits in a long run; verify acceptance halts and resumes deterministically each time. Covers repeated software throttling.
- `P040 | STRESS_MTS_040_csr_poll_every_32_cycles`: Poll control/status registers every 32 cycles during heavy traffic; verify no unintended datapath perturbation. Covers realistic software visibility load.

## 5. Overflow-Window Soaks

- `P041 | STRESS_MTS_041_single_overflow_run`: Run long enough to cross at least one MTS overflow; verify the scoreboard’s white-timestamp model remains aligned throughout. Establishes the first long-timebase stress.
- `P042 | STRESS_MTS_042_many_overflow_run`: Run long enough to cross many MTS overflows; verify no cumulative off-by-one drift. Covers extended wrap behavior.
- `P043 | STRESS_MTS_043_hits_just_below_upper_across_overflow`: Concentrate decoded timestamps just below `padding_upper` across overflow events; verify the non-adjust path stays stable. Covers the lower side of the correction window under load.
- `P044 | STRESS_MTS_044_hits_just_above_upper_across_overflow`: Concentrate decoded timestamps just above `padding_upper` across overflow events; verify the adjust path stays stable. Covers the upper side of the correction window under load.
- `P045 | STRESS_MTS_045_mixed_t_and_e_adjust_eligibility`: Alternate hits that trigger T-only, E-only, both, and neither adjustments; verify the per-hit correction latches behave under load. Covers branch diversity near overflow.
- `P046 | STRESS_MTS_046_bypass_off_overflow_soak`: Repeat the overflow soak with `bypass_lapse=0`; archive it as the main signoff trace. Covers the architecturally relevant path.
- `P047 | STRESS_MTS_047_bypass_on_overflow_soak`: Repeat with `bypass_lapse=1`; archive it as the bypass reference trace. Covers the debug path under long timebases.
- `P048 | STRESS_MTS_048_small_expected_latency_overflow`: Use a small `expected_latency` during overflow-heavy traffic; verify error flags assert frequently but deterministically. Covers a stressfully narrow window.
- `P049 | STRESS_MTS_049_large_expected_latency_overflow`: Use a large `expected_latency` during overflow-heavy traffic; verify error flags stay mostly clear. Covers a permissive window under long runs.
- `P050 | STRESS_MTS_050_dense_divider_launch_overflow`: Keep divider launches dense across overflow windows; verify `lpm_multi_valid_cnt` masking does not produce scoreboard drift. Covers the overflow/divider interaction at scale.

## 6. Debug-Stream Stress

- `P051 | STRESS_MTS_051_debug_ts_every_hit`: Under sustained accepted load, verify `debug_ts_valid` accompanies every processed hit. Establishes the debug-ts throughput baseline.
- `P052 | STRESS_MTS_052_debug_burst_after_warmup`: Under sustained accepted load, verify `debug_burst_valid` remains active after the history pipeline warms up. Establishes the debug-burst throughput baseline.
- `P053 | STRESS_MTS_053_ts_delta_after_warmup`: Under the same sustained load, verify `ts_delta_valid` remains active after warmup. Establishes the delta throughput baseline.
- `P054 | STRESS_MTS_054_alternating_increasing_decreasing_timestamps`: Alternate timestamps that rise and fall each hit; verify debug-burst sign flips cleanly at scale. Covers sign churn stress.
- `P055 | STRESS_MTS_055_equal_timestamp_pairs`: Repeatedly drive equal selected timestamps; verify zero-like delta behavior remains stable. Covers repeated zero-delta stress.
- `P056 | STRESS_MTS_056_error_pipeline_t_path_under_load`: Use `delay_ts_field_use_t=1` under dense traffic; verify the output error flag remains aligned to the correct output beat. Covers error-pipeline timing at scale.
- `P057 | STRESS_MTS_057_error_pipeline_e_path_under_load`: Repeat with `delay_ts_field_use_t=0`; verify the alternate path remains aligned. Covers the second error-pipeline mode at scale.
- `P058 | STRESS_MTS_058_expected_latency_at_distribution_edge`: Program the expected-latency window close to the observed debug-ts distribution and run long; verify clean and error beats occur exactly where predicted. Covers threshold stress.
- `P059 | STRESS_MTS_059_debug_streams_through_flushing`: Enter `FLUSHING` after heavy debug-producing traffic; verify only the currently implemented observables remain active. Covers the stop-time debug drain.
- `P060 | STRESS_MTS_060_debug_streams_clear_after_running`: Exit `RUNNING` repeatedly after dense traffic and verify debug histories clear every time. Covers repeated stop cleanup.

## 7. Repeated Run-Control Cycles

- `P061 | STRESS_MTS_061_hundred_empty_standard_runs`: Execute 100 legal standard run sequences with no hits; verify control state and counters remain stable. Covers pure control endurance.
- `P062 | STRESS_MTS_062_hundred_single_packet_runs`: Execute 100 standard runs with one packet each; verify boundaries and counters remain stable. Covers repeated short runs.
- `P063 | STRESS_MTS_063_hundred_multi_channel_runs`: Execute 100 standard runs with one packet per enabled channel; verify SOP bookkeeping resets correctly every run. Covers repeated multi-channel runs.
- `P064 | STRESS_MTS_064_hundred_stop_cycles_ready_low`: Repeat `RUNNING -> TERMINATING -> IDLE` 100 times while holding sink `ready=0`; verify current output independence from `ready`. Covers repeated stop/load interactions.
- `P065 | STRESS_MTS_065_hundred_running_abort_cycles`: Repeat `RUNNING -> IDLE` aborts 100 times; verify no stale `FLUSHING` state ever appears. Covers repeated direct aborts.
- `P066 | STRESS_MTS_066_alternate_standard_and_legacy_starts`: Alternate standard sequences and legacy direct starts; verify both remain functional in the same regression. Covers mixed startup styles.
- `P067 | STRESS_MTS_067_idleness_only_csr_rewrites`: Rewrite CSR fields only while `IDLE`; verify future runs start cleanly with the new configuration. Covers low-risk software programming patterns.
- `P068 | STRESS_MTS_068_prepare_phase_csr_rewrites`: Rewrite CSR fields during `RUN_PREPARE`; verify the DUT tolerates the software activity and uses the final settings in the next run. Covers preparation-time programming.
- `P069 | STRESS_MTS_069_flushing_phase_csr_rewrites`: Rewrite nonfatal CSR fields during `FLUSHING`; verify the current DUT remains deterministic. Covers software writes during stop drain.
- `P070 | STRESS_MTS_070_interspersed_illegal_ctrl_words`: Inject unsupported control words between legal sequences; verify they are contained and do not poison later legal runs. Covers control noise under endurance.

## 8. Termination / Drain Stress

- `P071 | STRESS_MTS_071_terminate_after_single_packet`: Terminate after a single accepted packet and verify boundary and drain timing. Establishes the shortest productive stop.
- `P072 | STRESS_MTS_072_terminate_after_dense_burst`: Terminate after a dense accepted burst and verify the drain finishes deterministically. Covers the heaviest short stop.
- `P073 | STRESS_MTS_073_terminate_with_eop_on_last_beat`: Place the final accepted EOP exactly on the last accepted beat before stop; verify one terminal boundary. Covers the clean stop ideal.
- `P074 | STRESS_MTS_074_terminate_with_late_eop`: Issue `TERMINATING`, keep accepting hits, and deliver EOP several beats later; verify the current DUT forwards that delayed boundary. Covers a longer drain.
- `P075 | STRESS_MTS_075_terminate_without_eop_then_idle`: Issue `TERMINATING` with no final EOP and later force `IDLE`; verify the current DUT stays deterministic even though no boundary is generated. Covers the current architectural gap under stress.
- `P076 | STRESS_MTS_076_multiple_late_eops`: Continue accepting multiple EOP-tagged beats in `FLUSHING`; verify the exact current boundary count. Covers duplicate-boundary stress.
- `P077 | STRESS_MTS_077_terminate_with_ready_low`: Hold sink `ready=0` during termination and verify current boundary behavior is unchanged. Covers stop-time ignored-ready stress.
- `P078 | STRESS_MTS_078_terminate_per_enabled_channel`: Build scenarios where the last packets belong to each enabled channel in turn; verify packet bookkeeping remains coherent. Covers channel-local stop bookkeeping.
- `P079 | STRESS_MTS_079_terminate_near_overflow_window`: Terminate immediately after an overflow-window correction event; verify drain bookkeeping remains aligned. Covers overlap of the two hardest features.
- `P080 | STRESS_MTS_080_terminate_during_heavy_csr_polling`: Poll CSRs aggressively while terminating a loaded run; verify marker timing remains deterministic. Covers realistic software stop monitoring.

## 9. Parameter Sweeps Under Load

- `P081 | STRESS_MTS_081_div_pipeline_two_under_load`: Run a long soak with `LPM_DIV_PIPELINE=2`; verify math correctness and archive latency statistics. Covers the packaged build under stress.
- `P082 | STRESS_MTS_082_div_pipeline_four_under_load`: Repeat with `LPM_DIV_PIPELINE=4`; archive latency statistics and compare against the packaged build. Covers the RTL-default build under stress.
- `P083 | STRESS_MTS_083_single_enabled_channel_soak`: Run a long soak with only one enabled channel; verify SOP bookkeeping and counters remain stable. Covers the narrowest channel configuration.
- `P084 | STRESS_MTS_084_two_enabled_channels_soak`: Run a long soak with a two-channel enabled window; verify only those channels participate in SOP bookkeeping. Covers a mid-width configuration.
- `P085 | STRESS_MTS_085_four_enabled_channels_soak`: Run the same soak with the default four-channel window; archive as the main default build reference. Covers the default configuration at scale.
- `P086 | STRESS_MTS_086_remapped_hiterr_soak`: Run a long soak with remapped `HITERR_BIT_LOC`; verify only the remapped bit drives discard. Covers error-bit relocation at scale.
- `P087 | STRESS_MTS_087_custom_default_latency_soak`: Build with a nondefault `MUTRIG_BUFFER_EXPECTED_LATENCY_8N` and run a long soak; verify power-on configuration and later behavior match. Covers custom generics at scale.
- `P088 | STRESS_MTS_088_debug_zero_soak`: Build with `DEBUG=0` and run a long soak; verify functional equivalence to `DEBUG=1`. Covers report-disabled endurance.
- `P089 | STRESS_MTS_089_bank_up_vs_down_compare`: Run identical long soaks with `BANK="UP"` and `BANK="DOWN"`; verify only report strings differ. Covers nonfunctional generic stability.
- `P090 | STRESS_MTS_090_inert_parameter_sweep_compare`: Sweep `PADDING_EOP_WAIT_CYCLE`, `CRCERR_BIT_LOC`, and `FRAME_CORRPT_BIT_LOC` across two builds and verify no current functional delta. Documents present inertness under stress.

## 10. Mixed-Random Traffic Stress

- `P091 | STRESS_MTS_091_random_marker_mix`: Drive a pseudo-random mix of SOP, EOP, SOP+EOP, and plain beats under legal valid timing; verify the scoreboard stays aligned. Covers marker entropy under load.
- `P092 | STRESS_MTS_092_random_accept_reject_mix`: Drive a pseudo-random mix of clean and hiterr beats under random discard policy changes; verify counters and outputs remain exact. Covers acceptance entropy under load.
- `P093 | STRESS_MTS_093_random_delay_path_mix`: Randomly switch between T and E delay-field selection between packets; verify debug and error observables remain coherent. Covers timing-source entropy.
- `P094 | STRESS_MTS_094_random_tot_mode_mix`: Randomly switch between short mode and ToT mode between packets; verify ET interpretation remains coherent. Covers ET-mode entropy.
- `P095 | STRESS_MTS_095_random_force_stop_pulses`: Inject occasional `force_stop` pulses during random traffic; verify deterministic rejection windows. Covers asynchronous software throttling at scale.
- `P096 | STRESS_MTS_096_random_soft_reset_pulses`: Inject occasional `soft_reset` pulses with bounded recovery gaps; verify deterministic restart. Covers software reset noise.
- `P097 | STRESS_MTS_097_random_control_chatter`: Mix legal and illegal run-control words around run boundaries; verify later legal behavior recovers cleanly. Covers hostile control environments.
- `P098 | STRESS_MTS_098_random_asic_ids`: Randomize ASIC IDs over a long run while keeping valid control flow; verify output packing remains correct. Covers identity entropy.
- `P099 | STRESS_MTS_099_random_payload_channels`: Randomize payload channel fields over a long run while keeping sideband channels legal; verify channel packing remains correct. Covers payload-channel entropy.
- `P100 | STRESS_MTS_100_random_expected_latency_rewrites`: Randomize expected-latency rewrites at bounded intervals and verify the error flag follows the active window. Covers software reconfiguration noise.

## 11. Legacy Smoke Vector Endurance

- `P101 | STRESS_MTS_101_repeat_smoke_positive_vector_1k`: Replay the checked-in positive-ET smoke vector 1000 times; verify no drift or stale state appears. Turns the smoke into an endurance check.
- `P102 | STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k`: Replay the checked-in zero-ET smoke vector 1000 times; verify no drift or stale state appears. Turns the smoke into an endurance check.
- `P103 | STRESS_MTS_103_repeat_smoke_clamp_vector_1k`: Replay the checked-in clamp/saturation vector 1000 times; verify no drift or stale state appears. Turns the smoke into an endurance check.
- `P104 | STRESS_MTS_104_smoke_vectors_under_standard_sequence`: Replay the three smoke vectors using the full legal run-control sequence instead of direct `RUNNING`; verify identical output semantics. Bridges the legacy bench to the future UVM flow.
- `P105 | STRESS_MTS_105_smoke_vectors_with_ready_low`: Replay the smoke vectors with output `ready=0`; verify identical output semantics. Documents ignored-backpressure endurance.
- `P106 | STRESS_MTS_106_smoke_vectors_div_pipeline_two`: Replay the smoke vectors in the packaged `LPM_DIV_PIPELINE=2` build; verify only latency changes. Bridges smoke coverage to the packaged configuration.
- `P107 | STRESS_MTS_107_smoke_vectors_div_pipeline_four`: Replay the smoke vectors in the RTL-default build; archive as the main reference. Bridges smoke coverage to the source configuration.
- `P108 | STRESS_MTS_108_smoke_vectors_bypass_on`: Replay the smoke vectors with `bypass_lapse=1`; verify the expected alternate timing interpretation. Extends the smoke baseline into bypass mode.
- `P109 | STRESS_MTS_109_smoke_vectors_delay_field_e`: Replay the smoke vectors while selecting the E path for delay/error debug. Extends the smoke baseline into the alternate timing field.
- `P110 | STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs`: Replay the smoke vectors repeatedly with a `soft_reset` between runs; verify the DUT reinitializes cleanly each time. Turns smoke into reset-endurance coverage.

## 12. Output-Sink Stress

- `P111 | STRESS_MTS_111_ready_high_baseline_log`: Record a full transaction log with output `ready=1`; use it as the golden baseline for sink-behavior comparisons. Establishes a reference artifact.
- `P112 | STRESS_MTS_112_ready_low_baseline_log`: Record the same log with output `ready=0`; verify it matches the baseline. Documents the no-backpressure contract at scale.
- `P113 | STRESS_MTS_113_ready_toggle_1010`: Toggle output `ready` every cycle and compare against the ready-high baseline; expect a matching emitted log. Covers periodic sink variation.
- `P114 | STRESS_MTS_114_ready_low_on_sop_beats`: Hold `ready=0` only on SOP beats and compare against the baseline; expect a matching emitted log. Covers marker-specific sink variation.
- `P115 | STRESS_MTS_115_ready_low_on_eop_beats`: Hold `ready=0` only on terminating EOP beats and compare against the baseline; expect a matching emitted log. Covers boundary-specific sink variation.
- `P116 | STRESS_MTS_116_ready_low_during_dense_burst`: Drop `ready` during the heaviest output burst and compare against the baseline; expect a matching emitted log. Covers maximum-data sink variation.
- `P117 | STRESS_MTS_117_ready_low_in_flushing`: Drop `ready` throughout `FLUSHING` and compare against the baseline; expect a matching emitted log. Covers stop-time sink variation.
- `P118 | STRESS_MTS_118_random_ready_toggle`: Randomize output `ready` every cycle for a long run and compare against the baseline; expect a matching emitted log. Covers sink noise.
- `P119 | STRESS_MTS_119_ready_low_across_resets`: Hold `ready=0` across reset assertions and releases; verify the DUT still comes back cleanly and output traces remain deterministic. Covers sink behavior through reset.
- `P120 | STRESS_MTS_120_sink_pattern_equivalence_summary`: Compare all sink-pattern logs against the ready-high baseline and require exact equivalence in current RTL. Converts the sink study into one explicit signoff check.

## 13. Upgrade-Directed Performance Studies

- `P121 | STRESS_MTS_121_future_ready_occupancy_histogram`: Define the future study that will measure how long `asi_ctrl_ready` stays low once stateful acknowledgement is implemented. Prepares the harness for the upgrade.
- `P122 | STRESS_MTS_122_drain_latency_histogram`: Measure cycles from `TERMINATING` command to the last emitted output beat across many runs. Creates the primary current and future drain metric.
- `P123 | STRESS_MTS_123_drain_latency_by_div_pipeline`: Break the drain-latency histogram out by `LPM_DIV_PIPELINE` value. Quantifies the packaged-vs-source configuration difference.
- `P124 | STRESS_MTS_124_drain_latency_by_enabled_window`: Break the drain-latency histogram out by enabled-channel window size. Quantifies channel-window impact on stop behavior.
- `P125 | STRESS_MTS_125_boundary_forwarding_rate`: Measure the rate at which terminating input EOPs become output boundaries over 1000 stop cycles. Creates the current boundary-success metric.
- `P126 | STRESS_MTS_126_missing_boundary_rate_post_upgrade`: Define the future metric that must be zero once synthetic/robust terminal boundaries are implemented. Captures the planned upgrade target numerically.
- `P127 | STRESS_MTS_127_extra_boundary_rate_post_upgrade`: Define the future metric that must be zero once exactly-one-boundary semantics are implemented. Captures the planned upgrade target numerically.
- `P128 | STRESS_MTS_128_ready_statefulness_cost`: Define the future study that verifies stateful `asi_ctrl_ready` does not reduce accepted RUNNING throughput. Guards against over-fixing the control plane.
- `P129 | STRESS_MTS_129_synthetic_boundary_no_real_eop`: Define the future stress case where termination completes correctly even when no real input EOP appears. Targets the core stop-gap called out in the plan.
- `P130 | STRESS_MTS_130_full_signoff_mixed_soak`: Bundle overflow, counters, debug streams, repeated starts/stops, and termination bookkeeping into one long mixed soak. This is the eventual top-level signoff stress run.
