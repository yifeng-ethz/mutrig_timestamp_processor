package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. dashboard_infra cmsis_svd lib mu3e_cmsis_svd.tcl]]
source $helper_file

namespace eval ::mu3e::cmsis::spec {}

proc ::mu3e::cmsis::spec::build_device {} {
    return [::mu3e::cmsis::svd::device MU3E_MTS_PROCESSOR \
        -version 26.0.404 \
        -description "CMSIS-SVD description of the MuTRiG timestamp processor CSR window. This conservative first-pass schema exposes the 8-word relative aperture as read-only WORD registers until the IP author replaces them with the exact CSR contract." \
        -peripherals [list \
            [::mu3e::cmsis::svd::peripheral MTS_PROCESSOR_CSR 0x0 \
                -description "Relative 8-word CSR aperture for the MuTRiG timestamp processor." \
                -groupName MU3E_DATA_PATH \
                -addressBlockSize 0x20 \
                -registers [::mu3e::cmsis::svd::word_window_registers 8 \
                    -descriptionPrefix "MTS processor CSR word" \
                    -fieldDescriptionPrefix "Raw MTS processor CSR word" \
                    -access read-only]]]]
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
