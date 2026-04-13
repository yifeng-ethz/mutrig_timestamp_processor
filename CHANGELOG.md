# Changelog

## 26.0.0403 - 2026-04-13

- Disabled Quartus auto shift-register inference on the shallow `hit_div` and
  `terminating_eop_pipe` delay lines so the standalone signoff build keeps them
  in flip-flops instead of `altshift_taps`.
- Closed the standalone `mts_processor` setup path that previously ran from the
  terminating EOP delay chain into the divider metadata pipeline.
- Bumped the packaged IP version and aligned the CMSIS-SVD version metadata to
  the new delivery.
