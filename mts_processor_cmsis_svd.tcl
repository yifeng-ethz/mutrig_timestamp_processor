package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. toolkits infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    return [::mu3e::cmsis::svd::device MU3E_MTS_PROCESSOR \
        -version 26.6.0.0716 \
        -description "CMSIS-SVD description of the exact MuTRiG timestamp processor CSR window for the optional external epoch-reset and 48-bit timestamp, arrival, and latency sideband release." \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral MTS_PROCESSOR_CSR 0x0 \
                -description "Relative CSR aperture for the MuTRiG timestamp processor." \
                -groupName MU3E_DATA_PATH \
                -addressBlockSize 0x20 \
                -registers [list \
                    [::mu3e::cmsis::svd::register CONTROL_STATUS 0x0 \
                        -description "Datapath controls and live RUNNING status. Bit 6 is a debug coordinate selector and must remain clear for physical hit-lifetime measurements." \
                        -access read-write \
                        -resetValue 0x20000010 \
                        -fields [list \
                            [::mu3e::cmsis::svd::field go 0 1 -description "Write-enable datapath generation; readback is the live RUNNING indication." -access read-write] \
                            [::mu3e::cmsis::svd::field force_stop 1 1 -description "Block new datapath output in every run state." -access read-write] \
                            [::mu3e::cmsis::svd::field soft_reset 2 1 -description "Self-clearing reset of counters and in-flight processing." -access read-write] \
                            [::mu3e::cmsis::svd::field bypass_lapse 3 1 -description "Bypass MTS-to-GTS lapse correction for raw-counter debug." -access read-write] \
                            [::mu3e::cmsis::svd::field discard_hiterr 4 1 -description "Reject Type0 beats carrying the configured hit-error bit." -access read-write] \
                            [::mu3e::cmsis::svd::field drop_delay_error 5 1 -description "Drop Type1 beats marked with a timestamp-delay error; clear forwards the marked beat." -access read-write] \
                            [::mu3e::cmsis::svd::field debug_overflow_base_arrival 6 1 -description "Debug only: select divided overflow-base arrival. The resulting signed latency is a phase coordinate, not physical lifetime." -access read-write] \
                            [::mu3e::cmsis::svd::field delay_ts_field_use_t 29 1 -description "Use T rather than E timestamp for delay classification." -access read-write] \
                            [::mu3e::cmsis::svd::field derive_tot 30 1 -description "Enable long-hit E-minus-T derivation." -access read-write]]] \
                    [::mu3e::cmsis::svd::register DISCARD_HIT_COUNTER 0x4 \
                        -description "Number of input hits rejected by the hit-error policy." \
                        -access read-only \
                        -resetValue 0x00000000 \
                        -fields [list \
                            [::mu3e::cmsis::svd::field discard_hit_count 0 32 -description "Discarded input-hit count." -access read-only]]] \
                    [::mu3e::cmsis::svd::register EXPECTED_LATENCY_8NS 0x8 \
                        -description "Upper bound for the legacy delay-error classifier, in 8 ns ticks." \
                        -access read-write \
                        -resetValue 0x000007D0 \
                        -fields [list \
                            [::mu3e::cmsis::svd::field expected_latency 0 32 -description "Configured delay-error window; default 2000 ticks." -access read-write]]] \
                    [::mu3e::cmsis::svd::register TOTAL_HIT_COUNT_HI 0xC \
                        -description "Upper 16 bits of the 48-bit Type0 ingress-hit counter." \
                        -access read-only \
                        -resetValue 0x00000000 \
                        -fields [list \
                            [::mu3e::cmsis::svd::field total_hit_count_hi 0 16 -description "Ingress-hit count bits 47 through 32." -access read-only]]] \
                    [::mu3e::cmsis::svd::register TOTAL_HIT_COUNT_LO 0x10 \
                        -description "Lower 32 bits of the 48-bit Type0 ingress-hit counter." \
                        -access read-only \
                        -resetValue 0x00000000 \
                        -fields [list \
                            [::mu3e::cmsis::svd::field total_hit_count_lo 0 32 -description "Ingress-hit count bits 31 through 0." -access read-only]]]]]]]
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
