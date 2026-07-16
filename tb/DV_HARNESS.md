# DV Harness Plan: mutrig_timestamp_processor

**Target:** `mts_processor`  
**Phase:** Implemented harness, VERSION `26.5.0.0713` delta closure
**Date:** 2026-07-15

## 1. Harness Goals

The harness must make these properties observable:
- CSR programming correctness and readback semantics
- legal and illegal run-control sequencing
- hit acceptance, discard, and state-gating behavior on `asi_hit_type0`
- exact timestamp conversion from accepted `hit_type0` to emitted `hit_type1`
- marker behavior on `startofpacket` and termination `endofpacket`
- debug side-stream correctness on `debug_ts`, `debug_burst`, and `ts_delta`
- software-visible counter correctness through reset and long runs
- the readyless run-control boundary and internal command-state behavior from `RUN_SEQ_UPGRADE_PLAN.md`
- the co-valid 48-bit true timestamp, selected arrival coordinate, and latency identity

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
- 48-bit `hit_type1_ts`
- 48-bit `hit_arrival_gts`
- 48-bit `hit_type1_latency_8n`
- cycle timestamp

### 3.5 Debug Monitor

Protocol:
- passive monitors on `debug_ts`, `debug_burst`, and `ts_delta`

Responsibilities:
- correlate side-stream timing with `hit_out.valid`
- capture `debug_ts` range checks against programmed `expected_latency`
- capture delta and sign behavior in `debug_burst` and `ts_delta`
- publish a dedicated debug analysis stream into the scoreboard. This is not
  optional bring-up logging; every payload hit observed on the normal
  `hit_type1` path must have a matching `debug_ts` sample, and the scoreboard
  treats missing or misaligned debug samples as a closure blocker.
- on every Type1 payload beat, check the independent conduit identity
  `latency48 == arrival_gts48 - true_hit_ts48` modulo 48 bits
- interpret signed-negative production lifetime as a retained upstream
  epoch/run-SYNC/PLL diagnostic, never as a valid physical delay
- allow signed-negative values only for explicit fault injection or CSR-bit-6
  overflow-base diagnostic tests

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

### 4.6 Debug/error and 48-bit lifetime model

Mirror:
- production lifetime `counter_gts_8n - selected_true_timestamp`
- debug-coordinate latency `counter_ov_base_1n6/5 - selected_true_timestamp`
  only when CSR bit 6 is set
- `aso_hit_type1_error` range check against `expected_latency`
- `debug_burst` trimmed delta fields
- `ts_delta` sign-magnitude to two's-complement conversion

The implemented UVM scoreboard now runs a dual-path cross-check:
- normal path: accepted `hit_type1` payload beats from the output monitor
- debug path: `debug_ts`, `debug_burst`, and `ts_delta` observations from the
  debug monitor
- CSR path: writes to `EXPECTED_LATENCY` update the scoreboard math window
- input path: accepted `hit_type0` beats provide the checkpoint count

For each normal payload beat, the scoreboard pairs the next `debug_ts` sample
at the same simulation time, records a per-hit trace entry, and recomputes the
timestamp-delay error from `debug_ts` and the current latency CSR. A mismatch
between that math result and `aso_hit_type1_error` is a `UVM_ERROR`.

The Type1 monitor also performs an unconditional 48-bit identity check. In
production mode a signed-negative result is a `UVM_ERROR` unless the testcase
has enabled its short directed-fault window. The raw value is still counted and
reported; no clamp or absolute-value conversion is permitted. The X041 delta
test selects CSR bit 6, proves `-900` exactly, maps it to diagnostic frame bin
10 with a 910-cycle modulus, and repeats the result after a standard SYNC.

### 4.7 Run-control gating model

A secondary checker tracks the obligations from `RUN_SEQ_UPGRADE_PLAN.md`:
- the external run-control sink remains readyless and cannot drop a legal
  command because of an unobservable local ready state
- local drain work completes before terminal packet-boundary propagation
- terminal packet-boundary propagation is explicit and deterministic

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
- no ready signal is assumed at the entity boundary
- legal commands are captured exactly once by the readyless sink

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
- `hit_type1_latency_8n == hit_arrival_gts_8n - hit_type1_ts` on every valid payload beat

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
- 48-bit carry, arrival-coordinate selection, production-lifetime sign, and
  910-cycle diagnostic-wrap coverpoints

Every testcase added later must name the bins it is expected to hit.

## 8. Current Execution Order

1. run the four maintained VHDL smoke targets;
2. compile the UVM harness and run B020/B099/E035/E071/X041;
3. run the complete documented-case and continuous-frame regression;
4. regenerate `DV_REPORT.json`, `DV_REPORT.md`, `DV_COV.md`, and `REPORT/`
   from the report generator;
5. run static and standalone synthesis/timing closure.
