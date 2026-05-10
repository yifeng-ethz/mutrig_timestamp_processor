# ✅ mtsp_bucket_frame_EDGE

**Kind:** `bucket_frame` &nbsp; **Build:** `after` &nbsp; **Bucket:** `EDGE` &nbsp; **Sequence:** `mtsp_continuous_frame_test ordered checkpoint stream`

## Summary

<!-- field legend:
  case_count              = number of plan cases composed into this run
  effort                  = practical (capped per case) or extensive (full planned stress)
  iter_cap, payload_cap   = practical-mode budget caps
  txns                    = total transactions driven through the DUT in this run
  functional_cross_pct    = functional coverage against DV_CROSS.md (percent)
  queued_overlap          = transactions enqueued before the previous drained
  counter_checks_failed   = scoreboard counter mismatches observed (0 is required for pass)
  unexpected_outputs      = outputs the scoreboard did not predict
-->

| status | field | value |
|:---:|---|---|
| ℹ️ | case_count | `131` |
| ℹ️ | effort | `signoff` |
| ℹ️ | iter_cap | `None` |
| ℹ️ | payload_cap | `None` |
| ℹ️ | txns | `131` |
| ✅ | functional_cross_pct | `100.0` |
| ℹ️ | queued_overlap | `0` |
| ✅ | counter_checks_failed | `0` |
| ✅ | unexpected_outputs | `0` |

## Code coverage

<!-- merged code coverage produced by this single run (not ordered-merged into any bucket). -->

| metric | pct |
|---|---|
| stmt | 84.55 |
| branch | 74.01 |
| cond | 50.86 |
| expr | 50.00 |
| fsm_state | 100.00 |
| fsm_trans | 44.44 |
| toggle | 28.49 |

## Scoreboard Evidence

<!-- analysis-port evidence from normal payload, debug timestamp, debug burst, and timestamp-delta monitors. -->

| status | port/counter | observed | requirement |
|:---:|---|---:|---|
| ✅ | `inputs` | 131 | `== case_count (131)` |
| ✅ | `beats` | 135 | `>= case_count (131)` |
| ✅ | `payloads` | 131 | `== case_count (131)` |
| ✅ | `eops` | 4 | `> 0` |
| ✅ | `empty_eops` | 4 | `> 0` |
| ✅ | `debug_ts` | 131 | `== case_count (131)` |
| ✅ | `debug_burst` | 131 | `== case_count (131)` |
| ✅ | `ts_delta` | 131 | `== case_count (131)` |
| ✅ | `dual_path_pairs` | 131 | `== case_count (131)` |
| ✅ | `traces` | 131 | `== case_count (131)` |
| ✅ | `trace_detail_lines` | 131 | `== case_count (131)` |

## Transaction growth curve

<!-- each row is one transaction step: which planned case fired, current functional-cross percent, -->
<!-- delta_bins = number of new cross bins hit at this step; reason = scoreboard checkpoint trigger. -->

| txn | case | seq | pct | delta_bins | reason |
|---:|---|---|---|---:|---|
| 1 | `E001` | `bucket_frame` | 0.76 | 1 | normal_debug_checkpoint |
| 2 | `E002` | `bucket_frame` | 1.53 | 1 | normal_debug_checkpoint |
| 3 | `E003` | `bucket_frame` | 2.29 | 1 | normal_debug_checkpoint |
| 4 | `E004` | `bucket_frame` | 3.05 | 1 | normal_debug_checkpoint |
| 5 | `E005` | `bucket_frame` | 3.82 | 1 | normal_debug_checkpoint |
| 6 | `E006` | `bucket_frame` | 4.58 | 1 | normal_debug_checkpoint |
| 7 | `E007` | `bucket_frame` | 5.34 | 1 | normal_debug_checkpoint |
| 8 | `E008` | `bucket_frame` | 6.11 | 1 | normal_debug_checkpoint |
| 9 | `E009` | `bucket_frame` | 6.87 | 1 | normal_debug_checkpoint |
| 10 | `E010` | `bucket_frame` | 7.63 | 1 | normal_debug_checkpoint |
| 11 | `E011` | `bucket_frame` | 8.4 | 1 | normal_debug_checkpoint |
| 12 | `E012` | `bucket_frame` | 9.16 | 1 | normal_debug_checkpoint |
| 13 | `E013` | `bucket_frame` | 9.92 | 1 | normal_debug_checkpoint |
| 14 | `E014` | `bucket_frame` | 10.69 | 1 | normal_debug_checkpoint |
| 15 | `E015` | `bucket_frame` | 11.45 | 1 | normal_debug_checkpoint |
| 16 | `E016` | `bucket_frame` | 12.21 | 1 | normal_debug_checkpoint |
| 17 | `E017` | `bucket_frame` | 12.98 | 1 | normal_debug_checkpoint |
| 18 | `E018` | `bucket_frame` | 13.74 | 1 | normal_debug_checkpoint |
| 19 | `E019` | `bucket_frame` | 14.5 | 1 | normal_debug_checkpoint |
| 20 | `E020` | `bucket_frame` | 15.27 | 1 | normal_debug_checkpoint |
| 21 | `E021` | `bucket_frame` | 16.03 | 1 | normal_debug_checkpoint |
| 22 | `E022` | `bucket_frame` | 16.79 | 1 | normal_debug_checkpoint |
| 23 | `E023` | `bucket_frame` | 17.56 | 1 | normal_debug_checkpoint |
| 24 | `E024` | `bucket_frame` | 18.32 | 1 | normal_debug_checkpoint |
| 25 | `E025` | `bucket_frame` | 19.08 | 1 | normal_debug_checkpoint |
| 26 | `E026` | `bucket_frame` | 19.85 | 1 | normal_debug_checkpoint |
| 27 | `E027` | `bucket_frame` | 20.61 | 1 | normal_debug_checkpoint |
| 28 | `E028` | `bucket_frame` | 21.37 | 1 | normal_debug_checkpoint |
| 29 | `E029` | `bucket_frame` | 22.14 | 1 | normal_debug_checkpoint |
| 30 | `E030` | `bucket_frame` | 22.9 | 1 | normal_debug_checkpoint |
| 31 | `E031` | `bucket_frame` | 23.66 | 1 | normal_debug_checkpoint |
| 32 | `E032` | `bucket_frame` | 24.43 | 1 | normal_debug_checkpoint |
| 33 | `E033` | `bucket_frame` | 25.19 | 1 | normal_debug_checkpoint |
| 34 | `E034` | `bucket_frame` | 25.95 | 1 | normal_debug_checkpoint |
| 35 | `E035` | `bucket_frame` | 26.72 | 1 | normal_debug_checkpoint |
| 36 | `E036` | `bucket_frame` | 27.48 | 1 | normal_debug_checkpoint |
| 37 | `E037` | `bucket_frame` | 28.24 | 1 | normal_debug_checkpoint |
| 38 | `E038` | `bucket_frame` | 29.01 | 1 | normal_debug_checkpoint |
| 39 | `E039` | `bucket_frame` | 29.77 | 1 | normal_debug_checkpoint |
| 40 | `E040` | `bucket_frame` | 30.53 | 1 | normal_debug_checkpoint |
| 41 | `E041` | `bucket_frame` | 31.3 | 1 | normal_debug_checkpoint |
| 42 | `E042` | `bucket_frame` | 32.06 | 1 | normal_debug_checkpoint |
| 43 | `E043` | `bucket_frame` | 32.82 | 1 | normal_debug_checkpoint |
| 44 | `E044` | `bucket_frame` | 33.59 | 1 | normal_debug_checkpoint |
| 45 | `E045` | `bucket_frame` | 34.35 | 1 | normal_debug_checkpoint |
| 46 | `E046` | `bucket_frame` | 35.11 | 1 | normal_debug_checkpoint |
| 47 | `E047` | `bucket_frame` | 35.88 | 1 | normal_debug_checkpoint |
| 48 | `E048` | `bucket_frame` | 36.64 | 1 | normal_debug_checkpoint |
| 49 | `E049` | `bucket_frame` | 37.4 | 1 | normal_debug_checkpoint |
| 50 | `E050` | `bucket_frame` | 38.17 | 1 | normal_debug_checkpoint |
| 51 | `E051` | `bucket_frame` | 38.93 | 1 | normal_debug_checkpoint |
| 52 | `E052` | `bucket_frame` | 39.69 | 1 | normal_debug_checkpoint |
| 53 | `E053` | `bucket_frame` | 40.46 | 1 | normal_debug_checkpoint |
| 54 | `E054` | `bucket_frame` | 41.22 | 1 | normal_debug_checkpoint |
| 55 | `E055` | `bucket_frame` | 41.98 | 1 | normal_debug_checkpoint |
| 56 | `E056` | `bucket_frame` | 42.75 | 1 | normal_debug_checkpoint |
| 57 | `E057` | `bucket_frame` | 43.51 | 1 | normal_debug_checkpoint |
| 58 | `E058` | `bucket_frame` | 44.27 | 1 | normal_debug_checkpoint |
| 59 | `E059` | `bucket_frame` | 45.04 | 1 | normal_debug_checkpoint |
| 60 | `E060` | `bucket_frame` | 45.8 | 1 | normal_debug_checkpoint |
| 61 | `E061` | `bucket_frame` | 46.56 | 1 | normal_debug_checkpoint |
| 62 | `E062` | `bucket_frame` | 47.33 | 1 | normal_debug_checkpoint |
| 63 | `E063` | `bucket_frame` | 48.09 | 1 | normal_debug_checkpoint |
| 64 | `E064` | `bucket_frame` | 48.85 | 1 | normal_debug_checkpoint |
| 65 | `E065` | `bucket_frame` | 49.62 | 1 | normal_debug_checkpoint |
| 66 | `E066` | `bucket_frame` | 50.38 | 1 | normal_debug_checkpoint |
| 67 | `E067` | `bucket_frame` | 51.15 | 1 | normal_debug_checkpoint |
| 68 | `E068` | `bucket_frame` | 51.91 | 1 | normal_debug_checkpoint |
| 69 | `E069` | `bucket_frame` | 52.67 | 1 | normal_debug_checkpoint |
| 70 | `E070` | `bucket_frame` | 53.44 | 1 | normal_debug_checkpoint |
| 71 | `E071` | `bucket_frame` | 54.2 | 1 | normal_debug_checkpoint |
| 72 | `E072` | `bucket_frame` | 54.96 | 1 | normal_debug_checkpoint |
| 73 | `E073` | `bucket_frame` | 55.73 | 1 | normal_debug_checkpoint |
| 74 | `E074` | `bucket_frame` | 56.49 | 1 | normal_debug_checkpoint |
| 75 | `E075` | `bucket_frame` | 57.25 | 1 | normal_debug_checkpoint |
| 76 | `E076` | `bucket_frame` | 58.02 | 1 | normal_debug_checkpoint |
| 77 | `E077` | `bucket_frame` | 58.78 | 1 | normal_debug_checkpoint |
| 78 | `E078` | `bucket_frame` | 59.54 | 1 | normal_debug_checkpoint |
| 79 | `E079` | `bucket_frame` | 60.31 | 1 | normal_debug_checkpoint |
| 80 | `E080` | `bucket_frame` | 61.07 | 1 | normal_debug_checkpoint |
| 81 | `E081` | `bucket_frame` | 61.83 | 1 | normal_debug_checkpoint |
| 82 | `E082` | `bucket_frame` | 62.6 | 1 | normal_debug_checkpoint |
| 83 | `E083` | `bucket_frame` | 63.36 | 1 | normal_debug_checkpoint |
| 84 | `E084` | `bucket_frame` | 64.12 | 1 | normal_debug_checkpoint |
| 85 | `E085` | `bucket_frame` | 64.89 | 1 | normal_debug_checkpoint |
| 86 | `E086` | `bucket_frame` | 65.65 | 1 | normal_debug_checkpoint |
| 87 | `E087` | `bucket_frame` | 66.41 | 1 | normal_debug_checkpoint |
| 88 | `E088` | `bucket_frame` | 67.18 | 1 | normal_debug_checkpoint |
| 89 | `E089` | `bucket_frame` | 67.94 | 1 | normal_debug_checkpoint |
| 90 | `E090` | `bucket_frame` | 68.7 | 1 | normal_debug_checkpoint |
| 91 | `E091` | `bucket_frame` | 69.47 | 1 | normal_debug_checkpoint |
| 92 | `E092` | `bucket_frame` | 70.23 | 1 | normal_debug_checkpoint |
| 93 | `E093` | `bucket_frame` | 70.99 | 1 | normal_debug_checkpoint |
| 94 | `E094` | `bucket_frame` | 71.76 | 1 | normal_debug_checkpoint |
| 95 | `E095` | `bucket_frame` | 72.52 | 1 | normal_debug_checkpoint |
| 96 | `E096` | `bucket_frame` | 73.28 | 1 | normal_debug_checkpoint |
| 97 | `E097` | `bucket_frame` | 74.05 | 1 | normal_debug_checkpoint |
| 98 | `E098` | `bucket_frame` | 74.81 | 1 | normal_debug_checkpoint |
| 99 | `E099` | `bucket_frame` | 75.57 | 1 | normal_debug_checkpoint |
| 100 | `E100` | `bucket_frame` | 76.34 | 1 | normal_debug_checkpoint |
| 101 | `E101` | `bucket_frame` | 77.1 | 1 | normal_debug_checkpoint |
| 102 | `E102` | `bucket_frame` | 77.86 | 1 | normal_debug_checkpoint |
| 103 | `E103` | `bucket_frame` | 78.63 | 1 | normal_debug_checkpoint |
| 104 | `E104` | `bucket_frame` | 79.39 | 1 | normal_debug_checkpoint |
| 105 | `E105` | `bucket_frame` | 80.15 | 1 | normal_debug_checkpoint |
| 106 | `E106` | `bucket_frame` | 80.92 | 1 | normal_debug_checkpoint |
| 107 | `E107` | `bucket_frame` | 81.68 | 1 | normal_debug_checkpoint |
| 108 | `E108` | `bucket_frame` | 82.44 | 1 | normal_debug_checkpoint |
| 109 | `E109` | `bucket_frame` | 83.21 | 1 | normal_debug_checkpoint |
| 110 | `E110` | `bucket_frame` | 83.97 | 1 | normal_debug_checkpoint |
| 111 | `E111` | `bucket_frame` | 84.73 | 1 | normal_debug_checkpoint |
| 112 | `E112` | `bucket_frame` | 85.5 | 1 | normal_debug_checkpoint |
| 113 | `E113` | `bucket_frame` | 86.26 | 1 | normal_debug_checkpoint |
| 114 | `E114` | `bucket_frame` | 87.02 | 1 | normal_debug_checkpoint |
| 115 | `E115` | `bucket_frame` | 87.79 | 1 | normal_debug_checkpoint |
| 116 | `E116` | `bucket_frame` | 88.55 | 1 | normal_debug_checkpoint |
| 117 | `E117` | `bucket_frame` | 89.31 | 1 | normal_debug_checkpoint |
| 118 | `E118` | `bucket_frame` | 90.08 | 1 | normal_debug_checkpoint |
| 119 | `E119` | `bucket_frame` | 90.84 | 1 | normal_debug_checkpoint |
| 120 | `E120` | `bucket_frame` | 91.6 | 1 | normal_debug_checkpoint |
| 121 | `E121` | `bucket_frame` | 92.37 | 1 | normal_debug_checkpoint |
| 122 | `E122` | `bucket_frame` | 93.13 | 1 | normal_debug_checkpoint |
| 123 | `E123` | `bucket_frame` | 93.89 | 1 | normal_debug_checkpoint |
| 124 | `E124` | `bucket_frame` | 94.66 | 1 | normal_debug_checkpoint |
| 125 | `E125` | `bucket_frame` | 95.42 | 1 | normal_debug_checkpoint |
| 126 | `E126` | `bucket_frame` | 96.18 | 1 | normal_debug_checkpoint |
| 127 | `E127` | `bucket_frame` | 96.95 | 1 | normal_debug_checkpoint |
| 128 | `E128` | `bucket_frame` | 97.71 | 1 | normal_debug_checkpoint |
| 129 | `E129` | `bucket_frame` | 98.47 | 1 | normal_debug_checkpoint |
| 130 | `E130` | `bucket_frame` | 99.24 | 1 | normal_debug_checkpoint |
| 131 | `E131` | `bucket_frame` | 100.0 | 1 | normal_debug_checkpoint |

---
_Back to [dashboard](../../DV_REPORT.md)_
