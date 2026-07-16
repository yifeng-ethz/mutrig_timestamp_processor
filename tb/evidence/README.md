# MTS exact-source signoff promotion

This directory holds the committed promotion receipt for release
`26.6.0.0716`. The workflow is fail closed: a pre-run nanosecond fence
and SHA-256 source ledger prevent older same-name logs or UCDBs from being
promoted.

## 1. Establish the clean run fence

~~~bash
set -euo pipefail
make -C tb/uvm clean
make -C tb clean
make -C tb/gate clean
RUN=/data3/yifeng/codex/mts_signoff_26_6_0_0716_$(date +%Y%m%d_%H%M%S)
mkdir -p "$RUN"
python3 tb/scripts/current_source_signoff.py begin \
  --state "$RUN/run_state.json"
~~~

The final marker must be `MTS_CURRENT_SOURCE_BEGIN_PASS`. Do not edit a
manifested source after this point.

## 2. Required EDA scope

Compile once and run all 521 case IDs in the current
`tb/uvm/mtsp_cases.svh` dispatch table with seed `1`. The inventory
must remain STD 130, CORNER 131, STRESS 130, and NEG 130, with no duplicate ID.
Then run:

~~~bash
for bucket in BASIC EDGE PROF ERROR; do
  make -C tb/uvm run_bucket_frame \
    RTL_VARIANT=after FRAME_BUCKET="$bucket" SEED=1
done
make -C tb/uvm run_all_buckets_frame RTL_VARIANT=after SEED=1

for case_id in \
  STD_MTS_020_op_mode_bits_readback \
  STD_MTS_099_arrival_delta_uses_gts \
  CORNER_MTS_035_mts_counter_wrap_pulse \
  CORNER_MTS_071_debug_ts_minus_one \
  NEG_MTS_041_negative_debug_ts_error; do
  make -C tb/uvm run_sim \
    RTL_VARIANT=after TEST=mtsp_doc_case_test \
    CASE_ID="$case_id" RUN_ID="$case_id" SEED=260716
done

make -C tb run_all 2>&1 | tee "$RUN/vhdl_smoke.log"
make -C tb/uvm hw_tcl_validate_check \
  2>&1 | tee "$RUN/hw_tcl_validate.log"

python3 ~/.codex/skills/rtl-linter-and-checker/scripts/questa_static_screen.py \
  --top mts_processor_syn_top \
  --filelist syn/quartus/mts_processor_static.f \
  --pre-do syn/quartus/questa_lpm_pre.do \
  --extra-do syn/quartus/questa_static_extra.do \
  --work-dir "$RUN/questa_static_external_epoch" \
  --modes lint,cdc,rdc \
  mts_processor.vhd syn/quartus/mts_processor_syn_top.vhd \
  2>&1 | tee "$RUN/questa_static_driver.log"

PATH=/data1/intelFPGA/18.1/quartus/bin:$PATH \
  bash syn/quartus/run_signoff.sh 2>&1 | tee "$RUN/quartus_flow.log"

(cd syn/quartus && /data1/intelFPGA/18.1/quartus/bin/quartus_sta \
  mts_processor_syn -c mts_processor_syn --do_report_timing \
  --model=slow --temperature=85 --voltage=1100) \
  2>&1 | tee "$RUN/sta_slow_85c.log"
(cd syn/quartus && /data1/intelFPGA/18.1/quartus/bin/quartus_sta \
  mts_processor_syn -c mts_processor_syn --do_report_timing \
  --model=slow --temperature=0 --voltage=1100) \
  2>&1 | tee "$RUN/sta_slow_0c.log"
(cd syn/quartus && /data1/intelFPGA/18.1/quartus/bin/quartus_sta \
  mts_processor_syn -c mts_processor_syn --do_report_timing \
  --model=fast --temperature=85 --voltage=1100) \
  2>&1 | tee "$RUN/sta_fast_85c.log"
(cd syn/quartus && /data1/intelFPGA/18.1/quartus/bin/quartus_sta \
  mts_processor_syn -c mts_processor_syn --do_report_timing \
  --model=fast --temperature=0 --voltage=1100) \
  2>&1 | tee "$RUN/sta_fast_0c.log"

make -C tb/gate compare 2>&1 | tee "$RUN/gate_compare.log"
~~~

The VHDL scope is five targets and six simulator invocations. Static findings
must be lint/CDC/RDC `0/0/0`. Quartus must use Standard Fit, seed
`1`, and `7.273 ns`. All setup, hold, recovery, removal, and
minimum-pulse-width WNS values must be nonnegative with zero TNS in all four
corners. Resources must remain within `doc/RTL_PLAN.md`. The gate
comparison is zero-delay and has no SDF; TimeQuest owns timing.

## 3. Verify and promote

~~~bash
python3 tb/scripts/current_source_signoff.py verify \
  --state "$RUN/run_state.json" \
  --compile-log "$RUN/uvm_compile.log" \
  --vhdl-log "$RUN/vhdl_smoke.log" \
  --hw-tcl-log "$RUN/hw_tcl_validate.log" \
  --static-log "$RUN/questa_static_external_epoch/questa_static_screen.log" \
  --quartus-flow-log "$RUN/quartus_flow.log" \
  --timing-report "slow_85c=$RUN/sta_slow_85c.log" \
  --timing-report "slow_0c=$RUN/sta_slow_0c.log" \
  --timing-report "fast_85c=$RUN/sta_fast_85c.log" \
  --timing-report "fast_0c=$RUN/sta_fast_0c.log" \
  --gate-compare-log "$RUN/gate_compare.log" \
  --vcover /data1/questaone_sim/questasim/bin/vcover \
  --json-out tb/evidence/current_source_signoff.json \
  --md-out tb/REPORT/current_release/full_dv_26_6_0_0716.md \
  --syn-report syn/SYN_REPORT.md

python3 tb/scripts/dv_report_gen_local.py \
  --tb tb \
  --verified-evidence tb/evidence/current_source_signoff.json
python3 tb/scripts/current_source_signoff.py check \
  --evidence tb/evidence/current_source_signoff.json
~~~

Verification health-merges all 531 required UCDB inputs, records exact source
and artifact aggregates, emits the committed receipt and DV/SYN summaries, and
only then allows the DV generator to remove its pending qualification.
