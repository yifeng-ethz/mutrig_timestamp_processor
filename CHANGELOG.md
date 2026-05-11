# Changelog

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
