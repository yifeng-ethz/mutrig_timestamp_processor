# Standalone Quartus Signoff

## 2026-05-11 - VERSION 26.1.0.0506

Verdict: PASS.

This signoff covers the current `mutrig_timestamp_processor` IP source at
VERSION `26.1.0.0506`. No older IP version was used, and the package VERSION was
not downgraded or bumped.

The standalone project is `syn/quartus/mts_processor_syn.qpf`, revision
`mts_processor_syn`, top `mts_processor_syn_top`, device `5AGXBA7D4F31C5`
(`Arria V`). The nominal IP clock target is 125 MHz. The standalone signoff
constraint is the 1.1x target, `F_signoff = 137.5 MHz`, implemented as
`create_clock -period 7.273` in `syn/quartus/mts_processor_syn.sdc`.

Quartus 18.1 for this Arria V device reports the final four setup timing models
as Slow 1100 mV 85 C, Slow 1100 mV 0 C, Fast 1100 mV 85 C, and Fast 1100 mV
0 C. Those are the device-specific final signoff corners used below.

## Build Evidence

| Item | Result |
|---|---|
| Quartus command | `quartus_sh --flow compile mts_processor_syn -c mts_processor_syn` |
| Tool | Quartus Prime 18.1.0 Build 625 Standard Edition |
| Build timestamp | started 2026-05-11 10:54:09, successful 2026-05-11 10:56:15 |
| Flow report | `syn/quartus/output_files/mts_processor_syn.flow.rpt`; archived as `syn/quartus/signoff_reports/mts_processor_syn.flow_20260511.log` |
| FIT summary | `syn/quartus/output_files/mts_processor_syn.fit.summary`; archived as `syn/quartus/signoff_reports/mts_processor_syn.fit_summary_20260511.log` |
| STA summary | `syn/quartus/output_files/mts_processor_syn.sta.summary`; archived as `syn/quartus/signoff_reports/mts_processor_syn.sta_summary_20260511.log` |
| Result | Full compilation successful, 0 errors, warnings only |

Resource snapshot from the fitted standalone revision:

| Resource | Fitted usage |
|---|---:|
| Logic utilization | 1,156 / 91,680 ALMs (1%) |
| Registers | 1,960 |
| Block memory bits | 491,670 / 13,987,840 (4%) |
| RAM blocks | 62 / 1,366 (5%) |
| DSP blocks | 0 / 800 (0%) |

## Setup Slack

Standalone signoff requires setup slack >= 0 ns at all four final timing
models. All corners pass.

| Corner | Worst setup slack | TNS | Clock | Explicit report_timing log |
|---|---:|---:|---|---|
| Slow 1100 mV 85 C | +1.518 ns | 0.000 ns | `clk` | `syn/quartus/signoff_reports/mts_processor_syn_sta_slow_1100mv_85c.report_timing.log` |
| Slow 1100 mV 0 C | +1.496 ns | 0.000 ns | `clk` | `syn/quartus/signoff_reports/mts_processor_syn_sta_slow_1100mv_0c.report_timing.log` |
| Fast 1100 mV 85 C | +3.879 ns | 0.000 ns | `clk` | `syn/quartus/signoff_reports/mts_processor_syn_sta_fast_1100mv_85c.report_timing.log` |
| Fast 1100 mV 0 C | +4.142 ns | 0.000 ns | `clk` | `syn/quartus/signoff_reports/mts_processor_syn_sta_fast_1100mv_0c.report_timing.log` |

Worst overall setup corner: Slow 1100 mV 0 C, `clk`, +1.496 ns.

Worst setup path at the worst corner:

| Field | Value |
|---|---|
| From | `mts_processor:u_dut|lpm_divide:ecc_div|lpm_divide_1sq:auto_generated|sign_div_unsign_77i:divider|alt_u_div_6af:divider|DFFStage[2]` |
| To | `mts_processor:u_dut|lpm_divide:ecc_div|lpm_divide_1sq:auto_generated|sign_div_unsign_77i:divider|alt_u_div_6af:divider|op_15~0_OTERM605_OTERM739` |
| Data arrival time | 9.345 ns |
| Data required time | 10.841 ns |
| Slack | +1.496 ns |

Pre-fit expectation was that the generated divider pipeline would own the top
standalone setup path. The fitted top setup paths are all inside the generated
`ecc_div` divider cone, so the result matches the expected bottleneck and does
not indicate a wrapper or integration-only owner.

## Static Screen

Command:

```bash
python3 ~/.codex/skills/rtl-linter-and-checker/scripts/questa_static_screen.py \
  --top mts_processor_syn_top \
  --filelist syn/quartus/mts_processor_static.f \
  --pre-do syn/quartus/questa_lpm_pre.do \
  --extra-do syn/quartus/questa_static_extra.do \
  --work-dir syn/quartus/questa_static_20260511 \
  --modes lint,cdc,rdc \
  mts_processor.vhd
```

Evidence log: `syn/quartus/questa_static_20260511/questa_static_screen.log`;
archived as
`syn/quartus/signoff_reports/mts_processor_syn.questa_static_screen_20260511.log`.

| Check | Result |
|---|---|
| Questa Lint | Error (0) |
| Questa CDC | Violations (0) |
| Questa RDC | Violation (0) |

## Notes

The first 2026-05-11 compile attempt stopped in Analysis and Synthesis because
Quartus 18.1 does not accept the VHDL `to_hstring` helper in a DEBUG report
string. The current source keeps the same DEBUG message field through a local
hex formatter, then the same standalone signoff project compiles and passes
STA. This is a compile-compatibility edit only; it does not change the datapath
or the packaged VERSION.

The Timing Analyzer reports the standalone harness I/O as not fully constrained,
which is expected for this mini-project because no board I/O timing contract is
claimed here. The internal `clk` domain setup and hold paths are constrained by
the 7.273 ns signoff clock and report nonnegative slack.
