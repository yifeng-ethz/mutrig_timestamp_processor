# DV Coverage Summary — `mutrig_timestamp_processor mtsp_doc_case_test`

This page is the coverage summary only. Per-case incremental coverage lives under
[`REPORT/cases/`](REPORT/cases/); per-bucket ordered-merge traces live under
[`REPORT/buckets/`](REPORT/buckets/).

## Legend

✅ pass / closed &middot; ⚠️ partial / below target &middot; ❌ failed / missing evidence &middot; ❓ pending &middot; ℹ️ informational

## Targets vs merged totals

<!-- merged_pct = merge across all evidenced isolated-mode UCDBs across all buckets. -->

| status | metric | merged_pct | target |
|:---:|---|---|---|
| ✅ | stmt | 97.61 | 95.0 |
| ✅ | branch | 95.36 | 90.0 |
| ℹ️ | cond | 84.95 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ⚠️ | fsm_trans | 77.77 | 90.0 |
| ⚠️ | toggle | 55.93 | 80.0 |

## Per-bucket merged totals

| status | bucket | stmt | branch | cond | expr | fsm_state | fsm_trans | toggle |
|:---:|---|---|---|---|---|---|---|---|
| ⚠️ | [`BASIC`](REPORT/buckets/BASIC.md) | 95.40 | 91.89 | 81.41 | 100.00 | 100.00 | 66.66 | 50.64 |
| ⚠️ | [`EDGE`](REPORT/buckets/EDGE.md) | 95.22 | 90.31 | 81.41 | 100.00 | 100.00 | 77.77 | 51.26 |
| ⚠️ | [`PROF`](REPORT/buckets/PROF.md) | 95.37 | 87.54 | 80.53 | 50.00 | 100.00 | 66.66 | 50.69 |
| ⚠️ | [`ERROR`](REPORT/buckets/ERROR.md) | 95.58 | 91.89 | 82.30 | 100.00 | 100.00 | 66.66 | 53.12 |

## Continuous-frame baselines by build

<!-- one row per bucket_frame / all_buckets_frame signoff run (see REPORT/cross/ for curves). -->

| status | run_id | kind | build | bucket | case_count | stmt | branch | toggle | functional_cross_pct | txns |
|:---:|---|---|---|---|---:|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](REPORT/cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | - | 521 | 97.61 | 95.36 | 55.93 | 100.0 | 29214 |

_Regenerate with `python3 tb/scripts/dv_report_gen_local.py --tb tb`._
