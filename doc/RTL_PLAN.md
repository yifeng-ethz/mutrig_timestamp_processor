# RTL Plan — `mutrig_timestamp_processor`

**Release profile:** `26.6.0.0716`  
**Device:** Arria V `5AGXBA7D4F31C5`  
**Nominal clock:** 125 MHz  
**Standalone signoff clock:** 137.5 MHz (`7.273 ns`, 1.1× nominal)

## Scope

The standalone revision is `syn/quartus/mts_processor_syn.qpf`, with top
`mts_processor_syn_top`.  It instantiates `mts_processor` with
`USE_EXTERNAL_EPOCH_RESET => true`, matching the production Phase-I profile.
The wrapper supplies a synthesizable three-clock `coe_epoch_reset` pulse over
each generated run-control `SYNC` command.  The pulse repeats in later
synthetic run cycles and is folded into `activity_probe`, so it cannot be
collapsed into the power-on reset or removed as an inactive generic branch.

The wrapper also folds all bits of the 48-bit hit timestamp, arrival GTS, and
latency outputs into `activity_probe`.  Standalone optimization therefore
cannot silently remove the upper carry logic that the histogram integration
uses.

## Build Contract

- Quartus Prime Standard 18.1, Standard Fit effort, seed 1.
- No seed scanning for closure.
- `mts_processor_syn.sdc` constrains the only clock to `7.273 ns`.
- Setup and hold must be nonnegative in every final Arria V timing model.
- The checked-in QSF and static file list must select the same DUT and
  `mts_processor_syn_top.vhd` wrapper.
- A new source hash requires a new fit, STA, resource, static, and DV evidence
  set; historical reports are comparison baselines only.

## Pre-Fit Resource Model

The last closed standalone fit, release `26.1.0.0506`, is the quantitative
baseline.  The current source adds the overflow-base division and external
epoch profile, so equality with the baseline is not expected.  The acceptance
window follows the workspace 50%–300% rule; an out-of-window result requires
investigation and an updated model before signoff.

| Resource | Baseline estimate | Acceptance window |
|---|---:|---:|
| ALMs | 1,156 | 578–3,468 |
| Registers | 1,960 | 980–5,880 |
| Block-memory bits | 491,670 | 245,835–1,475,010 |
| RAM blocks | 62 | 31–186 |
| DSP blocks | 0 | 0 expected; any use requires review |

The expected dominant structures are three pipelined divider cones, the
timestamp conversion/assembly pipeline, and the dual-port calibration ROM.
The external epoch reset adds a small synchronous fanout to the epoch-state
registers and should not dominate area.

## Timing Risk Model

Historical critical paths terminate inside generated divider logic.  The
current pre-fit expectation remains that a divider cone, not the standalone
wrapper, owns worst setup timing.  Review is required if the critical path
moves to the external epoch-reset fanout, the registered epoch-pulse compare,
or a 48-bit carry expression.  Recovery/removal timing is not claimed for
`coe_epoch_reset`; it is a synchronous input sampled in the MTS clock domain.

## Verification Gates

1. The five maintained VHDL targets pass: math, termination, re-arm, ASIC-ID,
   and external epoch.  ASIC-ID runs both UP and DW configurations, producing
   six `vsim` invocations in total.
2. The explicit UVM dispatch remains 521 cases.  The external-epoch VHDL test
   is not counted as a 522nd UVM case.
3. The four bucket continuous-frame runs and the all-buckets frame run pass on
   the exact release source.
4. Questa lint, CDC, and RDC screens report zero errors/violations for the
   standalone external-epoch top.
5. Quartus fit, resources, setup, and hold close at 137.5 MHz.
6. The maintained post-fit signature comparison passes.

The gate test is a zero-delay functional signature smoke using the Quartus
Verilog netlist.  The Arria V flow does not apply SDF here, and the gate test
does not replay the 521-case UVM plan.  It is therefore a netlist/export and
RTL-equivalence smoke, not a timing simulation or a substitute for RTL DV.

## Planned Commands

```bash
make -C tb run_all
make -C tb/uvm hw_tcl_validate_check
python3 ~/.codex/skills/rtl-linter-and-checker/scripts/questa_static_screen.py \
  --top mts_processor_syn_top \
  --filelist syn/quartus/mts_processor_static.f \
  --pre-do syn/quartus/questa_lpm_pre.do \
  --extra-do syn/quartus/questa_static_extra.do \
  --work-dir syn/quartus/questa_static_20260716_external_profile \
  --modes lint,cdc,rdc \
  mts_processor.vhd
cd syn/quartus && bash run_signoff.sh
make -C tb/gate compare
```

The standalone Quartus compile, full 521-case current-source UVM run, and gate
smoke are pending until their commands are actually executed.  This plan does
not assign them PASS status.
