# ✅ SYN Report — mutrig_timestamp_processor

**Release:** `26.6.0.0716`  
**Device:** `5AGXBA7D4F31C5`  
**Quartus:** `18.1.0 Build 625 Standard Edition`  
**Source manifest:** `6e8bd65c58772cdac91713b631ce9084573187128bcdb31f7c00dd845d32bed1`

## Signoff Summary

| status | gate | evidence |
|:---:|---|---|
| ✅ | Standard Fit | seed `1`, period `7.273 ns`, effort `STANDARD FIT` |
| ✅ | All-corner TimeQuest | setup, hold, recovery, removal, and minimum-pulse-width WNS are nonnegative; every TNS is zero |
| ✅ | Resource model | ALMs `1238`, registers `2321`, memory bits `491745`, RAM blocks `63`, DSPs `0` |
| ✅ | Questa static | lint `0`, CDC `0`, RDC `0` |
| ✅ | RTL/post-fit functional signature | `1820064b`; zero-delay, no SDF |

## Timing

| corner | setup | hold | recovery | removal | minimum pulse width |
|---|---:|---:|---:|---:|---:|
| slow_85c | `1.254 ns / TNS 0.0` | `0.272 ns / TNS 0.0` | `2.829 ns / TNS 0.0` | `1.017 ns / TNS 0.0` | `2.624 ns / TNS 0.0` |
| slow_0c | `1.293 ns / TNS 0.0` | `0.196 ns / TNS 0.0` | `3.035 ns / TNS 0.0` | `0.945 ns / TNS 0.0` | `2.667 ns / TNS 0.0` |
| fast_85c | `3.7 ns / TNS 0.0` | `0.164 ns / TNS 0.0` | `4.361 ns / TNS 0.0` | `0.563 ns / TNS 0.0` | `2.465 ns / TNS 0.0` |
| fast_0c | `4.008 ns / TNS 0.0` | `0.112 ns / TNS 0.0` | `4.67 ns / TNS 0.0` | `0.516 ns / TNS 0.0` | `2.471 ns / TNS 0.0` |

## Resource acceptance

| resource | result | accepted range |
|---|---:|---:|
| alms | `1238` | `578..3468` |
| registers | `2321` | `980..5880` |
| memory_bits | `491745` | `245835..1475010` |
| ram_blocks | `63` | `31..186` |
| dsp_blocks | `0` | `0..0` |

This report is bound to promotion receipt `92075a2db8acd9e617c00c1c88c1f179381b5dc2d56efe0462c00b2568b0d84d`. The gate comparison is a zero-delay functional-netlist smoke;
TimeQuest, not that simulation, owns timing closure.

**Result: PASS.**
