# DV Plan: mutrig_timestamp_processor

**DUT:** `mts_processor`  
**RTL baseline:** [mts_processor.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/mts_processor.vhd:1)  
**Packaging baseline:** [mts_processor_hw.tcl](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/mts_processor_hw.tcl:1)  
**Legacy smoke bench:** [mts_processor_tb.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/mts_processor_tb.vhd:1)  
**Run-sequence reference:** [RUN_SEQ_UPGRADE_PLAN.md](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/RUN_SEQ_UPGRADE_PLAN.md:1)  
**Date:** 2026-07-15
**Methodology:** Maintained standalone VHDL smoke tests plus explicit-case UVM 1.2, static screening, and standalone synthesis signoff
**Status:** VERSION `26.5.0.0713` delta verified; the pre-release 521-case dashboard is reference evidence only until the full current-release regression is rerun

## 1. Scope

This plan covers the standalone MuTRiG timestamp processor IP that:
- accepts `hit_type0` hits on an Avalon-ST sink,
- accepts 9-bit run-control words on a second Avalon-ST sink,
- exposes a small Avalon-MM CSR aperture,
- converts MuTRiG dark timestamps into `hit_type1` words by LUT decode, overflow-window padding, and divide-by-5,
- emits the `hit_type1_out` payload stream, three diagnostic streams
  (`debug_ts`, `debug_burst`, and `ts_delta`), and co-valid 48-bit
  `hit_type1_ts`, `hit_arrival_gts`, and `hit_type1_latency_8n` conduits.

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
- FEB/system timing closure outside the standalone IP project

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
- the packaged run-control sink is readyless (`USE_READY=0`); no entity-level
  `asi_ctrl_ready` signal may be used to backpressure the broadcast tree
- `processor_state` transitions between `IDLE`, `RESET`, `RUNNING`, and `FLUSHING`
- `RUN_PREPARE` drives `RESET/SCLR`
- `SYNC` drives `RESET/SYNC`
- `RUNNING` opens the datapath
- `TERMINATING` moves the processor into `FLUSHING`
- `IDLE` returns the processor to quiescent state

Run-sequence obligation from `RUN_SEQ_UPGRADE_PLAN.md`:
- internal command acceptance must remain deterministic even though the external
  broadcast tree has no ready handshake
- termination remains a first-class downstream packet-boundary contract

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
- bit 6 defaults to `0` and selects the direct emission GTS used for physical
  hit lifetime; bit 6=`1` selects the divided overflow-base diagnostic
  coordinate and must never be described as physical lifetime

### 2.5 48-bit timestamp and lifetime contract

On every valid Type1 payload beat the DUT exports three co-sampled values:

- `hit_type1_ts`: the selected true hit timestamp, including all upper epoch
  carry bits;
- `hit_arrival_gts`: direct emission GTS by default, or the explicit bit-6
  diagnostic coordinate;
- `hit_type1_latency_8n = hit_arrival_gts - hit_type1_ts` modulo 48 bits.

In production mode (CSR bit 6=`0`) the signed interpretation of latency must be
nonnegative. A negative value is retained and reported as an upstream
run-SYNC/epoch/PLL fault; the bench must not mask, clamp, or wrap it into an
apparently valid physical delay. In diagnostic mode (bit 6=`1`) a signed
negative phase is intentional: `ov_base/5 - hit_ts = -in_frame_phase`. The
consumer may bin that diagnostic modulo the known 910-cycle frame period, but
must keep it distinct from hit lifetime. `RUN_PREPARE -> SYNC -> RUNNING`
restarts the local epoch, and directed DV checks the same diagnostic before and
after the SYNC edge.

### 2.5 Legacy smoke coverage already present

The checked-in [mts_processor_tb.vhd](/home/yifeng/packages/mu3e_ip_dev/mu3e-ip-cores/mutrig_timestamp_processor/tb/mts_processor_tb.vhd:1) proves a narrow but useful baseline:
- CSR write of `0x40000001` to enable `go` plus `derive_tot`
- direct `RUNNING` control command without full `RUN_PREPARE -> SYNC` cadence
- one positive `ET_1n6` expectation
- one `EFlag=0` mask-to-zero expectation
- one clamp-path expectation using a crafted raw-symbol pair

The new DV plan keeps that bench as smoke evidence but expands coverage to the full DUT contract.

## 3. Verification Objectives

1. Prove the current RTL contract exactly as implemented, including its non-backpressurable output and readyless control sink.
2. Prove the timestamp-conversion datapath over accepted, discarded, reset, and overflow-window-sensitive traffic.
3. Prove `derive_tot`, `delay_ts_field_use_t`, `bypass_lapse`, and `expected_latency` independently and in combination.
4. Prove packet-marker behavior: first-hit `startofpacket`, delayed termination `endofpacket`, and the currently constant-zero `empty`.
5. Prove software-visible counters and status fields are coherent through reset, run, flush, and fault cases.
6. Prove the current termination behavior and isolate the exact cases that should change once the run-sequence upgrade lands.
7. Create a UVM harness specification that can drive real system-style run control rather than unit-only pulse sequences.
8. Prove the 48-bit identity `latency = arrival - true_hit_ts` on every valid
   beat, upper-epoch carry above bit 31, nonnegative production lifetime, and
   retained signed-negative diagnostics.
9. Prove the 910-cycle diagnostic wrap and repeatability across the standard
   run-control SYNC edge.

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

VERSION `26.5.0.0713` is releasable only when all of the following are true:

1. the four standalone VHDL smoke targets pass;
2. the latency delta cases B020, B099, E035, E071, and X041 pass with zero
   unexpected UVM errors;
3. the full 521-case isolated and continuous-frame regression is rerun on the
   current RTL, or the dashboard states unambiguously that its older evidence
   is reference-only;
4. lint, CDC, and RDC report zero violations;
5. the standalone 137.5 MHz Quartus project passes fit and STA at every final
   device corner, followed by the maintained gate-level check;
6. no production-mode negative lifetime is waived or hidden.
