# Direct validation check for mts_processor_hw.tcl parameter guards.

set script_dir [file dirname [file normalize [info script]]]
set ip_root [file normalize [file join $script_dir .. .. ..]]
set hw_tcl [file join $ip_root mts_processor_hw.tcl]
set failed 0

rename package __real_package
proc package {args} {
    if {[llength $args] == 4 &&
        [lindex $args 0] eq "require" &&
        [lindex $args 1] eq "-exact" &&
        [lindex $args 2] eq "qsys"} {
        return [lindex $args 3]
    }
    return [uplevel 1 __real_package $args]
}

array set params {}
array set defaults {}
set messages {}

proc no_op {args} {}
foreach cmd {
    set_module_property add_display_item set_display_item_property
    add_fileset set_fileset_property add_fileset_file
    set_parameter_property add_interface set_interface_property
    add_interface_port set_interface_assignment
} {
    proc $cmd {args} {}
}

proc add_parameter {name type default_value} {
    global params
    if {![info exists params($name)]} {
        set params($name) $default_value
    }
}

proc get_parameter_value {name} {
    global params
    if {![info exists params($name)]} {
        error "unknown parameter $name"
    }
    return $params($name)
}

proc set_parameter_value {name value} {
    global params
    set params($name) $value
}

proc send_message {severity text} {
    global messages
    lappend messages [list [string tolower $severity] $text]
}

proc reset_params {} {
    global params defaults messages
    array unset params
    array set params [array get defaults]
    set messages {}
}

proc message_contains {needle} {
    global messages
    foreach message $messages {
        if {[string first $needle [lindex $message 1]] >= 0} {
            return 1
        }
    }
    return 0
}

proc require_guard {case_name overrides expected_needles} {
    global params messages failed
    reset_params
    foreach {name value} $overrides {
        set params($name) $value
    }
    validate
    foreach needle $expected_needles {
        if {![message_contains $needle]} {
            puts "FAIL: $case_name missing guard message: $needle"
            puts "Observed messages: $messages"
            set failed 1
            return
        }
    }
    puts "PASS: $case_name"
}

source $hw_tcl
array set defaults [array get params]

require_guard "enabled_hi_less_than_lo" \
    {ENABLED_CHANNEL_LO 4 ENABLED_CHANNEL_HI 3} \
    {"ENABLED_CHANNEL_HI must be greater than or equal to ENABLED_CHANNEL_LO."}

require_guard "enabled_lo_out_of_range" \
    {ENABLED_CHANNEL_LO 16 ENABLED_CHANNEL_HI 16} \
    {"ENABLED_CHANNEL_LO must stay in the range 0..15." "ENABLED_CHANNEL_HI must stay in the range 0..15."}

require_guard "enabled_hi_out_of_range" \
    {ENABLED_CHANNEL_LO 0 ENABLED_CHANNEL_HI 16} \
    {"ENABLED_CHANNEL_HI must stay in the range 0..15."}

if {$failed} {
    exit 1
}
puts "HW_TCL_VALIDATE_CHECK_PASS cases=3"
