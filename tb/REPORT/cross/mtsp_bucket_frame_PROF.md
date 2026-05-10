# ✅ mtsp_bucket_frame_PROF

**Kind:** `bucket_frame` &nbsp; **Build:** `after` &nbsp; **Bucket:** `PROF` &nbsp; **Sequence:** `mtsp_continuous_frame_test ordered checkpoint stream`

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
| 1 | `P001` | `bucket_frame` | 0.77 | 1 | normal_debug_checkpoint |
| 2 | `P002` | `bucket_frame` | 1.54 | 1 | normal_debug_checkpoint |
| 3 | `P003` | `bucket_frame` | 2.31 | 1 | normal_debug_checkpoint |
| 4 | `P004` | `bucket_frame` | 3.08 | 1 | normal_debug_checkpoint |
| 5 | `P005` | `bucket_frame` | 3.85 | 1 | normal_debug_checkpoint |
| 6 | `P006` | `bucket_frame` | 4.62 | 1 | normal_debug_checkpoint |
| 7 | `P007` | `bucket_frame` | 5.38 | 1 | normal_debug_checkpoint |
| 8 | `P008` | `bucket_frame` | 6.15 | 1 | normal_debug_checkpoint |
| 9 | `P009` | `bucket_frame` | 6.92 | 1 | normal_debug_checkpoint |
| 10 | `P010` | `bucket_frame` | 7.69 | 1 | normal_debug_checkpoint |
| 11 | `P011` | `bucket_frame` | 8.46 | 1 | normal_debug_checkpoint |
| 12 | `P012` | `bucket_frame` | 9.23 | 1 | normal_debug_checkpoint |
| 13 | `P013` | `bucket_frame` | 10.0 | 1 | normal_debug_checkpoint |
| 14 | `P014` | `bucket_frame` | 10.77 | 1 | normal_debug_checkpoint |
| 15 | `P015` | `bucket_frame` | 11.54 | 1 | normal_debug_checkpoint |
| 16 | `P016` | `bucket_frame` | 12.31 | 1 | normal_debug_checkpoint |
| 17 | `P017` | `bucket_frame` | 13.08 | 1 | normal_debug_checkpoint |
| 18 | `P018` | `bucket_frame` | 13.85 | 1 | normal_debug_checkpoint |
| 19 | `P019` | `bucket_frame` | 14.62 | 1 | normal_debug_checkpoint |
| 20 | `P020` | `bucket_frame` | 15.38 | 1 | normal_debug_checkpoint |
| 21 | `P021` | `bucket_frame` | 16.15 | 1 | normal_debug_checkpoint |
| 22 | `P022` | `bucket_frame` | 16.92 | 1 | normal_debug_checkpoint |
| 23 | `P023` | `bucket_frame` | 17.69 | 1 | normal_debug_checkpoint |
| 24 | `P024` | `bucket_frame` | 18.46 | 1 | normal_debug_checkpoint |
| 25 | `P025` | `bucket_frame` | 19.23 | 1 | normal_debug_checkpoint |
| 26 | `P026` | `bucket_frame` | 20.0 | 1 | normal_debug_checkpoint |
| 27 | `P027` | `bucket_frame` | 20.77 | 1 | normal_debug_checkpoint |
| 28 | `P028` | `bucket_frame` | 21.54 | 1 | normal_debug_checkpoint |
| 29 | `P029` | `bucket_frame` | 22.31 | 1 | normal_debug_checkpoint |
| 30 | `P030` | `bucket_frame` | 23.08 | 1 | normal_debug_checkpoint |
| 31 | `P031` | `bucket_frame` | 23.85 | 1 | normal_debug_checkpoint |
| 32 | `P032` | `bucket_frame` | 24.62 | 1 | normal_debug_checkpoint |
| 33 | `P033` | `bucket_frame` | 25.38 | 1 | normal_debug_checkpoint |
| 34 | `P034` | `bucket_frame` | 26.15 | 1 | normal_debug_checkpoint |
| 35 | `P035` | `bucket_frame` | 26.92 | 1 | normal_debug_checkpoint |
| 36 | `P036` | `bucket_frame` | 27.69 | 1 | normal_debug_checkpoint |
| 37 | `P037` | `bucket_frame` | 28.46 | 1 | normal_debug_checkpoint |
| 38 | `P038` | `bucket_frame` | 29.23 | 1 | normal_debug_checkpoint |
| 39 | `P039` | `bucket_frame` | 30.0 | 1 | normal_debug_checkpoint |
| 40 | `P040` | `bucket_frame` | 30.77 | 1 | normal_debug_checkpoint |
| 41 | `P041` | `bucket_frame` | 31.54 | 1 | normal_debug_checkpoint |
| 42 | `P042` | `bucket_frame` | 32.31 | 1 | normal_debug_checkpoint |
| 43 | `P043` | `bucket_frame` | 33.08 | 1 | normal_debug_checkpoint |
| 44 | `P044` | `bucket_frame` | 33.85 | 1 | normal_debug_checkpoint |
| 45 | `P045` | `bucket_frame` | 34.62 | 1 | normal_debug_checkpoint |
| 46 | `P046` | `bucket_frame` | 35.38 | 1 | normal_debug_checkpoint |
| 47 | `P047` | `bucket_frame` | 36.15 | 1 | normal_debug_checkpoint |
| 48 | `P048` | `bucket_frame` | 36.92 | 1 | normal_debug_checkpoint |
| 49 | `P049` | `bucket_frame` | 37.69 | 1 | normal_debug_checkpoint |
| 50 | `P050` | `bucket_frame` | 38.46 | 1 | normal_debug_checkpoint |
| 51 | `P051` | `bucket_frame` | 39.23 | 1 | normal_debug_checkpoint |
| 52 | `P052` | `bucket_frame` | 40.0 | 1 | normal_debug_checkpoint |
| 53 | `P053` | `bucket_frame` | 40.77 | 1 | normal_debug_checkpoint |
| 54 | `P054` | `bucket_frame` | 41.54 | 1 | normal_debug_checkpoint |
| 55 | `P055` | `bucket_frame` | 42.31 | 1 | normal_debug_checkpoint |
| 56 | `P056` | `bucket_frame` | 43.08 | 1 | normal_debug_checkpoint |
| 57 | `P057` | `bucket_frame` | 43.85 | 1 | normal_debug_checkpoint |
| 58 | `P058` | `bucket_frame` | 44.62 | 1 | normal_debug_checkpoint |
| 59 | `P059` | `bucket_frame` | 45.38 | 1 | normal_debug_checkpoint |
| 60 | `P060` | `bucket_frame` | 46.15 | 1 | normal_debug_checkpoint |
| 61 | `P061` | `bucket_frame` | 46.92 | 1 | normal_debug_checkpoint |
| 62 | `P062` | `bucket_frame` | 47.69 | 1 | normal_debug_checkpoint |
| 63 | `P063` | `bucket_frame` | 48.46 | 1 | normal_debug_checkpoint |
| 64 | `P064` | `bucket_frame` | 49.23 | 1 | normal_debug_checkpoint |
| 65 | `P065` | `bucket_frame` | 50.0 | 1 | normal_debug_checkpoint |
| 66 | `P066` | `bucket_frame` | 50.77 | 1 | normal_debug_checkpoint |
| 67 | `P067` | `bucket_frame` | 51.54 | 1 | normal_debug_checkpoint |
| 68 | `P068` | `bucket_frame` | 52.31 | 1 | normal_debug_checkpoint |
| 69 | `P069` | `bucket_frame` | 53.08 | 1 | normal_debug_checkpoint |
| 70 | `P070` | `bucket_frame` | 53.85 | 1 | normal_debug_checkpoint |
| 71 | `P071` | `bucket_frame` | 54.62 | 1 | normal_debug_checkpoint |
| 72 | `P072` | `bucket_frame` | 55.38 | 1 | normal_debug_checkpoint |
| 73 | `P073` | `bucket_frame` | 56.15 | 1 | normal_debug_checkpoint |
| 74 | `P074` | `bucket_frame` | 56.92 | 1 | normal_debug_checkpoint |
| 75 | `P075` | `bucket_frame` | 57.69 | 1 | normal_debug_checkpoint |
| 76 | `P076` | `bucket_frame` | 58.46 | 1 | normal_debug_checkpoint |
| 77 | `P077` | `bucket_frame` | 59.23 | 1 | normal_debug_checkpoint |
| 78 | `P078` | `bucket_frame` | 60.0 | 1 | normal_debug_checkpoint |
| 79 | `P079` | `bucket_frame` | 60.77 | 1 | normal_debug_checkpoint |
| 80 | `P080` | `bucket_frame` | 61.54 | 1 | normal_debug_checkpoint |
| 81 | `P081` | `bucket_frame` | 62.31 | 1 | normal_debug_checkpoint |
| 82 | `P082` | `bucket_frame` | 63.08 | 1 | normal_debug_checkpoint |
| 83 | `P083` | `bucket_frame` | 63.85 | 1 | normal_debug_checkpoint |
| 84 | `P084` | `bucket_frame` | 64.62 | 1 | normal_debug_checkpoint |
| 85 | `P085` | `bucket_frame` | 65.38 | 1 | normal_debug_checkpoint |
| 86 | `P086` | `bucket_frame` | 66.15 | 1 | normal_debug_checkpoint |
| 87 | `P087` | `bucket_frame` | 66.92 | 1 | normal_debug_checkpoint |
| 88 | `P088` | `bucket_frame` | 67.69 | 1 | normal_debug_checkpoint |
| 89 | `P089` | `bucket_frame` | 68.46 | 1 | normal_debug_checkpoint |
| 90 | `P090` | `bucket_frame` | 69.23 | 1 | normal_debug_checkpoint |
| 91 | `P091` | `bucket_frame` | 70.0 | 1 | normal_debug_checkpoint |
| 92 | `P092` | `bucket_frame` | 70.77 | 1 | normal_debug_checkpoint |
| 93 | `P093` | `bucket_frame` | 71.54 | 1 | normal_debug_checkpoint |
| 94 | `P094` | `bucket_frame` | 72.31 | 1 | normal_debug_checkpoint |
| 95 | `P095` | `bucket_frame` | 73.08 | 1 | normal_debug_checkpoint |
| 96 | `P096` | `bucket_frame` | 73.85 | 1 | normal_debug_checkpoint |
| 97 | `P097` | `bucket_frame` | 74.62 | 1 | normal_debug_checkpoint |
| 98 | `P098` | `bucket_frame` | 75.38 | 1 | normal_debug_checkpoint |
| 99 | `P099` | `bucket_frame` | 76.15 | 1 | normal_debug_checkpoint |
| 100 | `P100` | `bucket_frame` | 76.92 | 1 | normal_debug_checkpoint |
| 101 | `P101` | `bucket_frame` | 77.69 | 1 | normal_debug_checkpoint |
| 102 | `P102` | `bucket_frame` | 78.46 | 1 | normal_debug_checkpoint |
| 103 | `P103` | `bucket_frame` | 79.23 | 1 | normal_debug_checkpoint |
| 104 | `P104` | `bucket_frame` | 80.0 | 1 | normal_debug_checkpoint |
| 105 | `P105` | `bucket_frame` | 80.77 | 1 | normal_debug_checkpoint |
| 106 | `P106` | `bucket_frame` | 81.54 | 1 | normal_debug_checkpoint |
| 107 | `P107` | `bucket_frame` | 82.31 | 1 | normal_debug_checkpoint |
| 108 | `P108` | `bucket_frame` | 83.08 | 1 | normal_debug_checkpoint |
| 109 | `P109` | `bucket_frame` | 83.85 | 1 | normal_debug_checkpoint |
| 110 | `P110` | `bucket_frame` | 84.62 | 1 | normal_debug_checkpoint |
| 111 | `P111` | `bucket_frame` | 85.38 | 1 | normal_debug_checkpoint |
| 112 | `P112` | `bucket_frame` | 86.15 | 1 | normal_debug_checkpoint |
| 113 | `P113` | `bucket_frame` | 86.92 | 1 | normal_debug_checkpoint |
| 114 | `P114` | `bucket_frame` | 87.69 | 1 | normal_debug_checkpoint |
| 115 | `P115` | `bucket_frame` | 88.46 | 1 | normal_debug_checkpoint |
| 116 | `P116` | `bucket_frame` | 89.23 | 1 | normal_debug_checkpoint |
| 117 | `P117` | `bucket_frame` | 90.0 | 1 | normal_debug_checkpoint |
| 118 | `P118` | `bucket_frame` | 90.77 | 1 | normal_debug_checkpoint |
| 119 | `P119` | `bucket_frame` | 91.54 | 1 | normal_debug_checkpoint |
| 120 | `P120` | `bucket_frame` | 92.31 | 1 | normal_debug_checkpoint |
| 121 | `P121` | `bucket_frame` | 93.08 | 1 | normal_debug_checkpoint |
| 122 | `P122` | `bucket_frame` | 93.85 | 1 | normal_debug_checkpoint |
| 123 | `P123` | `bucket_frame` | 94.62 | 1 | normal_debug_checkpoint |
| 124 | `P124` | `bucket_frame` | 95.38 | 1 | normal_debug_checkpoint |
| 125 | `P125` | `bucket_frame` | 96.15 | 1 | normal_debug_checkpoint |
| 126 | `P126` | `bucket_frame` | 96.92 | 1 | normal_debug_checkpoint |
| 127 | `P127` | `bucket_frame` | 97.69 | 1 | normal_debug_checkpoint |
| 128 | `P128` | `bucket_frame` | 98.46 | 1 | normal_debug_checkpoint |
| 129 | `P129` | `bucket_frame` | 99.23 | 1 | normal_debug_checkpoint |
| 130 | `P130` | `bucket_frame` | 100.0 | 1 | normal_debug_checkpoint |

---
_Back to [dashboard](../../DV_REPORT.md)_
