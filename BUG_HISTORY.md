# Bug History

## R-2026-04-18-01: Wrap-window timestamp reconstruction mismatch

- First seen: exact integrated SciFi bench `quartus_system/tb_int/INT_fe_scifi_v3-2026-04-17`, saturated short-mode traces `ts_sat_exact14` and `ts_sat_exact15`
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
  - the exact-bench integration copy under `quartus_system/scifi_datapath_system_v3/synthesis/submodules/mts_processor.vhd` was patched locally in the superproject for system-level verification alongside this IP fix
