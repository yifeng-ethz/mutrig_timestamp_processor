# Bug History

## R-2026-05-09-01: Timestamp-delay error sideband could attach to the wrong hit

- First seen: UVM case `CORNER_MTS_127_delay_error_sideband_tracks_hit`, comparing the `before` RTL against the current UVM debug/normal dual-path scoreboard.
- Symptom: a forced timestamp-delay error with `EXPECTED_LATENCY=0` did not assert `aso_hit_type1_error` on the corresponding output beat. The following restored-clean hit could inherit or mask the stale classification depending on traffic spacing.
- Root cause:
  - the visible `hit_type1` payload came from the registered `hit_out` path
  - the delay-error sideband was derived from the separate `debug_ts` valid path
  - mixed clean/error traffic therefore allowed the sideband classification to describe the neighboring hit instead of the beat on the normal output path
- Fix status: fixed in local commit pending hash assignment.
- Fix commit: pending local commit; replace with the commit hash after the verified fix commit is created.
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
