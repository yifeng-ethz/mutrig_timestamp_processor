# Changelog

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
