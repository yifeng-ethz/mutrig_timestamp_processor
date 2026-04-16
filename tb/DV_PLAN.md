# DV Plan: mutrig_timestamp_processor

**DUT:** `mts_processor`  
**RTL baseline:** [mts_processor.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/mts_processor.vhd:1)  
**Packaging baseline:** [mts_processor_hw.tcl](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/mts_processor_hw.tcl:1)  
**Legacy smoke bench:** [mts_processor_tb.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/mts_processor_tb.vhd:1)  
**Run-sequence reference:** [RUN_SEQ_UPGRADE_PLAN.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/RUN_SEQ_UPGRADE_PLAN.md:1)  
**Date:** 2026-04-15  
**Methodology:** Phase 0 DV plan package under the Claude DV workflow contract and the local Codex `dv-workflow` skill  
**Status:** Planning package for review before broad UVM implementation

## 1. Scope

This plan covers the standalone MuTRiG timestamp processor IP that:
- accepts `hit_type0` hits on an Avalon-ST sink,
- accepts 9-bit run-control words on a second Avalon-ST sink,
- exposes a small Avalon-MM CSR aperture,
- converts MuTRiG dark timestamps into `hit_type1` words by LUT decode, overflow-window padding, and divide-by-5,
- emits three observable output streams: `hit_type1_out`, `debug_ts`, `debug_burst`, and `ts_delta`.

In scope:
- CSR behavior implemented in `proc_avmm_csr`
- run-state decoding and processor-state transitions implemented in `proc_run_control_mgmt_agent` and `proc_processor_fsm`
- input acceptance, discard counting, and state gating
- timestamp conversion, `derive_tot`, `delay_ts_field_use_t`, `bypass_lapse`, and error-window behavior
- output marker behavior on `aso_hit_type1_{valid,startofpacket,endofpacket,channel,error}`
- current termination behavior and the planned upgrade obligations from `RUN_SEQ_UPGRADE_PLAN.md`
- packaging-visible parameter combinations that materially affect behavior

Out of scope for this plan set:
- full FEB-system integration outside the IP boundary
- analog front-end behavior
- PHY/LVDS capture
- Quartus timing closure itself

## 2. DUT Contract Summary

### 2.1 Functional datapath

The DUT performs the following staged transform:
1. accept `hit_type0` only when `processor_allow_input=1` and `hiterr` policy allows the beat,
2. decode `TCC` and `ECC` through `dual_port_rom`,
3. pad decoded MuTRiG timestamps into a 50-bit white-timestamp domain using the local overflow counter and the per-hit overflow-window latch,
4. divide by 5 to produce `tcc_8n` and `tcc_1n6`,
5. optionally derive `ET_1n6` when `csr.derive_tot=1`,
6. emit `hit_type1` with output routing channel equal to `"00" & hit_out.tcc_8n(5 downto 4)`.

### 2.2 Run-control contract

Current RTL behavior:
- `asi_ctrl_valid` decodes one-hot command words into `run_state_cmd`
- `asi_ctrl_ready` is hard-wired high today
- `processor_state` transitions between `IDLE`, `RESET`, `RUNNING`, and `FLUSHING`
- `RUN_PREPARE` drives `RESET/SCLR`
- `SYNC` drives `RESET/SYNC`
- `RUNNING` opens the datapath
- `TERMINATING` moves the processor into `FLUSHING`
- `IDLE` returns the processor to quiescent state

Upgrade intent from `RUN_SEQ_UPGRADE_PLAN.md`:
- `asi_ctrl_ready` should eventually acknowledge true completion of prepare/sync/termination work
- termination should be treated as a first-class downstream packet-boundary contract instead of a permanently-combinational ready

### 2.3 Observable quirks that the testbench must model honestly

The plan treats these as current DUT facts, not assumptions:
- `aso_hit_type1_ready` is present on the port list but is not consumed in RTL, so the source is effectively non-backpressurable today
- `aso_hit_type1_empty` is driven to `0` in all currently implemented paths
- `FRAME_CORRPT_BIT_LOC`, `CRCERR_BIT_LOC`, and `PADDING_EOP_WAIT_CYCLE` are generics but are not functionally consumed today
- `BANK` affects debug report strings only, not datapath behavior
- `mts_processor_hw.tcl` exposes `LPM_DIV_PIPELINE` default `2` while the VHDL generic default is `4`; DV must cover both compiled configurations

### 2.4 CSR contract

Implemented CSR words:
- `0x0`: control/status (`go`, `force_stop`, `soft_reset`, `bypass_lapse`, `discard_hiterr`, `op_mode[30:28]`)
- `0x4`: discarded-hit counter
- `0x8`: expected latency in 8 ns
- `0xC`: total hit count high
- `0x10`: total hit count low

Important semantic details:
- `go` reads back as live RUNNING-state indication, not the programmed bit value
- `soft_reset` self-clears
- `derive_tot` is `op_mode[30]`
- `delay_ts_field_use_t` is `op_mode[29]`
- `op_mode[28]` is currently unused

### 2.5 Legacy smoke coverage already present

The checked-in [mts_processor_tb.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/mts_processor_tb.vhd:1) proves a narrow but useful baseline:
- CSR write of `0x40000001` to enable `go` plus `derive_tot`
- direct `RUNNING` control command without full `RUN_PREPARE -> SYNC` cadence
- one positive `ET_1n6` expectation
- one `EFlag=0` mask-to-zero expectation
- one clamp-path expectation using a crafted raw-symbol pair

The new DV plan keeps that bench as smoke evidence but expands coverage to the full DUT contract.

## 3. Verification Objectives

1. Prove the current RTL contract exactly as implemented, including its non-backpressurable output and always-ready control sink.
2. Prove the timestamp-conversion datapath over accepted, discarded, reset, and overflow-window-sensitive traffic.
3. Prove `derive_tot`, `delay_ts_field_use_t`, `bypass_lapse`, and `expected_latency` independently and in combination.
4. Prove packet-marker behavior: first-hit `startofpacket`, delayed termination `endofpacket`, and the currently constant-zero `empty`.
5. Prove software-visible counters and status fields are coherent through reset, run, flush, and fault cases.
6. Prove the current termination behavior and isolate the exact cases that should change once the run-sequence upgrade lands.
7. Create a UVM harness specification that can drive real system-style run control rather than unit-only pulse sequences.

## 4. Planned Verification Architecture

The detailed harness contract is defined in [DV_HARNESS.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_HARNESS.md:1).

High-level architecture:

```text
CSR agent        ─┐
Run-control agent ├─> DUT mts_processor ──> hit_type1 monitor ──> scoreboard
hit_type0 agent   ┤                          ├─> debug_ts monitor
reset/clock agent ┘                          ├─> debug_burst monitor
                                              └─> ts_delta monitor

Bound SVA observes:
- AVMM CSR protocol
- run-control word stability
- hit_type0 acceptance and discard rules
- internal state / marker invariants
```

Two layers are planned:
- the existing VHDL smoke bench remains the shortest compile-and-run gate
- a UVM 1.2 environment becomes the main randomized and coverage-driven closure vehicle

## 5. Phase 0 Plan Files

| File | Purpose |
|---|---|
| [DV_PLAN.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_PLAN.md:1) | Top-level scope, objectives, references, and signoff gate |
| [DV_HARNESS.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_HARNESS.md:1) | UVM architecture, monitors, scoreboard model, SVA plan |
| [DV_BASIC.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_BASIC.md:1) | 130 baseline functional cases |
| [DV_EDGE.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_EDGE.md:1) | 130 boundary and corner cases |
| [DV_PROF.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_PROF.md:1) | 130 stress, throughput, and soak cases |
| [DV_ERROR.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_ERROR.md:1) | 130 fault, reset, and negative-protocol cases |
| [DV_CROSS.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_CROSS.md:1) | Functional coverage and cross-coverage contract |
| [DV_COV.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_COV.md:1) | Mandatory per-bucket coverage tables and execution-mode baselines |

## 6. Execution Modes

The maintained DV execution modes are:

1. `isolated`: default per-test timeframe with fresh DUT start
2. `bucket_frame`: continuous no-restart execution for every verification bucket in case-id order
3. `all_buckets_frame`: continuous no-restart execution across all sign-off buckets in bucket order, then case-id order

`bucket_frame` and `all_buckets_frame` are mandatory baselines for [DV_CROSS.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/DV_CROSS.md:1) and `DV_COV.md`.

Continuous-frame rules:
- directed cases execute one transaction per case
- random cases execute several transactions per case
- the DUT is not restarted between cases inside `bucket_frame` or `all_buckets_frame`

## 7. Coverage Targets

Planned closure targets:
- statement coverage above `95%`
- branch/FSM transition coverage above `90%`
- toggle coverage above `80%` on DUT-visible control, datapath, and marker signals
- functional coverage above `95%` for the coverpoints and crosses listed in `DV_CROSS.md`
- `DV_COV.md` complete for isolated, `bucket_frame`, and `all_buckets_frame`
- zero unexpected SVA failures in clean regressions

Required evidence items:
- merged UCDB or equivalent simulator coverage database
- per-testcase waveform capture for signature state/termination scenarios
- scoreboard-side traces for marker timing and timestamp conversion
- explicit pass/fail accounting for upgrade-gating cases from `RUN_SEQ_UPGRADE_PLAN.md`

## 8. Signoff Gate

Per the DV workflow contract, implementation should stop at plan signoff until the architect approves:
- the case taxonomy,
- the UVM harness contract,
- the explicit split between current-RTL facts and run-sequence upgrade targets,
- the coverage contract in `DV_CROSS.md`,
- and the execution-mode plus `DV_COV.md` contract.

After signoff, the next steps are:
1. retain the existing VHDL smoke bench as a fast sanity gate,
2. build the UVM scaffold described in `DV_HARNESS.md`,
3. implement the testcase groups in priority order,
4. then use the coverage results to drive the actual RTL/package upgrade work.
