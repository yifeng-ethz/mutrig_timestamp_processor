package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. toolkits infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    return [::mu3e::cmsis::svd::device MU3E_MTS_PROCESSOR \
        -version 26.0.9.0501 \
        -description "CMSIS-SVD description of the MuTRiG timestamp processor CSR window." \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral MTS_PROCESSOR_CSR 0x0 \
                -description "Relative 8-word CSR aperture for the MuTRiG timestamp processor." \
                -groupName MU3E_DATA_PATH \
                -addressBlockSize 0x20 \
                -registers [list \
                    [::mu3e::cmsis::svd::register CONTROL_STATUS 0x0 \
                        -description "Mixed control/status word. Read bit 0 mirrors RUNNING; writes update control fields." \
                        -access read-write \
                        -fields [list \
                            [::mu3e::cmsis::svd::field go_or_running 0 1 -access read-write -description "Write go; read RUNNING-state mirror."] \
                            [::mu3e::cmsis::svd::field force_stop 1 1 -access read-write -description "Manual stop gate."] \
                            [::mu3e::cmsis::svd::field soft_reset 2 1 -access read-write -description "One-shot local counter/state reset."] \
                            [::mu3e::cmsis::svd::field bypass_lapse 3 1 -access read-write -description "Bypass MTS-to-GTS lapse correction."] \
                            [::mu3e::cmsis::svd::field discard_hiterr 4 1 -access read-write -description "Discard hit_type0 beats with hiterr asserted."] \
                            [::mu3e::cmsis::svd::field drop_delay_error 5 1 -access read-write -description "Drop hit_type1 beats whose timestamp-delay sideband is asserted."] \
                            [::mu3e::cmsis::svd::field delay_ts_field_use_t 29 1 -access read-write -description "Use T timestamp for delay calculation."] \
                            [::mu3e::cmsis::svd::field derive_tot 30 1 -access read-write -description "Enable long-hit E-T derivation."]]] \
                    [::mu3e::cmsis::svd::register DISCARD_HIT_CNT 0x4 \
                        -description "Count of discarded input hits." \
                        -access read-only \
                        -fields [list [::mu3e::cmsis::svd::field value 0 32 -access read-only -description "Discarded-hit count."]]] \
                    [::mu3e::cmsis::svd::register EXPECTED_LATENCY 0x8 \
                        -description "Timestamp-latency error threshold in 8 ns ticks." \
                        -access read-write \
                        -fields [list [::mu3e::cmsis::svd::field expected_latency 0 32 -access read-write -description "Expected hit latency; independent from overflow lookback."]]] \
                    [::mu3e::cmsis::svd::register TOTAL_HIT_CNT_HI 0xC \
                        -description "Upper 16 bits of the accepted-hit counter." \
                        -access read-only \
                        -fields [list [::mu3e::cmsis::svd::field value 0 16 -access read-only -description "Accepted-hit count high halfword."]]] \
                    [::mu3e::cmsis::svd::register TOTAL_HIT_CNT_LO 0x10 \
                        -description "Lower 32 bits of the accepted-hit counter." \
                        -access read-only \
                        -fields [list [::mu3e::cmsis::svd::field value 0 32 -access read-only -description "Accepted-hit count low word."]]] \
                    [::mu3e::cmsis::svd::register OVERFLOW_LOOKBACK 0x14 \
                        -description "Post-wrap epoch-disambiguation lookback in 8 ns ticks." \
                        -access read-write \
                        -fields [list [::mu3e::cmsis::svd::field overflow_lookback 0 32 -access read-write -description "Runtime lapse/overflow lookback; writes are clamped to the non-negative MuTRiG wrap range."]]] \
                    [::mu3e::cmsis::svd::register RESERVED_6 0x18 \
                        -description "Reserved MTS processor CSR word 6." \
                        -access read-only \
                        -fields [list [::mu3e::cmsis::svd::field value 0 32 -access read-only -description "Reserved."]]] \
                    [::mu3e::cmsis::svd::register RESERVED_7 0x1C \
                        -description "Reserved MTS processor CSR word 7." \
                        -access read-only \
                        -fields [list [::mu3e::cmsis::svd::field value 0 32 -access read-only -description "Reserved."]]]]]]]
}

if {[info exists ::argv0] &&
    [file normalize $::argv0] eq [file normalize [info script]]} {
    set out_path [file join $script_dir mts_processor.svd]
    if {[llength $::argv] >= 1} {
        set out_path [lindex $::argv 0]
    }
    ::mu3e::cmsis::svd::write_device_file \
        [::mu3e::cmsis::spec::build_device] $out_path
}
