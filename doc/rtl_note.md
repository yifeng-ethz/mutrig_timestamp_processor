# RTL Note - mutrig_timestamp_processor

Date: 2026-05-01
Author: Codex

## 0. Summary

- Scope: add runtime CSR word `0x14` / word index `5` for
  `overflow_lookback` in 8 ns ticks, so Phase-6 hardware tuning can sweep the
  MTS post-wrap epoch-disambiguation window without rebuilding the IP.
- Status: RTL smoke regression, SVD determinism, packaging lint, qverify
  lint/CDC/RDC, and standalone Quartus synthesis/timing pass.
- Open: no gate-level simulation runner exists in this legacy IP tree; the
  user-requested pre-push gate for this VERSION bump was standalone TB plus
  standalone synthesis.

## 1. Targets

- Device: Arria V `5AGXBA7D4F31C5`.
- Nominal target: 125 MHz, `Tclk = 8.000 ns`.
- Standalone signoff clock: `7.273 ns`, equivalent to 137.5 MHz / 10% setup
  margin.
- Mini-project: `syn/quartus/mts_processor_syn.qsf`.
- No `RTL_PLAN.md` exists in this legacy IP repository, so resource checks use
  the fitted resource summary as the baseline for this checkpoint.

## 2. DV Signoff

- `make -C tb run_all`: PASS for `mts_processor_tb` and
  `mts_processor_terminating_tb`.
- `tb/run_mts_processor_tb.sh`: PASS for the legacy smoke bench.
- Added CSR word `5` smoke coverage:
  - reset/readback default `2000`
  - write/readback `400`
  - write `7000`, readback clamp `6553`
  - restore `2000`
- Known simulator warnings remain the legacy divider X-init and wide
  `to_integer` warnings.

## 3. Static Screen

Command:

```bash
MTS_PROCESSOR_SYN_DIR="$PWD/syn/quartus" \
python3 ~/.codex/skills/rtl-linter-and-checker/scripts/questa_static_screen.py \
  --top mts_processor_syn_top \
  --filelist syn/quartus/mts_processor_static.f \
  --pre-do syn/quartus/qverify_pre.do \
  --extra-do syn/quartus/qverify_extra.do \
  --work-dir syn/quartus/qverify_mts_runtime_lookback \
  mts_processor.vhd syn/quartus/mts_processor_syn_top.vhd
```

Result: PASS.

- Lint: PASS with no error findings.
- CDC: PASS, violations `0`.
- RDC: PASS, violations `0`.
- Static-only context uses `dual_port_rom_blackbox.sv` and
  `lpm_divide_blackbox.vhd`; Quartus synthesis uses the real ROM and Intel LPM
  divider.

## 4. Quartus Signoff

Command:

```bash
bash syn/quartus/run_signoff.sh
```

Result: PASS.

| Item | Result |
|:--|:--|
| Setup WNS/TNS | `+0.803 ns / 0.000 ns` worst selected setup |
| Hold WNS/TNS | `+0.152 ns / 0.000 ns` worst selected hold |
| ALMs | `1,048 / 91,680` |
| Registers | `1882` |
| RAM bits | `491,670 / 13,987,840` |
| RAM blocks | `62 / 1,366` |
| DSP | `0 / 800` |

Quartus reports the standalone design is not fully constrained for setup/hold
because only the clock is constrained; this is expected for the synthetic
top-level harness with unconstrained board I/O pins.

## 5. Change Safety

- The new CSR is local to the existing Avalon-MM CSR process.
- `expected_latency` remains the timestamp-error threshold.
- `overflow_lookback` alone controls the post-wrap lapse window; writes update
  `overflow_lookback_1n6` and `padding_upper` in the same clocked CSR process.
- Reset and soft reset restore the compile-time default unless software writes
  a new CSR value.
