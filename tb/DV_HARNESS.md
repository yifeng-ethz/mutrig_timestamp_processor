# DV Harness Plan: mutrig_timestamp_processor

**Target:** `mts_processor`  
**Phase:** Architecture definition for signoff  
**Date:** 2026-04-15

## 1. Harness Goals

The harness must make these properties observable:
- CSR programming correctness and readback semantics
- legal and illegal run-control sequencing
- hit acceptance, discard, and state-gating behavior on `asi_hit_type0`
- exact timestamp conversion from accepted `hit_type0` to emitted `hit_type1`
- marker behavior on `startofpacket` and termination `endofpacket`
- debug side-stream correctness on `debug_ts`, `debug_burst`, and `ts_delta`
- software-visible counter correctness through reset and long runs
- current always-ready control behavior and the future stateful-ready upgrade cases from `RUN_SEQ_UPGRADE_PLAN.md`

The harness must preserve the checked-in VHDL smoke bench while adding a reusable UVM layer that can drive real system-like run-control traffic.

## 2. Planned Directory Layout

```text
tb/
  run_mts_processor_tb.sh      # existing smoke runner retained
  mts_processor_tb.vhd         # existing directed smoke bench retained
  DV_PLAN.md
  DV_HARNESS.md
  DV_BASIC.md
  DV_EDGE.md
  DV_PROF.md
  DV_ERROR.md
  DV_CROSS.md
  uvm/
    Makefile
    tb_top.sv
    mts_env_pkg.sv
    mts_env.sv
    mts_csr_agent/
    mts_ctrl_agent/
    mts_hit0_agent/
    mts_hit1_agent/
    mts_dbg_agent/
    mts_scoreboard.sv
    mts_coverage.sv
    mts_base_test.sv
    tests/
    sequences/
    sva/
      mts_avmm_sva.sv
      mts_ctrl_sva.sv
      mts_hit0_sva.sv
      mts_hit1_sva.sv
      mts_internal_sva.sv
```

## 3. Agent Model

### 3.1 CSR Agent

Protocol:
- Avalon-MM master toward the DUT `csr` slave

Responsibilities:
- apply control/status writes and reads
- model `waitrequest` timing exactly
- expose a register abstraction that understands the current readback quirks, especially `go` as live RUNNING-state status

Transaction fields:
- address
- access type
- write data
- expected read mask/value
- optional post-write dwell cycles

### 3.2 Run-Control Agent

Protocol:
- Avalon-ST source toward `run_ctrl`

Responsibilities:
- drive one-hot 9-bit run-control words
- support the legal backbone `IDLE -> RUN_PREPARE -> SYNC -> RUNNING -> TERMINATING -> IDLE`
- support legacy direct-to-`RUNNING` entry because current RTL allows it
- support illegal or premature transitions used by `DV_ERROR.md`

Transaction fields:
- command word
- pulse width
- inter-command dwell
- sequence label
- expected acknowledgement mode: `current_always_ready` or `post_upgrade_stateful_ready`

### 3.3 hit_type0 Agent

Protocol:
- Avalon-ST source toward `hit_type0_in`

Responsibilities:
- generate valid beats with independently controlled `startofpacket`, `endofpacket`, `channel`, `error`, and 45-bit data payload
- drive accepted and intentionally discarded hits
- align input traffic against processor state changes and control edges
- reproduce the existing smoke-bench vectors for quick sanity

Sequence item fields:
- `asic_id`
- data-path `channel` field
- sideband `asi_hit_type0_channel`
- raw `tcc`, raw `ecc`, `tfine`, `eflag`
- `startofpacket`, `endofpacket`
- `error[2:0]`
- valid gap / spacing

### 3.4 hit_type1 Monitor

Protocol:
- passive monitor on `hit_type1_out`

Responsibilities:
- reconstruct output transactions on every `valid` beat
- capture `startofpacket`, `endofpacket`, `channel`, `error`, and `empty`
- record whether output emission occurred while sink `ready` was high or low, because current RTL ignores `ready`
- publish transactions to scoreboard and coverage

Observed transaction fields:
- output data fields (`asic`, `channel`, `tcc_8n`, `tcc_1n6`, `tfine`, `et_1n6`)
- route channel (`"00" & tcc_8n(5:4)`)
- `startofpacket`
- `endofpacket`
- `empty`
- `error`
- cycle timestamp

### 3.5 Debug Monitor

Protocol:
- passive monitors on `debug_ts`, `debug_burst`, and `ts_delta`

Responsibilities:
- correlate side-stream timing with `hit_out.valid`
- capture `debug_ts` range checks against programmed `expected_latency`
- capture delta and sign behavior in `debug_burst` and `ts_delta`

## 4. Scoreboard Model

The scoreboard is split into seven layers.

### 4.1 Acceptance model

Mirror:
- `processor_state`
- `reset_flow`
- `processor_allow_input`
- `csr.force_stop`
- `csr.discard_hiterr`

This layer predicts whether each input beat should be:
- accepted,
- dropped for state reasons,
- dropped for `hiterr`,
- or counted only in `total_hit_cnt`.

### 4.2 ROM decode model

The scoreboard must read [dual_port_rom_init.txt](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/dual_port_rom_init.txt:1) and mirror the same dark-to-gray mapping that the DUT applies through `dual_port_rom`.

### 4.3 White-timestamp padding model

Mirror:
- the local MTS counter behavior with the 5-tick stride
- the overflow-window latch behavior via `tot_t_adjust` and `tot_e_adjust`
- the `bypass_lapse` mode
- `expected_latency_1n6` and `padding_upper`

This layer is mandatory because many meaningful corner cases only appear around overflow-window compensation.

### 4.4 Divide and ET model

Mirror:
- `divide-by-5` quotient and remainder
- `derive_tot`
- `delay_ts_field_use_t`
- ET masking when `EFlag=0`
- ET clamp/saturation paths documented by the current smoke bench and the RTL comments

### 4.5 Output-marker model

Mirror:
- `startofrun_sent`
- `packet_in_transaction`
- delayed termination EOP through `terminating_eop_pipe`
- route channel selection from `tcc_8n(5:4)`
- current constant-zero `empty`

### 4.6 Debug/error model

Mirror:
- `debug_ts = counter_gts_8n - selected_timestamp`
- `aso_hit_type1_error` range check against `expected_latency`
- `debug_burst` trimmed delta fields
- `ts_delta` sign-magnitude to two's-complement conversion

### 4.7 Upgrade-gating model

A secondary checker tracks the obligations from `RUN_SEQ_UPGRADE_PLAN.md`:
- `asi_ctrl_ready` must become stateful after the upgrade
- termination acknowledgement must be deferred until local drain work is complete
- terminal packet-boundary propagation must be explicit and deterministic

These checks are expected to fail on current RTL for the upgrade-only cases and must therefore be separately tagged in regressions.

## 5. Planned SVA Modules

### 5.1 `mts_avmm_sva.sv`

Checks:
- no X/Z on CSR bus signals
- `waitrequest` deassertion only when a read or write is actually accepted
- read/write overlap is either forbidden by the driver or flagged
- stable address/data during an accepted transfer

### 5.2 `mts_ctrl_sva.sv`

Checks:
- run-control data stable while `valid=1`
- one-hot legal command in positive tests
- current `asi_ctrl_ready` high behavior captured as a known fact
- post-upgrade readiness checks enabled by test knob for upgrade-gating cases

### 5.3 `mts_hit0_sva.sv`

Checks:
- no X/Z on `hit_type0` valid/data/error/marker inputs
- `valid` beats remain stable for one cycle when the driver presents them
- sideband/data consistency assertions for tests that require it

### 5.4 `mts_hit1_sva.sv`

Checks:
- `startofpacket` only when `valid=1`
- `endofpacket` only when `valid=1`
- `empty` remains low in current RTL
- optional checker that records output emission while `ready=0` to document the current non-backpressure contract

### 5.5 `mts_internal_sva.sv`

Checks:
- legal `processor_state` and `reset_flow` transitions
- `asi_hit_type0_ready` matches state-machine intent
- accepted terminating EOP creates a delayed output EOP pulse
- `startofrun_sent` sets once per enabled channel and clears in reset
- `packet_in_transaction` only toggles on accepted SOP/EOP beats

## 6. Transaction And Sequence Strategy

The default system-level sequence mirrors the real run-control cadence:
1. hold reset,
2. release to `IDLE`,
3. send `RUN_PREPARE`,
4. send `SYNC`,
5. send `RUNNING`,
6. drive `hit_type0`,
7. send `TERMINATING`,
8. wait for terminal behavior,
9. send `IDLE`.

Additional sequence families:
- legacy direct-to-`RUNNING`
- abort-to-`IDLE`
- `force_stop` under load
- `soft_reset` under load
- output-sink `ready` throttling even though the current DUT ignores it
- packaging/generic sweeps such as `LPM_DIV_PIPELINE=2` and `LPM_DIV_PIPELINE=4`

## 7. Coverage Hooks

Coverage implementation must map directly to [DV_CROSS.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_CROSS.md:1):
- run-control and processor-state coverpoints
- CSR mode/control coverpoints
- input acceptance and discard coverpoints
- timestamp remainder/route/error coverpoints
- marker and termination coverpoints
- debug-stream delta/sign coverpoints

Every testcase added later must name the bins it is expected to hit.

## 8. Bring-Up Order

1. keep `run_mts_processor_tb.sh` and `mts_processor_tb.vhd` as the first smoke gate,
2. implement `tb_top.sv` plus interfaces and SVA bind points,
3. implement monitors and scoreboard before randomized sequences,
4. bring up a narrow deterministic subset that reproduces the existing smoke vectors,
5. then expand into the full `DV_BASIC`, `DV_EDGE`, `DV_PROF`, and `DV_ERROR` buckets.
