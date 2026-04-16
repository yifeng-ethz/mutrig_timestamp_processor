# DV Report: mutrig_timestamp_processor

**DUT:** `mts_processor`  
**Date:** 2026-04-16  
**Execution baseline used in this report:** `after` RTL, seed `1`, isolated doc-case runs merged in bucket order, then documented case order

## Scope

This report is generated from the bucket docs plus the case-keyed isolated UVM evidence under `tb/uvm/logs/` and `tb/uvm/cov_after/`.

Methodology used here:
- `coverage_by_this_case` is the ordered incremental code-coverage gain, in percentage points, added by that case versus the previously merged all-buckets documented baseline
- for directed cases, `coverage_incr_per_txn` repeats the same vector because each directed case contributes one deterministic transaction to the ordered baseline
- bucket and all-bucket totals are merged only from passing case-keyed UCDBs in bucket order, then documented case order
- each bucket also carries a bucket-local ordered merge trace so the row deltas stay auditable against the local bucket build-up
- raw isolated per-case UCDB evidence is still the source of truth, but the sign-off table publishes incremental gains rather than umbrella single-case totals
- cases without a passing isolated log/UCDB pair remain `pending` and do not contribute to bucket totals
- `bucket_frame` and `all_buckets_frame` remain pending until the no-restart doc-case runners are refreshed and rerun

## Bucket Summary

| bucket | planned_cases | evidenced_cases | execution_mode_baseline | current_code_coverage_total | current_functional_coverage_total |
|---|---:|---:|---|---|---|
| BASIC | 130 | 130 | isolated ordered-merge | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 | 100.00% (130/130) |
| EDGE | 130 | 130 | isolated ordered-merge | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 | 100.00% (130/130) |
| PROF | 130 | 130 | isolated ordered-merge | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 | 100.00% (130/130) |
| ERROR | 130 | 130 | isolated ordered-merge | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 | 100.00% (130/130) |
| CROSS | n/a | 0 | none yet | n/a | 0.00% (no instrumented covergroups yet) |

## BASIC Bucket

| case_id | type (d/r) | coverage_by_this_case | executed random txn | coverage_incr_per_txn |
|---|---|---|---|---|
| STD_MTS_001_powerup_reset_idle | d | stmt=56.20, branch=38.60, cond=3.12, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.74 | 0 | stmt=56.20, branch=38.60, cond=3.12, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.74 |
| STD_MTS_002_reset_release_idle_quiet | d | stmt=19.35, branch=19.88, cond=29.69, expr=60.00, fsm_state=50.00, fsm_trans=28.57, toggle=15.64 | 0 | stmt=19.35, branch=19.88, cond=29.69, expr=60.00, fsm_state=50.00, fsm_trans=28.57, toggle=15.64 |
| STD_MTS_003_direct_running_entry_allowed | d | stmt=0.85, branch=1.17, cond=3.12, expr=0.00, fsm_state=0.00, fsm_trans=14.29, toggle=2.71 | 0 | stmt=0.85, branch=1.17, cond=3.12, expr=0.00, fsm_state=0.00, fsm_trans=14.29, toggle=2.71 |
| STD_MTS_004_run_prepare_enters_reset_sclr | d | stmt=1.53, branch=2.34, cond=0.00, expr=10.00, fsm_state=0.00, fsm_trans=0.00, toggle=4.50 | 0 | stmt=1.53, branch=2.34, cond=0.00, expr=10.00, fsm_state=0.00, fsm_trans=0.00, toggle=4.50 |
| STD_MTS_005_sync_enters_reset_sync | d | stmt=0.34, branch=1.17, cond=3.12, expr=0.00, fsm_state=0.00, fsm_trans=14.29, toggle=0.02 | 0 | stmt=0.34, branch=1.17, cond=3.12, expr=0.00, fsm_state=0.00, fsm_trans=14.29, toggle=0.02 |
| STD_MTS_006_running_from_sync | d | stmt=1.70, branch=1.46, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.46 | 0 | stmt=1.70, branch=1.46, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.46 |
| STD_MTS_007_terminating_enters_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.95 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.95 |
| STD_MTS_008_idle_from_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_009_running_abort_to_idle | d | stmt=2.04, branch=3.22, cond=9.38, expr=20.00, fsm_state=25.00, fsm_trans=28.57, toggle=0.90 | 0 | stmt=2.04, branch=3.22, cond=9.38, expr=20.00, fsm_state=25.00, fsm_trans=28.57, toggle=0.90 |
| STD_MTS_010_global_reset_during_flushing | d | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=3.24 | 0 | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=3.24 |
| STD_MTS_011_control_readback_after_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_012_discard_counter_default_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_013_expected_latency_default_2000 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.11 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.11 |
| STD_MTS_014_total_counter_hi_default_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_015_total_counter_lo_default_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.17 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.17 |
| STD_MTS_016_force_stop_readback | d | stmt=0.68, branch=0.58, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.97 | 0 | stmt=0.68, branch=0.58, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.97 |
| STD_MTS_017_soft_reset_self_clear | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_018_bypass_lapse_readback | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_019_discard_hiterr_readback | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_020_op_mode_bits_readback | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_021_expected_latency_zero_write | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_022_expected_latency_small_write | d | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.15 | 0 | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.15 |
| STD_MTS_023_expected_latency_maxword_write | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_024_unsupported_write_addr1_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_025_unsupported_write_addr3_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_026_unsupported_write_addr4_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_027_unsupported_read_addr5_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_028_csr_waitrequest_ack | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.11 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.11 |
| STD_MTS_029_csr_burst_of_serial_accesses | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_030_total_counter_counts_all_valid | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_031_running_accepts_clean_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_032_idle_rejects_clean_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 |
| STD_MTS_033_reset_sclr_flush_accept | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_034_reset_sync_blocks_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.08 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.08 |
| STD_MTS_035_flushing_accepts_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_036_hiterr_discard_enabled | d | stmt=0.17, branch=0.58, cond=7.81, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 | 0 | stmt=0.17, branch=0.58, cond=7.81, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 |
| STD_MTS_037_hiterr_discard_disabled | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_038_force_stop_blocks_acceptance | d | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 | 0 | stmt=0.17, branch=0.29, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 |
| STD_MTS_039_rejected_hiterr_still_counts_total | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_040_matched_sideband_and_data_fields | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_041_legacy_running_plus_one_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_042_standard_prepare_sync_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_043_run_prepare_without_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_044_repeated_sync_pulses | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_045_terminating_without_eop_then_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_046_running_abort_no_flush | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.21 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.21 |
| STD_MTS_047_link_test_word_is_nonfunctional_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_048_sync_test_word_is_nonfunctional_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_049_reset_word_is_nonfunctional_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_050_out_of_daq_word_is_nonfunctional_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_051_tcc_uses_rom_decode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_052_ecc_uses_second_rom_port | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 |
| STD_MTS_053_bypass_off_uses_white_timestamp | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_054_bypass_on_uses_gray_timestamp | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_055_expected_latency_updates_padding_upper | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_056_no_adjust_below_upper_bound | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_057_t_path_adjust_above_upper_bound | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_058_e_path_adjust_above_upper_bound | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_059_divider_quotient_populates_tcc8n | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_060_divider_remainder_populates_tcc1n6 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_061_short_mode_zeroes_et | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_062_tot_mode_masks_eflag0 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_063_tot_mode_positive_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 |
| STD_MTS_064_tot_mode_negative_delta_reference | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 |
| STD_MTS_065_tot_mode_saturates_above_511 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_066_delay_field_t_path | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.02 |
| STD_MTS_067_delay_field_e_path | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_068_tfine_passthrough | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_069_asic_passthrough | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_070_channel_passthrough | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_071_sop_first_hit_channel0 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_072_sop_first_hit_channel1 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_073_sop_first_hit_channel2 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_074_sop_first_hit_channel3 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_075_no_repeated_sop_same_channel | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 |
| STD_MTS_076_reset_clears_startofrun_sent | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_077_terminating_input_eop_forwards_output_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_078_nonterminating_eop_not_forwarded | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_079_empty_stays_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_080_output_valid_only_in_run_or_flush | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_081_route_lane0 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_082_route_lane1 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_083_route_lane2 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_084_route_lane3 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_085_error_low_in_range | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_086_error_high_at_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_087_error_high_for_negative | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_088_error_high_at_or_above_limit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.15 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.15 |
| STD_MTS_089_debug_ts_valid_alignment | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_090_delay_field_changes_error_source | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_091_debug_burst_only_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_092_ts_delta_only_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_093_first_running_hit_warms_history | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_094_positive_timestamp_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_095_negative_timestamp_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_096_zero_timestamp_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_097_positive_signmag_conversion | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_098_negative_signmag_conversion | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_099_arrival_delta_uses_gts | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_100_debug_streams_clear_outside_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_101_replay_smoke_positive_et | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_102_replay_smoke_eflag_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_103_replay_smoke_clamp_vector | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_104_discard_counter_matches_rejections | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_105_total_counter_matches_all_valid | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_106_total_counter_hi_rollover | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.04 |
| STD_MTS_107_soft_reset_clears_counters | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_108_sync_clears_counters | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_109_running_status_bit_semantics | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_110_force_stop_persists_until_cleared | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_111_compile_rtl_default_div_pipeline | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.13 |
| STD_MTS_112_compile_packaged_div_pipeline | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_113_single_enabled_channel_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_114_upper_enabled_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_115_remapped_hiterr_bit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_116_remapped_crcerr_still_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_117_remapped_frame_corrupt_still_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_118_changed_latency_generic_at_power_on | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_119_bank_string_is_debug_only | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_120_debug_zero_is_functionally_equivalent | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_121_preterminate_hit_still_drains | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_122_terminating_eop_and_hit_emit_final_boundary | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_123_flushing_accepts_more_hits_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_124_flushing_quiet_without_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_125_ctrl_ready_high_through_terminate | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_126_ctrl_ready_high_through_prepare_and_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_127_upgrade_case_stateful_ready_on_terminate | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_129_upgrade_case_idle_after_boundary_only | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STD_MTS_130_full_standard_sequence_baseline | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |

### Bucket-Local Ordered Isolated Merge Trace

| step | case_id | merged_total_after_case |
|---:|---|---|
| 1 | STD_MTS_001_powerup_reset_idle | stmt=56.20, branch=38.60, cond=3.12, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.74 |
| 2 | STD_MTS_002_reset_release_idle_quiet | stmt=75.55, branch=58.48, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=16.37 |
| 3 | STD_MTS_003_direct_running_entry_allowed | stmt=76.40, branch=59.65, cond=35.94, expr=60.00, fsm_state=75.00, fsm_trans=42.86, toggle=19.09 |
| 4 | STD_MTS_004_run_prepare_enters_reset_sclr | stmt=77.93, branch=61.99, cond=35.94, expr=70.00, fsm_state=75.00, fsm_trans=42.86, toggle=23.59 |
| 5 | STD_MTS_005_sync_enters_reset_sync | stmt=78.27, branch=63.16, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=23.61 |
| 6 | STD_MTS_006_running_from_sync | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=24.07 |
| 7 | STD_MTS_007_terminating_enters_flushing | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=25.02 |
| 8 | STD_MTS_008_idle_from_flushing | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=25.02 |
| 9 | STD_MTS_009_running_abort_to_idle | stmt=82.00, branch=67.84, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=25.93 |
| 10 | STD_MTS_010_global_reset_during_flushing | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.17 |
| 11 | STD_MTS_011_control_readback_after_reset | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.17 |
| 12 | STD_MTS_012_discard_counter_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.21 |
| 13 | STD_MTS_013_expected_latency_default_2000 | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.31 |
| 14 | STD_MTS_014_total_counter_hi_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.31 |
| 15 | STD_MTS_015_total_counter_lo_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.48 |
| 16 | STD_MTS_016_force_stop_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 17 | STD_MTS_017_soft_reset_self_clear | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 18 | STD_MTS_018_bypass_lapse_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 19 | STD_MTS_019_discard_hiterr_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 20 | STD_MTS_020_op_mode_bits_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 21 | STD_MTS_021_expected_latency_zero_write | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.49 |
| 22 | STD_MTS_022_expected_latency_small_write | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 23 | STD_MTS_023_expected_latency_maxword_write | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 24 | STD_MTS_024_unsupported_write_addr1_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 25 | STD_MTS_025_unsupported_write_addr3_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 26 | STD_MTS_026_unsupported_write_addr4_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 27 | STD_MTS_027_unsupported_read_addr5_zero | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 28 | STD_MTS_028_csr_waitrequest_ack | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 29 | STD_MTS_029_csr_burst_of_serial_accesses | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 30 | STD_MTS_030_total_counter_counts_all_valid | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 31 | STD_MTS_031_running_accepts_clean_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 32 | STD_MTS_032_idle_rejects_clean_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.87 |
| 33 | STD_MTS_033_reset_sclr_flush_accept | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.87 |
| 34 | STD_MTS_034_reset_sync_blocks_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.96 |
| 35 | STD_MTS_035_flushing_accepts_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.96 |
| 36 | STD_MTS_036_hiterr_discard_enabled | stmt=83.19, branch=69.59, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.08 |
| 37 | STD_MTS_037_hiterr_discard_disabled | stmt=83.19, branch=69.59, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.08 |
| 38 | STD_MTS_038_force_stop_blocks_acceptance | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 39 | STD_MTS_039_rejected_hiterr_still_counts_total | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 40 | STD_MTS_040_matched_sideband_and_data_fields | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 41 | STD_MTS_041_legacy_running_plus_one_hit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 42 | STD_MTS_042_standard_prepare_sync_run | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 43 | STD_MTS_043_run_prepare_without_sync | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 44 | STD_MTS_044_repeated_sync_pulses | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 45 | STD_MTS_045_terminating_without_eop_then_idle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 46 | STD_MTS_046_running_abort_no_flush | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 47 | STD_MTS_047_link_test_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 48 | STD_MTS_048_sync_test_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 49 | STD_MTS_049_reset_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 50 | STD_MTS_050_out_of_daq_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 51 | STD_MTS_051_tcc_uses_rom_decode | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 52 | STD_MTS_052_ecc_uses_second_rom_port | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 53 | STD_MTS_053_bypass_off_uses_white_timestamp | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 54 | STD_MTS_054_bypass_on_uses_gray_timestamp | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 55 | STD_MTS_055_expected_latency_updates_padding_upper | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 56 | STD_MTS_056_no_adjust_below_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 57 | STD_MTS_057_t_path_adjust_above_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 58 | STD_MTS_058_e_path_adjust_above_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 59 | STD_MTS_059_divider_quotient_populates_tcc8n | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 60 | STD_MTS_060_divider_remainder_populates_tcc1n6 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 61 | STD_MTS_061_short_mode_zeroes_et | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 62 | STD_MTS_062_tot_mode_masks_eflag0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 63 | STD_MTS_063_tot_mode_positive_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.40 |
| 64 | STD_MTS_064_tot_mode_negative_delta_reference | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.52 |
| 65 | STD_MTS_065_tot_mode_saturates_above_511 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.52 |
| 66 | STD_MTS_066_delay_field_t_path | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 67 | STD_MTS_067_delay_field_e_path | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 68 | STD_MTS_068_tfine_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 69 | STD_MTS_069_asic_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 70 | STD_MTS_070_channel_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 71 | STD_MTS_071_sop_first_hit_channel0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 72 | STD_MTS_072_sop_first_hit_channel1 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 73 | STD_MTS_073_sop_first_hit_channel2 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 74 | STD_MTS_074_sop_first_hit_channel3 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 75 | STD_MTS_075_no_repeated_sop_same_channel | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 76 | STD_MTS_076_reset_clears_startofrun_sent | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 77 | STD_MTS_077_terminating_input_eop_forwards_output_eop | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 78 | STD_MTS_078_nonterminating_eop_not_forwarded | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 79 | STD_MTS_079_empty_stays_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 80 | STD_MTS_080_output_valid_only_in_run_or_flush | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 81 | STD_MTS_081_route_lane0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 82 | STD_MTS_082_route_lane1 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 83 | STD_MTS_083_route_lane2 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 84 | STD_MTS_084_route_lane3 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 85 | STD_MTS_085_error_low_in_range | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 86 | STD_MTS_086_error_high_at_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 87 | STD_MTS_087_error_high_for_negative | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 88 | STD_MTS_088_error_high_at_or_above_limit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 89 | STD_MTS_089_debug_ts_valid_alignment | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 90 | STD_MTS_090_delay_field_changes_error_source | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 91 | STD_MTS_091_debug_burst_only_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 92 | STD_MTS_092_ts_delta_only_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 93 | STD_MTS_093_first_running_hit_warms_history | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 94 | STD_MTS_094_positive_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 95 | STD_MTS_095_negative_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 96 | STD_MTS_096_zero_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 97 | STD_MTS_097_positive_signmag_conversion | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 98 | STD_MTS_098_negative_signmag_conversion | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 99 | STD_MTS_099_arrival_delta_uses_gts | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 100 | STD_MTS_100_debug_streams_clear_outside_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 101 | STD_MTS_101_replay_smoke_positive_et | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 102 | STD_MTS_102_replay_smoke_eflag_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 103 | STD_MTS_103_replay_smoke_clamp_vector | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 104 | STD_MTS_104_discard_counter_matches_rejections | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 105 | STD_MTS_105_total_counter_matches_all_valid | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 106 | STD_MTS_106_total_counter_hi_rollover | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 107 | STD_MTS_107_soft_reset_clears_counters | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 108 | STD_MTS_108_sync_clears_counters | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 109 | STD_MTS_109_running_status_bit_semantics | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 110 | STD_MTS_110_force_stop_persists_until_cleared | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 111 | STD_MTS_111_compile_rtl_default_div_pipeline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 112 | STD_MTS_112_compile_packaged_div_pipeline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 113 | STD_MTS_113_single_enabled_channel_window | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 114 | STD_MTS_114_upper_enabled_window | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 115 | STD_MTS_115_remapped_hiterr_bit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 116 | STD_MTS_116_remapped_crcerr_still_inert | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 117 | STD_MTS_117_remapped_frame_corrupt_still_inert | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 118 | STD_MTS_118_changed_latency_generic_at_power_on | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 119 | STD_MTS_119_bank_string_is_debug_only | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 120 | STD_MTS_120_debug_zero_is_functionally_equivalent | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 121 | STD_MTS_121_preterminate_hit_still_drains | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 122 | STD_MTS_122_terminating_eop_and_hit_emit_final_boundary | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 123 | STD_MTS_123_flushing_accepts_more_hits_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 124 | STD_MTS_124_flushing_quiet_without_hits | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 125 | STD_MTS_125_ctrl_ready_high_through_terminate | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 126 | STD_MTS_126_ctrl_ready_high_through_prepare_and_sync | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 127 | STD_MTS_127_upgrade_case_stateful_ready_on_terminate | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 128 | STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 129 | STD_MTS_129_upgrade_case_idle_after_boundary_only | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 130 | STD_MTS_130_full_standard_sequence_baseline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |

## EDGE Bucket

| case_id | type (d/r) | coverage_by_this_case | executed random txn | coverage_incr_per_txn |
|---|---|---|---|---|
| CORNER_MTS_001_reset_release_with_ctrl_valid | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_002_running_and_first_hit_same_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_003_terminate_on_final_eop_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_004_idle_on_output_valid_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_005_prepare_then_immediate_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_006_sync_then_immediate_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_007_back_to_back_running_words | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_008_back_to_back_terminating_words | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_009_illegal_ctrl_word_while_active | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_010_stale_ctrl_data_with_valid_gap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_011_expected_latency_zero | d | stmt=0.00, branch=0.00, cond=1.56, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=1.56, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_012_expected_latency_one | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_013_expected_latency_large_16bit_value | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_014_expected_latency_all_ones | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_015_reserved_opmode_bit28_only | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_016_multi_field_control_write | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_017_read_during_soft_reset_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_018_counter_read_on_low_word_rollover | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_019_csr_access_in_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_020_polling_unsupported_addr7 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_021_plain_hit_no_markers | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_022_sop_only_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_023_eop_only_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_024_single_beat_packet | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_025_zero_gap_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_026_one_cycle_gap_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_027_long_gap_then_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_028_max_payload_fields | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_029_nonzero_mux_bits_in_sideband | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_030_sideband_channel_outside_enabled_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_031_t_gray_equal_padding_upper | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_032_t_gray_one_above_upper | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_033_e_gray_equal_padding_upper | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_034_e_gray_one_above_upper | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_035_mts_counter_wrap_pulse | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_036_overflow_lookback_expiry | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_037_lpm_multi_valid_masks_adjust | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_038_bypass_toggle_before_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_039_bypass_toggle_after_hit_accept | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_040_latency_write_at_overflow_boundary | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_041_remainder_zero_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_042_remainder_one_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_043_remainder_two_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_044_remainder_three_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_045_remainder_four_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_046_route_bits_00 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_047_route_bits_01 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_048_route_bits_10 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_049_route_bits_11 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_050_route_change_across_boundary | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_051_short_mode_with_eflag_high | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_052_tot_mode_eflag_zero_large_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_053_tot_mode_smallest_positive_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_054_tot_mode_largest_unsaturated_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_055_tot_mode_first_saturated_delta | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_056_tot_mode_negative_delta_case | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_057_toggle_derive_tot_between_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_058_toggle_delay_field_between_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_059_toggle_eflag_between_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_060_tfine_extremes | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_061_first_sop_channel0_after_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_062_first_sop_channel3_after_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_063_first_hit_disabled_channel_no_sop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_064_interleaved_channels_no_repeat_sop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_065_single_terminating_eop_pulse | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_066_eop_pipe_without_valid_alignment | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_067_nonterminating_eop_is_local_only | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_068_output_eop_with_ready_low | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_069_sop_and_eop_same_output_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_070_empty_zero_on_all_output_classes | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_071_debug_ts_minus_one | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_072_debug_ts_zero | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_073_debug_ts_plus_one | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_074_debug_ts_expected_minus_one | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_075_debug_ts_expected_exact | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_076_debug_ts_expected_plus_one | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_077_t_vs_e_path_error_flip | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_078_debug_burst_positive_trim_edge | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_079_debug_burst_negative_trim_edge | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_080_ts_delta_zero_boundary | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_081_force_stop_same_cycle_as_valid | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_082_force_stop_clear_before_next_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_083_soft_reset_while_running_idle_pipe | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_084_soft_reset_with_inflight_beats | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_085_soft_reset_in_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_086_global_reset_with_pending_term_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_087_global_reset_with_debug_history | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_088_prepare_after_soft_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_089_sync_after_force_stop_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_090_idle_during_sclr_flush | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_091_single_channel_window_index0 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_092_single_channel_window_index3 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_093_middle_window_indexing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_094_packaged_div_pipeline_delay | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_095_rtl_div_pipeline_delay | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_096_zero_default_latency_generic | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_097_one_tick_default_latency_generic | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_098_remapped_hiterr_to_bit2 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_099_frame_corrupt_bit_still_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_100_padding_eop_wait_still_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_101_output_ready_low_single_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_102_output_ready_low_multi_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_103_output_ready_toggle_every_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_104_output_ready_low_on_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_105_output_ready_unknown_monitor_trap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_106_input_ready_high_in_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_107_input_ready_low_in_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_108_input_ready_high_in_reset_sclr | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_109_input_ready_low_in_reset_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_110_output_quiet_outside_running_flush | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_111_terminate_with_no_packet_open | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_112_terminate_one_cycle_before_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_113_terminate_same_cycle_as_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_114_terminate_one_cycle_after_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_115_idle_before_eop_delay_matures | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_116_multiple_eops_in_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_117_packet_open_then_abort | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_118_terminating_eop_disabled_sideband_channel | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_119_flushing_accepts_non_eop_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_120_upgrade_ready_should_wait_for_drain | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_121_prepare_ready_gap_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_122_sync_ready_gap_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_123_flushing_ready_gap_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_124_missing_synthetic_boundary_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_125_eop_alignment_hole_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_126_crcerr_ignore_upgrade_gap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_128_accept_command_vs_complete_work_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_129_one_boundary_per_run_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| CORNER_MTS_130_idle_after_boundary_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |

### Bucket-Local Ordered Isolated Merge Trace

| step | case_id | merged_total_after_case |
|---:|---|---|
| 1 | CORNER_MTS_001_reset_release_with_ctrl_valid | stmt=74.19, branch=57.89, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=11.62 |
| 2 | CORNER_MTS_002_running_and_first_hit_same_cycle | stmt=75.89, branch=59.06, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=19.49 |
| 3 | CORNER_MTS_003_terminate_on_final_eop_cycle | stmt=78.10, branch=63.16, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=23.48 |
| 4 | CORNER_MTS_004_idle_on_output_valid_cycle | stmt=79.63, branch=64.91, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=25.55 |
| 5 | CORNER_MTS_005_prepare_then_immediate_idle | stmt=79.80, branch=65.79, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=25.55 |
| 6 | CORNER_MTS_006_sync_then_immediate_running | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.01 |
| 7 | CORNER_MTS_007_back_to_back_running_words | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.26 |
| 8 | CORNER_MTS_008_back_to_back_terminating_words | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.35 |
| 9 | CORNER_MTS_009_illegal_ctrl_word_while_active | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.45 |
| 10 | CORNER_MTS_010_stale_ctrl_data_with_valid_gap | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.67 |
| 11 | CORNER_MTS_011_expected_latency_zero | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.80 |
| 12 | CORNER_MTS_012_expected_latency_one | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.84 |
| 13 | CORNER_MTS_013_expected_latency_large_16bit_value | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.84 |
| 14 | CORNER_MTS_014_expected_latency_all_ones | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.84 |
| 15 | CORNER_MTS_015_reserved_opmode_bit28_only | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.99 |
| 16 | CORNER_MTS_016_multi_field_control_write | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.43 |
| 17 | CORNER_MTS_017_read_during_soft_reset_window | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.43 |
| 18 | CORNER_MTS_018_counter_read_on_low_word_rollover | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.43 |
| 19 | CORNER_MTS_019_csr_access_in_flushing | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.43 |
| 20 | CORNER_MTS_020_polling_unsupported_addr7 | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.43 |
| 21 | CORNER_MTS_021_plain_hit_no_markers | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.45 |
| 22 | CORNER_MTS_022_sop_only_beat | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 23 | CORNER_MTS_023_eop_only_beat | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 24 | CORNER_MTS_024_single_beat_packet | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 25 | CORNER_MTS_025_zero_gap_hits | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 26 | CORNER_MTS_026_one_cycle_gap_hits | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 27 | CORNER_MTS_027_long_gap_then_hit | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 28 | CORNER_MTS_028_max_payload_fields | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 29 | CORNER_MTS_029_nonzero_mux_bits_in_sideband | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 30 | CORNER_MTS_030_sideband_channel_outside_enabled_window | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 31 | CORNER_MTS_031_t_gray_equal_padding_upper | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 32 | CORNER_MTS_032_t_gray_one_above_upper | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.77 |
| 33 | CORNER_MTS_033_e_gray_equal_padding_upper | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.77 |
| 34 | CORNER_MTS_034_e_gray_one_above_upper | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.85 |
| 35 | CORNER_MTS_035_mts_counter_wrap_pulse | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.85 |
| 36 | CORNER_MTS_036_overflow_lookback_expiry | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 37 | CORNER_MTS_037_lpm_multi_valid_masks_adjust | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 38 | CORNER_MTS_038_bypass_toggle_before_hit | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 39 | CORNER_MTS_039_bypass_toggle_after_hit_accept | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 40 | CORNER_MTS_040_latency_write_at_overflow_boundary | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 41 | CORNER_MTS_041_remainder_zero_case | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 42 | CORNER_MTS_042_remainder_one_case | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 43 | CORNER_MTS_043_remainder_two_case | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 44 | CORNER_MTS_044_remainder_three_case | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 45 | CORNER_MTS_045_remainder_four_case | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 46 | CORNER_MTS_046_route_bits_00 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 47 | CORNER_MTS_047_route_bits_01 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 48 | CORNER_MTS_048_route_bits_10 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 49 | CORNER_MTS_049_route_bits_11 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 50 | CORNER_MTS_050_route_change_across_boundary | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 51 | CORNER_MTS_051_short_mode_with_eflag_high | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 52 | CORNER_MTS_052_tot_mode_eflag_zero_large_delta | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 53 | CORNER_MTS_053_tot_mode_smallest_positive_delta | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 54 | CORNER_MTS_054_tot_mode_largest_unsaturated_delta | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 55 | CORNER_MTS_055_tot_mode_first_saturated_delta | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 56 | CORNER_MTS_056_tot_mode_negative_delta_case | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 57 | CORNER_MTS_057_toggle_derive_tot_between_hits | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 58 | CORNER_MTS_058_toggle_delay_field_between_hits | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 59 | CORNER_MTS_059_toggle_eflag_between_hits | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 60 | CORNER_MTS_060_tfine_extremes | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 61 | CORNER_MTS_061_first_sop_channel0_after_reset | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 62 | CORNER_MTS_062_first_sop_channel3_after_reset | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 63 | CORNER_MTS_063_first_hit_disabled_channel_no_sop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 64 | CORNER_MTS_064_interleaved_channels_no_repeat_sop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 65 | CORNER_MTS_065_single_terminating_eop_pulse | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 66 | CORNER_MTS_066_eop_pipe_without_valid_alignment | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 67 | CORNER_MTS_067_nonterminating_eop_is_local_only | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 68 | CORNER_MTS_068_output_eop_with_ready_low | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 69 | CORNER_MTS_069_sop_and_eop_same_output_beat | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 70 | CORNER_MTS_070_empty_zero_on_all_output_classes | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 71 | CORNER_MTS_071_debug_ts_minus_one | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 72 | CORNER_MTS_072_debug_ts_zero | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 73 | CORNER_MTS_073_debug_ts_plus_one | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 74 | CORNER_MTS_074_debug_ts_expected_minus_one | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 75 | CORNER_MTS_075_debug_ts_expected_exact | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 76 | CORNER_MTS_076_debug_ts_expected_plus_one | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 77 | CORNER_MTS_077_t_vs_e_path_error_flip | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 78 | CORNER_MTS_078_debug_burst_positive_trim_edge | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 79 | CORNER_MTS_079_debug_burst_negative_trim_edge | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 80 | CORNER_MTS_080_ts_delta_zero_boundary | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 81 | CORNER_MTS_081_force_stop_same_cycle_as_valid | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 82 | CORNER_MTS_082_force_stop_clear_before_next_hit | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 83 | CORNER_MTS_083_soft_reset_while_running_idle_pipe | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 84 | CORNER_MTS_084_soft_reset_with_inflight_beats | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 85 | CORNER_MTS_085_soft_reset_in_flushing | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 86 | CORNER_MTS_086_global_reset_with_pending_term_eop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 87 | CORNER_MTS_087_global_reset_with_debug_history | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 88 | CORNER_MTS_088_prepare_after_soft_reset | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 89 | CORNER_MTS_089_sync_after_force_stop_cycle | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 90 | CORNER_MTS_090_idle_during_sclr_flush | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 91 | CORNER_MTS_091_single_channel_window_index0 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 92 | CORNER_MTS_092_single_channel_window_index3 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 93 | CORNER_MTS_093_middle_window_indexing | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 94 | CORNER_MTS_094_packaged_div_pipeline_delay | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 95 | CORNER_MTS_095_rtl_div_pipeline_delay | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 96 | CORNER_MTS_096_zero_default_latency_generic | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 97 | CORNER_MTS_097_one_tick_default_latency_generic | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 98 | CORNER_MTS_098_remapped_hiterr_to_bit2 | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 99 | CORNER_MTS_099_frame_corrupt_bit_still_inert | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 100 | CORNER_MTS_100_padding_eop_wait_still_inert | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 101 | CORNER_MTS_101_output_ready_low_single_beat | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 102 | CORNER_MTS_102_output_ready_low_multi_beat | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 103 | CORNER_MTS_103_output_ready_toggle_every_cycle | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 104 | CORNER_MTS_104_output_ready_low_on_eop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 105 | CORNER_MTS_105_output_ready_unknown_monitor_trap | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 106 | CORNER_MTS_106_input_ready_high_in_flushing | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 107 | CORNER_MTS_107_input_ready_low_in_idle | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 108 | CORNER_MTS_108_input_ready_high_in_reset_sclr | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 109 | CORNER_MTS_109_input_ready_low_in_reset_sync | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 110 | CORNER_MTS_110_output_quiet_outside_running_flush | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 111 | CORNER_MTS_111_terminate_with_no_packet_open | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 112 | CORNER_MTS_112_terminate_one_cycle_before_eop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 113 | CORNER_MTS_113_terminate_same_cycle_as_eop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 114 | CORNER_MTS_114_terminate_one_cycle_after_eop | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 115 | CORNER_MTS_115_idle_before_eop_delay_matures | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 116 | CORNER_MTS_116_multiple_eops_in_flushing | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 117 | CORNER_MTS_117_packet_open_then_abort | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 118 | CORNER_MTS_118_terminating_eop_disabled_sideband_channel | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 119 | CORNER_MTS_119_flushing_accepts_non_eop_hits | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 120 | CORNER_MTS_120_upgrade_ready_should_wait_for_drain | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 121 | CORNER_MTS_121_prepare_ready_gap_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 122 | CORNER_MTS_122_sync_ready_gap_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 123 | CORNER_MTS_123_flushing_ready_gap_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 124 | CORNER_MTS_124_missing_synthetic_boundary_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 125 | CORNER_MTS_125_eop_alignment_hole_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 126 | CORNER_MTS_126_crcerr_ignore_upgrade_gap | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 127 | CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 128 | CORNER_MTS_128_accept_command_vs_complete_work_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 129 | CORNER_MTS_129_one_boundary_per_run_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 130 | CORNER_MTS_130_idle_after_boundary_upgrade | stmt=82.68, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |

## PROF Bucket

| case_id | type (d/r) | coverage_by_this_case | executed random txn | coverage_incr_per_txn |
|---|---|---|---|---|
| STRESS_MTS_001_line_rate_short_mode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_002_line_rate_tot_mode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_003_every_other_cycle_stream | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_004_burst_of_eight_pattern | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_005_clean_hiterr_free_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_006_mixed_hiterr_soak_keep_disabled | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_007_mixed_hiterr_soak_discard_enabled | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_008_sustained_output_ready_high | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_009_sustained_output_ready_low | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_010_flushing_after_large_backlog | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_011_long_run_short_mode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_012_long_run_tot_mode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_013_toggle_derive_tot_every_256_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_014_long_run_delay_field_t | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_015_long_run_delay_field_e | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_016_toggle_delay_field_every_256_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_017_long_run_bypass_off | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_018_long_run_bypass_on | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_019_toggle_bypass_between_packets | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_020_rewrite_expected_latency_mid_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_021_round_robin_enabled_channels | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_022_hotspot_channel0 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_023_hotspot_channel3 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_024_dense_payload_channel_sweep | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_025_dense_asic_id_sweep | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_026_single_beat_packet_stream | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_027_multi_beat_packet_stream | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_028_periodic_hiterr_every_16th | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_029_periodic_hiterr_keep_mode | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_030_nonzero_mux_bits_under_load | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_031_discard_counter_monotonic_1k | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_032_total_counter_monotonic_1k | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_033_mixed_accept_reject_counter_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_034_hi_lo_snapshot_polling | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_035_soft_reset_every_10k_cycles | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_036_global_reset_periodic_recovery | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_037_standard_run_sequence_repeated_100x | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_038_direct_running_sequence_repeated_100x | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_039_force_stop_pulse_every_100_hits | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_040_csr_poll_every_32_cycles | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_041_single_overflow_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_042_many_overflow_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_043_hits_just_below_upper_across_overflow | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_044_hits_just_above_upper_across_overflow | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_045_mixed_t_and_e_adjust_eligibility | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_046_bypass_off_overflow_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_047_bypass_on_overflow_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_048_small_expected_latency_overflow | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_049_large_expected_latency_overflow | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_050_dense_divider_launch_overflow | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_051_debug_ts_every_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_052_debug_burst_after_warmup | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_053_ts_delta_after_warmup | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_054_alternating_increasing_decreasing_timestamps | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_055_equal_timestamp_pairs | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_056_error_pipeline_t_path_under_load | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_057_error_pipeline_e_path_under_load | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_058_expected_latency_at_distribution_edge | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_059_debug_streams_through_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_060_debug_streams_clear_after_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_061_hundred_empty_standard_runs | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_062_hundred_single_packet_runs | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_063_hundred_multi_channel_runs | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_064_hundred_stop_cycles_ready_low | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_065_hundred_running_abort_cycles | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_066_alternate_standard_and_legacy_starts | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_067_idleness_only_csr_rewrites | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_068_prepare_phase_csr_rewrites | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_069_flushing_phase_csr_rewrites | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_070_interspersed_illegal_ctrl_words | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_071_terminate_after_single_packet | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_072_terminate_after_dense_burst | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_073_terminate_with_eop_on_last_beat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_074_terminate_with_late_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_075_terminate_without_eop_then_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_076_multiple_late_eops | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_077_terminate_with_ready_low | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_078_terminate_per_enabled_channel | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_079_terminate_near_overflow_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_080_terminate_during_heavy_csr_polling | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_081_div_pipeline_two_under_load | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_082_div_pipeline_four_under_load | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_083_single_enabled_channel_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_084_two_enabled_channels_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_085_four_enabled_channels_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_086_remapped_hiterr_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_087_custom_default_latency_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_088_debug_zero_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_089_bank_up_vs_down_compare | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_090_inert_parameter_sweep_compare | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_091_random_marker_mix | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_092_random_accept_reject_mix | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_093_random_delay_path_mix | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_094_random_tot_mode_mix | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_095_random_force_stop_pulses | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_096_random_soft_reset_pulses | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_097_random_control_chatter | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_098_random_asic_ids | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_099_random_payload_channels | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_100_random_expected_latency_rewrites | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_101_repeat_smoke_positive_vector_1k | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_103_repeat_smoke_clamp_vector_1k | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_104_smoke_vectors_under_standard_sequence | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_105_smoke_vectors_with_ready_low | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_106_smoke_vectors_div_pipeline_two | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_107_smoke_vectors_div_pipeline_four | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_108_smoke_vectors_bypass_on | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_109_smoke_vectors_delay_field_e | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_111_ready_high_baseline_log | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_112_ready_low_baseline_log | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_113_ready_toggle_1010 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_114_ready_low_on_sop_beats | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_115_ready_low_on_eop_beats | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_116_ready_low_during_dense_burst | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_117_ready_low_in_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_118_random_ready_toggle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_119_ready_low_across_resets | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_120_sink_pattern_equivalence_summary | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_121_future_ready_occupancy_histogram | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_122_drain_latency_histogram | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_123_drain_latency_by_div_pipeline | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_124_drain_latency_by_enabled_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_125_boundary_forwarding_rate | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_126_missing_boundary_rate_post_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_127_extra_boundary_rate_post_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_128_ready_statefulness_cost | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_129_synthetic_boundary_no_real_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| STRESS_MTS_130_full_signoff_mixed_soak | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |

### Bucket-Local Ordered Isolated Merge Trace

| step | case_id | merged_total_after_case |
|---:|---|---|
| 1 | STRESS_MTS_001_line_rate_short_mode | stmt=74.19, branch=57.89, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=11.62 |
| 2 | STRESS_MTS_002_line_rate_tot_mode | stmt=75.89, branch=59.06, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=19.49 |
| 3 | STRESS_MTS_003_every_other_cycle_stream | stmt=78.10, branch=63.16, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=23.48 |
| 4 | STRESS_MTS_004_burst_of_eight_pattern | stmt=79.63, branch=64.91, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=25.55 |
| 5 | STRESS_MTS_005_clean_hiterr_free_soak | stmt=79.80, branch=65.79, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=25.55 |
| 6 | STRESS_MTS_006_mixed_hiterr_soak_keep_disabled | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.01 |
| 7 | STRESS_MTS_007_mixed_hiterr_soak_discard_enabled | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.26 |
| 8 | STRESS_MTS_008_sustained_output_ready_high | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.35 |
| 9 | STRESS_MTS_009_sustained_output_ready_low | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.45 |
| 10 | STRESS_MTS_010_flushing_after_large_backlog | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.67 |
| 11 | STRESS_MTS_011_long_run_short_mode | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.67 |
| 12 | STRESS_MTS_012_long_run_tot_mode | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.71 |
| 13 | STRESS_MTS_013_toggle_derive_tot_every_256_hits | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.71 |
| 14 | STRESS_MTS_014_long_run_delay_field_t | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.80 |
| 15 | STRESS_MTS_015_long_run_delay_field_e | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.95 |
| 16 | STRESS_MTS_016_toggle_delay_field_every_256_hits | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 17 | STRESS_MTS_017_long_run_bypass_off | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 18 | STRESS_MTS_018_long_run_bypass_on | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 19 | STRESS_MTS_019_toggle_bypass_between_packets | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 20 | STRESS_MTS_020_rewrite_expected_latency_mid_run | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 21 | STRESS_MTS_021_round_robin_enabled_channels | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.41 |
| 22 | STRESS_MTS_022_hotspot_channel0 | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 23 | STRESS_MTS_023_hotspot_channel3 | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 24 | STRESS_MTS_024_dense_payload_channel_sweep | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 25 | STRESS_MTS_025_dense_asic_id_sweep | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 26 | STRESS_MTS_026_single_beat_packet_stream | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 27 | STRESS_MTS_027_multi_beat_packet_stream | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.53 |
| 28 | STRESS_MTS_028_periodic_hiterr_every_16th | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 29 | STRESS_MTS_029_periodic_hiterr_keep_mode | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 30 | STRESS_MTS_030_nonzero_mux_bits_under_load | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 31 | STRESS_MTS_031_discard_counter_monotonic_1k | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 32 | STRESS_MTS_032_total_counter_monotonic_1k | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.77 |
| 33 | STRESS_MTS_033_mixed_accept_reject_counter_soak | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.77 |
| 34 | STRESS_MTS_034_hi_lo_snapshot_polling | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.85 |
| 35 | STRESS_MTS_035_soft_reset_every_10k_cycles | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.85 |
| 36 | STRESS_MTS_036_global_reset_periodic_recovery | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 37 | STRESS_MTS_037_standard_run_sequence_repeated_100x | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 38 | STRESS_MTS_038_direct_running_sequence_repeated_100x | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 39 | STRESS_MTS_039_force_stop_pulse_every_100_hits | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 40 | STRESS_MTS_040_csr_poll_every_32_cycles | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 41 | STRESS_MTS_041_single_overflow_run | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 42 | STRESS_MTS_042_many_overflow_run | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 43 | STRESS_MTS_043_hits_just_below_upper_across_overflow | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 44 | STRESS_MTS_044_hits_just_above_upper_across_overflow | stmt=82.51, branch=68.42, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 45 | STRESS_MTS_045_mixed_t_and_e_adjust_eligibility | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.89 |
| 46 | STRESS_MTS_046_bypass_off_overflow_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 47 | STRESS_MTS_047_bypass_on_overflow_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 48 | STRESS_MTS_048_small_expected_latency_overflow | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 49 | STRESS_MTS_049_large_expected_latency_overflow | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 50 | STRESS_MTS_050_dense_divider_launch_overflow | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 51 | STRESS_MTS_051_debug_ts_every_hit | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.10 |
| 52 | STRESS_MTS_052_debug_burst_after_warmup | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 53 | STRESS_MTS_053_ts_delta_after_warmup | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 54 | STRESS_MTS_054_alternating_increasing_decreasing_timestamps | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 55 | STRESS_MTS_055_equal_timestamp_pairs | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 56 | STRESS_MTS_056_error_pipeline_t_path_under_load | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 57 | STRESS_MTS_057_error_pipeline_e_path_under_load | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 58 | STRESS_MTS_058_expected_latency_at_distribution_edge | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 59 | STRESS_MTS_059_debug_streams_through_flushing | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 60 | STRESS_MTS_060_debug_streams_clear_after_running | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 61 | STRESS_MTS_061_hundred_empty_standard_runs | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 62 | STRESS_MTS_062_hundred_single_packet_runs | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 63 | STRESS_MTS_063_hundred_multi_channel_runs | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.12 |
| 64 | STRESS_MTS_064_hundred_stop_cycles_ready_low | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 65 | STRESS_MTS_065_hundred_running_abort_cycles | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 66 | STRESS_MTS_066_alternate_standard_and_legacy_starts | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 67 | STRESS_MTS_067_idleness_only_csr_rewrites | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 68 | STRESS_MTS_068_prepare_phase_csr_rewrites | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 69 | STRESS_MTS_069_flushing_phase_csr_rewrites | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.29 |
| 70 | STRESS_MTS_070_interspersed_illegal_ctrl_words | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 71 | STRESS_MTS_071_terminate_after_single_packet | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 72 | STRESS_MTS_072_terminate_after_dense_burst | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 73 | STRESS_MTS_073_terminate_with_eop_on_last_beat | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 74 | STRESS_MTS_074_terminate_with_late_eop | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.33 |
| 75 | STRESS_MTS_075_terminate_without_eop_then_idle | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 76 | STRESS_MTS_076_multiple_late_eops | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 77 | STRESS_MTS_077_terminate_with_ready_low | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 78 | STRESS_MTS_078_terminate_per_enabled_channel | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 79 | STRESS_MTS_079_terminate_near_overflow_window | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 80 | STRESS_MTS_080_terminate_during_heavy_csr_polling | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 81 | STRESS_MTS_081_div_pipeline_two_under_load | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 82 | STRESS_MTS_082_div_pipeline_four_under_load | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 83 | STRESS_MTS_083_single_enabled_channel_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 84 | STRESS_MTS_084_two_enabled_channels_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 85 | STRESS_MTS_085_four_enabled_channels_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 86 | STRESS_MTS_086_remapped_hiterr_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 87 | STRESS_MTS_087_custom_default_latency_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.46 |
| 88 | STRESS_MTS_088_debug_zero_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 89 | STRESS_MTS_089_bank_up_vs_down_compare | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 90 | STRESS_MTS_090_inert_parameter_sweep_compare | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 91 | STRESS_MTS_091_random_marker_mix | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 92 | STRESS_MTS_092_random_accept_reject_mix | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 93 | STRESS_MTS_093_random_delay_path_mix | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 94 | STRESS_MTS_094_random_tot_mode_mix | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 95 | STRESS_MTS_095_random_force_stop_pulses | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 96 | STRESS_MTS_096_random_soft_reset_pulses | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 97 | STRESS_MTS_097_random_control_chatter | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 98 | STRESS_MTS_098_random_asic_ids | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 99 | STRESS_MTS_099_random_payload_channels | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 100 | STRESS_MTS_100_random_expected_latency_rewrites | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 101 | STRESS_MTS_101_repeat_smoke_positive_vector_1k | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 102 | STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 103 | STRESS_MTS_103_repeat_smoke_clamp_vector_1k | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 104 | STRESS_MTS_104_smoke_vectors_under_standard_sequence | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 105 | STRESS_MTS_105_smoke_vectors_with_ready_low | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.65 |
| 106 | STRESS_MTS_106_smoke_vectors_div_pipeline_two | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 107 | STRESS_MTS_107_smoke_vectors_div_pipeline_four | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 108 | STRESS_MTS_108_smoke_vectors_bypass_on | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 109 | STRESS_MTS_109_smoke_vectors_delay_field_e | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 110 | STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.69 |
| 111 | STRESS_MTS_111_ready_high_baseline_log | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 112 | STRESS_MTS_112_ready_low_baseline_log | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 113 | STRESS_MTS_113_ready_toggle_1010 | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 114 | STRESS_MTS_114_ready_low_on_sop_beats | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 115 | STRESS_MTS_115_ready_low_on_eop_beats | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 116 | STRESS_MTS_116_ready_low_during_dense_burst | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 117 | STRESS_MTS_117_ready_low_in_flushing | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 118 | STRESS_MTS_118_random_ready_toggle | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 119 | STRESS_MTS_119_ready_low_across_resets | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 120 | STRESS_MTS_120_sink_pattern_equivalence_summary | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 121 | STRESS_MTS_121_future_ready_occupancy_histogram | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 122 | STRESS_MTS_122_drain_latency_histogram | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 123 | STRESS_MTS_123_drain_latency_by_div_pipeline | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 124 | STRESS_MTS_124_drain_latency_by_enabled_window | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 125 | STRESS_MTS_125_boundary_forwarding_rate | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 126 | STRESS_MTS_126_missing_boundary_rate_post_upgrade | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 127 | STRESS_MTS_127_extra_boundary_rate_post_upgrade | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 128 | STRESS_MTS_128_ready_statefulness_cost | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 129 | STRESS_MTS_129_synthetic_boundary_no_real_eop | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |
| 130 | STRESS_MTS_130_full_signoff_mixed_soak | stmt=82.68, branch=68.71, cond=46.88, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.82 |

## ERROR Bucket

| case_id | type (d/r) | coverage_by_this_case | executed random txn | coverage_incr_per_txn |
|---|---|---|---|---|
| NEG_MTS_001_all_zero_ctrl_word | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_002_multi_hot_ctrl_word | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_003_illegal_ctrl_during_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_004_illegal_ctrl_during_flushing | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_005_ctrl_valid_high_data_changes | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_006_ctrl_data_unknown_injection | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_007_running_without_sync_documented_nonstandard | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_008_terminate_from_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_009_link_test_during_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_010_always_ready_masks_incomplete_work | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_011_simultaneous_read_write_same_cycle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_012_write_unsupported_addr5 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_013_read_unsupported_addr6 | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_014_reserved_opmode_bit28_write | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_015_write_expected_latency_during_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_016_back_to_back_soft_reset_pulses | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_017_rapid_force_stop_toggle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_018_driver_ignores_waitrequest | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_019_counter_reads_mid_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_020_expected_latency_overflow_model | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_021_hiterr_rejected_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_022_hiterr_kept_running | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_023_crcerr_only_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_024_frame_corrupt_only_inert | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_025_combined_error_bits_only_hiterr_matters | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_026_valid_beat_in_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_027_valid_beat_in_reset_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_028_valid_beat_under_force_stop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_029_sop_without_matching_eop_then_abort | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_030_sideband_outside_enabled_window | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_031_valid_while_input_ready_low_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_032_valid_while_input_ready_low_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_033_source_drops_valid_too_early | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_034_output_ready_low_single_fault | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_035_output_ready_low_boundary_fault | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_036_output_ready_unknown_fault | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_037_csr_driver_waitrequest_fault | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_038_ctrl_driver_assumes_stateful_ready | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_039_hit_source_changes_payload_midbeat | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_040_ctrl_valid_on_reset_edge | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_041_negative_debug_ts_error | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_042_zero_debug_ts_error | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_043_equal_expected_latency_error | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_044_above_expected_latency_error | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_045_zero_window_fault_everything | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_046_bypass_toggle_midstream_mismatch | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_047_padding_upper_regression_trap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_048_quotient_remainder_mismatch_trap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_049_route_channel_mismatch_trap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_050_tfine_corruption_trap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_051_short_mode_nonzero_et_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_053_positive_delta_missing_et | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_054_above_511_unsaturated_et | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_055_negative_delta_wrong_clamp | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_056_stale_derive_tot_after_toggle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_057_stale_delay_field_after_toggle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_058_eflag_pipeline_corruption | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_059_legacy_positive_vector_regression | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_060_legacy_clamp_vector_regression | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_061_missing_first_sop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_062_repeated_sop_same_channel | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_063_sop_on_disabled_channel | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_064_eop_outside_terminating_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_065_missing_forwarded_terminating_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_066_eop_pipe_alignment_hole | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_067_empty_nonzero_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_068_duplicate_output_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_069_output_valid_outside_active_states | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_070_packet_tracker_not_cleared_by_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_071_global_reset_clears_inflight_valids | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_072_global_reset_clears_debug_history | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_073_soft_reset_hangs_running_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_074_soft_reset_creates_phantom_eop | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_075_prepare_after_aborted_packet | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_076_force_stop_stuck_high | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_077_force_stop_clear_not_reopening | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_078_reset_flow_stuck_sclr | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_079_reset_flow_stuck_sync | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_080_direct_running_no_accept_illegal | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_081_pipeline_two_math_regression | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_082_remapped_hiterr_not_honored | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_083_default_latency_generic_not_reflected | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_084_debug_zero_changes_functionality | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_085_bank_string_changes_functionality | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_086_padding_eop_wait_changes_behavior_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_087_crcerr_bit_changes_behavior_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_088_frame_corrupt_bit_changes_behavior_today | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_089_invalid_enabled_window_compile_guard | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_090_out_of_range_enabled_values | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_091_debug_ts_without_processed_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_092_stale_debug_ts_data | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_093_debug_burst_on_first_hit_without_history | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_094_ts_delta_without_burst_context | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_096_arrival_delta_wrap_fault | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_097_signmag_conversion_extreme_negative | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_098_delay_field_switch_no_debug_source_change | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_099_debug_outputs_active_in_idle | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_100_debug_outputs_active_in_reset | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_101_discard_counter_on_clean_hit | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_102_missing_discard_increment | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_103_missing_total_increment_on_reject | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_104_spurious_total_increment_without_valid | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_105_hi_lo_counter_snapshot_incoherent | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_106_soft_reset_counter_clear_failure | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_107_sync_counter_clear_failure | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_108_running_status_high_outside_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_109_running_status_low_inside_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_110_control_readback_mismatch | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_111_terminate_without_real_eop_gap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_112_idle_before_eop_delay_finishes | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_113_multiple_eops_multiple_boundaries | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_114_packet_crosses_terminate_edge | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_115_disabled_sideband_boundary_loss | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_116_terminate_ack_before_work_done | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_118_missing_boundary_with_packet_open | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_119_duplicate_boundary_per_run | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_120_idle_before_pipeline_empty | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_121_prepare_ready_stateful_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_122_sync_ready_stateful_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_123_flushing_ready_stateful_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_124_terminate_ack_after_drain_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_126_no_fresh_accept_in_flushing_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_127_exactly_one_boundary_per_stop_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_128_idle_only_after_boundary_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |
| NEG_MTS_130_full_run_sequence_upgrade_suite | d | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 | 0 | stmt=0.00, branch=0.00, cond=0.00, expr=0.00, fsm_state=0.00, fsm_trans=0.00, toggle=0.00 |

### Bucket-Local Ordered Isolated Merge Trace

| step | case_id | merged_total_after_case |
|---:|---|---|
| 1 | NEG_MTS_001_all_zero_ctrl_word | stmt=74.19, branch=57.89, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=11.62 |
| 2 | NEG_MTS_002_multi_hot_ctrl_word | stmt=75.89, branch=59.06, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=19.49 |
| 3 | NEG_MTS_003_illegal_ctrl_during_running | stmt=78.10, branch=63.16, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=23.48 |
| 4 | NEG_MTS_004_illegal_ctrl_during_flushing | stmt=79.63, branch=64.91, cond=42.19, expr=90.00, fsm_state=100.00, fsm_trans=57.14, toggle=25.55 |
| 5 | NEG_MTS_005_ctrl_valid_high_data_changes | stmt=79.80, branch=65.79, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=25.55 |
| 6 | NEG_MTS_006_ctrl_data_unknown_injection | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.01 |
| 7 | NEG_MTS_007_running_without_sync_documented_nonstandard | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.26 |
| 8 | NEG_MTS_008_terminate_from_idle | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.35 |
| 9 | NEG_MTS_009_link_test_during_running | stmt=81.49, branch=67.25, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=26.45 |
| 10 | NEG_MTS_010_always_ready_masks_incomplete_work | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.67 |
| 11 | NEG_MTS_011_simultaneous_read_write_same_cycle | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.67 |
| 12 | NEG_MTS_012_write_unsupported_addr5 | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.71 |
| 13 | NEG_MTS_013_read_unsupported_addr6 | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.71 |
| 14 | NEG_MTS_014_reserved_opmode_bit28_write | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.80 |
| 15 | NEG_MTS_015_write_expected_latency_during_reset | stmt=81.66, branch=67.54, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=29.95 |
| 16 | NEG_MTS_016_back_to_back_soft_reset_pulses | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 17 | NEG_MTS_017_rapid_force_stop_toggle | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 18 | NEG_MTS_018_driver_ignores_waitrequest | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 19 | NEG_MTS_019_counter_reads_mid_reset | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 20 | NEG_MTS_020_expected_latency_overflow_model | stmt=82.34, branch=68.13, cond=45.31, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.39 |
| 21 | NEG_MTS_021_hiterr_rejected_running | stmt=82.51, branch=68.71, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.51 |
| 22 | NEG_MTS_022_hiterr_kept_running | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 23 | NEG_MTS_023_crcerr_only_inert | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 24 | NEG_MTS_024_frame_corrupt_only_inert | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 25 | NEG_MTS_025_combined_error_bits_only_hiterr_matters | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 26 | NEG_MTS_026_valid_beat_in_idle | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 27 | NEG_MTS_027_valid_beat_in_reset_sync | stmt=82.68, branch=69.01, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.64 |
| 28 | NEG_MTS_028_valid_beat_under_force_stop | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.66 |
| 29 | NEG_MTS_029_sop_without_matching_eop_then_abort | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.66 |
| 30 | NEG_MTS_030_sideband_outside_enabled_window | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.66 |
| 31 | NEG_MTS_031_valid_while_input_ready_low_idle | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.66 |
| 32 | NEG_MTS_032_valid_while_input_ready_low_sync | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.79 |
| 33 | NEG_MTS_033_source_drops_valid_too_early | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.79 |
| 34 | NEG_MTS_034_output_ready_low_single_fault | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.91 |
| 35 | NEG_MTS_035_output_ready_low_boundary_fault | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.91 |
| 36 | NEG_MTS_036_output_ready_unknown_fault | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.96 |
| 37 | NEG_MTS_037_csr_driver_waitrequest_fault | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.96 |
| 38 | NEG_MTS_038_ctrl_driver_assumes_stateful_ready | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.96 |
| 39 | NEG_MTS_039_hit_source_changes_payload_midbeat | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 40 | NEG_MTS_040_ctrl_valid_on_reset_edge | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 41 | NEG_MTS_041_negative_debug_ts_error | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 42 | NEG_MTS_042_zero_debug_ts_error | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 43 | NEG_MTS_043_equal_expected_latency_error | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 44 | NEG_MTS_044_above_expected_latency_error | stmt=82.85, branch=69.30, cond=53.12, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 45 | NEG_MTS_045_zero_window_fault_everything | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=30.98 |
| 46 | NEG_MTS_046_bypass_toggle_midstream_mismatch | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 47 | NEG_MTS_047_padding_upper_regression_trap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 48 | NEG_MTS_048_quotient_remainder_mismatch_trap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 49 | NEG_MTS_049_route_channel_mismatch_trap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 50 | NEG_MTS_050_tfine_corruption_trap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 51 | NEG_MTS_051_short_mode_nonzero_et_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.19 |
| 52 | NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 53 | NEG_MTS_053_positive_delta_missing_et | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 54 | NEG_MTS_054_above_511_unsaturated_et | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 55 | NEG_MTS_055_negative_delta_wrong_clamp | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 56 | NEG_MTS_056_stale_derive_tot_after_toggle | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 57 | NEG_MTS_057_stale_delay_field_after_toggle | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.21 |
| 58 | NEG_MTS_058_eflag_pipeline_corruption | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 59 | NEG_MTS_059_legacy_positive_vector_regression | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 60 | NEG_MTS_060_legacy_clamp_vector_regression | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 61 | NEG_MTS_061_missing_first_sop | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 62 | NEG_MTS_062_repeated_sop_same_channel | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 63 | NEG_MTS_063_sop_on_disabled_channel | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.25 |
| 64 | NEG_MTS_064_eop_outside_terminating_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.38 |
| 65 | NEG_MTS_065_missing_forwarded_terminating_eop | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.38 |
| 66 | NEG_MTS_066_eop_pipe_alignment_hole | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.42 |
| 67 | NEG_MTS_067_empty_nonzero_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.42 |
| 68 | NEG_MTS_068_duplicate_output_eop | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.42 |
| 69 | NEG_MTS_069_output_valid_outside_active_states | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.42 |
| 70 | NEG_MTS_070_packet_tracker_not_cleared_by_reset | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.48 |
| 71 | NEG_MTS_071_global_reset_clears_inflight_valids | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.48 |
| 72 | NEG_MTS_072_global_reset_clears_debug_history | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.48 |
| 73 | NEG_MTS_073_soft_reset_hangs_running_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.48 |
| 74 | NEG_MTS_074_soft_reset_creates_phantom_eop | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.48 |
| 75 | NEG_MTS_075_prepare_after_aborted_packet | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 76 | NEG_MTS_076_force_stop_stuck_high | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 77 | NEG_MTS_077_force_stop_clear_not_reopening | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 78 | NEG_MTS_078_reset_flow_stuck_sclr | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 79 | NEG_MTS_079_reset_flow_stuck_sync | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 80 | NEG_MTS_080_direct_running_no_accept_illegal | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 81 | NEG_MTS_081_pipeline_two_math_regression | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 82 | NEG_MTS_082_remapped_hiterr_not_honored | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 83 | NEG_MTS_083_default_latency_generic_not_reflected | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 84 | NEG_MTS_084_debug_zero_changes_functionality | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 85 | NEG_MTS_085_bank_string_changes_functionality | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 86 | NEG_MTS_086_padding_eop_wait_changes_behavior_today | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 87 | NEG_MTS_087_crcerr_bit_changes_behavior_today | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.61 |
| 88 | NEG_MTS_088_frame_corrupt_bit_changes_behavior_today | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 89 | NEG_MTS_089_invalid_enabled_window_compile_guard | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 90 | NEG_MTS_090_out_of_range_enabled_values | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 91 | NEG_MTS_091_debug_ts_without_processed_hit | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 92 | NEG_MTS_092_stale_debug_ts_data | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 93 | NEG_MTS_093_debug_burst_on_first_hit_without_history | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.76 |
| 94 | NEG_MTS_094_ts_delta_without_burst_context | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 95 | NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 96 | NEG_MTS_096_arrival_delta_wrap_fault | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 97 | NEG_MTS_097_signmag_conversion_extreme_negative | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 98 | NEG_MTS_098_delay_field_switch_no_debug_source_change | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 99 | NEG_MTS_099_debug_outputs_active_in_idle | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 100 | NEG_MTS_100_debug_outputs_active_in_reset | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 101 | NEG_MTS_101_discard_counter_on_clean_hit | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 102 | NEG_MTS_102_missing_discard_increment | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 103 | NEG_MTS_103_missing_total_increment_on_reject | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 104 | NEG_MTS_104_spurious_total_increment_without_valid | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 105 | NEG_MTS_105_hi_lo_counter_snapshot_incoherent | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.80 |
| 106 | NEG_MTS_106_soft_reset_counter_clear_failure | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.84 |
| 107 | NEG_MTS_107_sync_counter_clear_failure | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.84 |
| 108 | NEG_MTS_108_running_status_high_outside_run | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.84 |
| 109 | NEG_MTS_109_running_status_low_inside_run | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.84 |
| 110 | NEG_MTS_110_control_readback_mismatch | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.84 |
| 111 | NEG_MTS_111_terminate_without_real_eop_gap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 112 | NEG_MTS_112_idle_before_eop_delay_finishes | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 113 | NEG_MTS_113_multiple_eops_multiple_boundaries | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 114 | NEG_MTS_114_packet_crosses_terminate_edge | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 115 | NEG_MTS_115_disabled_sideband_boundary_loss | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 116 | NEG_MTS_116_terminate_ack_before_work_done | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 117 | NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 118 | NEG_MTS_118_missing_boundary_with_packet_open | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 119 | NEG_MTS_119_duplicate_boundary_per_run | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 120 | NEG_MTS_120_idle_before_pipeline_empty | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 121 | NEG_MTS_121_prepare_ready_stateful_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 122 | NEG_MTS_122_sync_ready_stateful_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 123 | NEG_MTS_123_flushing_ready_stateful_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 124 | NEG_MTS_124_terminate_ack_after_drain_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 125 | NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 126 | NEG_MTS_126_no_fresh_accept_in_flushing_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 127 | NEG_MTS_127_exactly_one_boundary_per_stop_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 128 | NEG_MTS_128_idle_only_after_boundary_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 129 | NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |
| 130 | NEG_MTS_130_full_run_sequence_upgrade_suite | stmt=83.02, branch=69.59, cond=54.69, expr=90.00, fsm_state=100.00, fsm_trans=71.43, toggle=31.97 |

## CROSS Bucket

| case_id | type (d/r) | coverage_by_this_case | executed random txn | coverage_incr_per_txn |
|---|---|---|---|---|
| pending_covergroup_instrumentation | d | n/a | 0 | n/a |

## All-Buckets Ordered Isolated Merge Trace

| step | bucket | case_id | merged_total_after_case |
|---:|---|---|---|
| 1 | BASIC | STD_MTS_001_powerup_reset_idle | stmt=56.20, branch=38.60, cond=3.12, expr=0.00, fsm_state=25.00, fsm_trans=0.00, toggle=0.74 |
| 2 | BASIC | STD_MTS_002_reset_release_idle_quiet | stmt=75.55, branch=58.48, cond=32.81, expr=60.00, fsm_state=75.00, fsm_trans=28.57, toggle=16.37 |
| 3 | BASIC | STD_MTS_003_direct_running_entry_allowed | stmt=76.40, branch=59.65, cond=35.94, expr=60.00, fsm_state=75.00, fsm_trans=42.86, toggle=19.09 |
| 4 | BASIC | STD_MTS_004_run_prepare_enters_reset_sclr | stmt=77.93, branch=61.99, cond=35.94, expr=70.00, fsm_state=75.00, fsm_trans=42.86, toggle=23.59 |
| 5 | BASIC | STD_MTS_005_sync_enters_reset_sync | stmt=78.27, branch=63.16, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=23.61 |
| 6 | BASIC | STD_MTS_006_running_from_sync | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=24.07 |
| 7 | BASIC | STD_MTS_007_terminating_enters_flushing | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=25.02 |
| 8 | BASIC | STD_MTS_008_idle_from_flushing | stmt=79.97, branch=64.62, cond=39.06, expr=70.00, fsm_state=75.00, fsm_trans=57.14, toggle=25.02 |
| 9 | BASIC | STD_MTS_009_running_abort_to_idle | stmt=82.00, branch=67.84, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=25.93 |
| 10 | BASIC | STD_MTS_010_global_reset_during_flushing | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.17 |
| 11 | BASIC | STD_MTS_011_control_readback_after_reset | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.17 |
| 12 | BASIC | STD_MTS_012_discard_counter_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.21 |
| 13 | BASIC | STD_MTS_013_expected_latency_default_2000 | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.31 |
| 14 | BASIC | STD_MTS_014_total_counter_hi_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.31 |
| 15 | BASIC | STD_MTS_015_total_counter_lo_default_zero | stmt=82.17, branch=68.13, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=29.48 |
| 16 | BASIC | STD_MTS_016_force_stop_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 17 | BASIC | STD_MTS_017_soft_reset_self_clear | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 18 | BASIC | STD_MTS_018_bypass_lapse_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 19 | BASIC | STD_MTS_019_discard_hiterr_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 20 | BASIC | STD_MTS_020_op_mode_bits_readback | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.45 |
| 21 | BASIC | STD_MTS_021_expected_latency_zero_write | stmt=82.85, branch=68.71, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.49 |
| 22 | BASIC | STD_MTS_022_expected_latency_small_write | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 23 | BASIC | STD_MTS_023_expected_latency_maxword_write | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 24 | BASIC | STD_MTS_024_unsupported_write_addr1_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 25 | BASIC | STD_MTS_025_unsupported_write_addr3_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 26 | BASIC | STD_MTS_026_unsupported_write_addr4_inert | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 27 | BASIC | STD_MTS_027_unsupported_read_addr5_zero | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.64 |
| 28 | BASIC | STD_MTS_028_csr_waitrequest_ack | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 29 | BASIC | STD_MTS_029_csr_burst_of_serial_accesses | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 30 | BASIC | STD_MTS_030_total_counter_counts_all_valid | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 31 | BASIC | STD_MTS_031_running_accepts_clean_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.74 |
| 32 | BASIC | STD_MTS_032_idle_rejects_clean_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.87 |
| 33 | BASIC | STD_MTS_033_reset_sclr_flush_accept | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.87 |
| 34 | BASIC | STD_MTS_034_reset_sync_blocks_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.96 |
| 35 | BASIC | STD_MTS_035_flushing_accepts_hit | stmt=83.02, branch=69.01, cond=48.44, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=30.96 |
| 36 | BASIC | STD_MTS_036_hiterr_discard_enabled | stmt=83.19, branch=69.59, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.08 |
| 37 | BASIC | STD_MTS_037_hiterr_discard_disabled | stmt=83.19, branch=69.59, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.08 |
| 38 | BASIC | STD_MTS_038_force_stop_blocks_acceptance | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 39 | BASIC | STD_MTS_039_rejected_hiterr_still_counts_total | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 40 | BASIC | STD_MTS_040_matched_sideband_and_data_fields | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 41 | BASIC | STD_MTS_041_legacy_running_plus_one_hit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.10 |
| 42 | BASIC | STD_MTS_042_standard_prepare_sync_run | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 43 | BASIC | STD_MTS_043_run_prepare_without_sync | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 44 | BASIC | STD_MTS_044_repeated_sync_pulses | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 45 | BASIC | STD_MTS_045_terminating_without_eop_then_idle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.14 |
| 46 | BASIC | STD_MTS_046_running_abort_no_flush | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 47 | BASIC | STD_MTS_047_link_test_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 48 | BASIC | STD_MTS_048_sync_test_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 49 | BASIC | STD_MTS_049_reset_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 50 | BASIC | STD_MTS_050_out_of_daq_word_is_nonfunctional_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 51 | BASIC | STD_MTS_051_tcc_uses_rom_decode | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.36 |
| 52 | BASIC | STD_MTS_052_ecc_uses_second_rom_port | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 53 | BASIC | STD_MTS_053_bypass_off_uses_white_timestamp | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 54 | BASIC | STD_MTS_054_bypass_on_uses_gray_timestamp | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 55 | BASIC | STD_MTS_055_expected_latency_updates_padding_upper | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 56 | BASIC | STD_MTS_056_no_adjust_below_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 57 | BASIC | STD_MTS_057_t_path_adjust_above_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 58 | BASIC | STD_MTS_058_e_path_adjust_above_upper_bound | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 59 | BASIC | STD_MTS_059_divider_quotient_populates_tcc8n | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 60 | BASIC | STD_MTS_060_divider_remainder_populates_tcc1n6 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 61 | BASIC | STD_MTS_061_short_mode_zeroes_et | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 62 | BASIC | STD_MTS_062_tot_mode_masks_eflag0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.38 |
| 63 | BASIC | STD_MTS_063_tot_mode_positive_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.40 |
| 64 | BASIC | STD_MTS_064_tot_mode_negative_delta_reference | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.52 |
| 65 | BASIC | STD_MTS_065_tot_mode_saturates_above_511 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.52 |
| 66 | BASIC | STD_MTS_066_delay_field_t_path | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 67 | BASIC | STD_MTS_067_delay_field_e_path | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 68 | BASIC | STD_MTS_068_tfine_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 69 | BASIC | STD_MTS_069_asic_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.54 |
| 70 | BASIC | STD_MTS_070_channel_passthrough | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 71 | BASIC | STD_MTS_071_sop_first_hit_channel0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 72 | BASIC | STD_MTS_072_sop_first_hit_channel1 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 73 | BASIC | STD_MTS_073_sop_first_hit_channel2 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 74 | BASIC | STD_MTS_074_sop_first_hit_channel3 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.59 |
| 75 | BASIC | STD_MTS_075_no_repeated_sop_same_channel | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 76 | BASIC | STD_MTS_076_reset_clears_startofrun_sent | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 77 | BASIC | STD_MTS_077_terminating_input_eop_forwards_output_eop | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 78 | BASIC | STD_MTS_078_nonterminating_eop_not_forwarded | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 79 | BASIC | STD_MTS_079_empty_stays_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 80 | BASIC | STD_MTS_080_output_valid_only_in_run_or_flush | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 81 | BASIC | STD_MTS_081_route_lane0 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 82 | BASIC | STD_MTS_082_route_lane1 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 83 | BASIC | STD_MTS_083_route_lane2 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 84 | BASIC | STD_MTS_084_route_lane3 | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 85 | BASIC | STD_MTS_085_error_low_in_range | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 86 | BASIC | STD_MTS_086_error_high_at_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 87 | BASIC | STD_MTS_087_error_high_for_negative | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.71 |
| 88 | BASIC | STD_MTS_088_error_high_at_or_above_limit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 89 | BASIC | STD_MTS_089_debug_ts_valid_alignment | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 90 | BASIC | STD_MTS_090_delay_field_changes_error_source | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 91 | BASIC | STD_MTS_091_debug_burst_only_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 92 | BASIC | STD_MTS_092_ts_delta_only_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 93 | BASIC | STD_MTS_093_first_running_hit_warms_history | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.86 |
| 94 | BASIC | STD_MTS_094_positive_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 95 | BASIC | STD_MTS_095_negative_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 96 | BASIC | STD_MTS_096_zero_timestamp_delta | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 97 | BASIC | STD_MTS_097_positive_signmag_conversion | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 98 | BASIC | STD_MTS_098_negative_signmag_conversion | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 99 | BASIC | STD_MTS_099_arrival_delta_uses_gts | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 100 | BASIC | STD_MTS_100_debug_streams_clear_outside_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 101 | BASIC | STD_MTS_101_replay_smoke_positive_et | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 102 | BASIC | STD_MTS_102_replay_smoke_eflag_zero | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 103 | BASIC | STD_MTS_103_replay_smoke_clamp_vector | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 104 | BASIC | STD_MTS_104_discard_counter_matches_rejections | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 105 | BASIC | STD_MTS_105_total_counter_matches_all_valid | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.90 |
| 106 | BASIC | STD_MTS_106_total_counter_hi_rollover | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 107 | BASIC | STD_MTS_107_soft_reset_clears_counters | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 108 | BASIC | STD_MTS_108_sync_clears_counters | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 109 | BASIC | STD_MTS_109_running_status_bit_semantics | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 110 | BASIC | STD_MTS_110_force_stop_persists_until_cleared | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=31.94 |
| 111 | BASIC | STD_MTS_111_compile_rtl_default_div_pipeline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 112 | BASIC | STD_MTS_112_compile_packaged_div_pipeline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 113 | BASIC | STD_MTS_113_single_enabled_channel_window | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 114 | BASIC | STD_MTS_114_upper_enabled_window | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 115 | BASIC | STD_MTS_115_remapped_hiterr_bit | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 116 | BASIC | STD_MTS_116_remapped_crcerr_still_inert | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 117 | BASIC | STD_MTS_117_remapped_frame_corrupt_still_inert | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 118 | BASIC | STD_MTS_118_changed_latency_generic_at_power_on | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 119 | BASIC | STD_MTS_119_bank_string_is_debug_only | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 120 | BASIC | STD_MTS_120_debug_zero_is_functionally_equivalent | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 121 | BASIC | STD_MTS_121_preterminate_hit_still_drains | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 122 | BASIC | STD_MTS_122_terminating_eop_and_hit_emit_final_boundary | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 123 | BASIC | STD_MTS_123_flushing_accepts_more_hits_today | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 124 | BASIC | STD_MTS_124_flushing_quiet_without_hits | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 125 | BASIC | STD_MTS_125_ctrl_ready_high_through_terminate | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 126 | BASIC | STD_MTS_126_ctrl_ready_high_through_prepare_and_sync | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 127 | BASIC | STD_MTS_127_upgrade_case_stateful_ready_on_terminate | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 128 | BASIC | STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 129 | BASIC | STD_MTS_129_upgrade_case_idle_after_boundary_only | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 130 | BASIC | STD_MTS_130_full_standard_sequence_baseline | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 131 | EDGE | CORNER_MTS_001_reset_release_with_ctrl_valid | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 132 | EDGE | CORNER_MTS_002_running_and_first_hit_same_cycle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 133 | EDGE | CORNER_MTS_003_terminate_on_final_eop_cycle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 134 | EDGE | CORNER_MTS_004_idle_on_output_valid_cycle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 135 | EDGE | CORNER_MTS_005_prepare_then_immediate_idle | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 136 | EDGE | CORNER_MTS_006_sync_then_immediate_running | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 137 | EDGE | CORNER_MTS_007_back_to_back_running_words | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 138 | EDGE | CORNER_MTS_008_back_to_back_terminating_words | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 139 | EDGE | CORNER_MTS_009_illegal_ctrl_word_while_active | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 140 | EDGE | CORNER_MTS_010_stale_ctrl_data_with_valid_gap | stmt=83.36, branch=69.88, cond=56.25, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 141 | EDGE | CORNER_MTS_011_expected_latency_zero | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 142 | EDGE | CORNER_MTS_012_expected_latency_one | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 143 | EDGE | CORNER_MTS_013_expected_latency_large_16bit_value | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 144 | EDGE | CORNER_MTS_014_expected_latency_all_ones | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 145 | EDGE | CORNER_MTS_015_reserved_opmode_bit28_only | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 146 | EDGE | CORNER_MTS_016_multi_field_control_write | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 147 | EDGE | CORNER_MTS_017_read_during_soft_reset_window | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 148 | EDGE | CORNER_MTS_018_counter_read_on_low_word_rollover | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 149 | EDGE | CORNER_MTS_019_csr_access_in_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 150 | EDGE | CORNER_MTS_020_polling_unsupported_addr7 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 151 | EDGE | CORNER_MTS_021_plain_hit_no_markers | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 152 | EDGE | CORNER_MTS_022_sop_only_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 153 | EDGE | CORNER_MTS_023_eop_only_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 154 | EDGE | CORNER_MTS_024_single_beat_packet | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 155 | EDGE | CORNER_MTS_025_zero_gap_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 156 | EDGE | CORNER_MTS_026_one_cycle_gap_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 157 | EDGE | CORNER_MTS_027_long_gap_then_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 158 | EDGE | CORNER_MTS_028_max_payload_fields | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 159 | EDGE | CORNER_MTS_029_nonzero_mux_bits_in_sideband | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 160 | EDGE | CORNER_MTS_030_sideband_channel_outside_enabled_window | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 161 | EDGE | CORNER_MTS_031_t_gray_equal_padding_upper | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 162 | EDGE | CORNER_MTS_032_t_gray_one_above_upper | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 163 | EDGE | CORNER_MTS_033_e_gray_equal_padding_upper | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 164 | EDGE | CORNER_MTS_034_e_gray_one_above_upper | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 165 | EDGE | CORNER_MTS_035_mts_counter_wrap_pulse | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 166 | EDGE | CORNER_MTS_036_overflow_lookback_expiry | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 167 | EDGE | CORNER_MTS_037_lpm_multi_valid_masks_adjust | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 168 | EDGE | CORNER_MTS_038_bypass_toggle_before_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 169 | EDGE | CORNER_MTS_039_bypass_toggle_after_hit_accept | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 170 | EDGE | CORNER_MTS_040_latency_write_at_overflow_boundary | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 171 | EDGE | CORNER_MTS_041_remainder_zero_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 172 | EDGE | CORNER_MTS_042_remainder_one_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 173 | EDGE | CORNER_MTS_043_remainder_two_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 174 | EDGE | CORNER_MTS_044_remainder_three_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 175 | EDGE | CORNER_MTS_045_remainder_four_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 176 | EDGE | CORNER_MTS_046_route_bits_00 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 177 | EDGE | CORNER_MTS_047_route_bits_01 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 178 | EDGE | CORNER_MTS_048_route_bits_10 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 179 | EDGE | CORNER_MTS_049_route_bits_11 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 180 | EDGE | CORNER_MTS_050_route_change_across_boundary | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 181 | EDGE | CORNER_MTS_051_short_mode_with_eflag_high | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 182 | EDGE | CORNER_MTS_052_tot_mode_eflag_zero_large_delta | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 183 | EDGE | CORNER_MTS_053_tot_mode_smallest_positive_delta | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 184 | EDGE | CORNER_MTS_054_tot_mode_largest_unsaturated_delta | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 185 | EDGE | CORNER_MTS_055_tot_mode_first_saturated_delta | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 186 | EDGE | CORNER_MTS_056_tot_mode_negative_delta_case | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 187 | EDGE | CORNER_MTS_057_toggle_derive_tot_between_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 188 | EDGE | CORNER_MTS_058_toggle_delay_field_between_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 189 | EDGE | CORNER_MTS_059_toggle_eflag_between_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 190 | EDGE | CORNER_MTS_060_tfine_extremes | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 191 | EDGE | CORNER_MTS_061_first_sop_channel0_after_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 192 | EDGE | CORNER_MTS_062_first_sop_channel3_after_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 193 | EDGE | CORNER_MTS_063_first_hit_disabled_channel_no_sop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 194 | EDGE | CORNER_MTS_064_interleaved_channels_no_repeat_sop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 195 | EDGE | CORNER_MTS_065_single_terminating_eop_pulse | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 196 | EDGE | CORNER_MTS_066_eop_pipe_without_valid_alignment | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 197 | EDGE | CORNER_MTS_067_nonterminating_eop_is_local_only | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 198 | EDGE | CORNER_MTS_068_output_eop_with_ready_low | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 199 | EDGE | CORNER_MTS_069_sop_and_eop_same_output_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 200 | EDGE | CORNER_MTS_070_empty_zero_on_all_output_classes | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 201 | EDGE | CORNER_MTS_071_debug_ts_minus_one | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 202 | EDGE | CORNER_MTS_072_debug_ts_zero | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 203 | EDGE | CORNER_MTS_073_debug_ts_plus_one | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 204 | EDGE | CORNER_MTS_074_debug_ts_expected_minus_one | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 205 | EDGE | CORNER_MTS_075_debug_ts_expected_exact | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 206 | EDGE | CORNER_MTS_076_debug_ts_expected_plus_one | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 207 | EDGE | CORNER_MTS_077_t_vs_e_path_error_flip | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 208 | EDGE | CORNER_MTS_078_debug_burst_positive_trim_edge | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 209 | EDGE | CORNER_MTS_079_debug_burst_negative_trim_edge | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 210 | EDGE | CORNER_MTS_080_ts_delta_zero_boundary | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 211 | EDGE | CORNER_MTS_081_force_stop_same_cycle_as_valid | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 212 | EDGE | CORNER_MTS_082_force_stop_clear_before_next_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 213 | EDGE | CORNER_MTS_083_soft_reset_while_running_idle_pipe | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 214 | EDGE | CORNER_MTS_084_soft_reset_with_inflight_beats | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 215 | EDGE | CORNER_MTS_085_soft_reset_in_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 216 | EDGE | CORNER_MTS_086_global_reset_with_pending_term_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 217 | EDGE | CORNER_MTS_087_global_reset_with_debug_history | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 218 | EDGE | CORNER_MTS_088_prepare_after_soft_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 219 | EDGE | CORNER_MTS_089_sync_after_force_stop_cycle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 220 | EDGE | CORNER_MTS_090_idle_during_sclr_flush | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 221 | EDGE | CORNER_MTS_091_single_channel_window_index0 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 222 | EDGE | CORNER_MTS_092_single_channel_window_index3 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 223 | EDGE | CORNER_MTS_093_middle_window_indexing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 224 | EDGE | CORNER_MTS_094_packaged_div_pipeline_delay | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 225 | EDGE | CORNER_MTS_095_rtl_div_pipeline_delay | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 226 | EDGE | CORNER_MTS_096_zero_default_latency_generic | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 227 | EDGE | CORNER_MTS_097_one_tick_default_latency_generic | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 228 | EDGE | CORNER_MTS_098_remapped_hiterr_to_bit2 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 229 | EDGE | CORNER_MTS_099_frame_corrupt_bit_still_inert | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 230 | EDGE | CORNER_MTS_100_padding_eop_wait_still_inert | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 231 | EDGE | CORNER_MTS_101_output_ready_low_single_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 232 | EDGE | CORNER_MTS_102_output_ready_low_multi_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 233 | EDGE | CORNER_MTS_103_output_ready_toggle_every_cycle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 234 | EDGE | CORNER_MTS_104_output_ready_low_on_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 235 | EDGE | CORNER_MTS_105_output_ready_unknown_monitor_trap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 236 | EDGE | CORNER_MTS_106_input_ready_high_in_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 237 | EDGE | CORNER_MTS_107_input_ready_low_in_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 238 | EDGE | CORNER_MTS_108_input_ready_high_in_reset_sclr | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 239 | EDGE | CORNER_MTS_109_input_ready_low_in_reset_sync | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 240 | EDGE | CORNER_MTS_110_output_quiet_outside_running_flush | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 241 | EDGE | CORNER_MTS_111_terminate_with_no_packet_open | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 242 | EDGE | CORNER_MTS_112_terminate_one_cycle_before_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 243 | EDGE | CORNER_MTS_113_terminate_same_cycle_as_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 244 | EDGE | CORNER_MTS_114_terminate_one_cycle_after_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 245 | EDGE | CORNER_MTS_115_idle_before_eop_delay_matures | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 246 | EDGE | CORNER_MTS_116_multiple_eops_in_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 247 | EDGE | CORNER_MTS_117_packet_open_then_abort | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 248 | EDGE | CORNER_MTS_118_terminating_eop_disabled_sideband_channel | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 249 | EDGE | CORNER_MTS_119_flushing_accepts_non_eop_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 250 | EDGE | CORNER_MTS_120_upgrade_ready_should_wait_for_drain | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 251 | EDGE | CORNER_MTS_121_prepare_ready_gap_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 252 | EDGE | CORNER_MTS_122_sync_ready_gap_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 253 | EDGE | CORNER_MTS_123_flushing_ready_gap_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 254 | EDGE | CORNER_MTS_124_missing_synthetic_boundary_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 255 | EDGE | CORNER_MTS_125_eop_alignment_hole_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 256 | EDGE | CORNER_MTS_126_crcerr_ignore_upgrade_gap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 257 | EDGE | CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 258 | EDGE | CORNER_MTS_128_accept_command_vs_complete_work_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 259 | EDGE | CORNER_MTS_129_one_boundary_per_run_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 260 | EDGE | CORNER_MTS_130_idle_after_boundary_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 261 | PROF | STRESS_MTS_001_line_rate_short_mode | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 262 | PROF | STRESS_MTS_002_line_rate_tot_mode | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 263 | PROF | STRESS_MTS_003_every_other_cycle_stream | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 264 | PROF | STRESS_MTS_004_burst_of_eight_pattern | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 265 | PROF | STRESS_MTS_005_clean_hiterr_free_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 266 | PROF | STRESS_MTS_006_mixed_hiterr_soak_keep_disabled | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 267 | PROF | STRESS_MTS_007_mixed_hiterr_soak_discard_enabled | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 268 | PROF | STRESS_MTS_008_sustained_output_ready_high | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 269 | PROF | STRESS_MTS_009_sustained_output_ready_low | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 270 | PROF | STRESS_MTS_010_flushing_after_large_backlog | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 271 | PROF | STRESS_MTS_011_long_run_short_mode | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 272 | PROF | STRESS_MTS_012_long_run_tot_mode | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 273 | PROF | STRESS_MTS_013_toggle_derive_tot_every_256_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 274 | PROF | STRESS_MTS_014_long_run_delay_field_t | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 275 | PROF | STRESS_MTS_015_long_run_delay_field_e | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 276 | PROF | STRESS_MTS_016_toggle_delay_field_every_256_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 277 | PROF | STRESS_MTS_017_long_run_bypass_off | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 278 | PROF | STRESS_MTS_018_long_run_bypass_on | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 279 | PROF | STRESS_MTS_019_toggle_bypass_between_packets | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 280 | PROF | STRESS_MTS_020_rewrite_expected_latency_mid_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 281 | PROF | STRESS_MTS_021_round_robin_enabled_channels | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 282 | PROF | STRESS_MTS_022_hotspot_channel0 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 283 | PROF | STRESS_MTS_023_hotspot_channel3 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 284 | PROF | STRESS_MTS_024_dense_payload_channel_sweep | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 285 | PROF | STRESS_MTS_025_dense_asic_id_sweep | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 286 | PROF | STRESS_MTS_026_single_beat_packet_stream | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 287 | PROF | STRESS_MTS_027_multi_beat_packet_stream | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 288 | PROF | STRESS_MTS_028_periodic_hiterr_every_16th | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 289 | PROF | STRESS_MTS_029_periodic_hiterr_keep_mode | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 290 | PROF | STRESS_MTS_030_nonzero_mux_bits_under_load | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 291 | PROF | STRESS_MTS_031_discard_counter_monotonic_1k | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 292 | PROF | STRESS_MTS_032_total_counter_monotonic_1k | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 293 | PROF | STRESS_MTS_033_mixed_accept_reject_counter_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 294 | PROF | STRESS_MTS_034_hi_lo_snapshot_polling | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 295 | PROF | STRESS_MTS_035_soft_reset_every_10k_cycles | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 296 | PROF | STRESS_MTS_036_global_reset_periodic_recovery | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 297 | PROF | STRESS_MTS_037_standard_run_sequence_repeated_100x | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 298 | PROF | STRESS_MTS_038_direct_running_sequence_repeated_100x | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 299 | PROF | STRESS_MTS_039_force_stop_pulse_every_100_hits | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 300 | PROF | STRESS_MTS_040_csr_poll_every_32_cycles | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 301 | PROF | STRESS_MTS_041_single_overflow_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 302 | PROF | STRESS_MTS_042_many_overflow_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 303 | PROF | STRESS_MTS_043_hits_just_below_upper_across_overflow | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 304 | PROF | STRESS_MTS_044_hits_just_above_upper_across_overflow | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 305 | PROF | STRESS_MTS_045_mixed_t_and_e_adjust_eligibility | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 306 | PROF | STRESS_MTS_046_bypass_off_overflow_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 307 | PROF | STRESS_MTS_047_bypass_on_overflow_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 308 | PROF | STRESS_MTS_048_small_expected_latency_overflow | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 309 | PROF | STRESS_MTS_049_large_expected_latency_overflow | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 310 | PROF | STRESS_MTS_050_dense_divider_launch_overflow | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 311 | PROF | STRESS_MTS_051_debug_ts_every_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 312 | PROF | STRESS_MTS_052_debug_burst_after_warmup | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 313 | PROF | STRESS_MTS_053_ts_delta_after_warmup | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 314 | PROF | STRESS_MTS_054_alternating_increasing_decreasing_timestamps | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 315 | PROF | STRESS_MTS_055_equal_timestamp_pairs | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 316 | PROF | STRESS_MTS_056_error_pipeline_t_path_under_load | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 317 | PROF | STRESS_MTS_057_error_pipeline_e_path_under_load | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 318 | PROF | STRESS_MTS_058_expected_latency_at_distribution_edge | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 319 | PROF | STRESS_MTS_059_debug_streams_through_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 320 | PROF | STRESS_MTS_060_debug_streams_clear_after_running | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 321 | PROF | STRESS_MTS_061_hundred_empty_standard_runs | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 322 | PROF | STRESS_MTS_062_hundred_single_packet_runs | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 323 | PROF | STRESS_MTS_063_hundred_multi_channel_runs | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 324 | PROF | STRESS_MTS_064_hundred_stop_cycles_ready_low | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 325 | PROF | STRESS_MTS_065_hundred_running_abort_cycles | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 326 | PROF | STRESS_MTS_066_alternate_standard_and_legacy_starts | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 327 | PROF | STRESS_MTS_067_idleness_only_csr_rewrites | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 328 | PROF | STRESS_MTS_068_prepare_phase_csr_rewrites | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 329 | PROF | STRESS_MTS_069_flushing_phase_csr_rewrites | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 330 | PROF | STRESS_MTS_070_interspersed_illegal_ctrl_words | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 331 | PROF | STRESS_MTS_071_terminate_after_single_packet | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 332 | PROF | STRESS_MTS_072_terminate_after_dense_burst | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 333 | PROF | STRESS_MTS_073_terminate_with_eop_on_last_beat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 334 | PROF | STRESS_MTS_074_terminate_with_late_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 335 | PROF | STRESS_MTS_075_terminate_without_eop_then_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 336 | PROF | STRESS_MTS_076_multiple_late_eops | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 337 | PROF | STRESS_MTS_077_terminate_with_ready_low | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 338 | PROF | STRESS_MTS_078_terminate_per_enabled_channel | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 339 | PROF | STRESS_MTS_079_terminate_near_overflow_window | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 340 | PROF | STRESS_MTS_080_terminate_during_heavy_csr_polling | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 341 | PROF | STRESS_MTS_081_div_pipeline_two_under_load | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 342 | PROF | STRESS_MTS_082_div_pipeline_four_under_load | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 343 | PROF | STRESS_MTS_083_single_enabled_channel_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 344 | PROF | STRESS_MTS_084_two_enabled_channels_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 345 | PROF | STRESS_MTS_085_four_enabled_channels_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 346 | PROF | STRESS_MTS_086_remapped_hiterr_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 347 | PROF | STRESS_MTS_087_custom_default_latency_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 348 | PROF | STRESS_MTS_088_debug_zero_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 349 | PROF | STRESS_MTS_089_bank_up_vs_down_compare | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 350 | PROF | STRESS_MTS_090_inert_parameter_sweep_compare | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 351 | PROF | STRESS_MTS_091_random_marker_mix | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 352 | PROF | STRESS_MTS_092_random_accept_reject_mix | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 353 | PROF | STRESS_MTS_093_random_delay_path_mix | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 354 | PROF | STRESS_MTS_094_random_tot_mode_mix | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 355 | PROF | STRESS_MTS_095_random_force_stop_pulses | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 356 | PROF | STRESS_MTS_096_random_soft_reset_pulses | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 357 | PROF | STRESS_MTS_097_random_control_chatter | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 358 | PROF | STRESS_MTS_098_random_asic_ids | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 359 | PROF | STRESS_MTS_099_random_payload_channels | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 360 | PROF | STRESS_MTS_100_random_expected_latency_rewrites | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 361 | PROF | STRESS_MTS_101_repeat_smoke_positive_vector_1k | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 362 | PROF | STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 363 | PROF | STRESS_MTS_103_repeat_smoke_clamp_vector_1k | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 364 | PROF | STRESS_MTS_104_smoke_vectors_under_standard_sequence | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 365 | PROF | STRESS_MTS_105_smoke_vectors_with_ready_low | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 366 | PROF | STRESS_MTS_106_smoke_vectors_div_pipeline_two | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 367 | PROF | STRESS_MTS_107_smoke_vectors_div_pipeline_four | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 368 | PROF | STRESS_MTS_108_smoke_vectors_bypass_on | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 369 | PROF | STRESS_MTS_109_smoke_vectors_delay_field_e | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 370 | PROF | STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 371 | PROF | STRESS_MTS_111_ready_high_baseline_log | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 372 | PROF | STRESS_MTS_112_ready_low_baseline_log | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 373 | PROF | STRESS_MTS_113_ready_toggle_1010 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 374 | PROF | STRESS_MTS_114_ready_low_on_sop_beats | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 375 | PROF | STRESS_MTS_115_ready_low_on_eop_beats | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 376 | PROF | STRESS_MTS_116_ready_low_during_dense_burst | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 377 | PROF | STRESS_MTS_117_ready_low_in_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 378 | PROF | STRESS_MTS_118_random_ready_toggle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 379 | PROF | STRESS_MTS_119_ready_low_across_resets | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 380 | PROF | STRESS_MTS_120_sink_pattern_equivalence_summary | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 381 | PROF | STRESS_MTS_121_future_ready_occupancy_histogram | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 382 | PROF | STRESS_MTS_122_drain_latency_histogram | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 383 | PROF | STRESS_MTS_123_drain_latency_by_div_pipeline | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 384 | PROF | STRESS_MTS_124_drain_latency_by_enabled_window | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 385 | PROF | STRESS_MTS_125_boundary_forwarding_rate | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 386 | PROF | STRESS_MTS_126_missing_boundary_rate_post_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 387 | PROF | STRESS_MTS_127_extra_boundary_rate_post_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 388 | PROF | STRESS_MTS_128_ready_statefulness_cost | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 389 | PROF | STRESS_MTS_129_synthetic_boundary_no_real_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 390 | PROF | STRESS_MTS_130_full_signoff_mixed_soak | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 391 | ERROR | NEG_MTS_001_all_zero_ctrl_word | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 392 | ERROR | NEG_MTS_002_multi_hot_ctrl_word | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 393 | ERROR | NEG_MTS_003_illegal_ctrl_during_running | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 394 | ERROR | NEG_MTS_004_illegal_ctrl_during_flushing | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 395 | ERROR | NEG_MTS_005_ctrl_valid_high_data_changes | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 396 | ERROR | NEG_MTS_006_ctrl_data_unknown_injection | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 397 | ERROR | NEG_MTS_007_running_without_sync_documented_nonstandard | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 398 | ERROR | NEG_MTS_008_terminate_from_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 399 | ERROR | NEG_MTS_009_link_test_during_running | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 400 | ERROR | NEG_MTS_010_always_ready_masks_incomplete_work | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 401 | ERROR | NEG_MTS_011_simultaneous_read_write_same_cycle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 402 | ERROR | NEG_MTS_012_write_unsupported_addr5 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 403 | ERROR | NEG_MTS_013_read_unsupported_addr6 | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 404 | ERROR | NEG_MTS_014_reserved_opmode_bit28_write | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 405 | ERROR | NEG_MTS_015_write_expected_latency_during_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 406 | ERROR | NEG_MTS_016_back_to_back_soft_reset_pulses | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 407 | ERROR | NEG_MTS_017_rapid_force_stop_toggle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 408 | ERROR | NEG_MTS_018_driver_ignores_waitrequest | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 409 | ERROR | NEG_MTS_019_counter_reads_mid_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 410 | ERROR | NEG_MTS_020_expected_latency_overflow_model | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 411 | ERROR | NEG_MTS_021_hiterr_rejected_running | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 412 | ERROR | NEG_MTS_022_hiterr_kept_running | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 413 | ERROR | NEG_MTS_023_crcerr_only_inert | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 414 | ERROR | NEG_MTS_024_frame_corrupt_only_inert | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 415 | ERROR | NEG_MTS_025_combined_error_bits_only_hiterr_matters | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 416 | ERROR | NEG_MTS_026_valid_beat_in_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 417 | ERROR | NEG_MTS_027_valid_beat_in_reset_sync | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 418 | ERROR | NEG_MTS_028_valid_beat_under_force_stop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 419 | ERROR | NEG_MTS_029_sop_without_matching_eop_then_abort | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 420 | ERROR | NEG_MTS_030_sideband_outside_enabled_window | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 421 | ERROR | NEG_MTS_031_valid_while_input_ready_low_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 422 | ERROR | NEG_MTS_032_valid_while_input_ready_low_sync | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 423 | ERROR | NEG_MTS_033_source_drops_valid_too_early | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 424 | ERROR | NEG_MTS_034_output_ready_low_single_fault | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 425 | ERROR | NEG_MTS_035_output_ready_low_boundary_fault | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 426 | ERROR | NEG_MTS_036_output_ready_unknown_fault | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 427 | ERROR | NEG_MTS_037_csr_driver_waitrequest_fault | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 428 | ERROR | NEG_MTS_038_ctrl_driver_assumes_stateful_ready | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 429 | ERROR | NEG_MTS_039_hit_source_changes_payload_midbeat | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 430 | ERROR | NEG_MTS_040_ctrl_valid_on_reset_edge | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 431 | ERROR | NEG_MTS_041_negative_debug_ts_error | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 432 | ERROR | NEG_MTS_042_zero_debug_ts_error | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 433 | ERROR | NEG_MTS_043_equal_expected_latency_error | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 434 | ERROR | NEG_MTS_044_above_expected_latency_error | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 435 | ERROR | NEG_MTS_045_zero_window_fault_everything | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 436 | ERROR | NEG_MTS_046_bypass_toggle_midstream_mismatch | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 437 | ERROR | NEG_MTS_047_padding_upper_regression_trap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 438 | ERROR | NEG_MTS_048_quotient_remainder_mismatch_trap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 439 | ERROR | NEG_MTS_049_route_channel_mismatch_trap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 440 | ERROR | NEG_MTS_050_tfine_corruption_trap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 441 | ERROR | NEG_MTS_051_short_mode_nonzero_et_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 442 | ERROR | NEG_MTS_052_tot_mode_eflag0_nonzero_et_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 443 | ERROR | NEG_MTS_053_positive_delta_missing_et | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 444 | ERROR | NEG_MTS_054_above_511_unsaturated_et | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 445 | ERROR | NEG_MTS_055_negative_delta_wrong_clamp | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 446 | ERROR | NEG_MTS_056_stale_derive_tot_after_toggle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 447 | ERROR | NEG_MTS_057_stale_delay_field_after_toggle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 448 | ERROR | NEG_MTS_058_eflag_pipeline_corruption | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 449 | ERROR | NEG_MTS_059_legacy_positive_vector_regression | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 450 | ERROR | NEG_MTS_060_legacy_clamp_vector_regression | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 451 | ERROR | NEG_MTS_061_missing_first_sop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 452 | ERROR | NEG_MTS_062_repeated_sop_same_channel | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 453 | ERROR | NEG_MTS_063_sop_on_disabled_channel | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 454 | ERROR | NEG_MTS_064_eop_outside_terminating_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 455 | ERROR | NEG_MTS_065_missing_forwarded_terminating_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 456 | ERROR | NEG_MTS_066_eop_pipe_alignment_hole | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 457 | ERROR | NEG_MTS_067_empty_nonzero_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 458 | ERROR | NEG_MTS_068_duplicate_output_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 459 | ERROR | NEG_MTS_069_output_valid_outside_active_states | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 460 | ERROR | NEG_MTS_070_packet_tracker_not_cleared_by_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 461 | ERROR | NEG_MTS_071_global_reset_clears_inflight_valids | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 462 | ERROR | NEG_MTS_072_global_reset_clears_debug_history | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 463 | ERROR | NEG_MTS_073_soft_reset_hangs_running_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 464 | ERROR | NEG_MTS_074_soft_reset_creates_phantom_eop | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 465 | ERROR | NEG_MTS_075_prepare_after_aborted_packet | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 466 | ERROR | NEG_MTS_076_force_stop_stuck_high | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 467 | ERROR | NEG_MTS_077_force_stop_clear_not_reopening | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 468 | ERROR | NEG_MTS_078_reset_flow_stuck_sclr | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 469 | ERROR | NEG_MTS_079_reset_flow_stuck_sync | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 470 | ERROR | NEG_MTS_080_direct_running_no_accept_illegal | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 471 | ERROR | NEG_MTS_081_pipeline_two_math_regression | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 472 | ERROR | NEG_MTS_082_remapped_hiterr_not_honored | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 473 | ERROR | NEG_MTS_083_default_latency_generic_not_reflected | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 474 | ERROR | NEG_MTS_084_debug_zero_changes_functionality | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 475 | ERROR | NEG_MTS_085_bank_string_changes_functionality | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 476 | ERROR | NEG_MTS_086_padding_eop_wait_changes_behavior_today | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 477 | ERROR | NEG_MTS_087_crcerr_bit_changes_behavior_today | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 478 | ERROR | NEG_MTS_088_frame_corrupt_bit_changes_behavior_today | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 479 | ERROR | NEG_MTS_089_invalid_enabled_window_compile_guard | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 480 | ERROR | NEG_MTS_090_out_of_range_enabled_values | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 481 | ERROR | NEG_MTS_091_debug_ts_without_processed_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 482 | ERROR | NEG_MTS_092_stale_debug_ts_data | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 483 | ERROR | NEG_MTS_093_debug_burst_on_first_hit_without_history | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 484 | ERROR | NEG_MTS_094_ts_delta_without_burst_context | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 485 | ERROR | NEG_MTS_095_debug_burst_and_ts_delta_sign_disagree | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 486 | ERROR | NEG_MTS_096_arrival_delta_wrap_fault | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 487 | ERROR | NEG_MTS_097_signmag_conversion_extreme_negative | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 488 | ERROR | NEG_MTS_098_delay_field_switch_no_debug_source_change | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 489 | ERROR | NEG_MTS_099_debug_outputs_active_in_idle | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 490 | ERROR | NEG_MTS_100_debug_outputs_active_in_reset | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 491 | ERROR | NEG_MTS_101_discard_counter_on_clean_hit | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 492 | ERROR | NEG_MTS_102_missing_discard_increment | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 493 | ERROR | NEG_MTS_103_missing_total_increment_on_reject | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 494 | ERROR | NEG_MTS_104_spurious_total_increment_without_valid | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 495 | ERROR | NEG_MTS_105_hi_lo_counter_snapshot_incoherent | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 496 | ERROR | NEG_MTS_106_soft_reset_counter_clear_failure | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 497 | ERROR | NEG_MTS_107_sync_counter_clear_failure | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 498 | ERROR | NEG_MTS_108_running_status_high_outside_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 499 | ERROR | NEG_MTS_109_running_status_low_inside_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 500 | ERROR | NEG_MTS_110_control_readback_mismatch | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 501 | ERROR | NEG_MTS_111_terminate_without_real_eop_gap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 502 | ERROR | NEG_MTS_112_idle_before_eop_delay_finishes | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 503 | ERROR | NEG_MTS_113_multiple_eops_multiple_boundaries | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 504 | ERROR | NEG_MTS_114_packet_crosses_terminate_edge | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 505 | ERROR | NEG_MTS_115_disabled_sideband_boundary_loss | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 506 | ERROR | NEG_MTS_116_terminate_ack_before_work_done | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 507 | ERROR | NEG_MTS_117_flushing_accepts_fresh_hits_upgrade_gap | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 508 | ERROR | NEG_MTS_118_missing_boundary_with_packet_open | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 509 | ERROR | NEG_MTS_119_duplicate_boundary_per_run | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 510 | ERROR | NEG_MTS_120_idle_before_pipeline_empty | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 511 | ERROR | NEG_MTS_121_prepare_ready_stateful_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 512 | ERROR | NEG_MTS_122_sync_ready_stateful_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 513 | ERROR | NEG_MTS_123_flushing_ready_stateful_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 514 | ERROR | NEG_MTS_124_terminate_ack_after_drain_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 515 | ERROR | NEG_MTS_125_synthetic_boundary_without_real_eop_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 516 | ERROR | NEG_MTS_126_no_fresh_accept_in_flushing_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 517 | ERROR | NEG_MTS_127_exactly_one_boundary_per_stop_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 518 | ERROR | NEG_MTS_128_idle_only_after_boundary_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 519 | ERROR | NEG_MTS_129_ctrl_handshake_reflects_completion_upgrade | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |
| 520 | ERROR | NEG_MTS_130_full_run_sequence_upgrade_suite | stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07 |

## Current Totals

- Merged total code coverage across all passing doc-case evidence: `stmt=83.36, branch=69.88, cond=57.81, expr=90.00, fsm_state=100.00, fsm_trans=85.71, toggle=32.07`
- Total final functional coverage from visible testcase rows: `100.00% (520/520 planned cases evidenced)`
- Cases excluded from totals because they do not yet have passing evidence: `0`
- `bucket_frame` merged total code coverage: pending refresh
- `all_buckets_frame` merged total code coverage: pending refresh

