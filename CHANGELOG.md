# Changelog

## 26.0.9.0501 - 2026-05-01

- Added CSR word `0x14` / word index `5` as a runtime
  `overflow_lookback` register in 8 ns ticks.
- Runtime writes now update the 1.6 ns overflow-lookback window and the
  padding threshold together, clamped to `0..6553`, so Phase-6 hardware tuning
  can separate MuTRiG PLL/TDC behavior from MTS lapse-window classification.
- Updated the CMSIS-SVD, board-bring-up CSR metadata, Platform Designer
  register-map HTML, VHDL smoke bench, and standalone synthesis harness to
  cover the new register.

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
