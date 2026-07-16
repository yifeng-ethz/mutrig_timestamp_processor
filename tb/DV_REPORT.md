# ✅ DV Report — `mutrig_timestamp_processor mtsp_doc_case_test`

**DUT:** `mts_processor` &nbsp; **Date:** `2026-07-16` &nbsp;
**RTL variant:** `after` &nbsp; **Seed:** `1`

This page is the chief-architect dashboard. All per-case evidence lives under [`REPORT/`](REPORT/README.md).

## Legend

✅ pass / closed &middot; ⚠️ partial / below target / known limitation &middot; ❌ failed / missing evidence &middot; ❓ pending &middot; ℹ️ informational

## Health

| status | field | value |
|:---:|---|---|
| ✅ | failed_cases | `0` |
| ✅ | signoff_runs_with_failures | `0` |
| ✅ | catalog_backlog_cases | `0` |
| ✅ | unimplemented_cases | `0` |
| ✅ | stale_artifacts | `0` |

## Phase-I R16 Closure Evidence

| status | gate | evidence |
|:---:|---|---|
| ✅ | VERSION `26.6.0.0716` directed latency48 delta | `5/5` PASS, seed `260716` |
| ✅ | Maintained VHDL smoke | `PASS`; required scope is `5` targets / `6` `vsim` invocations |
| ✅ | Questa static screen | `PASS`; required findings are lint `0`, CDC `0`, RDC `0` |
| ✅ | Full current-release regression | `PASS` |
| ✅ | Physical latency48 audit | `27944` exact identities; `0` mismatches; `0` production-negative errors; `14` directed diagnostics in `8` explicit cases |
| ✅ | Standalone Quartus closure | `PASS`; Standard Fit seed `1`, four-corner STA/resources at `7.273 ns` |
| ✅ | Current-release gate simulation | `PASS` |

Detailed current-release evidence: [`REPORT/current_release/full_dv_26_6_0_0716.md`](REPORT/current_release/full_dv_26_6_0_0716.md).
## Signoff Scope

| field | claimed value |
|---|---|
| DUT_IMPL | `VHDL rtl` |
| RTL_VARIANT | `after` |
| DEBUG_PATH_REQUIRED | `1` |
| RESET_EXPECTED_LATENCY | `2000` |
| EXPLICIT_CASES | `521` |
| DEBUG_REQUIRED_CASES | `521/521` |
| DUAL_PATH_PAIRS | `19416` |
| SCOREBOARD_TRACES | `19416` |
| TRACE_DETAIL_LINES | `19188` |
| LATENCY48_IDENTITIES | `27944` |
| LATENCY48_IDENTITY_MISMATCHES | `0` |
| LATENCY48_PRODUCTION_NEGATIVE_ERRORS | `0` |
| LATENCY48_DIRECTED_NEGATIVE_DIAGNOSTICS | `14 samples in 8 explicit cases` |
| BUCKET_FRAME_RUNS | `4/4` |
| ALL_BUCKETS_FRAME_RUNS | `1/1` |
| EVIDENCE_GIT_BRANCH | `master` |
| EVIDENCE_GIT_COMMIT | `19e5310afe8a + exact source manifest` |
| EVIDENCE_DATE | `2026-07-16` |
| CURRENT_RELEASE | `26.6.0.0716` |
| CURRENT_SOURCE_GIT_HEAD | `19e5310afe8a` |
| CURRENT_RELEASE_UVM_SCOPE | `521/521 isolated PASS, seed=1; 5/5 continuous-frame PASS` |
| CURRENT_RELEASE_DELTA_UVM | `5/5 PASS, seed=260716; exact-source receipt verified` |
| CURRENT_RELEASE_VHDL_SMOKE | `5/5 maintained targets PASS (6 vsim invocations)` |
| CURRENT_RELEASE_STATIC | `lint=0, cdc=0, rdc=0` |
| CURRENT_RELEASE_FULL_521 | `PASS exact-source 521/521 isolated and 5/5 continuous-frame` |
| CURRENT_RELEASE_SYNTHESIS | `PASS Standard Fit seed=1, 7.273 ns, four-corner STA/resources` |
| CURRENT_RELEASE_GATE_SIM | `PASS matching RTL/post-fit signature 1820064b` |
| CURRENT_RELEASE_DELTA_REPORT | `REPORT/current_release/full_dv_26_6_0_0716.md` |
| probe_only_exclusions | `none` |
| CURRENT_SOURCE_MANIFEST | `6e8bd65c58772cdac91713b631ce9084573187128bcdb31f7c00dd845d32bed1` |
| CURRENT_RELEASE_PROMOTION_RECEIPT | `92075a2db8acd9e617c00c1c88c1f179381b5dc2d56efe0462c00b2568b0d84d` |

## Non-Claims

- Raw DUT toggle coverage remains below the 80% target; statement, branch, FSM-state, FSM-transition, functional, and mandatory continuous-frame targets pass.

## Bucket Summary

<!-- status: overall per-bucket health; merged columns: bucket-local ordered-merge percentages. -->

| status | bucket | catalog_planned | promoted | evidenced | backlog | merged | promoted functional |
|:---:|---|---:|---:|---:|---:|---|---|
| ⚠️ | [`BASIC`](REPORT/buckets/BASIC.md) | 130 | 130 | 130 | 0 | stmt=93.23, branch=85.80, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=44.66 | 100.0% (130/130) |
| ⚠️ | [`EDGE`](REPORT/buckets/EDGE.md) | 131 | 131 | 131 | 0 | stmt=93.10, branch=84.51, cond=80.64, expr=100.00, fsm_state=100.00, fsm_trans=100.00, toggle=46.73 | 100.0% (131/131) |
| ⚠️ | [`PROF`](REPORT/buckets/PROF.md) | 130 | 130 | 130 | 0 | stmt=93.70, branch=82.46, cond=79.03, expr=83.33, fsm_state=100.00, fsm_trans=66.66, toggle=50.91 | 100.0% (130/130) |
| ⚠️ | [`ERROR`](REPORT/buckets/ERROR.md) | 130 | 130 | 130 | 0 | stmt=93.99, branch=86.77, cond=84.67, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=49.40 | 100.0% (130/130) |

## Totals

| status | metric | pct | target |
|:---:|---|---|---|
| ✅ | stmt | 96.16 | 95.0 |
| ✅ | branch | 90.32 | 90.0 |
| ℹ️ | cond | 89.51 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ✅ | fsm_trans | 100.00 | 90.0 |
| ⚠️ | toggle | 55.18 | 80.0 |

- catalog_planned_cases: `521`
- promoted_signoff_cases: `521`
- evidenced_promoted_cases: `521`
- promoted functional coverage: `100.0% (521/521)`

## Signoff Runs

<!-- one row per run; follow the run_id link for the full transaction-growth curve. -->

| status | run_id | kind | build | seq | txns | cross_pct |
|:---:|---|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](REPORT/cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | mtsp_doc_case_test plus MTSP_CASE_ID for all explicit handlers | 29307 | 100.0 |
| ✅ | [`mtsp_bucket_frame_BASIC`](REPORT/cross/mtsp_bucket_frame_BASIC.md) | bucket_frame | after | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_bucket_frame_EDGE`](REPORT/cross/mtsp_bucket_frame_EDGE.md) | bucket_frame | after | mtsp_continuous_frame_test ordered checkpoint stream | 131 | 100.0 |
| ✅ | [`mtsp_bucket_frame_PROF`](REPORT/cross/mtsp_bucket_frame_PROF.md) | bucket_frame | after | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_bucket_frame_ERROR`](REPORT/cross/mtsp_bucket_frame_ERROR.md) | bucket_frame | after | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_all_buckets_frame`](REPORT/cross/mtsp_all_buckets_frame.md) | all_buckets_frame | after | mtsp_continuous_frame_test ordered checkpoint stream | 521 | 100.0 |

## Index

- [`REPORT/README.md`](REPORT/README.md) — reviewer entry point
- [`REPORT/buckets/`](REPORT/buckets/) — ordered-merge trace per bucket
- [`REPORT/cases/`](REPORT/cases/) — one page per case
- [`REPORT/cross/`](REPORT/cross/) — one page per signoff run
- [`DV_COV.md`](DV_COV.md) — coverage totals, ordering, and baseline scope
- [`DV_REPORT.json`](DV_REPORT.json) — machine-readable source of truth

_This dashboard is generated by `python3 tb/scripts/dv_report_gen_local.py --tb tb`. Edits are overwritten; fix the JSON or the generator instead._
