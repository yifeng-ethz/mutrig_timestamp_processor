# DV Cross Coverage — mutrig_timestamp_processor

**Purpose:** functional cross-coverage contract for `mts_processor`  
**Date:** 2026-04-15

## 1. Core Coverpoints

### 1.1 Run And State

| Coverpoint | Bins |
|---|---|
| `cp_run_cmd` | `idle`, `run_prepare`, `sync`, `running`, `terminating`, `link_test`, `sync_test`, `reset`, `out_of_daq`, `illegal_other` |
| `cp_processor_state` | `idle`, `reset`, `running`, `flushing`, `error_other` |
| `cp_reset_flow` | `sclr`, `sync`, `done` |
| `cp_ctrl_ready_mode` | `current_always_ready`, `post_upgrade_stateful_ready` |

### 1.2 CSR And Configuration

| Coverpoint | Bins |
|---|---|
| `cp_go` | `clear`, `set` |
| `cp_force_stop` | `clear`, `set` |
| `cp_soft_reset` | `clear`, `pulse` |
| `cp_discard_hiterr` | `discard`, `keep` |
| `cp_bypass_lapse` | `off`, `on` |
| `cp_derive_tot` | `short_mode`, `tot_mode` |
| `cp_delay_ts_field` | `use_t`, `use_e` |
| `cp_expected_latency_cfg` | `zero`, `small`, `default_2000`, `large`, `max_word` |
| `cp_lpm_div_pipeline_cfg` | `rtl_default_4`, `hw_tcl_default_2`, `other_override` |

### 1.3 Input Acceptance

| Coverpoint | Bins |
|---|---|
| `cp_input_kind` | `plain_hit`, `sop_hit`, `eop_hit`, `sop_eop_hit` |
| `cp_input_accept` | `accepted`, `discard_hiterr`, `discard_state`, `discard_force_stop` |
| `cp_hiterr_bit` | `clear`, `set` |
| `cp_input_sideband_channel` | `asic0_3`, `asic4_15`, `mux_nonzero` |
| `cp_enabled_window` | `default_0_3`, `single_channel`, `upper_half`, `custom_span` |

### 1.4 Timestamp Conversion

| Coverpoint | Bins |
|---|---|
| `cp_padding_mode` | `normal`, `overflow_adjust_t`, `overflow_adjust_e`, `bypass` |
| `cp_div_remainder` | `r0`, `r1`, `r2`, `r3`, `r4` |
| `cp_route_channel` | `lane0`, `lane1`, `lane2`, `lane3` |
| `cp_et_kind` | `masked_eflag0`, `positive`, `zero_negative_clamp`, `saturated_511` |
| `cp_debug_ts_window` | `negative`, `zero`, `in_range`, `above_expected` |

### 1.5 Output Markers And Debug

| Coverpoint | Bins |
|---|---|
| `cp_output_kind` | `quiet`, `hit_only`, `hit_plus_sop`, `hit_plus_eop` |
| `cp_output_ready_level` | `ready_high`, `ready_low_ignored` |
| `cp_empty_behavior` | `always_zero` |
| `cp_debug_burst_sign` | `positive`, `negative`, `zero` |
| `cp_ts_delta_sign` | `positive`, `negative`, `zero` |

### 1.6 Termination Upgrade

| Coverpoint | Bins |
|---|---|
| `cp_term_path` | `running_to_flushing`, `flushing_to_idle`, `direct_idle_abort`, `upgrade_ack_pending` |
| `cp_term_eop_seen` | `no`, `yes` |
| `cp_term_boundary_kind` | `real_input_eop`, `missing_boundary`, `planned_synthetic_boundary` |
| `cp_upgrade_result` | `current_expected_fail`, `post_patch_pass` |

## 2. Mandatory Crosses

| Cross ID | Cross | Required outcome |
|---|---|---|
| `XC01` | `cp_run_cmd x cp_processor_state` | Legal transitions covered and illegal paths tagged separately |
| `XC02` | `cp_run_cmd x cp_ctrl_ready_mode` | Current always-ready behavior documented, upgrade-ready bins reserved |
| `XC03` | `cp_go x cp_run_cmd x cp_input_accept` | `go` gating proven across direct-run and standard-run sequences |
| `XC04` | `cp_force_stop x cp_input_accept` | Force-stop blocks fresh acceptance without corrupting counters |
| `XC05` | `cp_soft_reset x cp_processor_state` | Soft-reset interaction covered in idle, run, and flushing contexts |
| `XC06` | `cp_discard_hiterr x cp_hiterr_bit x cp_input_accept` | Discard policy proven for both accepted and rejected error beats |
| `XC07` | `cp_bypass_lapse x cp_padding_mode` | Bypass and padded modes both observed |
| `XC08` | `cp_derive_tot x cp_et_kind` | Short-mode zeroing and ToT-mode derivation both covered |
| `XC09` | `cp_delay_ts_field x cp_debug_ts_window` | T-path and E-path delay checks both exercised |
| `XC10` | `cp_expected_latency_cfg x cp_debug_ts_window` | Error window proven at zero/small/default/large extremes |
| `XC11` | `cp_input_kind x cp_input_accept` | SOP/EOP/plain combinations covered for accepted and rejected traffic |
| `XC12` | `cp_div_remainder x cp_route_channel` | Quotient/remainder and route-lane mapping covered together |
| `XC13` | `cp_output_kind x cp_output_ready_level` | Current no-backpressure contract explicitly covered |
| `XC14` | `cp_output_kind x cp_empty_behavior` | `empty` remains zero across all current output forms |
| `XC15` | `cp_debug_burst_sign x cp_ts_delta_sign` | Burst-delta and ts-delta sign agreement covered |
| `XC16` | `cp_enabled_window x cp_output_kind` | Enabled-channel parameterization covered against marker behavior |
| `XC17` | `cp_lpm_div_pipeline_cfg x cp_div_remainder` | Both packaging defaults covered against actual math outcomes |
| `XC18` | `cp_term_path x cp_term_eop_seen x cp_term_boundary_kind` | Termination paths and boundary observation covered |
| `XC19` | `cp_term_path x cp_upgrade_result` | Current expected-fail upgrade bins remain explicit until RTL changes |
| `XC20` | `cp_run_cmd x cp_term_boundary_kind x cp_output_kind` | Terminal marker behavior tied back to the control phase |

## 3. Error-Bin Expectations

These bins must be empty in clean regressions and intentionally hit only by `DV_ERROR.md` cases:

| Bin | Meaning |
|---|---|
| `cp_processor_state.error_other` | Illegal or unknown processor-state encoding observed |
| `cp_run_cmd.illegal_other` | Illegal control word accepted as a legal command |
| `cp_input_accept.discard_state` during legal running | State machine dropped an otherwise legal running hit |
| `cp_debug_ts_window.negative` in clean nominal traffic | Selected timestamp path went past the global timestamp |
| `cp_debug_ts_window.above_expected` in clean nominal traffic | Error window tripped unexpectedly |
| `cp_term_boundary_kind.missing_boundary` in post-patch clean runs | Terminal boundary was lost |
| `cp_upgrade_result.post_patch_pass` before RTL upgrade | Upgrade-only bins accidentally appear green too early |

## 4. Closure Rules

1. Every non-error bin in Sections 1.1 through 1.5 must be hit by passing tests.
2. Every legal bin in `XC01` through `XC18` must be hit by passing tests.
3. `XC19` and `XC20` must show both current-RTL evidence and reserved post-patch evidence.
4. Coverage is not closed until both `LPM_DIV_PIPELINE=4` and packaged `LPM_DIV_PIPELINE=2` builds have been sampled.
5. Current-RTL quirks such as ignored output `ready` and constant-zero `empty` must be treated as covered facts, not silently abstracted away.
6. `bucket_frame` and `all_buckets_frame` are mandatory `DV_CROSS` baselines:
   - each bucket-frame run executes cases in case-id order without restarting the DUT between cases
   - the all-buckets-frame run executes buckets in bucket order and cases in case-id order without restarting the DUT between cases
   - directed cases contribute one transaction per case in these continuous frames
   - random cases contribute several transactions per case in these continuous frames

## 5. Evidence Artifacts

The regression flow should archive:
- merged coverage database,
- isolated-run merged coverage database(s) used by `DV_COV.md`,
- bucket-frame merged coverage database(s) used as `DV_CROSS` baseline,
- all-buckets-frame merged coverage database used as `DV_CROSS` baseline,
- scoreboard transaction traces for accepted and discarded input beats,
- a route-channel histogram,
- a remainder histogram,
- termination-boundary waveforms for current and upgrade-gating cases.
