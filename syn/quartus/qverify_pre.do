if {[catch {vlib lpm} msg]} { puts "vlib lpm: $msg" }
vmap lpm lpm
vcom -2008 -work lpm /data1/intelFPGA_pro/23.1/quartus/eda/sim_lib/220pack.vhd
if {[info exists env(MTS_PROCESSOR_SYN_DIR)]} {
    set qverify_pre_dir $env(MTS_PROCESSOR_SYN_DIR)
} else {
    error "Set MTS_PROCESSOR_SYN_DIR to the mutrig_timestamp_processor/syn/quartus directory before running qverify_pre.do"
}
vcom -2008 -work lpm [file join $qverify_pre_dir lpm_divide_blackbox.vhd]
