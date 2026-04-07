package require Tcl 8.5

set script_dir [file dirname [info script]]
set helper_file [file normalize [file join $script_dir .. dashboard_infra system_console lib board_bring_up_meta.tcl]]
if {![llength [info commands ::board_bring_up::meta::field]]} {
        source $helper_file
}

namespace eval ::board_bring_up::meta::mts_processor {
}

proc ::board_bring_up::meta::mts_processor::get_contract {} {
        set registers [list \
                [::board_bring_up::meta::register \
                        "control_and_status" \
                        "Control and status registers of MuTRiG Timestamp Processor IP" \
                        "0x0" \
                        [list \
                                [::board_bring_up::meta::field "go" "allow to generate new hits during RUNNING run state" {[0:0]} "read-write"] \
                                [::board_bring_up::meta::field "force_stop" "force to stop the datapath processing output in any run state" {[1:1]} "read-write"] \
                                [::board_bring_up::meta::field "soft_reset" "soft reset this IP, including counters and in-processing hits" {[2:2]} "read-write"] \
                                [::board_bring_up::meta::field "bypass_lapse" "disable the lapse (leap) correction between mts and gts. debug to see the raw coarse counter distribution." {[3:3]} "read-write"] \
                                [::board_bring_up::meta::field "discard_hiterr" "disable input error check of 'hiterr' error signal" {[4:4]} "read-write"] \
                                [::board_bring_up::meta::field "op_mode" "three-bit operating mode control" {[30:28]} "read-write"]]] \
                [::board_bring_up::meta::register \
                        "discard_hit_counter" \
                        "Counter of discarded hit at the input due to 'hiterr'" \
                        "0x4" \
                        [list [::board_bring_up::meta::field "discard_hit_count" "number of discarded hit" {[31:0]} "read-only"]]] \
                [::board_bring_up::meta::register \
                        "expected_latency_8ns" \
                        "Expected mutrig buffering latency in 8ns" \
                        "0x8" \
                        [list [::board_bring_up::meta::field "expected_latency" "expected latency of the hit (default=2000)." {[31:0]} "read-write"]]] \
                [::board_bring_up::meta::register \
                        "total_hit_cnt_hi" \
                        "Counter of total number of hits at ingress port (upper 16 bits)" \
                        "0xc" \
                        [list [::board_bring_up::meta::field "total_hit_cnt_hi" "Total number of hits, upper 16 bits." {[15:0]} "read-only"]]] \
                [::board_bring_up::meta::register \
                        "total_hit_cnt_lo" \
                        "Counter of total number of hits at ingress port (lower 32 bits)" \
                        "0x10" \
                        [list [::board_bring_up::meta::field "total_hit_cnt_lo" "Total number of hits, lower 32 bits." {[31:0]} "read-only"]]]]

        return [::board_bring_up::meta::contract $registers]
}
