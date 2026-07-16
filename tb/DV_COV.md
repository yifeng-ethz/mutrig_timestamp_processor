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
| ✅ | stmt | 96.16 | 95.0 |
| ✅ | branch | 90.32 | 90.0 |
| ℹ️ | cond | 89.51 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ✅ | fsm_trans | 100.00 | 90.0 |
| ⚠️ | toggle | 55.18 | 80.0 |

## Per-bucket merged totals

| status | bucket | stmt | branch | cond | expr | fsm_state | fsm_trans | toggle |
|:---:|---|---|---|---|---|---|---|---|
| ⚠️ | [`BASIC`](REPORT/buckets/BASIC.md) | 93.23 | 85.80 | 80.64 | 100.00 | 100.00 | 77.77 | 44.66 |
| ⚠️ | [`EDGE`](REPORT/buckets/EDGE.md) | 93.10 | 84.51 | 80.64 | 100.00 | 100.00 | 100.00 | 46.73 |
| ⚠️ | [`PROF`](REPORT/buckets/PROF.md) | 93.70 | 82.46 | 79.03 | 83.33 | 100.00 | 66.66 | 50.91 |
| ⚠️ | [`ERROR`](REPORT/buckets/ERROR.md) | 93.99 | 86.77 | 84.67 | 100.00 | 100.00 | 88.88 | 49.40 |

## Continuous-frame baselines by build

<!-- one row per bucket_frame / all_buckets_frame signoff run (see REPORT/cross/ for curves). -->

| status | run_id | kind | build | bucket | case_count | stmt | branch | toggle | functional_cross_pct | txns |
|:---:|---|---|---|---|---:|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](REPORT/cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | - | 521 | 96.16 | 90.32 | 55.18 | 100.0 | 29307 |
| ✅ | [`mtsp_bucket_frame_BASIC`](REPORT/cross/mtsp_bucket_frame_BASIC.md) | bucket_frame | after | BASIC | 130 | 82.54 | 70.12 | 25.13 | 100.0 | 130 |
| ✅ | [`mtsp_bucket_frame_EDGE`](REPORT/cross/mtsp_bucket_frame_EDGE.md) | bucket_frame | after | EDGE | 131 | 82.54 | 70.12 | 25.13 | 100.0 | 131 |
| ✅ | [`mtsp_bucket_frame_PROF`](REPORT/cross/mtsp_bucket_frame_PROF.md) | bucket_frame | after | PROF | 130 | 82.54 | 70.12 | 25.13 | 100.0 | 130 |
| ✅ | [`mtsp_bucket_frame_ERROR`](REPORT/cross/mtsp_bucket_frame_ERROR.md) | bucket_frame | after | ERROR | 130 | 82.54 | 70.12 | 25.13 | 100.0 | 130 |
| ✅ | [`mtsp_all_buckets_frame`](REPORT/cross/mtsp_all_buckets_frame.md) | all_buckets_frame | after | - | 521 | 83.31 | 71.75 | 29.14 | 100.0 | 521 |

_Regenerate with `python3 tb/scripts/dv_report_gen_local.py --tb tb`._
