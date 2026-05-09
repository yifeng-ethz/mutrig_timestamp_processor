# Bug History

## R-2026-05-09-03: Hit ready, datapath sampling, and counters could diverge during bring-up

- First seen: UVM cases `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop` while executing the documented-case sequence through the normal/debug dual-path scoreboard.
- Symptom:
  - the first standard-sequence hit after `RUN_PREPARE -> SYNC -> RUNNING` could be transformed or counted inconsistently depending on the stale ready phase observed by the driver and monitors
  - force-stop needed to keep the input ready contract observable while dropping the current beat from the transform path
  - total/discard counter readback and transformed payload evidence could disagree around bring-up edges
- Root cause:
  - `asi_hit_type0_ready_i` was registered from the previous processor phase, so the externally visible accept window could lag the current FSM state
  - the datapath sampled `valid && hit_in_ok` rather than the same ready/valid acceptance event observed at the Avalon-ST boundary
  - reset-flow state could remain at `SYNC` long enough to clear counters after the first standard-sequence acceptance
  - the UVM `run_start()` helper treated the command handshake as sufficient evidence of `RUNNING`, and the CSR driver could sample read data before the acknowledged transaction had settled
- Fix status: fixed.
- Fix commit: `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)
- Verification context:
  - all 42 explicit documented-case handlers passed with `make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1`
  - `STD_MTS_006_running_from_sync` proves the standard bring-up sequence waits for CSR `RUNNING`, observes hit input ready, forwards the first clean hit, and reports `TOTAL_HIT_CNT=1`
  - `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop` cross-check ready, total/discard counters, and no-output behavior under accepted drop conditions
  - `make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1` passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8 debug_ts=2 dual_path_pairs=2 traces=2`
  - `./tb/run_mts_processor_tb.sh` passed the legacy VHDL testbench
- Notes:
  - RTL now derives the input ready window combinationally from current state, reset flow, and upstream end-of-run state
  - datapath and packet bookkeeping now sample only `asi_hit_type0_accept && hit_in_ok`
  - force-stop keeps ready high for the documented current contract, but `hit_in_ok=0` prevents transform while counters record the accepted/drop observation
  - the UVM CSR driver now drives requests on `negedge`, waits for positive-edge acknowledgement, samples after a small settle delay, and `run_start()` polls CSR status plus input ready before returning

## R-2026-05-09-02: debug_ts could emit reset/SCLR flush samples with no normal hit payload

- First seen: UVM case `STD_MTS_005_sync_enters_reset_sync` after enabling the debug monitor path as a required cross-check against normal `hit_type1` output.
- Symptom: the scoreboard observed `debug_ts_valid=1` while no normal `hit_type1` payload beat was emitted, creating an unpaired debug transaction during reset/SCLR or reset-to-SYNC bring-up traffic.
- Root cause:
  - the internal debug timestamp path was driven from the divider pipeline without checking that the processor was in an active output state
  - the external debug sideband register forwarded internal debug valid without the same state and drop-policy gating used by the normal output path
- Fix status: fixed.
- Fix commit: `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)
- Verification context:
  - all 42 explicit documented-case handlers passed with `make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1`
  - `STD_MTS_002_reset_release_idle_quiet`, `STD_MTS_005_sync_enters_reset_sync`, and `STD_MTS_010_global_reset_during_flushing` now require zero unpaired normal/debug activity through reset and bring-up boundaries
  - the merged after-fix UCDB report was regenerated with `make -C tb/uvm cov_report_total RTL_VARIANT=after`
- Notes:
  - `proc_debug_ts` now clears internal debug data/valid unless reset is deasserted, the processor is in `RUNNING` or `FLUSHING`, and the divider stage holds a valid hit
  - `proc_debug_ts_comb` now resets and only forwards debug sideband data when the normal output state and delay-error drop policy allow an observable hit sideband
  - the UVM scoreboard requires normal/debug pair agreement, so future debug-only samples remain a closure blocker rather than a tolerated artifact

## R-2026-05-09-01: Timestamp-delay error sideband could attach to the wrong hit

- First seen: UVM case `CORNER_MTS_127_delay_error_sideband_tracks_hit`, comparing the `before` RTL against the current UVM debug/normal dual-path scoreboard.
- Symptom: a forced timestamp-delay error with `EXPECTED_LATENCY=0` did not assert `aso_hit_type1_error` on the corresponding output beat. The following restored-clean hit could inherit or mask the stale classification depending on traffic spacing.
- Root cause:
  - the visible `hit_type1` payload came from the registered `hit_out` path
  - the delay-error sideband was derived from the separate `debug_ts` valid path
  - mixed clean/error traffic therefore allowed the sideband classification to describe the neighboring hit instead of the beat on the normal output path
- Fix status: fixed.
- Fix commit: `497bf11` (`[FIX] Align delay error sideband with hit`)
- Verification context:
  - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_127_delay_error_sideband_tracks_hit SEED=1`
  - `before` RTL fails with `MTSP_DELAY_MATH` / `MTSP_CASE`
  - current RTL passes with `inputs=2 beats=2 payloads=2 debug_ts=2 debug_burst=2 ts_delta=2 dual_path_pairs=2 traces=2`
  - additional green guards: `STD_MTS_001_powerup_reset_idle`, `STD_MTS_031_running_accepts_clean_hit`, `COMBO_MTSP_001_terminate_contract_test`, and `./tb/run_mts_processor_tb.sh`
- Notes:
  - the UVM environment now has analysis ports for CSR writes, accepted hit0, normal hit1, and debug streams
  - the scoreboard recomputes the delay-error decision from `debug_ts` and `EXPECTED_LATENCY` and requires it to match `aso_hit_type1_error` per payload beat

## R-2026-04-18-01: Wrap-window timestamp reconstruction mismatch

- First seen: exact integrated SciFi bench `firmware_builds/tb_int/INT_fe_scifi_v3-2026-04-17`, saturated short-mode traces `ts_sat_exact14` and `ts_sat_exact15`
- Symptom: `mts_processor` emitted wrong `tcc_8n` and non-zero `tcc_1n6` around the MuTRiG coarse-counter wrap, which raised `aso_hit_type1_error` and caused pre-RBCAM drops even though the injected hit true timestamp was still within the expected 2000-cycle latency window
- Root cause:
  - the per-hit overflow-adjust decision missed the first hit that used the newly valid overflow-product pipeline result
  - the wrap correction subtracted `32766` ticks instead of the true `32767` MuTRiG coarse-time period, leaving a residual `+1` 1.6 ns remainder after wrap
- Fix status: fixed
- Fix commit: `0399f04` (`mts_processor: fix wrap-window timestamp reconstruction`)
- Verification context:
  - exact true-time trace after the fix in `REPORT/ts_sat_exact16/emulator_timestamp_trace.csv`
  - original failing wrap samples were `hit_id=2891` and `hit_id=2895`
  - after the fix those hits decode with `tcc8n_act=tcc8n_exp=5549`, `tcc1n6=0`, `err_act=0`
- Notes:
  - the remaining `debug_ts` delta offset in the exact bench is a monitor phase issue, not a recovered-hit timestamp mismatch
  - the exact-bench integration copy under `firmware_builds/scifi_datapath_system_v3/synthesis/submodules/mts_processor.vhd` was patched locally in the superproject for system-level verification alongside this IP fix
