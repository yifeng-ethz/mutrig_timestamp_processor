# RTL Note — `mutrig_timestamp_processor` 26.6.0.0716

**Status:** current-source physical closure and full UVM rerun pending.

## Signoff Profile

The production standalone profile is now explicit in
`syn/quartus/mts_processor_syn_top.vhd`:

- `USE_EXTERNAL_EPOCH_RESET => true`;
- `coe_epoch_reset` receives a registered three-clock synchronous pulse
  coincident with each generated `SYNC` control command;
- the pulse repeats after the stimulus counter wraps its low 11 bits, rather
  than being equivalent to global reset;
- the epoch pulse and all bits of the 48-bit timestamp, arrival-GTS, and
  latency conduits contribute to `activity_probe`.

`syn/quartus/mts_processor_syn.qsf` and
`syn/quartus/mts_processor_static.f` both compile `mts_processor.vhd` plus the
same standalone wrapper.  The QSF also supplies the ROM implementation and
initialization file required by Quartus; the static screen deliberately uses
its simulation stub.

## DV Inventory

The release inventory is 521 explicit UVM cases plus five maintained VHDL
targets.  The VHDL targets invoke `vsim` six times because ASIC-ID is checked
once for UP and once for DW.  The added external-epoch target is VHDL-only and
does not change the UVM case count.

Archived 521-case artifacts produced before the 26.6 external-epoch source
change remain useful regression history, but they are not current-source
closure.  A fresh exact-source 521-case run and the five continuous-frame runs
must be recorded before release PASS is claimed.

## Pre-Fit Expectations

The signoff clock is 137.5 MHz (`7.273 ns`) on Arria V
`5AGXBA7D4F31C5`, using Standard Fit and seed 1.  The historical resource model
is 1,156 ALMs, 1,960 registers, 491,670 memory bits, 62 RAM blocks, and no DSPs;
the auditable 50%–300% bounds are recorded in `RTL_PLAN.md`.  Generated divider
logic is expected to remain the critical-path owner.  A path dominated by the
external epoch fanout or registered pulse compare requires review.

## Evidence Ledger

| Gate | Current state | Required evidence |
|---|---|---|
| Five maintained VHDL targets / six `vsim` invocations | PASS | `make -C tb run_all`, exit 0 on 2026-07-16 |
| `_hw.tcl` HDL-port validation | PASS, 3/3 | `make -C tb/uvm hw_tcl_validate_check` |
| Standalone lint/CDC/RDC | PASS, 0/0/0 | `syn/quartus/questa_static_20260716_external_profile/questa_static_screen.log` |
| 521 explicit UVM cases | pending | exact-source case logs and aggregate hashes |
| Five continuous-frame UVM runs | pending | exact-source frame logs and coverage DBs |
| Quartus Standard Fit and resources | pending | new flow and fit reports |
| Setup/hold at every final corner | pending | new STA summary and explicit timing reports |
| Gate signature smoke | pending | zero-delay RTL/netlist comparison log |

No Quartus compile, full 521-case UVM regression, or gate simulation result is
claimed by this note.  The maintained gate flow is a zero-delay functional
signature comparison without SDF and is not full gate-level DV.
