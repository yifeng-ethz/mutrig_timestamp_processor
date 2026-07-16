# Changelog

## 26.6.0.0716 - 2026-07-16

- Added the opt-in `USE_EXTERNAL_EPOCH_RESET` generic and conditional
  `epoch_reset` Platform Designer conduit. The conduit is synchronous to the
  MTS clock and resets only the MTS/GTS timestamp epoch state.
- Preserved the legacy `processor_state=RESET` plus `reset_flow=SYNC` epoch
  reset behavior as the default elaborated implementation. `csr.soft_reset`
  remains effective in both configurations.
- Added a dual-instance directed VHDL regression that compares legacy and
  external epoch release, then proves both instances converge after a shared
  CSR soft-reset pulse. Full DV and standalone synthesis closure remain to be
  recorded in the release reports.

## 26.5.0.0713 - 2026-07-13

- Added co-valid 48-bit `hit_type1_ts`, selected arrival GTS, and
  `hit_type1_latency_8n` outputs. Latency is computed inside MTS as
  `arrival - true_hit_timestamp` on the same Type1 beat, preserving all upper
  epoch carry bits.
- Kept CSR control/status bit 6 default-low for direct emission GTS and
  nonnegative physical hit lifetime. A signed-negative production result is
  retained as an upstream PLL/run-SYNC/epoch diagnostic and is never hidden,
  clamped, or relabeled as valid transport latency.
- Added the explicit bit-6 overflow-base diagnostic coordinate using a third
  divide-by-5 path. In that mode the signed result is
  `ov_base/5 - hit_ts = -in_frame_phase`; it is diagnostic phase rather than
  physical lifetime.
- Updated Platform Designer packaging, CSR metadata, CMSIS-SVD, standalone
  wrappers, VHDL smoke benches, and UVM monitor/scoreboard surfaces for the new
  conduit.
- Added directed closure for CSR selection, 48-bit identity and carry,
  retained negative fault diagnostics, a 910-cycle frame wrap (`-900` to bin
  10), and repeatability across the run-control SYNC edge.
- Corrected the UVM default source-channel encoding so requested ASIC slots are
  driven in AVST channel bits `[5:4]`, and corrected B099 nominal stimulus so it
  no longer creates a future hit timestamp after SYNC.
- Current release delta status: four maintained VHDL smoke targets pass; B020,
  B099, E035, E071, and X041 pass with zero UVM errors/fatals; Questa static
  screen reports lint 0, CDC 0, and RDC 0. Full 521-case and standalone
  synthesis/gate-level closure are tracked as pending in the reports.

## 26.2.0.0511 - 2026-05-11

- Dropped `asi_ctrl_ready` from the `run_ctrl` AVST sink at the
  `mts_processor` entity boundary and from the `_hw.tcl` interface port list
  so the sink matches the readyless `USE_READY=0` rc-network contract
  advertised by `runctl_mgmt_host`. Qsys no longer auto-inserts an
  `altera_avalon_st_timing_adapter` on the rc fan-out for this IP.
- Preserved the internal `ctrl_ready_comb` FSM gate that drives the
  run-command capture process (`asi_ctrl_valid AND ctrl_ready_comb`) and
  the `status_v(11)` field; only the entity-level driver
  `asi_ctrl_ready <= ctrl_ready_comb;` was removed.
- Validated against the FEB v3 integration `tb_int` regression
  (`B065`/`B066`/`B067`/`B068`/`B069` plus the directed `RC_EMUL` run); all
  six tests reported `*** TEST PASSED ***` with zero UVM errors.

## 26.1.0.0506 - 2026-05-06

- Added the DEBUG sidecar contract for `mts_processor`: `DEBUG>=1` exposes a
  packed synthesizable status conduit, and `DEBUG>=2` propagates a 64-bit
  per-hit sidecar from accepted `hit_type0` payload beats to delivered
  `hit_type1` payload beats.
- Kept `DEBUG=0` nominal payload behavior unchanged, with deterministic zero
  tieoffs on the new debug-status and sidecar outputs.
- Updated Platform Designer packaging to materialize the new conduits only at
  the requested DEBUG levels.

## 26.0.0404 - 2026-04-14

- Reset the MuTRiG and global timestamp counter state on `i_rst` so the
  overflow multiplier and white-timestamp path no longer start from unknown
  values in standalone simulation.
- Reworked the white-timestamp combinational math to use local variables, which
  removes delta-cycle `X` propagation from the padded timestamp outputs in
  simulation.
- Clamp negative derived ToT to zero using an explicit operand comparison and
  keep the existing saturation to `511` on positive overflow.
- Updated the standalone TB to match the current scalar sideband ports and
  report ET mismatches with the observed field value.

## 26.0.0403 - 2026-04-13

- Disabled Quartus auto shift-register inference on the shallow `hit_div` and
  `terminating_eop_pipe` delay lines so the standalone signoff build keeps them
  in flip-flops instead of `altshift_taps`.
- Closed the standalone `mts_processor` setup path that previously ran from the
  terminating EOP delay chain into the divider metadata pipeline.
- Bumped the packaged IP version and aligned the CMSIS-SVD version metadata to
  the new delivery.
