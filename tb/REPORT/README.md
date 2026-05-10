# mutrig_timestamp_processor mtsp_doc_case_test — REPORT index

**DUT:** `mts_processor` &nbsp; **Date:** `2026-05-10` &nbsp;
**RTL variant:** `after` &nbsp; **Seed:** `1`

## Legend

✅ pass / closed / target met &middot; ⚠️ partial / below target / known limitation &middot; ❌ failed / missing evidence &middot; ❓ pending &middot; ℹ️ informational

## Buckets

<!-- click a bucket row to open its ordered-merge trace and linked per-case pages. -->

| status | bucket | planned | evidenced | merged (stmt/branch/cond/expr/fsm_state/fsm_trans/toggle) |
|:---:|---|---:|---:|---|
| ⚠️ | [`BASIC`](buckets/BASIC.md) | 130 | 130 | stmt=95.40, branch=91.89, cond=81.41, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.64 |
| ⚠️ | [`EDGE`](buckets/EDGE.md) | 131 | 131 | stmt=95.22, branch=90.31, cond=81.41, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=51.26 |
| ⚠️ | [`PROF`](buckets/PROF.md) | 130 | 130 | stmt=95.37, branch=87.54, cond=80.53, expr=50.00, fsm_state=100.00, fsm_trans=66.66, toggle=50.69 |
| ⚠️ | [`ERROR`](buckets/ERROR.md) | 130 | 130 | stmt=95.58, branch=91.89, cond=82.30, expr=100.00, fsm_state=100.00, fsm_trans=66.66, toggle=53.12 |

## Cross / continuous-frame runs

| status | run_id | kind | build | bucket | seq | txns | cross_pct |
|:---:|---|---|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | - | mtsp_doc_case_test plus MTSP_CASE_ID for all explicit handlers | 29214 | 100.0 |

## Random long-run cases

<!-- each random case has a txn_growth page; pages are pending until checkpoint UCDBs exist. -->

| status | case_id | bucket | observed_txn | growth_page |
|:---:|---|---|---:|---|

## Totals

<!-- merged_total_code_coverage is the merge across all evidenced cases in all buckets. -->

- planned_cases = `521`
- evidenced_cases = `521`
- excluded_cases = `0`
- merged total code coverage: `stmt=97.61, branch=95.36, cond=84.95, expr=100.00, fsm_state=100.00, fsm_trans=77.77, toggle=55.93`
- functional coverage: `100.0% (521/521)`

---
_[Dashboard](../DV_REPORT.md) &middot; [Coverage](../DV_COV.md)_
