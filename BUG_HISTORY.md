# Bug History

## R-2026-05-01-01: ASIC5 production-lapse split required runtime overflow-lookback tuning

- First seen: Phase-6 FEB head-sync hardware run on 2026-05-01, ASIC5, with
  production MTS lapse enabled.
- Symptom: ASIC5 could produce a deterministic single-bin delay histogram when
  MTS lapse correction was bypassed, but the production-lapse path split the
  same physical hits into two or more delay bins. Changing the runtime
  `expected_latency` threshold did not move the split because that CSR only
  controls error classification after timestamp reconstruction.
- Root cause: the compiled `MUTRIG_OVERFLOW_LOOKBACK_8N` value owned the
  post-wrap epoch-disambiguation window. The old CSR map had no way to sweep
  that window on hardware, forcing rebuilds for a physical tuning parameter.
- Fix status: fixed in source, awaiting rebuilt FEB image and board A/B
  confirmation.
- Fix: add runtime CSR word `0x14` / word index `5` for
  `overflow_lookback` in 8 ns ticks. Writes are clamped to `0..6553` and update
  both `overflow_lookback_1n6` and `padding_upper`.
- Verification context:
  - VHDL smoke regression reads reset value `2000`, writes/reads `400`,
    verifies clamp of `7000` to `6553`, and restores `2000`.
  - CMSIS-SVD generation is deterministic against the checked-in
    `mts_processor.svd`.
  - Questa static lint/CDC/RDC passes with the `syn/quartus/mts_processor_static.f`
    context and static-only Intel ROM/divider blackboxes.
  - Standalone Quartus signoff on Arria V `5AGXBA7D4F31C5` passes at the
    tightened `7.273 ns` clock constraint: worst setup slack `+0.803 ns`, worst
    hold slack `+0.152 ns`.

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
