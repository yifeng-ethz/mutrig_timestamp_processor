# ✅ mtsp_bucket_frame_ERROR

**Kind:** `bucket_frame` &nbsp; **Build:** `after` &nbsp; **Bucket:** `ERROR` &nbsp; **Sequence:** `mtsp_continuous_frame_test ordered checkpoint stream`

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
| ℹ️ | case_count | `130` |
| ℹ️ | effort | `signoff` |
| ℹ️ | iter_cap | `None` |
| ℹ️ | payload_cap | `None` |
| ℹ️ | txns | `130` |
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
| ✅ | `inputs` | 130 | `== case_count (130)` |
| ✅ | `beats` | 134 | `>= case_count (130)` |
| ✅ | `payloads` | 130 | `== case_count (130)` |
| ✅ | `eops` | 4 | `> 0` |
| ✅ | `empty_eops` | 4 | `> 0` |
| ✅ | `debug_ts` | 130 | `== case_count (130)` |
| ✅ | `debug_burst` | 130 | `== case_count (130)` |
| ✅ | `ts_delta` | 130 | `== case_count (130)` |
| ✅ | `dual_path_pairs` | 130 | `== case_count (130)` |
| ✅ | `traces` | 130 | `== case_count (130)` |
| ✅ | `trace_detail_lines` | 130 | `== case_count (130)` |

## Transaction growth curve

<!-- each row is one transaction step: which planned case fired, current functional-cross percent, -->
<!-- delta_bins = number of new cross bins hit at this step; reason = scoreboard checkpoint trigger. -->

| txn | case | seq | pct | delta_bins | reason |
|---:|---|---|---|---:|---|
| 1 | `X001` | `bucket_frame` | 0.77 | 1 | normal_debug_checkpoint |
| 2 | `X002` | `bucket_frame` | 1.54 | 1 | normal_debug_checkpoint |
| 3 | `X003` | `bucket_frame` | 2.31 | 1 | normal_debug_checkpoint |
| 4 | `X004` | `bucket_frame` | 3.08 | 1 | normal_debug_checkpoint |
| 5 | `X005` | `bucket_frame` | 3.85 | 1 | normal_debug_checkpoint |
| 6 | `X006` | `bucket_frame` | 4.62 | 1 | normal_debug_checkpoint |
| 7 | `X007` | `bucket_frame` | 5.38 | 1 | normal_debug_checkpoint |
| 8 | `X008` | `bucket_frame` | 6.15 | 1 | normal_debug_checkpoint |
| 9 | `X009` | `bucket_frame` | 6.92 | 1 | normal_debug_checkpoint |
| 10 | `X010` | `bucket_frame` | 7.69 | 1 | normal_debug_checkpoint |
| 11 | `X011` | `bucket_frame` | 8.46 | 1 | normal_debug_checkpoint |
| 12 | `X012` | `bucket_frame` | 9.23 | 1 | normal_debug_checkpoint |
| 13 | `X013` | `bucket_frame` | 10.0 | 1 | normal_debug_checkpoint |
| 14 | `X014` | `bucket_frame` | 10.77 | 1 | normal_debug_checkpoint |
| 15 | `X015` | `bucket_frame` | 11.54 | 1 | normal_debug_checkpoint |
| 16 | `X016` | `bucket_frame` | 12.31 | 1 | normal_debug_checkpoint |
| 17 | `X017` | `bucket_frame` | 13.08 | 1 | normal_debug_checkpoint |
| 18 | `X018` | `bucket_frame` | 13.85 | 1 | normal_debug_checkpoint |
| 19 | `X019` | `bucket_frame` | 14.62 | 1 | normal_debug_checkpoint |
| 20 | `X020` | `bucket_frame` | 15.38 | 1 | normal_debug_checkpoint |
| 21 | `X021` | `bucket_frame` | 16.15 | 1 | normal_debug_checkpoint |
| 22 | `X022` | `bucket_frame` | 16.92 | 1 | normal_debug_checkpoint |
| 23 | `X023` | `bucket_frame` | 17.69 | 1 | normal_debug_checkpoint |
| 24 | `X024` | `bucket_frame` | 18.46 | 1 | normal_debug_checkpoint |
| 25 | `X025` | `bucket_frame` | 19.23 | 1 | normal_debug_checkpoint |
| 26 | `X026` | `bucket_frame` | 20.0 | 1 | normal_debug_checkpoint |
| 27 | `X027` | `bucket_frame` | 20.77 | 1 | normal_debug_checkpoint |
| 28 | `X028` | `bucket_frame` | 21.54 | 1 | normal_debug_checkpoint |
| 29 | `X029` | `bucket_frame` | 22.31 | 1 | normal_debug_checkpoint |
| 30 | `X030` | `bucket_frame` | 23.08 | 1 | normal_debug_checkpoint |
| 31 | `X031` | `bucket_frame` | 23.85 | 1 | normal_debug_checkpoint |
| 32 | `X032` | `bucket_frame` | 24.62 | 1 | normal_debug_checkpoint |
| 33 | `X033` | `bucket_frame` | 25.38 | 1 | normal_debug_checkpoint |
| 34 | `X034` | `bucket_frame` | 26.15 | 1 | normal_debug_checkpoint |
| 35 | `X035` | `bucket_frame` | 26.92 | 1 | normal_debug_checkpoint |
| 36 | `X036` | `bucket_frame` | 27.69 | 1 | normal_debug_checkpoint |
| 37 | `X037` | `bucket_frame` | 28.46 | 1 | normal_debug_checkpoint |
| 38 | `X038` | `bucket_frame` | 29.23 | 1 | normal_debug_checkpoint |
| 39 | `X039` | `bucket_frame` | 30.0 | 1 | normal_debug_checkpoint |
| 40 | `X040` | `bucket_frame` | 30.77 | 1 | normal_debug_checkpoint |
| 41 | `X041` | `bucket_frame` | 31.54 | 1 | normal_debug_checkpoint |
| 42 | `X042` | `bucket_frame` | 32.31 | 1 | normal_debug_checkpoint |
| 43 | `X043` | `bucket_frame` | 33.08 | 1 | normal_debug_checkpoint |
| 44 | `X044` | `bucket_frame` | 33.85 | 1 | normal_debug_checkpoint |
| 45 | `X045` | `bucket_frame` | 34.62 | 1 | normal_debug_checkpoint |
| 46 | `X046` | `bucket_frame` | 35.38 | 1 | normal_debug_checkpoint |
| 47 | `X047` | `bucket_frame` | 36.15 | 1 | normal_debug_checkpoint |
| 48 | `X048` | `bucket_frame` | 36.92 | 1 | normal_debug_checkpoint |
| 49 | `X049` | `bucket_frame` | 37.69 | 1 | normal_debug_checkpoint |
| 50 | `X050` | `bucket_frame` | 38.46 | 1 | normal_debug_checkpoint |
| 51 | `X051` | `bucket_frame` | 39.23 | 1 | normal_debug_checkpoint |
| 52 | `X052` | `bucket_frame` | 40.0 | 1 | normal_debug_checkpoint |
| 53 | `X053` | `bucket_frame` | 40.77 | 1 | normal_debug_checkpoint |
| 54 | `X054` | `bucket_frame` | 41.54 | 1 | normal_debug_checkpoint |
| 55 | `X055` | `bucket_frame` | 42.31 | 1 | normal_debug_checkpoint |
| 56 | `X056` | `bucket_frame` | 43.08 | 1 | normal_debug_checkpoint |
| 57 | `X057` | `bucket_frame` | 43.85 | 1 | normal_debug_checkpoint |
| 58 | `X058` | `bucket_frame` | 44.62 | 1 | normal_debug_checkpoint |
| 59 | `X059` | `bucket_frame` | 45.38 | 1 | normal_debug_checkpoint |
| 60 | `X060` | `bucket_frame` | 46.15 | 1 | normal_debug_checkpoint |
| 61 | `X061` | `bucket_frame` | 46.92 | 1 | normal_debug_checkpoint |
| 62 | `X062` | `bucket_frame` | 47.69 | 1 | normal_debug_checkpoint |
| 63 | `X063` | `bucket_frame` | 48.46 | 1 | normal_debug_checkpoint |
| 64 | `X064` | `bucket_frame` | 49.23 | 1 | normal_debug_checkpoint |
| 65 | `X065` | `bucket_frame` | 50.0 | 1 | normal_debug_checkpoint |
| 66 | `X066` | `bucket_frame` | 50.77 | 1 | normal_debug_checkpoint |
| 67 | `X067` | `bucket_frame` | 51.54 | 1 | normal_debug_checkpoint |
| 68 | `X068` | `bucket_frame` | 52.31 | 1 | normal_debug_checkpoint |
| 69 | `X069` | `bucket_frame` | 53.08 | 1 | normal_debug_checkpoint |
| 70 | `X070` | `bucket_frame` | 53.85 | 1 | normal_debug_checkpoint |
| 71 | `X071` | `bucket_frame` | 54.62 | 1 | normal_debug_checkpoint |
| 72 | `X072` | `bucket_frame` | 55.38 | 1 | normal_debug_checkpoint |
| 73 | `X073` | `bucket_frame` | 56.15 | 1 | normal_debug_checkpoint |
| 74 | `X074` | `bucket_frame` | 56.92 | 1 | normal_debug_checkpoint |
| 75 | `X075` | `bucket_frame` | 57.69 | 1 | normal_debug_checkpoint |
| 76 | `X076` | `bucket_frame` | 58.46 | 1 | normal_debug_checkpoint |
| 77 | `X077` | `bucket_frame` | 59.23 | 1 | normal_debug_checkpoint |
| 78 | `X078` | `bucket_frame` | 60.0 | 1 | normal_debug_checkpoint |
| 79 | `X079` | `bucket_frame` | 60.77 | 1 | normal_debug_checkpoint |
| 80 | `X080` | `bucket_frame` | 61.54 | 1 | normal_debug_checkpoint |
| 81 | `X081` | `bucket_frame` | 62.31 | 1 | normal_debug_checkpoint |
| 82 | `X082` | `bucket_frame` | 63.08 | 1 | normal_debug_checkpoint |
| 83 | `X083` | `bucket_frame` | 63.85 | 1 | normal_debug_checkpoint |
| 84 | `X084` | `bucket_frame` | 64.62 | 1 | normal_debug_checkpoint |
| 85 | `X085` | `bucket_frame` | 65.38 | 1 | normal_debug_checkpoint |
| 86 | `X086` | `bucket_frame` | 66.15 | 1 | normal_debug_checkpoint |
| 87 | `X087` | `bucket_frame` | 66.92 | 1 | normal_debug_checkpoint |
| 88 | `X088` | `bucket_frame` | 67.69 | 1 | normal_debug_checkpoint |
| 89 | `X089` | `bucket_frame` | 68.46 | 1 | normal_debug_checkpoint |
| 90 | `X090` | `bucket_frame` | 69.23 | 1 | normal_debug_checkpoint |
| 91 | `X091` | `bucket_frame` | 70.0 | 1 | normal_debug_checkpoint |
| 92 | `X092` | `bucket_frame` | 70.77 | 1 | normal_debug_checkpoint |
| 93 | `X093` | `bucket_frame` | 71.54 | 1 | normal_debug_checkpoint |
| 94 | `X094` | `bucket_frame` | 72.31 | 1 | normal_debug_checkpoint |
| 95 | `X095` | `bucket_frame` | 73.08 | 1 | normal_debug_checkpoint |
| 96 | `X096` | `bucket_frame` | 73.85 | 1 | normal_debug_checkpoint |
| 97 | `X097` | `bucket_frame` | 74.62 | 1 | normal_debug_checkpoint |
| 98 | `X098` | `bucket_frame` | 75.38 | 1 | normal_debug_checkpoint |
| 99 | `X099` | `bucket_frame` | 76.15 | 1 | normal_debug_checkpoint |
| 100 | `X100` | `bucket_frame` | 76.92 | 1 | normal_debug_checkpoint |
| 101 | `X101` | `bucket_frame` | 77.69 | 1 | normal_debug_checkpoint |
| 102 | `X102` | `bucket_frame` | 78.46 | 1 | normal_debug_checkpoint |
| 103 | `X103` | `bucket_frame` | 79.23 | 1 | normal_debug_checkpoint |
| 104 | `X104` | `bucket_frame` | 80.0 | 1 | normal_debug_checkpoint |
| 105 | `X105` | `bucket_frame` | 80.77 | 1 | normal_debug_checkpoint |
| 106 | `X106` | `bucket_frame` | 81.54 | 1 | normal_debug_checkpoint |
| 107 | `X107` | `bucket_frame` | 82.31 | 1 | normal_debug_checkpoint |
| 108 | `X108` | `bucket_frame` | 83.08 | 1 | normal_debug_checkpoint |
| 109 | `X109` | `bucket_frame` | 83.85 | 1 | normal_debug_checkpoint |
| 110 | `X110` | `bucket_frame` | 84.62 | 1 | normal_debug_checkpoint |
| 111 | `X111` | `bucket_frame` | 85.38 | 1 | normal_debug_checkpoint |
| 112 | `X112` | `bucket_frame` | 86.15 | 1 | normal_debug_checkpoint |
| 113 | `X113` | `bucket_frame` | 86.92 | 1 | normal_debug_checkpoint |
| 114 | `X114` | `bucket_frame` | 87.69 | 1 | normal_debug_checkpoint |
| 115 | `X115` | `bucket_frame` | 88.46 | 1 | normal_debug_checkpoint |
| 116 | `X116` | `bucket_frame` | 89.23 | 1 | normal_debug_checkpoint |
| 117 | `X117` | `bucket_frame` | 90.0 | 1 | normal_debug_checkpoint |
| 118 | `X118` | `bucket_frame` | 90.77 | 1 | normal_debug_checkpoint |
| 119 | `X119` | `bucket_frame` | 91.54 | 1 | normal_debug_checkpoint |
| 120 | `X120` | `bucket_frame` | 92.31 | 1 | normal_debug_checkpoint |
| 121 | `X121` | `bucket_frame` | 93.08 | 1 | normal_debug_checkpoint |
| 122 | `X122` | `bucket_frame` | 93.85 | 1 | normal_debug_checkpoint |
| 123 | `X123` | `bucket_frame` | 94.62 | 1 | normal_debug_checkpoint |
| 124 | `X124` | `bucket_frame` | 95.38 | 1 | normal_debug_checkpoint |
| 125 | `X125` | `bucket_frame` | 96.15 | 1 | normal_debug_checkpoint |
| 126 | `X126` | `bucket_frame` | 96.92 | 1 | normal_debug_checkpoint |
| 127 | `X127` | `bucket_frame` | 97.69 | 1 | normal_debug_checkpoint |
| 128 | `X128` | `bucket_frame` | 98.46 | 1 | normal_debug_checkpoint |
| 129 | `X129` | `bucket_frame` | 99.23 | 1 | normal_debug_checkpoint |
| 130 | `X130` | `bucket_frame` | 100.0 | 1 | normal_debug_checkpoint |

---
_Back to [dashboard](../../DV_REPORT.md)_
