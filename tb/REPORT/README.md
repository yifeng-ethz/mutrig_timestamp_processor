# mutrig_timestamp_processor mtsp_doc_case_test — REPORT index

**DUT:** `mts_processor` &nbsp; **Date:** `2026-05-10` &nbsp;
**RTL variant:** `after` &nbsp; **Seed:** `1`

## Legend

✅ pass / closed / target met &middot; ⚠️ partial / below target / known limitation &middot; ❌ failed / missing evidence &middot; ❓ pending &middot; ℹ️ informational

## Buckets

<!-- click a bucket row to open its ordered-merge trace and linked per-case pages. -->

| status | bucket | planned | evidenced | merged (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) |
|:---:|---|---:|---:|---|
| ⚠️ | [`BASIC`](buckets/BASIC.md) | 130 | 130 | stmt=95.77, branch=92.27, cond=81.41, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=50.64 |
| ⚠️ | [`EDGE`](buckets/EDGE.md) | 131 | 131 | stmt=95.58, branch=90.69, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=88.88, toggle=51.26 |
| ⚠️ | [`PROF`](buckets/PROF.md) | 130 | 130 | stmt=95.37, branch=87.54, cond=80.53, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.69 |
| ⚠️ | [`ERROR`](buckets/ERROR.md) | 130 | 130 | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.12 |

## Cross / continuous-frame runs

| status | run_id | kind | build | bucket | seq | txns | cross_pct |
|:---:|---|---|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | - | mtsp_doc_case_test plus MTSP_CASE_ID for all explicit handlers | 29214 | 100.0 |
| ✅ | [`mtsp_bucket_frame_BASIC`](cross/mtsp_bucket_frame_BASIC.md) | bucket_frame | after | BASIC | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_bucket_frame_EDGE`](cross/mtsp_bucket_frame_EDGE.md) | bucket_frame | after | EDGE | mtsp_continuous_frame_test ordered checkpoint stream | 131 | 100.0 |
| ✅ | [`mtsp_bucket_frame_PROF`](cross/mtsp_bucket_frame_PROF.md) | bucket_frame | after | PROF | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_bucket_frame_ERROR`](cross/mtsp_bucket_frame_ERROR.md) | bucket_frame | after | ERROR | mtsp_continuous_frame_test ordered checkpoint stream | 130 | 100.0 |
| ✅ | [`mtsp_all_buckets_frame`](cross/mtsp_all_buckets_frame.md) | all_buckets_frame | after | - | mtsp_continuous_frame_test ordered checkpoint stream | 521 | 100.0 |

## Random long-run cases

<!-- each random case has a txn_growth page; pages are pending until checkpoint UCDBs exist. -->

| status | case_id | bucket | observed_txn | growth_page |
|:---:|---|---|---:|---|

## Totals

<!-- merged_total_code_coverage is the merge across all evidenced cases in all buckets. -->

- planned_cases = `521`
- evidenced_cases = `521`
- excluded_cases = `0`
- merged total code coverage: `stmt=98.34, branch=96.13, cond=85.84, expr=100.00, fsm_state=100.00, fsm_trans=100.00, toggle=55.93`
- functional coverage: `100.0% (521/521)`

---
_[Dashboard](../DV_REPORT.md) &middot; [Coverage](../DV_COV.md)_
