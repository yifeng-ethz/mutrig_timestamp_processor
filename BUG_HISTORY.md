# BUG_HISTORY.md - mutrig_timestamp_processor DV bug ledger

Class legend:
- `R` = RTL / DUT bug
- `H` = harness / testcase / reporting bug

Severity legend:
- `soft error` = the bad packet/data flushes through the stream and does not leave the later datapath stuck
- `hard stuck error` = the bug poisons later packet handling and typically needs a functional reset / fresh restart to recover
- `non-datapath-refactor` = observability, reporting, harness, or naming/accounting consistency work with no direct packet-contract effect

Encounterability legend:
- practical severity is `severity x encounterability`, so the index must say how likely a reader is to hit the bug in normal use rather than only when it first appeared in one simulation log
- nominal datapath operation = legal traffic, about `50%` link load, iid per-lane behavior, and no forced error injection or artificially pathological stalls
- nominal control-path operation = routine bring-up / CSR program / readback / clear-counter sequences
- `common (...)` = readily hit in nominal operation
- `occasional (...)` = hit in nominal operation without heroic setup, but not in every short run
- `rare (...)` = legal in nominal operation, but usually needs long runtime or unlucky alignment
- `corner-only (...)` = requires a legal but non-nominal stress or corner profile
- `directed-only (...)` = requires targeted error injection, formal/probe flow, reporting-only flow, or another non-operational stimulus
- detailed `min / p50 / max` first-hit sim-time studies may still appear inside individual bug sections when useful

Fix status detail contract for active entries and future updates:
- `state` = fixed / open / partial plus the current verification gate
- `mechanism` = how the implemented repair changes the RTL or harness behavior
- `before_fix_outcome` and `after_fix_outcome` = concise evidence showing what changed
- `potential_hazard` = whether the fix looks permanent or is still provisional / profile-limited
- `Claude Opus 4.7 xhigh review decision` = explicit review state; use `pending / not run` until that review has actually happened

Historical formal note:
- This IP ledger currently records RTL/DV simulation findings from the legacy VHDL smoke bench and the UVM documented-case harness.
- Formal/static signoff is tracked separately when a qverify/qstatic flow is run for this IP.

## Index

| bug_id | class | severity | encounterability | status | first seen | commit | summary |
|---|---|---|---|---|---|---|---|
| [BUG-001-R](#bug-001-r-wrap-window-timestamp-reconstruction-mismatch) | R | soft error | `corner-only (wrap-window timestamp traffic)` | fixed | exact integrated SciFi bench `INT_fe_scifi_v3-2026-04-17` | `0399f04` | Wrap correction used the wrong MuTRiG coarse-time period and left a residual timestamp error near coarse-counter wrap. |
| [BUG-002-R](#bug-002-r-timestamp-delay-error-sideband-could-attach-to-the-wrong-hit) | R | soft error | `directed-only (delay-error classification)` | fixed | `CORNER_MTS_127_delay_error_sideband_tracks_hit` | `497bf11` | Delay-error sideband could describe a neighboring hit instead of the visible output payload beat. |
| [BUG-003-R](#bug-003-r-debug-ts-could-emit-reset-or-sclr-flush-samples-with-no-normal-payload) | R | non-datapath-refactor | `directed-only (reset/debug observability)` | fixed | `STD_MTS_005_sync_enters_reset_sync` | `67ef6ac` | Debug timestamp valid could fire for reset/SCLR flush traffic with no normal `hit_type1` payload. |
| [BUG-004-R](#bug-004-r-hit-ready-datapath-sampling-and-counters-could-diverge-during-bring-up) | R | soft error | `common (routine bring-up)` | fixed | `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, `NEG_MTS_028_valid_beat_under_force_stop` | `67ef6ac` | Hit ready, datapath sampling, and CSR counters could disagree around stale ready/accept windows. |
| [BUG-005-R](#bug-005-r-control-commands-could-be-decoded-while-asi-ctrl-ready-0) | R | hard stuck error | `common (routine terminate-to-idle control)` | fixed | `STD_MTS_129_upgrade_case_idle_after_boundary_only` | `e61fc9f` | Control words could be decoded while `asi_ctrl_ready=0`, allowing premature IDLE acceptance before close markers. |

## 2026-05-09

### BUG-005-R: Control commands could be decoded while `asi_ctrl_ready=0`

- First seen:
  - UVM case `STD_MTS_129_upgrade_case_idle_after_boundary_only` during the delivered terminate-boundary upgrade sequence
- Symptom:
  - an `IDLE` command driven while `asi_ctrl_ready=0` during `FLUSHING` could be accepted before the empty close-marker train completed
  - the before-fix run failed at 220 ns with `IDLE command must not be accepted before close markers complete`
  - the terminal boundary evidence was skipped even though the control driver was using the ready/valid handshake contract
- Root cause:
  - `proc_run_control_mgmt_agent` decoded `asi_ctrl_valid` without also checking `ctrl_ready_comb`
  - a control word held valid while ready was low could update `run_state_cmd` before the DUT had finished terminate drain and close-marker generation
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL now decodes run-control commands only when `asi_ctrl_valid = '1' and ctrl_ready_comb = '1'`
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=STD_MTS_129_upgrade_case_idle_after_boundary_only SEED=1` fails on the before RTL
  - after_fix_outcome:
    - the same `prove_delta` command passes on the after RTL with `inputs=0 beats=4 payloads=0 eops=4 empty_eops=4 debug_ts=0 debug_burst=0 ts_delta=0 dual_path_pairs=0 traces=0`
    - final explicit documented-case sequence passed with `FINAL_ALL_133_EXPLICIT_CASES_PASS`
    - `make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1` passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8 debug_ts=2 dual_path_pairs=2 traces=2`
    - `make -C tb/uvm cov_report_total RTL_VARIANT=after` completed with filtered merged coverage `64.44%`
    - `./tb/run_mts_processor_tb.sh` passed the legacy VHDL testbench
  - potential_hazard:
    - fixed for the legal stateful terminate/endofrun/close-marker/IDLE contract now covered by `STD_MTS_125` through `STD_MTS_130`
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - `STD_MTS_008_idle_from_flushing` and `STD_MTS_045_terminating_without_eop_then_idle` were reconciled to the same stateful contract: assert upstream `endofrun`, wait for close markers, then send `IDLE`
  - `DEBUG=0` suppresses VHDL report text only; the current debug sideband outputs remain paired with normal payload evidence and are still required by the UVM scoreboard
- Commit:
  - `e61fc9f22e83` (`[FIX] Gate MTSP control commands on ready`)

### BUG-004-R: Hit ready, datapath sampling, and counters could diverge during bring-up

- First seen:
  - UVM cases `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop`
- Symptom:
  - the first standard-sequence hit after `RUN_PREPARE -> SYNC -> RUNNING` could be transformed or counted inconsistently depending on the stale ready phase observed by the driver and monitors
  - force-stop needed to keep the input ready contract observable while dropping the current beat from the transform path
  - total/discard counter readback and transformed payload evidence could disagree around bring-up edges
- Root cause:
  - `asi_hit_type0_ready_i` was registered from the previous processor phase, so the externally visible accept window could lag the current FSM state
  - the datapath sampled `valid && hit_in_ok` rather than the same ready/valid acceptance event observed at the Avalon-ST boundary
  - reset-flow state could remain at `SYNC` long enough to clear counters after the first standard-sequence acceptance
  - the UVM `run_start()` helper treated the command handshake as sufficient evidence of `RUNNING`, and the CSR driver could sample read data before the acknowledged transaction had settled
- Fix status:
  - state:
    - fixed
  - mechanism:
    - RTL derives the input ready window combinationally from current state, reset flow, and upstream end-of-run state
    - datapath and packet bookkeeping sample only `asi_hit_type0_accept && hit_in_ok`
    - the UVM CSR driver drives requests on `negedge`, waits for positive-edge acknowledgement, and samples after a small settle delay
  - before_fix_outcome:
    - first-hit transform, total counter, and discard counter evidence could diverge around bring-up and force-stop edges
  - after_fix_outcome:
    - all 42 then-explicit documented-case handlers passed with `make -C tb/uvm run_after TEST=mtsp_doc_case_test CASE_ID=<case_id> SEED=1`
    - `STD_MTS_006_running_from_sync`, `STD_MTS_030_total_counter_counts_all_valid`, `STD_MTS_038_force_stop_blocks_acceptance`, and `NEG_MTS_028_valid_beat_under_force_stop` cross-check ready, total/discard counters, and no-output behavior under accepted drop conditions
  - potential_hazard:
    - fixed for the current single-clock UVM and legacy VHDL simulation scope
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - `make -C tb/uvm run_after TEST=COMBO_MTSP_001_terminate_contract_test SEED=1` passed with `inputs=2 beats=10 payloads=2 eops=8 empty_eops=8 debug_ts=2 dual_path_pairs=2 traces=2`
  - `./tb/run_mts_processor_tb.sh` passed the legacy VHDL testbench
- Commit:
  - `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)

### BUG-003-R: debug_ts could emit reset or SCLR flush samples with no normal payload

- First seen:
  - UVM case `STD_MTS_005_sync_enters_reset_sync` after enabling the debug monitor path as a required cross-check against normal `hit_type1` output
- Symptom:
  - the scoreboard observed `debug_ts_valid=1` while no normal `hit_type1` payload beat was emitted, creating an unpaired debug transaction during reset/SCLR or reset-to-SYNC bring-up traffic
- Root cause:
  - the internal debug timestamp path was driven from the divider pipeline without checking that the processor was in an active output state
  - the external debug sideband register forwarded internal debug valid without the same state and drop-policy gating used by the normal output path
- Fix status:
  - state:
    - fixed
  - mechanism:
    - `proc_debug_ts` clears internal debug data/valid unless reset is deasserted, the processor is in `RUNNING` or `FLUSHING`, and the divider stage holds a valid hit
    - `proc_debug_ts_comb` resets and forwards debug sideband data only when the normal output state and delay-error drop policy allow an observable hit sideband
  - before_fix_outcome:
    - reset/SCLR traffic could produce debug-only samples
  - after_fix_outcome:
    - all 42 then-explicit documented-case handlers passed
    - `STD_MTS_002_reset_release_idle_quiet`, `STD_MTS_005_sync_enters_reset_sync`, and `STD_MTS_010_global_reset_during_flushing` require zero unpaired normal/debug activity through reset and bring-up boundaries
  - potential_hazard:
    - fixed for current exposed debug sideband contract
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the UVM scoreboard requires normal/debug pair agreement, so future debug-only samples remain a closure blocker rather than a tolerated artifact
- Commit:
  - `67ef6ac` (`[FIX] Align MTSP ready and debug evidence`)

### BUG-002-R: Timestamp-delay error sideband could attach to the wrong hit

- First seen:
  - UVM case `CORNER_MTS_127_delay_error_sideband_tracks_hit`, comparing the `before` RTL against the UVM debug/normal dual-path scoreboard
- Symptom:
  - a forced timestamp-delay error with `EXPECTED_LATENCY=0` did not assert `aso_hit_type1_error` on the corresponding output beat
  - the following restored-clean hit could inherit or mask the stale classification depending on traffic spacing
- Root cause:
  - the visible `hit_type1` payload came from the registered `hit_out` path
  - the delay-error sideband was derived from the separate `debug_ts` valid path
  - mixed clean/error traffic therefore allowed the sideband classification to describe the neighboring hit instead of the beat on the normal output path
- Fix status:
  - state:
    - fixed
  - mechanism:
    - delay-error sideband is aligned with the visible output payload beat
  - before_fix_outcome:
    - `make -C tb/uvm prove_delta TEST=mtsp_doc_case_test CASE_ID=CORNER_MTS_127_delay_error_sideband_tracks_hit SEED=1` fails on the before RTL with `MTSP_DELAY_MATH` / `MTSP_CASE`
  - after_fix_outcome:
    - current RTL passes with `inputs=2 beats=2 payloads=2 debug_ts=2 debug_burst=2 ts_delta=2 dual_path_pairs=2 traces=2`
    - additional green guards were `STD_MTS_001_powerup_reset_idle`, `STD_MTS_031_running_accepts_clean_hit`, `COMBO_MTSP_001_terminate_contract_test`, and `./tb/run_mts_processor_tb.sh`
  - potential_hazard:
    - fixed for the current normal/debug paired output path
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the UVM environment has analysis ports for CSR writes, accepted hit0, normal hit1, and debug streams
  - the scoreboard recomputes the delay-error decision from `debug_ts` and `EXPECTED_LATENCY` and requires it to match `aso_hit_type1_error` per payload beat
- Commit:
  - `497bf11` (`[FIX] Align delay error sideband with hit`)

## 2026-04-18

### BUG-001-R: Wrap-window timestamp reconstruction mismatch

- First seen:
  - exact integrated SciFi bench `firmware_builds/tb_int/INT_fe_scifi_v3-2026-04-17`
  - saturated short-mode traces `ts_sat_exact14` and `ts_sat_exact15`
- Symptom:
  - `mts_processor` emitted wrong `tcc_8n` and non-zero `tcc_1n6` around the MuTRiG coarse-counter wrap
  - `aso_hit_type1_error` was raised and pre-RBCAM drops occurred even though the injected hit true timestamp was still within the expected 2000-cycle latency window
- Root cause:
  - the per-hit overflow-adjust decision missed the first hit that used the newly valid overflow-product pipeline result
  - the wrap correction subtracted `32766` ticks instead of the true `32767` MuTRiG coarse-time period, leaving a residual `+1` 1.6 ns remainder after wrap
- Fix status:
  - state:
    - fixed
  - mechanism:
    - wrap-window timestamp reconstruction now uses the true MuTRiG coarse-time period and catches the first hit after the overflow-product pipeline becomes valid
  - before_fix_outcome:
    - original failing wrap samples were `hit_id=2891` and `hit_id=2895`
  - after_fix_outcome:
    - exact true-time trace after the fix is in `REPORT/ts_sat_exact16/emulator_timestamp_trace.csv`
    - after the fix those hits decode with `tcc8n_act=tcc8n_exp=5549`, `tcc1n6=0`, `err_act=0`
  - potential_hazard:
    - fixed for the exact SciFi wrap-window reproduction
  - Claude Opus 4.7 xhigh review decision:
    - pending / not run in this turn
- Runtime / coverage context:
  - the remaining `debug_ts` delta offset in the exact bench is a monitor phase issue, not a recovered-hit timestamp mismatch
  - the exact-bench integration copy under `firmware_builds/scifi_datapath_system_v3/synthesis/submodules/mts_processor.vhd` was patched locally in the superproject for system-level verification alongside this IP fix
- Commit:
  - `0399f04` (`mts_processor: fix wrap-window timestamp reconstruction`)
