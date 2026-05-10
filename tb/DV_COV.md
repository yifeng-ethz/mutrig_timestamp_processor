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
| ✅ | stmt | 98.31 | 95.0 |
| ✅ | branch | 96.10 | 90.0 |
| ℹ️ | cond | 88.79 | - |
| ℹ️ | expr | 100.00 | - |
| ✅ | fsm_state | 100.00 | 95.0 |
| ✅ | fsm_trans | 100.00 | 90.0 |
| ⚠️ | toggle | 58.95 | 80.0 |

## Per-bucket merged totals

| status | bucket | stmt | branch | cond | expr | fsm_state | fsm_trans | toggle |
|:---:|---|---|---|---|---|---|---|---|
| ⚠️ | [`BASIC`](REPORT/buckets/BASIC.md) | 95.70 | 92.21 | 81.03 | 100.00 | 100.00 | 77.77 | 53.02 |
| ⚠️ | [`EDGE`](REPORT/buckets/EDGE.md) | 95.88 | 91.01 | 81.03 | 100.00 | 100.00 | 100.00 | 53.84 |
| ⚠️ | [`PROF`](REPORT/buckets/PROF.md) | 95.29 | 87.45 | 79.31 | 50.00 | 100.00 | 66.66 | 53.45 |
| ⚠️ | [`ERROR`](REPORT/buckets/ERROR.md) | 96.26 | 92.60 | 86.20 | 100.00 | 100.00 | 88.88 | 56.01 |

## Continuous-frame baselines by build

<!-- one row per bucket_frame / all_buckets_frame signoff run (see REPORT/cross/ for curves). -->

| status | run_id | kind | build | bucket | case_count | stmt | branch | toggle | functional_cross_pct | txns |
|:---:|---|---|---|---|---:|---|---|---|---:|---:|
| ✅ | [`mtsp_explicit_521_ordered_isolated_merge`](REPORT/cross/mtsp_explicit_521_ordered_isolated_merge.md) | ordered_isolated_merge | after | - | 521 | 98.31 | 96.10 | 58.95 | 100.0 | 29215 |
| ✅ | [`mtsp_bucket_frame_BASIC`](REPORT/cross/mtsp_bucket_frame_BASIC.md) | bucket_frame | after | BASIC | 130 | 84.55 | 74.01 | 28.49 | 100.0 | 130 |
| ✅ | [`mtsp_bucket_frame_EDGE`](REPORT/cross/mtsp_bucket_frame_EDGE.md) | bucket_frame | after | EDGE | 131 | 84.55 | 74.01 | 28.49 | 100.0 | 131 |
| ✅ | [`mtsp_bucket_frame_PROF`](REPORT/cross/mtsp_bucket_frame_PROF.md) | bucket_frame | after | PROF | 130 | 84.55 | 74.01 | 28.49 | 100.0 | 130 |
| ✅ | [`mtsp_bucket_frame_ERROR`](REPORT/cross/mtsp_bucket_frame_ERROR.md) | bucket_frame | after | ERROR | 130 | 84.55 | 74.01 | 28.49 | 100.0 | 130 |
| ✅ | [`mtsp_all_buckets_frame`](REPORT/cross/mtsp_all_buckets_frame.md) | all_buckets_frame | after | - | 521 | 85.87 | 76.37 | 32.34 | 100.0 | 521 |

_Regenerate with `python3 ~/.codex/skills/dv-workflow/scripts/dv_report_gen.py <tb>`._
