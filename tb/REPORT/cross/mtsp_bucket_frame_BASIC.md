# ✅ mtsp_bucket_frame_BASIC

**Kind:** `bucket_frame` &nbsp; **Build:** `after` &nbsp; **Bucket:** `BASIC` &nbsp; **Sequence:** `mtsp_continuous_frame_test ordered checkpoint stream`

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
| stmt | 82.54 |
| branch | 70.12 |
| cond | 49.19 |
| expr | 50.00 |
| fsm_state | 100.00 |
| fsm_trans | 44.44 |
| toggle | 25.13 |

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
| ✅ | `latency48_identity` | 134 | `== valid beats (134)` |
| ✅ | `latency48_negative_diagnostics` | 0 | `== 0 in nominal continuous traffic` |

## Transaction growth curve

<!-- each row is one transaction step: which planned case fired, current functional-cross percent, -->
<!-- delta_bins = number of new cross bins hit at this step; reason = scoreboard checkpoint trigger. -->

| txn | case | seq | pct | delta_bins | reason |
|---:|---|---|---|---:|---|
| 1 | `B001` | `bucket_frame` | 0.77 | 1 | normal_debug_checkpoint |
| 2 | `B002` | `bucket_frame` | 1.54 | 1 | normal_debug_checkpoint |
| 3 | `B003` | `bucket_frame` | 2.31 | 1 | normal_debug_checkpoint |
| 4 | `B004` | `bucket_frame` | 3.08 | 1 | normal_debug_checkpoint |
| 5 | `B005` | `bucket_frame` | 3.85 | 1 | normal_debug_checkpoint |
| 6 | `B006` | `bucket_frame` | 4.62 | 1 | normal_debug_checkpoint |
| 7 | `B007` | `bucket_frame` | 5.38 | 1 | normal_debug_checkpoint |
| 8 | `B008` | `bucket_frame` | 6.15 | 1 | normal_debug_checkpoint |
| 9 | `B009` | `bucket_frame` | 6.92 | 1 | normal_debug_checkpoint |
| 10 | `B010` | `bucket_frame` | 7.69 | 1 | normal_debug_checkpoint |
| 11 | `B011` | `bucket_frame` | 8.46 | 1 | normal_debug_checkpoint |
| 12 | `B012` | `bucket_frame` | 9.23 | 1 | normal_debug_checkpoint |
| 13 | `B013` | `bucket_frame` | 10.0 | 1 | normal_debug_checkpoint |
| 14 | `B014` | `bucket_frame` | 10.77 | 1 | normal_debug_checkpoint |
| 15 | `B015` | `bucket_frame` | 11.54 | 1 | normal_debug_checkpoint |
| 16 | `B016` | `bucket_frame` | 12.31 | 1 | normal_debug_checkpoint |
| 17 | `B017` | `bucket_frame` | 13.08 | 1 | normal_debug_checkpoint |
| 18 | `B018` | `bucket_frame` | 13.85 | 1 | normal_debug_checkpoint |
| 19 | `B019` | `bucket_frame` | 14.62 | 1 | normal_debug_checkpoint |
| 20 | `B020` | `bucket_frame` | 15.38 | 1 | normal_debug_checkpoint |
| 21 | `B021` | `bucket_frame` | 16.15 | 1 | normal_debug_checkpoint |
| 22 | `B022` | `bucket_frame` | 16.92 | 1 | normal_debug_checkpoint |
| 23 | `B023` | `bucket_frame` | 17.69 | 1 | normal_debug_checkpoint |
| 24 | `B024` | `bucket_frame` | 18.46 | 1 | normal_debug_checkpoint |
| 25 | `B025` | `bucket_frame` | 19.23 | 1 | normal_debug_checkpoint |
| 26 | `B026` | `bucket_frame` | 20.0 | 1 | normal_debug_checkpoint |
| 27 | `B027` | `bucket_frame` | 20.77 | 1 | normal_debug_checkpoint |
| 28 | `B028` | `bucket_frame` | 21.54 | 1 | normal_debug_checkpoint |
| 29 | `B029` | `bucket_frame` | 22.31 | 1 | normal_debug_checkpoint |
| 30 | `B030` | `bucket_frame` | 23.08 | 1 | normal_debug_checkpoint |
| 31 | `B031` | `bucket_frame` | 23.85 | 1 | normal_debug_checkpoint |
| 32 | `B032` | `bucket_frame` | 24.62 | 1 | normal_debug_checkpoint |
| 33 | `B033` | `bucket_frame` | 25.38 | 1 | normal_debug_checkpoint |
| 34 | `B034` | `bucket_frame` | 26.15 | 1 | normal_debug_checkpoint |
| 35 | `B035` | `bucket_frame` | 26.92 | 1 | normal_debug_checkpoint |
| 36 | `B036` | `bucket_frame` | 27.69 | 1 | normal_debug_checkpoint |
| 37 | `B037` | `bucket_frame` | 28.46 | 1 | normal_debug_checkpoint |
| 38 | `B038` | `bucket_frame` | 29.23 | 1 | normal_debug_checkpoint |
| 39 | `B039` | `bucket_frame` | 30.0 | 1 | normal_debug_checkpoint |
| 40 | `B040` | `bucket_frame` | 30.77 | 1 | normal_debug_checkpoint |
| 41 | `B041` | `bucket_frame` | 31.54 | 1 | normal_debug_checkpoint |
| 42 | `B042` | `bucket_frame` | 32.31 | 1 | normal_debug_checkpoint |
| 43 | `B043` | `bucket_frame` | 33.08 | 1 | normal_debug_checkpoint |
| 44 | `B044` | `bucket_frame` | 33.85 | 1 | normal_debug_checkpoint |
| 45 | `B045` | `bucket_frame` | 34.62 | 1 | normal_debug_checkpoint |
| 46 | `B046` | `bucket_frame` | 35.38 | 1 | normal_debug_checkpoint |
| 47 | `B047` | `bucket_frame` | 36.15 | 1 | normal_debug_checkpoint |
| 48 | `B048` | `bucket_frame` | 36.92 | 1 | normal_debug_checkpoint |
| 49 | `B049` | `bucket_frame` | 37.69 | 1 | normal_debug_checkpoint |
| 50 | `B050` | `bucket_frame` | 38.46 | 1 | normal_debug_checkpoint |
| 51 | `B051` | `bucket_frame` | 39.23 | 1 | normal_debug_checkpoint |
| 52 | `B052` | `bucket_frame` | 40.0 | 1 | normal_debug_checkpoint |
| 53 | `B053` | `bucket_frame` | 40.77 | 1 | normal_debug_checkpoint |
| 54 | `B054` | `bucket_frame` | 41.54 | 1 | normal_debug_checkpoint |
| 55 | `B055` | `bucket_frame` | 42.31 | 1 | normal_debug_checkpoint |
| 56 | `B056` | `bucket_frame` | 43.08 | 1 | normal_debug_checkpoint |
| 57 | `B057` | `bucket_frame` | 43.85 | 1 | normal_debug_checkpoint |
| 58 | `B058` | `bucket_frame` | 44.62 | 1 | normal_debug_checkpoint |
| 59 | `B059` | `bucket_frame` | 45.38 | 1 | normal_debug_checkpoint |
| 60 | `B060` | `bucket_frame` | 46.15 | 1 | normal_debug_checkpoint |
| 61 | `B061` | `bucket_frame` | 46.92 | 1 | normal_debug_checkpoint |
| 62 | `B062` | `bucket_frame` | 47.69 | 1 | normal_debug_checkpoint |
| 63 | `B063` | `bucket_frame` | 48.46 | 1 | normal_debug_checkpoint |
| 64 | `B064` | `bucket_frame` | 49.23 | 1 | normal_debug_checkpoint |
| 65 | `B065` | `bucket_frame` | 50.0 | 1 | normal_debug_checkpoint |
| 66 | `B066` | `bucket_frame` | 50.77 | 1 | normal_debug_checkpoint |
| 67 | `B067` | `bucket_frame` | 51.54 | 1 | normal_debug_checkpoint |
| 68 | `B068` | `bucket_frame` | 52.31 | 1 | normal_debug_checkpoint |
| 69 | `B069` | `bucket_frame` | 53.08 | 1 | normal_debug_checkpoint |
| 70 | `B070` | `bucket_frame` | 53.85 | 1 | normal_debug_checkpoint |
| 71 | `B071` | `bucket_frame` | 54.62 | 1 | normal_debug_checkpoint |
| 72 | `B072` | `bucket_frame` | 55.38 | 1 | normal_debug_checkpoint |
| 73 | `B073` | `bucket_frame` | 56.15 | 1 | normal_debug_checkpoint |
| 74 | `B074` | `bucket_frame` | 56.92 | 1 | normal_debug_checkpoint |
| 75 | `B075` | `bucket_frame` | 57.69 | 1 | normal_debug_checkpoint |
| 76 | `B076` | `bucket_frame` | 58.46 | 1 | normal_debug_checkpoint |
| 77 | `B077` | `bucket_frame` | 59.23 | 1 | normal_debug_checkpoint |
| 78 | `B078` | `bucket_frame` | 60.0 | 1 | normal_debug_checkpoint |
| 79 | `B079` | `bucket_frame` | 60.77 | 1 | normal_debug_checkpoint |
| 80 | `B080` | `bucket_frame` | 61.54 | 1 | normal_debug_checkpoint |
| 81 | `B081` | `bucket_frame` | 62.31 | 1 | normal_debug_checkpoint |
| 82 | `B082` | `bucket_frame` | 63.08 | 1 | normal_debug_checkpoint |
| 83 | `B083` | `bucket_frame` | 63.85 | 1 | normal_debug_checkpoint |
| 84 | `B084` | `bucket_frame` | 64.62 | 1 | normal_debug_checkpoint |
| 85 | `B085` | `bucket_frame` | 65.38 | 1 | normal_debug_checkpoint |
| 86 | `B086` | `bucket_frame` | 66.15 | 1 | normal_debug_checkpoint |
| 87 | `B087` | `bucket_frame` | 66.92 | 1 | normal_debug_checkpoint |
| 88 | `B088` | `bucket_frame` | 67.69 | 1 | normal_debug_checkpoint |
| 89 | `B089` | `bucket_frame` | 68.46 | 1 | normal_debug_checkpoint |
| 90 | `B090` | `bucket_frame` | 69.23 | 1 | normal_debug_checkpoint |
| 91 | `B091` | `bucket_frame` | 70.0 | 1 | normal_debug_checkpoint |
| 92 | `B092` | `bucket_frame` | 70.77 | 1 | normal_debug_checkpoint |
| 93 | `B093` | `bucket_frame` | 71.54 | 1 | normal_debug_checkpoint |
| 94 | `B094` | `bucket_frame` | 72.31 | 1 | normal_debug_checkpoint |
| 95 | `B095` | `bucket_frame` | 73.08 | 1 | normal_debug_checkpoint |
| 96 | `B096` | `bucket_frame` | 73.85 | 1 | normal_debug_checkpoint |
| 97 | `B097` | `bucket_frame` | 74.62 | 1 | normal_debug_checkpoint |
| 98 | `B098` | `bucket_frame` | 75.38 | 1 | normal_debug_checkpoint |
| 99 | `B099` | `bucket_frame` | 76.15 | 1 | normal_debug_checkpoint |
| 100 | `B100` | `bucket_frame` | 76.92 | 1 | normal_debug_checkpoint |
| 101 | `B101` | `bucket_frame` | 77.69 | 1 | normal_debug_checkpoint |
| 102 | `B102` | `bucket_frame` | 78.46 | 1 | normal_debug_checkpoint |
| 103 | `B103` | `bucket_frame` | 79.23 | 1 | normal_debug_checkpoint |
| 104 | `B104` | `bucket_frame` | 80.0 | 1 | normal_debug_checkpoint |
| 105 | `B105` | `bucket_frame` | 80.77 | 1 | normal_debug_checkpoint |
| 106 | `B106` | `bucket_frame` | 81.54 | 1 | normal_debug_checkpoint |
| 107 | `B107` | `bucket_frame` | 82.31 | 1 | normal_debug_checkpoint |
| 108 | `B108` | `bucket_frame` | 83.08 | 1 | normal_debug_checkpoint |
| 109 | `B109` | `bucket_frame` | 83.85 | 1 | normal_debug_checkpoint |
| 110 | `B110` | `bucket_frame` | 84.62 | 1 | normal_debug_checkpoint |
| 111 | `B111` | `bucket_frame` | 85.38 | 1 | normal_debug_checkpoint |
| 112 | `B112` | `bucket_frame` | 86.15 | 1 | normal_debug_checkpoint |
| 113 | `B113` | `bucket_frame` | 86.92 | 1 | normal_debug_checkpoint |
| 114 | `B114` | `bucket_frame` | 87.69 | 1 | normal_debug_checkpoint |
| 115 | `B115` | `bucket_frame` | 88.46 | 1 | normal_debug_checkpoint |
| 116 | `B116` | `bucket_frame` | 89.23 | 1 | normal_debug_checkpoint |
| 117 | `B117` | `bucket_frame` | 90.0 | 1 | normal_debug_checkpoint |
| 118 | `B118` | `bucket_frame` | 90.77 | 1 | normal_debug_checkpoint |
| 119 | `B119` | `bucket_frame` | 91.54 | 1 | normal_debug_checkpoint |
| 120 | `B120` | `bucket_frame` | 92.31 | 1 | normal_debug_checkpoint |
| 121 | `B121` | `bucket_frame` | 93.08 | 1 | normal_debug_checkpoint |
| 122 | `B122` | `bucket_frame` | 93.85 | 1 | normal_debug_checkpoint |
| 123 | `B123` | `bucket_frame` | 94.62 | 1 | normal_debug_checkpoint |
| 124 | `B124` | `bucket_frame` | 95.38 | 1 | normal_debug_checkpoint |
| 125 | `B125` | `bucket_frame` | 96.15 | 1 | normal_debug_checkpoint |
| 126 | `B126` | `bucket_frame` | 96.92 | 1 | normal_debug_checkpoint |
| 127 | `B127` | `bucket_frame` | 97.69 | 1 | normal_debug_checkpoint |
| 128 | `B128` | `bucket_frame` | 98.46 | 1 | normal_debug_checkpoint |
| 129 | `B129` | `bucket_frame` | 99.23 | 1 | normal_debug_checkpoint |
| 130 | `B130` | `bucket_frame` | 100.0 | 1 | normal_debug_checkpoint |

---
_Back to [dashboard](../../DV_REPORT.md)_
