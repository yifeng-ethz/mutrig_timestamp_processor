# ✅ mtsp_all_buckets_frame

**Kind:** `all_buckets_frame` &nbsp; **Build:** `after` &nbsp; **Bucket:** `-` &nbsp; **Sequence:** `mtsp_continuous_frame_test ordered checkpoint stream`

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
| ℹ️ | case_count | `521` |
| ℹ️ | effort | `signoff` |
| ℹ️ | iter_cap | `None` |
| ℹ️ | payload_cap | `None` |
| ℹ️ | txns | `521` |
| ✅ | functional_cross_pct | `100.0` |
| ℹ️ | queued_overlap | `0` |
| ✅ | counter_checks_failed | `0` |
| ✅ | unexpected_outputs | `0` |

## Code coverage

<!-- merged code coverage produced by this single run (not ordered-merged into any bucket). -->

| metric | pct |
|---|---|
| stmt | 85.87 |
| branch | 76.37 |
| cond | 55.17 |
| expr | 50.00 |
| fsm_state | 100.00 |
| fsm_trans | 44.44 |
| toggle | 32.34 |

## Scoreboard Evidence

<!-- analysis-port evidence from normal payload, debug timestamp, debug burst, and timestamp-delta monitors. -->

| status | port/counter | observed | requirement |
|:---:|---|---:|---|
| ✅ | `inputs` | 521 | `== case_count (521)` |
| ✅ | `beats` | 525 | `>= case_count (521)` |
| ✅ | `payloads` | 521 | `== case_count (521)` |
| ✅ | `eops` | 4 | `> 0` |
| ✅ | `empty_eops` | 4 | `> 0` |
| ✅ | `debug_ts` | 521 | `== case_count (521)` |
| ✅ | `debug_burst` | 521 | `== case_count (521)` |
| ✅ | `ts_delta` | 521 | `== case_count (521)` |
| ✅ | `dual_path_pairs` | 521 | `== case_count (521)` |
| ✅ | `traces` | 521 | `== case_count (521)` |
| ✅ | `trace_detail_lines` | 521 | `== case_count (521)` |

## Transaction growth curve

<!-- each row is one transaction step: which planned case fired, current functional-cross percent, -->
<!-- delta_bins = number of new cross bins hit at this step; reason = scoreboard checkpoint trigger. -->

| txn | case | seq | pct | delta_bins | reason |
|---:|---|---|---|---:|---|
| 1 | `B001` | `all_buckets_frame` | 0.19 | 1 | normal_debug_checkpoint |
| 2 | `B002` | `all_buckets_frame` | 0.38 | 1 | normal_debug_checkpoint |
| 3 | `B003` | `all_buckets_frame` | 0.58 | 1 | normal_debug_checkpoint |
| 4 | `B004` | `all_buckets_frame` | 0.77 | 1 | normal_debug_checkpoint |
| 5 | `B005` | `all_buckets_frame` | 0.96 | 1 | normal_debug_checkpoint |
| 6 | `B006` | `all_buckets_frame` | 1.15 | 1 | normal_debug_checkpoint |
| 7 | `B007` | `all_buckets_frame` | 1.34 | 1 | normal_debug_checkpoint |
| 8 | `B008` | `all_buckets_frame` | 1.54 | 1 | normal_debug_checkpoint |
| 9 | `B009` | `all_buckets_frame` | 1.73 | 1 | normal_debug_checkpoint |
| 10 | `B010` | `all_buckets_frame` | 1.92 | 1 | normal_debug_checkpoint |
| 11 | `B011` | `all_buckets_frame` | 2.11 | 1 | normal_debug_checkpoint |
| 12 | `B012` | `all_buckets_frame` | 2.3 | 1 | normal_debug_checkpoint |
| 13 | `B013` | `all_buckets_frame` | 2.5 | 1 | normal_debug_checkpoint |
| 14 | `B014` | `all_buckets_frame` | 2.69 | 1 | normal_debug_checkpoint |
| 15 | `B015` | `all_buckets_frame` | 2.88 | 1 | normal_debug_checkpoint |
| 16 | `B016` | `all_buckets_frame` | 3.07 | 1 | normal_debug_checkpoint |
| 17 | `B017` | `all_buckets_frame` | 3.26 | 1 | normal_debug_checkpoint |
| 18 | `B018` | `all_buckets_frame` | 3.45 | 1 | normal_debug_checkpoint |
| 19 | `B019` | `all_buckets_frame` | 3.65 | 1 | normal_debug_checkpoint |
| 20 | `B020` | `all_buckets_frame` | 3.84 | 1 | normal_debug_checkpoint |
| 21 | `B021` | `all_buckets_frame` | 4.03 | 1 | normal_debug_checkpoint |
| 22 | `B022` | `all_buckets_frame` | 4.22 | 1 | normal_debug_checkpoint |
| 23 | `B023` | `all_buckets_frame` | 4.41 | 1 | normal_debug_checkpoint |
| 24 | `B024` | `all_buckets_frame` | 4.61 | 1 | normal_debug_checkpoint |
| 25 | `B025` | `all_buckets_frame` | 4.8 | 1 | normal_debug_checkpoint |
| 26 | `B026` | `all_buckets_frame` | 4.99 | 1 | normal_debug_checkpoint |
| 27 | `B027` | `all_buckets_frame` | 5.18 | 1 | normal_debug_checkpoint |
| 28 | `B028` | `all_buckets_frame` | 5.37 | 1 | normal_debug_checkpoint |
| 29 | `B029` | `all_buckets_frame` | 5.57 | 1 | normal_debug_checkpoint |
| 30 | `B030` | `all_buckets_frame` | 5.76 | 1 | normal_debug_checkpoint |
| 31 | `B031` | `all_buckets_frame` | 5.95 | 1 | normal_debug_checkpoint |
| 32 | `B032` | `all_buckets_frame` | 6.14 | 1 | normal_debug_checkpoint |
| 33 | `B033` | `all_buckets_frame` | 6.33 | 1 | normal_debug_checkpoint |
| 34 | `B034` | `all_buckets_frame` | 6.53 | 1 | normal_debug_checkpoint |
| 35 | `B035` | `all_buckets_frame` | 6.72 | 1 | normal_debug_checkpoint |
| 36 | `B036` | `all_buckets_frame` | 6.91 | 1 | normal_debug_checkpoint |
| 37 | `B037` | `all_buckets_frame` | 7.1 | 1 | normal_debug_checkpoint |
| 38 | `B038` | `all_buckets_frame` | 7.29 | 1 | normal_debug_checkpoint |
| 39 | `B039` | `all_buckets_frame` | 7.49 | 1 | normal_debug_checkpoint |
| 40 | `B040` | `all_buckets_frame` | 7.68 | 1 | normal_debug_checkpoint |
| 41 | `B041` | `all_buckets_frame` | 7.87 | 1 | normal_debug_checkpoint |
| 42 | `B042` | `all_buckets_frame` | 8.06 | 1 | normal_debug_checkpoint |
| 43 | `B043` | `all_buckets_frame` | 8.25 | 1 | normal_debug_checkpoint |
| 44 | `B044` | `all_buckets_frame` | 8.45 | 1 | normal_debug_checkpoint |
| 45 | `B045` | `all_buckets_frame` | 8.64 | 1 | normal_debug_checkpoint |
| 46 | `B046` | `all_buckets_frame` | 8.83 | 1 | normal_debug_checkpoint |
| 47 | `B047` | `all_buckets_frame` | 9.02 | 1 | normal_debug_checkpoint |
| 48 | `B048` | `all_buckets_frame` | 9.21 | 1 | normal_debug_checkpoint |
| 49 | `B049` | `all_buckets_frame` | 9.4 | 1 | normal_debug_checkpoint |
| 50 | `B050` | `all_buckets_frame` | 9.6 | 1 | normal_debug_checkpoint |
| 51 | `B051` | `all_buckets_frame` | 9.79 | 1 | normal_debug_checkpoint |
| 52 | `B052` | `all_buckets_frame` | 9.98 | 1 | normal_debug_checkpoint |
| 53 | `B053` | `all_buckets_frame` | 10.17 | 1 | normal_debug_checkpoint |
| 54 | `B054` | `all_buckets_frame` | 10.36 | 1 | normal_debug_checkpoint |
| 55 | `B055` | `all_buckets_frame` | 10.56 | 1 | normal_debug_checkpoint |
| 56 | `B056` | `all_buckets_frame` | 10.75 | 1 | normal_debug_checkpoint |
| 57 | `B057` | `all_buckets_frame` | 10.94 | 1 | normal_debug_checkpoint |
| 58 | `B058` | `all_buckets_frame` | 11.13 | 1 | normal_debug_checkpoint |
| 59 | `B059` | `all_buckets_frame` | 11.32 | 1 | normal_debug_checkpoint |
| 60 | `B060` | `all_buckets_frame` | 11.52 | 1 | normal_debug_checkpoint |
| 61 | `B061` | `all_buckets_frame` | 11.71 | 1 | normal_debug_checkpoint |
| 62 | `B062` | `all_buckets_frame` | 11.9 | 1 | normal_debug_checkpoint |
| 63 | `B063` | `all_buckets_frame` | 12.09 | 1 | normal_debug_checkpoint |
| 64 | `B064` | `all_buckets_frame` | 12.28 | 1 | normal_debug_checkpoint |
| 65 | `B065` | `all_buckets_frame` | 12.48 | 1 | normal_debug_checkpoint |
| 66 | `B066` | `all_buckets_frame` | 12.67 | 1 | normal_debug_checkpoint |
| 67 | `B067` | `all_buckets_frame` | 12.86 | 1 | normal_debug_checkpoint |
| 68 | `B068` | `all_buckets_frame` | 13.05 | 1 | normal_debug_checkpoint |
| 69 | `B069` | `all_buckets_frame` | 13.24 | 1 | normal_debug_checkpoint |
| 70 | `B070` | `all_buckets_frame` | 13.44 | 1 | normal_debug_checkpoint |
| 71 | `B071` | `all_buckets_frame` | 13.63 | 1 | normal_debug_checkpoint |
| 72 | `B072` | `all_buckets_frame` | 13.82 | 1 | normal_debug_checkpoint |
| 73 | `B073` | `all_buckets_frame` | 14.01 | 1 | normal_debug_checkpoint |
| 74 | `B074` | `all_buckets_frame` | 14.2 | 1 | normal_debug_checkpoint |
| 75 | `B075` | `all_buckets_frame` | 14.4 | 1 | normal_debug_checkpoint |
| 76 | `B076` | `all_buckets_frame` | 14.59 | 1 | normal_debug_checkpoint |
| 77 | `B077` | `all_buckets_frame` | 14.78 | 1 | normal_debug_checkpoint |
| 78 | `B078` | `all_buckets_frame` | 14.97 | 1 | normal_debug_checkpoint |
| 79 | `B079` | `all_buckets_frame` | 15.16 | 1 | normal_debug_checkpoint |
| 80 | `B080` | `all_buckets_frame` | 15.36 | 1 | normal_debug_checkpoint |
| 81 | `B081` | `all_buckets_frame` | 15.55 | 1 | normal_debug_checkpoint |
| 82 | `B082` | `all_buckets_frame` | 15.74 | 1 | normal_debug_checkpoint |
| 83 | `B083` | `all_buckets_frame` | 15.93 | 1 | normal_debug_checkpoint |
| 84 | `B084` | `all_buckets_frame` | 16.12 | 1 | normal_debug_checkpoint |
| 85 | `B085` | `all_buckets_frame` | 16.31 | 1 | normal_debug_checkpoint |
| 86 | `B086` | `all_buckets_frame` | 16.51 | 1 | normal_debug_checkpoint |
| 87 | `B087` | `all_buckets_frame` | 16.7 | 1 | normal_debug_checkpoint |
| 88 | `B088` | `all_buckets_frame` | 16.89 | 1 | normal_debug_checkpoint |
| 89 | `B089` | `all_buckets_frame` | 17.08 | 1 | normal_debug_checkpoint |
| 90 | `B090` | `all_buckets_frame` | 17.27 | 1 | normal_debug_checkpoint |
| 91 | `B091` | `all_buckets_frame` | 17.47 | 1 | normal_debug_checkpoint |
| 92 | `B092` | `all_buckets_frame` | 17.66 | 1 | normal_debug_checkpoint |
| 93 | `B093` | `all_buckets_frame` | 17.85 | 1 | normal_debug_checkpoint |
| 94 | `B094` | `all_buckets_frame` | 18.04 | 1 | normal_debug_checkpoint |
| 95 | `B095` | `all_buckets_frame` | 18.23 | 1 | normal_debug_checkpoint |
| 96 | `B096` | `all_buckets_frame` | 18.43 | 1 | normal_debug_checkpoint |
| 97 | `B097` | `all_buckets_frame` | 18.62 | 1 | normal_debug_checkpoint |
| 98 | `B098` | `all_buckets_frame` | 18.81 | 1 | normal_debug_checkpoint |
| 99 | `B099` | `all_buckets_frame` | 19.0 | 1 | normal_debug_checkpoint |
| 100 | `B100` | `all_buckets_frame` | 19.19 | 1 | normal_debug_checkpoint |
| 101 | `B101` | `all_buckets_frame` | 19.39 | 1 | normal_debug_checkpoint |
| 102 | `B102` | `all_buckets_frame` | 19.58 | 1 | normal_debug_checkpoint |
| 103 | `B103` | `all_buckets_frame` | 19.77 | 1 | normal_debug_checkpoint |
| 104 | `B104` | `all_buckets_frame` | 19.96 | 1 | normal_debug_checkpoint |
| 105 | `B105` | `all_buckets_frame` | 20.15 | 1 | normal_debug_checkpoint |
| 106 | `B106` | `all_buckets_frame` | 20.35 | 1 | normal_debug_checkpoint |
| 107 | `B107` | `all_buckets_frame` | 20.54 | 1 | normal_debug_checkpoint |
| 108 | `B108` | `all_buckets_frame` | 20.73 | 1 | normal_debug_checkpoint |
| 109 | `B109` | `all_buckets_frame` | 20.92 | 1 | normal_debug_checkpoint |
| 110 | `B110` | `all_buckets_frame` | 21.11 | 1 | normal_debug_checkpoint |
| 111 | `B111` | `all_buckets_frame` | 21.31 | 1 | normal_debug_checkpoint |
| 112 | `B112` | `all_buckets_frame` | 21.5 | 1 | normal_debug_checkpoint |
| 113 | `B113` | `all_buckets_frame` | 21.69 | 1 | normal_debug_checkpoint |
| 114 | `B114` | `all_buckets_frame` | 21.88 | 1 | normal_debug_checkpoint |
| 115 | `B115` | `all_buckets_frame` | 22.07 | 1 | normal_debug_checkpoint |
| 116 | `B116` | `all_buckets_frame` | 22.26 | 1 | normal_debug_checkpoint |
| 117 | `B117` | `all_buckets_frame` | 22.46 | 1 | normal_debug_checkpoint |
| 118 | `B118` | `all_buckets_frame` | 22.65 | 1 | normal_debug_checkpoint |
| 119 | `B119` | `all_buckets_frame` | 22.84 | 1 | normal_debug_checkpoint |
| 120 | `B120` | `all_buckets_frame` | 23.03 | 1 | normal_debug_checkpoint |
| 121 | `B121` | `all_buckets_frame` | 23.22 | 1 | normal_debug_checkpoint |
| 122 | `B122` | `all_buckets_frame` | 23.42 | 1 | normal_debug_checkpoint |
| 123 | `B123` | `all_buckets_frame` | 23.61 | 1 | normal_debug_checkpoint |
| 124 | `B124` | `all_buckets_frame` | 23.8 | 1 | normal_debug_checkpoint |
| 125 | `B125` | `all_buckets_frame` | 23.99 | 1 | normal_debug_checkpoint |
| 126 | `B126` | `all_buckets_frame` | 24.18 | 1 | normal_debug_checkpoint |
| 127 | `B127` | `all_buckets_frame` | 24.38 | 1 | normal_debug_checkpoint |
| 128 | `B128` | `all_buckets_frame` | 24.57 | 1 | normal_debug_checkpoint |
| 129 | `B129` | `all_buckets_frame` | 24.76 | 1 | normal_debug_checkpoint |
| 130 | `B130` | `all_buckets_frame` | 24.95 | 1 | normal_debug_checkpoint |
| 131 | `E001` | `all_buckets_frame` | 25.14 | 1 | normal_debug_checkpoint |
| 132 | `E002` | `all_buckets_frame` | 25.34 | 1 | normal_debug_checkpoint |
| 133 | `E003` | `all_buckets_frame` | 25.53 | 1 | normal_debug_checkpoint |
| 134 | `E004` | `all_buckets_frame` | 25.72 | 1 | normal_debug_checkpoint |
| 135 | `E005` | `all_buckets_frame` | 25.91 | 1 | normal_debug_checkpoint |
| 136 | `E006` | `all_buckets_frame` | 26.1 | 1 | normal_debug_checkpoint |
| 137 | `E007` | `all_buckets_frame` | 26.3 | 1 | normal_debug_checkpoint |
| 138 | `E008` | `all_buckets_frame` | 26.49 | 1 | normal_debug_checkpoint |
| 139 | `E009` | `all_buckets_frame` | 26.68 | 1 | normal_debug_checkpoint |
| 140 | `E010` | `all_buckets_frame` | 26.87 | 1 | normal_debug_checkpoint |
| 141 | `E011` | `all_buckets_frame` | 27.06 | 1 | normal_debug_checkpoint |
| 142 | `E012` | `all_buckets_frame` | 27.26 | 1 | normal_debug_checkpoint |
| 143 | `E013` | `all_buckets_frame` | 27.45 | 1 | normal_debug_checkpoint |
| 144 | `E014` | `all_buckets_frame` | 27.64 | 1 | normal_debug_checkpoint |
| 145 | `E015` | `all_buckets_frame` | 27.83 | 1 | normal_debug_checkpoint |
| 146 | `E016` | `all_buckets_frame` | 28.02 | 1 | normal_debug_checkpoint |
| 147 | `E017` | `all_buckets_frame` | 28.21 | 1 | normal_debug_checkpoint |
| 148 | `E018` | `all_buckets_frame` | 28.41 | 1 | normal_debug_checkpoint |
| 149 | `E019` | `all_buckets_frame` | 28.6 | 1 | normal_debug_checkpoint |
| 150 | `E020` | `all_buckets_frame` | 28.79 | 1 | normal_debug_checkpoint |
| 151 | `E021` | `all_buckets_frame` | 28.98 | 1 | normal_debug_checkpoint |
| 152 | `E022` | `all_buckets_frame` | 29.17 | 1 | normal_debug_checkpoint |
| 153 | `E023` | `all_buckets_frame` | 29.37 | 1 | normal_debug_checkpoint |
| 154 | `E024` | `all_buckets_frame` | 29.56 | 1 | normal_debug_checkpoint |
| 155 | `E025` | `all_buckets_frame` | 29.75 | 1 | normal_debug_checkpoint |
| 156 | `E026` | `all_buckets_frame` | 29.94 | 1 | normal_debug_checkpoint |
| 157 | `E027` | `all_buckets_frame` | 30.13 | 1 | normal_debug_checkpoint |
| 158 | `E028` | `all_buckets_frame` | 30.33 | 1 | normal_debug_checkpoint |
| 159 | `E029` | `all_buckets_frame` | 30.52 | 1 | normal_debug_checkpoint |
| 160 | `E030` | `all_buckets_frame` | 30.71 | 1 | normal_debug_checkpoint |
| 161 | `E031` | `all_buckets_frame` | 30.9 | 1 | normal_debug_checkpoint |
| 162 | `E032` | `all_buckets_frame` | 31.09 | 1 | normal_debug_checkpoint |
| 163 | `E033` | `all_buckets_frame` | 31.29 | 1 | normal_debug_checkpoint |
| 164 | `E034` | `all_buckets_frame` | 31.48 | 1 | normal_debug_checkpoint |
| 165 | `E035` | `all_buckets_frame` | 31.67 | 1 | normal_debug_checkpoint |
| 166 | `E036` | `all_buckets_frame` | 31.86 | 1 | normal_debug_checkpoint |
| 167 | `E037` | `all_buckets_frame` | 32.05 | 1 | normal_debug_checkpoint |
| 168 | `E038` | `all_buckets_frame` | 32.25 | 1 | normal_debug_checkpoint |
| 169 | `E039` | `all_buckets_frame` | 32.44 | 1 | normal_debug_checkpoint |
| 170 | `E040` | `all_buckets_frame` | 32.63 | 1 | normal_debug_checkpoint |
| 171 | `E041` | `all_buckets_frame` | 32.82 | 1 | normal_debug_checkpoint |
| 172 | `E042` | `all_buckets_frame` | 33.01 | 1 | normal_debug_checkpoint |
| 173 | `E043` | `all_buckets_frame` | 33.21 | 1 | normal_debug_checkpoint |
| 174 | `E044` | `all_buckets_frame` | 33.4 | 1 | normal_debug_checkpoint |
| 175 | `E045` | `all_buckets_frame` | 33.59 | 1 | normal_debug_checkpoint |
| 176 | `E046` | `all_buckets_frame` | 33.78 | 1 | normal_debug_checkpoint |
| 177 | `E047` | `all_buckets_frame` | 33.97 | 1 | normal_debug_checkpoint |
| 178 | `E048` | `all_buckets_frame` | 34.17 | 1 | normal_debug_checkpoint |
| 179 | `E049` | `all_buckets_frame` | 34.36 | 1 | normal_debug_checkpoint |
| 180 | `E050` | `all_buckets_frame` | 34.55 | 1 | normal_debug_checkpoint |
| 181 | `E051` | `all_buckets_frame` | 34.74 | 1 | normal_debug_checkpoint |
| 182 | `E052` | `all_buckets_frame` | 34.93 | 1 | normal_debug_checkpoint |
| 183 | `E053` | `all_buckets_frame` | 35.12 | 1 | normal_debug_checkpoint |
| 184 | `E054` | `all_buckets_frame` | 35.32 | 1 | normal_debug_checkpoint |
| 185 | `E055` | `all_buckets_frame` | 35.51 | 1 | normal_debug_checkpoint |
| 186 | `E056` | `all_buckets_frame` | 35.7 | 1 | normal_debug_checkpoint |
| 187 | `E057` | `all_buckets_frame` | 35.89 | 1 | normal_debug_checkpoint |
| 188 | `E058` | `all_buckets_frame` | 36.08 | 1 | normal_debug_checkpoint |
| 189 | `E059` | `all_buckets_frame` | 36.28 | 1 | normal_debug_checkpoint |
| 190 | `E060` | `all_buckets_frame` | 36.47 | 1 | normal_debug_checkpoint |
| 191 | `E061` | `all_buckets_frame` | 36.66 | 1 | normal_debug_checkpoint |
| 192 | `E062` | `all_buckets_frame` | 36.85 | 1 | normal_debug_checkpoint |
| 193 | `E063` | `all_buckets_frame` | 37.04 | 1 | normal_debug_checkpoint |
| 194 | `E064` | `all_buckets_frame` | 37.24 | 1 | normal_debug_checkpoint |
| 195 | `E065` | `all_buckets_frame` | 37.43 | 1 | normal_debug_checkpoint |
| 196 | `E066` | `all_buckets_frame` | 37.62 | 1 | normal_debug_checkpoint |
| 197 | `E067` | `all_buckets_frame` | 37.81 | 1 | normal_debug_checkpoint |
| 198 | `E068` | `all_buckets_frame` | 38.0 | 1 | normal_debug_checkpoint |
| 199 | `E069` | `all_buckets_frame` | 38.2 | 1 | normal_debug_checkpoint |
| 200 | `E070` | `all_buckets_frame` | 38.39 | 1 | normal_debug_checkpoint |
| 201 | `E071` | `all_buckets_frame` | 38.58 | 1 | normal_debug_checkpoint |
| 202 | `E072` | `all_buckets_frame` | 38.77 | 1 | normal_debug_checkpoint |
| 203 | `E073` | `all_buckets_frame` | 38.96 | 1 | normal_debug_checkpoint |
| 204 | `E074` | `all_buckets_frame` | 39.16 | 1 | normal_debug_checkpoint |
| 205 | `E075` | `all_buckets_frame` | 39.35 | 1 | normal_debug_checkpoint |
| 206 | `E076` | `all_buckets_frame` | 39.54 | 1 | normal_debug_checkpoint |
| 207 | `E077` | `all_buckets_frame` | 39.73 | 1 | normal_debug_checkpoint |
| 208 | `E078` | `all_buckets_frame` | 39.92 | 1 | normal_debug_checkpoint |
| 209 | `E079` | `all_buckets_frame` | 40.12 | 1 | normal_debug_checkpoint |
| 210 | `E080` | `all_buckets_frame` | 40.31 | 1 | normal_debug_checkpoint |
| 211 | `E081` | `all_buckets_frame` | 40.5 | 1 | normal_debug_checkpoint |
| 212 | `E082` | `all_buckets_frame` | 40.69 | 1 | normal_debug_checkpoint |
| 213 | `E083` | `all_buckets_frame` | 40.88 | 1 | normal_debug_checkpoint |
| 214 | `E084` | `all_buckets_frame` | 41.07 | 1 | normal_debug_checkpoint |
| 215 | `E085` | `all_buckets_frame` | 41.27 | 1 | normal_debug_checkpoint |
| 216 | `E086` | `all_buckets_frame` | 41.46 | 1 | normal_debug_checkpoint |
| 217 | `E087` | `all_buckets_frame` | 41.65 | 1 | normal_debug_checkpoint |
| 218 | `E088` | `all_buckets_frame` | 41.84 | 1 | normal_debug_checkpoint |
| 219 | `E089` | `all_buckets_frame` | 42.03 | 1 | normal_debug_checkpoint |
| 220 | `E090` | `all_buckets_frame` | 42.23 | 1 | normal_debug_checkpoint |
| 221 | `E091` | `all_buckets_frame` | 42.42 | 1 | normal_debug_checkpoint |
| 222 | `E092` | `all_buckets_frame` | 42.61 | 1 | normal_debug_checkpoint |
| 223 | `E093` | `all_buckets_frame` | 42.8 | 1 | normal_debug_checkpoint |
| 224 | `E094` | `all_buckets_frame` | 42.99 | 1 | normal_debug_checkpoint |
| 225 | `E095` | `all_buckets_frame` | 43.19 | 1 | normal_debug_checkpoint |
| 226 | `E096` | `all_buckets_frame` | 43.38 | 1 | normal_debug_checkpoint |
| 227 | `E097` | `all_buckets_frame` | 43.57 | 1 | normal_debug_checkpoint |
| 228 | `E098` | `all_buckets_frame` | 43.76 | 1 | normal_debug_checkpoint |
| 229 | `E099` | `all_buckets_frame` | 43.95 | 1 | normal_debug_checkpoint |
| 230 | `E100` | `all_buckets_frame` | 44.15 | 1 | normal_debug_checkpoint |
| 231 | `E101` | `all_buckets_frame` | 44.34 | 1 | normal_debug_checkpoint |
| 232 | `E102` | `all_buckets_frame` | 44.53 | 1 | normal_debug_checkpoint |
| 233 | `E103` | `all_buckets_frame` | 44.72 | 1 | normal_debug_checkpoint |
| 234 | `E104` | `all_buckets_frame` | 44.91 | 1 | normal_debug_checkpoint |
| 235 | `E105` | `all_buckets_frame` | 45.11 | 1 | normal_debug_checkpoint |
| 236 | `E106` | `all_buckets_frame` | 45.3 | 1 | normal_debug_checkpoint |
| 237 | `E107` | `all_buckets_frame` | 45.49 | 1 | normal_debug_checkpoint |
| 238 | `E108` | `all_buckets_frame` | 45.68 | 1 | normal_debug_checkpoint |
| 239 | `E109` | `all_buckets_frame` | 45.87 | 1 | normal_debug_checkpoint |
| 240 | `E110` | `all_buckets_frame` | 46.07 | 1 | normal_debug_checkpoint |
| 241 | `E111` | `all_buckets_frame` | 46.26 | 1 | normal_debug_checkpoint |
| 242 | `E112` | `all_buckets_frame` | 46.45 | 1 | normal_debug_checkpoint |
| 243 | `E113` | `all_buckets_frame` | 46.64 | 1 | normal_debug_checkpoint |
| 244 | `E114` | `all_buckets_frame` | 46.83 | 1 | normal_debug_checkpoint |
| 245 | `E115` | `all_buckets_frame` | 47.02 | 1 | normal_debug_checkpoint |
| 246 | `E116` | `all_buckets_frame` | 47.22 | 1 | normal_debug_checkpoint |
| 247 | `E117` | `all_buckets_frame` | 47.41 | 1 | normal_debug_checkpoint |
| 248 | `E118` | `all_buckets_frame` | 47.6 | 1 | normal_debug_checkpoint |
| 249 | `E119` | `all_buckets_frame` | 47.79 | 1 | normal_debug_checkpoint |
| 250 | `E120` | `all_buckets_frame` | 47.98 | 1 | normal_debug_checkpoint |
| 251 | `E121` | `all_buckets_frame` | 48.18 | 1 | normal_debug_checkpoint |
| 252 | `E122` | `all_buckets_frame` | 48.37 | 1 | normal_debug_checkpoint |
| 253 | `E123` | `all_buckets_frame` | 48.56 | 1 | normal_debug_checkpoint |
| 254 | `E124` | `all_buckets_frame` | 48.75 | 1 | normal_debug_checkpoint |
| 255 | `E125` | `all_buckets_frame` | 48.94 | 1 | normal_debug_checkpoint |
| 256 | `E126` | `all_buckets_frame` | 49.14 | 1 | normal_debug_checkpoint |
| 257 | `E127` | `all_buckets_frame` | 49.33 | 1 | normal_debug_checkpoint |
| 258 | `E128` | `all_buckets_frame` | 49.52 | 1 | normal_debug_checkpoint |
| 259 | `E129` | `all_buckets_frame` | 49.71 | 1 | normal_debug_checkpoint |
| 260 | `E130` | `all_buckets_frame` | 49.9 | 1 | normal_debug_checkpoint |
| 261 | `E131` | `all_buckets_frame` | 50.1 | 1 | normal_debug_checkpoint |
| 262 | `P001` | `all_buckets_frame` | 50.29 | 1 | normal_debug_checkpoint |
| 263 | `P002` | `all_buckets_frame` | 50.48 | 1 | normal_debug_checkpoint |
| 264 | `P003` | `all_buckets_frame` | 50.67 | 1 | normal_debug_checkpoint |
| 265 | `P004` | `all_buckets_frame` | 50.86 | 1 | normal_debug_checkpoint |
| 266 | `P005` | `all_buckets_frame` | 51.06 | 1 | normal_debug_checkpoint |
| 267 | `P006` | `all_buckets_frame` | 51.25 | 1 | normal_debug_checkpoint |
| 268 | `P007` | `all_buckets_frame` | 51.44 | 1 | normal_debug_checkpoint |
| 269 | `P008` | `all_buckets_frame` | 51.63 | 1 | normal_debug_checkpoint |
| 270 | `P009` | `all_buckets_frame` | 51.82 | 1 | normal_debug_checkpoint |
| 271 | `P010` | `all_buckets_frame` | 52.02 | 1 | normal_debug_checkpoint |
| 272 | `P011` | `all_buckets_frame` | 52.21 | 1 | normal_debug_checkpoint |
| 273 | `P012` | `all_buckets_frame` | 52.4 | 1 | normal_debug_checkpoint |
| 274 | `P013` | `all_buckets_frame` | 52.59 | 1 | normal_debug_checkpoint |
| 275 | `P014` | `all_buckets_frame` | 52.78 | 1 | normal_debug_checkpoint |
| 276 | `P015` | `all_buckets_frame` | 52.98 | 1 | normal_debug_checkpoint |
| 277 | `P016` | `all_buckets_frame` | 53.17 | 1 | normal_debug_checkpoint |
| 278 | `P017` | `all_buckets_frame` | 53.36 | 1 | normal_debug_checkpoint |
| 279 | `P018` | `all_buckets_frame` | 53.55 | 1 | normal_debug_checkpoint |
| 280 | `P019` | `all_buckets_frame` | 53.74 | 1 | normal_debug_checkpoint |
| 281 | `P020` | `all_buckets_frame` | 53.93 | 1 | normal_debug_checkpoint |
| 282 | `P021` | `all_buckets_frame` | 54.13 | 1 | normal_debug_checkpoint |
| 283 | `P022` | `all_buckets_frame` | 54.32 | 1 | normal_debug_checkpoint |
| 284 | `P023` | `all_buckets_frame` | 54.51 | 1 | normal_debug_checkpoint |
| 285 | `P024` | `all_buckets_frame` | 54.7 | 1 | normal_debug_checkpoint |
| 286 | `P025` | `all_buckets_frame` | 54.89 | 1 | normal_debug_checkpoint |
| 287 | `P026` | `all_buckets_frame` | 55.09 | 1 | normal_debug_checkpoint |
| 288 | `P027` | `all_buckets_frame` | 55.28 | 1 | normal_debug_checkpoint |
| 289 | `P028` | `all_buckets_frame` | 55.47 | 1 | normal_debug_checkpoint |
| 290 | `P029` | `all_buckets_frame` | 55.66 | 1 | normal_debug_checkpoint |
| 291 | `P030` | `all_buckets_frame` | 55.85 | 1 | normal_debug_checkpoint |
| 292 | `P031` | `all_buckets_frame` | 56.05 | 1 | normal_debug_checkpoint |
| 293 | `P032` | `all_buckets_frame` | 56.24 | 1 | normal_debug_checkpoint |
| 294 | `P033` | `all_buckets_frame` | 56.43 | 1 | normal_debug_checkpoint |
| 295 | `P034` | `all_buckets_frame` | 56.62 | 1 | normal_debug_checkpoint |
| 296 | `P035` | `all_buckets_frame` | 56.81 | 1 | normal_debug_checkpoint |
| 297 | `P036` | `all_buckets_frame` | 57.01 | 1 | normal_debug_checkpoint |
| 298 | `P037` | `all_buckets_frame` | 57.2 | 1 | normal_debug_checkpoint |
| 299 | `P038` | `all_buckets_frame` | 57.39 | 1 | normal_debug_checkpoint |
| 300 | `P039` | `all_buckets_frame` | 57.58 | 1 | normal_debug_checkpoint |
| 301 | `P040` | `all_buckets_frame` | 57.77 | 1 | normal_debug_checkpoint |
| 302 | `P041` | `all_buckets_frame` | 57.97 | 1 | normal_debug_checkpoint |
| 303 | `P042` | `all_buckets_frame` | 58.16 | 1 | normal_debug_checkpoint |
| 304 | `P043` | `all_buckets_frame` | 58.35 | 1 | normal_debug_checkpoint |
| 305 | `P044` | `all_buckets_frame` | 58.54 | 1 | normal_debug_checkpoint |
| 306 | `P045` | `all_buckets_frame` | 58.73 | 1 | normal_debug_checkpoint |
| 307 | `P046` | `all_buckets_frame` | 58.93 | 1 | normal_debug_checkpoint |
| 308 | `P047` | `all_buckets_frame` | 59.12 | 1 | normal_debug_checkpoint |
| 309 | `P048` | `all_buckets_frame` | 59.31 | 1 | normal_debug_checkpoint |
| 310 | `P049` | `all_buckets_frame` | 59.5 | 1 | normal_debug_checkpoint |
| 311 | `P050` | `all_buckets_frame` | 59.69 | 1 | normal_debug_checkpoint |
| 312 | `P051` | `all_buckets_frame` | 59.88 | 1 | normal_debug_checkpoint |
| 313 | `P052` | `all_buckets_frame` | 60.08 | 1 | normal_debug_checkpoint |
| 314 | `P053` | `all_buckets_frame` | 60.27 | 1 | normal_debug_checkpoint |
| 315 | `P054` | `all_buckets_frame` | 60.46 | 1 | normal_debug_checkpoint |
| 316 | `P055` | `all_buckets_frame` | 60.65 | 1 | normal_debug_checkpoint |
| 317 | `P056` | `all_buckets_frame` | 60.84 | 1 | normal_debug_checkpoint |
| 318 | `P057` | `all_buckets_frame` | 61.04 | 1 | normal_debug_checkpoint |
| 319 | `P058` | `all_buckets_frame` | 61.23 | 1 | normal_debug_checkpoint |
| 320 | `P059` | `all_buckets_frame` | 61.42 | 1 | normal_debug_checkpoint |
| 321 | `P060` | `all_buckets_frame` | 61.61 | 1 | normal_debug_checkpoint |
| 322 | `P061` | `all_buckets_frame` | 61.8 | 1 | normal_debug_checkpoint |
| 323 | `P062` | `all_buckets_frame` | 62.0 | 1 | normal_debug_checkpoint |
| 324 | `P063` | `all_buckets_frame` | 62.19 | 1 | normal_debug_checkpoint |
| 325 | `P064` | `all_buckets_frame` | 62.38 | 1 | normal_debug_checkpoint |
| 326 | `P065` | `all_buckets_frame` | 62.57 | 1 | normal_debug_checkpoint |
| 327 | `P066` | `all_buckets_frame` | 62.76 | 1 | normal_debug_checkpoint |
| 328 | `P067` | `all_buckets_frame` | 62.96 | 1 | normal_debug_checkpoint |
| 329 | `P068` | `all_buckets_frame` | 63.15 | 1 | normal_debug_checkpoint |
| 330 | `P069` | `all_buckets_frame` | 63.34 | 1 | normal_debug_checkpoint |
| 331 | `P070` | `all_buckets_frame` | 63.53 | 1 | normal_debug_checkpoint |
| 332 | `P071` | `all_buckets_frame` | 63.72 | 1 | normal_debug_checkpoint |
| 333 | `P072` | `all_buckets_frame` | 63.92 | 1 | normal_debug_checkpoint |
| 334 | `P073` | `all_buckets_frame` | 64.11 | 1 | normal_debug_checkpoint |
| 335 | `P074` | `all_buckets_frame` | 64.3 | 1 | normal_debug_checkpoint |
| 336 | `P075` | `all_buckets_frame` | 64.49 | 1 | normal_debug_checkpoint |
| 337 | `P076` | `all_buckets_frame` | 64.68 | 1 | normal_debug_checkpoint |
| 338 | `P077` | `all_buckets_frame` | 64.88 | 1 | normal_debug_checkpoint |
| 339 | `P078` | `all_buckets_frame` | 65.07 | 1 | normal_debug_checkpoint |
| 340 | `P079` | `all_buckets_frame` | 65.26 | 1 | normal_debug_checkpoint |
| 341 | `P080` | `all_buckets_frame` | 65.45 | 1 | normal_debug_checkpoint |
| 342 | `P081` | `all_buckets_frame` | 65.64 | 1 | normal_debug_checkpoint |
| 343 | `P082` | `all_buckets_frame` | 65.83 | 1 | normal_debug_checkpoint |
| 344 | `P083` | `all_buckets_frame` | 66.03 | 1 | normal_debug_checkpoint |
| 345 | `P084` | `all_buckets_frame` | 66.22 | 1 | normal_debug_checkpoint |
| 346 | `P085` | `all_buckets_frame` | 66.41 | 1 | normal_debug_checkpoint |
| 347 | `P086` | `all_buckets_frame` | 66.6 | 1 | normal_debug_checkpoint |
| 348 | `P087` | `all_buckets_frame` | 66.79 | 1 | normal_debug_checkpoint |
| 349 | `P088` | `all_buckets_frame` | 66.99 | 1 | normal_debug_checkpoint |
| 350 | `P089` | `all_buckets_frame` | 67.18 | 1 | normal_debug_checkpoint |
| 351 | `P090` | `all_buckets_frame` | 67.37 | 1 | normal_debug_checkpoint |
| 352 | `P091` | `all_buckets_frame` | 67.56 | 1 | normal_debug_checkpoint |
| 353 | `P092` | `all_buckets_frame` | 67.75 | 1 | normal_debug_checkpoint |
| 354 | `P093` | `all_buckets_frame` | 67.95 | 1 | normal_debug_checkpoint |
| 355 | `P094` | `all_buckets_frame` | 68.14 | 1 | normal_debug_checkpoint |
| 356 | `P095` | `all_buckets_frame` | 68.33 | 1 | normal_debug_checkpoint |
| 357 | `P096` | `all_buckets_frame` | 68.52 | 1 | normal_debug_checkpoint |
| 358 | `P097` | `all_buckets_frame` | 68.71 | 1 | normal_debug_checkpoint |
| 359 | `P098` | `all_buckets_frame` | 68.91 | 1 | normal_debug_checkpoint |
| 360 | `P099` | `all_buckets_frame` | 69.1 | 1 | normal_debug_checkpoint |
| 361 | `P100` | `all_buckets_frame` | 69.29 | 1 | normal_debug_checkpoint |
| 362 | `P101` | `all_buckets_frame` | 69.48 | 1 | normal_debug_checkpoint |
| 363 | `P102` | `all_buckets_frame` | 69.67 | 1 | normal_debug_checkpoint |
| 364 | `P103` | `all_buckets_frame` | 69.87 | 1 | normal_debug_checkpoint |
| 365 | `P104` | `all_buckets_frame` | 70.06 | 1 | normal_debug_checkpoint |
| 366 | `P105` | `all_buckets_frame` | 70.25 | 1 | normal_debug_checkpoint |
| 367 | `P106` | `all_buckets_frame` | 70.44 | 1 | normal_debug_checkpoint |
| 368 | `P107` | `all_buckets_frame` | 70.63 | 1 | normal_debug_checkpoint |
| 369 | `P108` | `all_buckets_frame` | 70.83 | 1 | normal_debug_checkpoint |
| 370 | `P109` | `all_buckets_frame` | 71.02 | 1 | normal_debug_checkpoint |
| 371 | `P110` | `all_buckets_frame` | 71.21 | 1 | normal_debug_checkpoint |
| 372 | `P111` | `all_buckets_frame` | 71.4 | 1 | normal_debug_checkpoint |
| 373 | `P112` | `all_buckets_frame` | 71.59 | 1 | normal_debug_checkpoint |
| 374 | `P113` | `all_buckets_frame` | 71.79 | 1 | normal_debug_checkpoint |
| 375 | `P114` | `all_buckets_frame` | 71.98 | 1 | normal_debug_checkpoint |
| 376 | `P115` | `all_buckets_frame` | 72.17 | 1 | normal_debug_checkpoint |
| 377 | `P116` | `all_buckets_frame` | 72.36 | 1 | normal_debug_checkpoint |
| 378 | `P117` | `all_buckets_frame` | 72.55 | 1 | normal_debug_checkpoint |
| 379 | `P118` | `all_buckets_frame` | 72.74 | 1 | normal_debug_checkpoint |
| 380 | `P119` | `all_buckets_frame` | 72.94 | 1 | normal_debug_checkpoint |
| 381 | `P120` | `all_buckets_frame` | 73.13 | 1 | normal_debug_checkpoint |
| 382 | `P121` | `all_buckets_frame` | 73.32 | 1 | normal_debug_checkpoint |
| 383 | `P122` | `all_buckets_frame` | 73.51 | 1 | normal_debug_checkpoint |
| 384 | `P123` | `all_buckets_frame` | 73.7 | 1 | normal_debug_checkpoint |
| 385 | `P124` | `all_buckets_frame` | 73.9 | 1 | normal_debug_checkpoint |
| 386 | `P125` | `all_buckets_frame` | 74.09 | 1 | normal_debug_checkpoint |
| 387 | `P126` | `all_buckets_frame` | 74.28 | 1 | normal_debug_checkpoint |
| 388 | `P127` | `all_buckets_frame` | 74.47 | 1 | normal_debug_checkpoint |
| 389 | `P128` | `all_buckets_frame` | 74.66 | 1 | normal_debug_checkpoint |
| 390 | `P129` | `all_buckets_frame` | 74.86 | 1 | normal_debug_checkpoint |
| 391 | `P130` | `all_buckets_frame` | 75.05 | 1 | normal_debug_checkpoint |
| 392 | `X001` | `all_buckets_frame` | 75.24 | 1 | normal_debug_checkpoint |
| 393 | `X002` | `all_buckets_frame` | 75.43 | 1 | normal_debug_checkpoint |
| 394 | `X003` | `all_buckets_frame` | 75.62 | 1 | normal_debug_checkpoint |
| 395 | `X004` | `all_buckets_frame` | 75.82 | 1 | normal_debug_checkpoint |
| 396 | `X005` | `all_buckets_frame` | 76.01 | 1 | normal_debug_checkpoint |
| 397 | `X006` | `all_buckets_frame` | 76.2 | 1 | normal_debug_checkpoint |
| 398 | `X007` | `all_buckets_frame` | 76.39 | 1 | normal_debug_checkpoint |
| 399 | `X008` | `all_buckets_frame` | 76.58 | 1 | normal_debug_checkpoint |
| 400 | `X009` | `all_buckets_frame` | 76.78 | 1 | normal_debug_checkpoint |
| 401 | `X010` | `all_buckets_frame` | 76.97 | 1 | normal_debug_checkpoint |
| 402 | `X011` | `all_buckets_frame` | 77.16 | 1 | normal_debug_checkpoint |
| 403 | `X012` | `all_buckets_frame` | 77.35 | 1 | normal_debug_checkpoint |
| 404 | `X013` | `all_buckets_frame` | 77.54 | 1 | normal_debug_checkpoint |
| 405 | `X014` | `all_buckets_frame` | 77.74 | 1 | normal_debug_checkpoint |
| 406 | `X015` | `all_buckets_frame` | 77.93 | 1 | normal_debug_checkpoint |
| 407 | `X016` | `all_buckets_frame` | 78.12 | 1 | normal_debug_checkpoint |
| 408 | `X017` | `all_buckets_frame` | 78.31 | 1 | normal_debug_checkpoint |
| 409 | `X018` | `all_buckets_frame` | 78.5 | 1 | normal_debug_checkpoint |
| 410 | `X019` | `all_buckets_frame` | 78.69 | 1 | normal_debug_checkpoint |
| 411 | `X020` | `all_buckets_frame` | 78.89 | 1 | normal_debug_checkpoint |
| 412 | `X021` | `all_buckets_frame` | 79.08 | 1 | normal_debug_checkpoint |
| 413 | `X022` | `all_buckets_frame` | 79.27 | 1 | normal_debug_checkpoint |
| 414 | `X023` | `all_buckets_frame` | 79.46 | 1 | normal_debug_checkpoint |
| 415 | `X024` | `all_buckets_frame` | 79.65 | 1 | normal_debug_checkpoint |
| 416 | `X025` | `all_buckets_frame` | 79.85 | 1 | normal_debug_checkpoint |
| 417 | `X026` | `all_buckets_frame` | 80.04 | 1 | normal_debug_checkpoint |
| 418 | `X027` | `all_buckets_frame` | 80.23 | 1 | normal_debug_checkpoint |
| 419 | `X028` | `all_buckets_frame` | 80.42 | 1 | normal_debug_checkpoint |
| 420 | `X029` | `all_buckets_frame` | 80.61 | 1 | normal_debug_checkpoint |
| 421 | `X030` | `all_buckets_frame` | 80.81 | 1 | normal_debug_checkpoint |
| 422 | `X031` | `all_buckets_frame` | 81.0 | 1 | normal_debug_checkpoint |
| 423 | `X032` | `all_buckets_frame` | 81.19 | 1 | normal_debug_checkpoint |
| 424 | `X033` | `all_buckets_frame` | 81.38 | 1 | normal_debug_checkpoint |
| 425 | `X034` | `all_buckets_frame` | 81.57 | 1 | normal_debug_checkpoint |
| 426 | `X035` | `all_buckets_frame` | 81.77 | 1 | normal_debug_checkpoint |
| 427 | `X036` | `all_buckets_frame` | 81.96 | 1 | normal_debug_checkpoint |
| 428 | `X037` | `all_buckets_frame` | 82.15 | 1 | normal_debug_checkpoint |
| 429 | `X038` | `all_buckets_frame` | 82.34 | 1 | normal_debug_checkpoint |
| 430 | `X039` | `all_buckets_frame` | 82.53 | 1 | normal_debug_checkpoint |
| 431 | `X040` | `all_buckets_frame` | 82.73 | 1 | normal_debug_checkpoint |
| 432 | `X041` | `all_buckets_frame` | 82.92 | 1 | normal_debug_checkpoint |
| 433 | `X042` | `all_buckets_frame` | 83.11 | 1 | normal_debug_checkpoint |
| 434 | `X043` | `all_buckets_frame` | 83.3 | 1 | normal_debug_checkpoint |
| 435 | `X044` | `all_buckets_frame` | 83.49 | 1 | normal_debug_checkpoint |
| 436 | `X045` | `all_buckets_frame` | 83.69 | 1 | normal_debug_checkpoint |
| 437 | `X046` | `all_buckets_frame` | 83.88 | 1 | normal_debug_checkpoint |
| 438 | `X047` | `all_buckets_frame` | 84.07 | 1 | normal_debug_checkpoint |
| 439 | `X048` | `all_buckets_frame` | 84.26 | 1 | normal_debug_checkpoint |
| 440 | `X049` | `all_buckets_frame` | 84.45 | 1 | normal_debug_checkpoint |
| 441 | `X050` | `all_buckets_frame` | 84.64 | 1 | normal_debug_checkpoint |
| 442 | `X051` | `all_buckets_frame` | 84.84 | 1 | normal_debug_checkpoint |
| 443 | `X052` | `all_buckets_frame` | 85.03 | 1 | normal_debug_checkpoint |
| 444 | `X053` | `all_buckets_frame` | 85.22 | 1 | normal_debug_checkpoint |
| 445 | `X054` | `all_buckets_frame` | 85.41 | 1 | normal_debug_checkpoint |
| 446 | `X055` | `all_buckets_frame` | 85.6 | 1 | normal_debug_checkpoint |
| 447 | `X056` | `all_buckets_frame` | 85.8 | 1 | normal_debug_checkpoint |
| 448 | `X057` | `all_buckets_frame` | 85.99 | 1 | normal_debug_checkpoint |
| 449 | `X058` | `all_buckets_frame` | 86.18 | 1 | normal_debug_checkpoint |
| 450 | `X059` | `all_buckets_frame` | 86.37 | 1 | normal_debug_checkpoint |
| 451 | `X060` | `all_buckets_frame` | 86.56 | 1 | normal_debug_checkpoint |
| 452 | `X061` | `all_buckets_frame` | 86.76 | 1 | normal_debug_checkpoint |
| 453 | `X062` | `all_buckets_frame` | 86.95 | 1 | normal_debug_checkpoint |
| 454 | `X063` | `all_buckets_frame` | 87.14 | 1 | normal_debug_checkpoint |
| 455 | `X064` | `all_buckets_frame` | 87.33 | 1 | normal_debug_checkpoint |
| 456 | `X065` | `all_buckets_frame` | 87.52 | 1 | normal_debug_checkpoint |
| 457 | `X066` | `all_buckets_frame` | 87.72 | 1 | normal_debug_checkpoint |
| 458 | `X067` | `all_buckets_frame` | 87.91 | 1 | normal_debug_checkpoint |
| 459 | `X068` | `all_buckets_frame` | 88.1 | 1 | normal_debug_checkpoint |
| 460 | `X069` | `all_buckets_frame` | 88.29 | 1 | normal_debug_checkpoint |
| 461 | `X070` | `all_buckets_frame` | 88.48 | 1 | normal_debug_checkpoint |
| 462 | `X071` | `all_buckets_frame` | 88.68 | 1 | normal_debug_checkpoint |
| 463 | `X072` | `all_buckets_frame` | 88.87 | 1 | normal_debug_checkpoint |
| 464 | `X073` | `all_buckets_frame` | 89.06 | 1 | normal_debug_checkpoint |
| 465 | `X074` | `all_buckets_frame` | 89.25 | 1 | normal_debug_checkpoint |
| 466 | `X075` | `all_buckets_frame` | 89.44 | 1 | normal_debug_checkpoint |
| 467 | `X076` | `all_buckets_frame` | 89.64 | 1 | normal_debug_checkpoint |
| 468 | `X077` | `all_buckets_frame` | 89.83 | 1 | normal_debug_checkpoint |
| 469 | `X078` | `all_buckets_frame` | 90.02 | 1 | normal_debug_checkpoint |
| 470 | `X079` | `all_buckets_frame` | 90.21 | 1 | normal_debug_checkpoint |
| 471 | `X080` | `all_buckets_frame` | 90.4 | 1 | normal_debug_checkpoint |
| 472 | `X081` | `all_buckets_frame` | 90.6 | 1 | normal_debug_checkpoint |
| 473 | `X082` | `all_buckets_frame` | 90.79 | 1 | normal_debug_checkpoint |
| 474 | `X083` | `all_buckets_frame` | 90.98 | 1 | normal_debug_checkpoint |
| 475 | `X084` | `all_buckets_frame` | 91.17 | 1 | normal_debug_checkpoint |
| 476 | `X085` | `all_buckets_frame` | 91.36 | 1 | normal_debug_checkpoint |
| 477 | `X086` | `all_buckets_frame` | 91.55 | 1 | normal_debug_checkpoint |
| 478 | `X087` | `all_buckets_frame` | 91.75 | 1 | normal_debug_checkpoint |
| 479 | `X088` | `all_buckets_frame` | 91.94 | 1 | normal_debug_checkpoint |
| 480 | `X089` | `all_buckets_frame` | 92.13 | 1 | normal_debug_checkpoint |
| 481 | `X090` | `all_buckets_frame` | 92.32 | 1 | normal_debug_checkpoint |
| 482 | `X091` | `all_buckets_frame` | 92.51 | 1 | normal_debug_checkpoint |
| 483 | `X092` | `all_buckets_frame` | 92.71 | 1 | normal_debug_checkpoint |
| 484 | `X093` | `all_buckets_frame` | 92.9 | 1 | normal_debug_checkpoint |
| 485 | `X094` | `all_buckets_frame` | 93.09 | 1 | normal_debug_checkpoint |
| 486 | `X095` | `all_buckets_frame` | 93.28 | 1 | normal_debug_checkpoint |
| 487 | `X096` | `all_buckets_frame` | 93.47 | 1 | normal_debug_checkpoint |
| 488 | `X097` | `all_buckets_frame` | 93.67 | 1 | normal_debug_checkpoint |
| 489 | `X098` | `all_buckets_frame` | 93.86 | 1 | normal_debug_checkpoint |
| 490 | `X099` | `all_buckets_frame` | 94.05 | 1 | normal_debug_checkpoint |
| 491 | `X100` | `all_buckets_frame` | 94.24 | 1 | normal_debug_checkpoint |
| 492 | `X101` | `all_buckets_frame` | 94.43 | 1 | normal_debug_checkpoint |
| 493 | `X102` | `all_buckets_frame` | 94.63 | 1 | normal_debug_checkpoint |
| 494 | `X103` | `all_buckets_frame` | 94.82 | 1 | normal_debug_checkpoint |
| 495 | `X104` | `all_buckets_frame` | 95.01 | 1 | normal_debug_checkpoint |
| 496 | `X105` | `all_buckets_frame` | 95.2 | 1 | normal_debug_checkpoint |
| 497 | `X106` | `all_buckets_frame` | 95.39 | 1 | normal_debug_checkpoint |
| 498 | `X107` | `all_buckets_frame` | 95.59 | 1 | normal_debug_checkpoint |
| 499 | `X108` | `all_buckets_frame` | 95.78 | 1 | normal_debug_checkpoint |
| 500 | `X109` | `all_buckets_frame` | 95.97 | 1 | normal_debug_checkpoint |
| 501 | `X110` | `all_buckets_frame` | 96.16 | 1 | normal_debug_checkpoint |
| 502 | `X111` | `all_buckets_frame` | 96.35 | 1 | normal_debug_checkpoint |
| 503 | `X112` | `all_buckets_frame` | 96.55 | 1 | normal_debug_checkpoint |
| 504 | `X113` | `all_buckets_frame` | 96.74 | 1 | normal_debug_checkpoint |
| 505 | `X114` | `all_buckets_frame` | 96.93 | 1 | normal_debug_checkpoint |
| 506 | `X115` | `all_buckets_frame` | 97.12 | 1 | normal_debug_checkpoint |
| 507 | `X116` | `all_buckets_frame` | 97.31 | 1 | normal_debug_checkpoint |
| 508 | `X117` | `all_buckets_frame` | 97.5 | 1 | normal_debug_checkpoint |
| 509 | `X118` | `all_buckets_frame` | 97.7 | 1 | normal_debug_checkpoint |
| 510 | `X119` | `all_buckets_frame` | 97.89 | 1 | normal_debug_checkpoint |
| 511 | `X120` | `all_buckets_frame` | 98.08 | 1 | normal_debug_checkpoint |
| 512 | `X121` | `all_buckets_frame` | 98.27 | 1 | normal_debug_checkpoint |
| 513 | `X122` | `all_buckets_frame` | 98.46 | 1 | normal_debug_checkpoint |
| 514 | `X123` | `all_buckets_frame` | 98.66 | 1 | normal_debug_checkpoint |
| 515 | `X124` | `all_buckets_frame` | 98.85 | 1 | normal_debug_checkpoint |
| 516 | `X125` | `all_buckets_frame` | 99.04 | 1 | normal_debug_checkpoint |
| 517 | `X126` | `all_buckets_frame` | 99.23 | 1 | normal_debug_checkpoint |
| 518 | `X127` | `all_buckets_frame` | 99.42 | 1 | normal_debug_checkpoint |
| 519 | `X128` | `all_buckets_frame` | 99.62 | 1 | normal_debug_checkpoint |
| 520 | `X129` | `all_buckets_frame` | 99.81 | 1 | normal_debug_checkpoint |
| 521 | `X130` | `all_buckets_frame` | 100.0 | 1 | normal_debug_checkpoint |

---
_Back to [dashboard](../../DV_REPORT.md)_
