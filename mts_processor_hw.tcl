# mts_processor_hw.tcl
# Platform Designer component for the MuTRiG timestamp processor

package require -exact qsys 16.1

# ========================================================================
# Packaging constants
# ========================================================================
set SCRIPT_DIR [file dirname [info script]]
if {[string length $SCRIPT_DIR] == 0} {
    set SCRIPT_DIR [pwd]
}

set DEFAULT_LPM_DIV_PIPELINE_CONST         4
set DEFAULT_EXPECTED_LATENCY_8N_CONST      2000
set DEFAULT_OVERFLOW_LOOKBACK_8N_CONST     2000
set DEFAULT_PADDING_EOP_WAIT_CYCLE_CONST   512

set IP_UID_DEFAULT_CONST                   1297376080 ;# ASCII "MTSP" = 0x4D545350
set VERSION_MAJOR_DEFAULT_CONST            26
set VERSION_MINOR_DEFAULT_CONST            6
set VERSION_PATCH_DEFAULT_CONST            0
set BUILD_DEFAULT_CONST                    716
set VERSION_DATE_DEFAULT_CONST             20260716
set VERSION_GIT_DEFAULT_CONST              0
set VERSION_GIT_SHORT_DEFAULT_CONST        "unknown"
set VERSION_GIT_DESCRIBE_DEFAULT_CONST     "unknown"
if {![catch {set VERSION_GIT_SHORT_DEFAULT_CONST [string trim [exec git -C $SCRIPT_DIR rev-parse --short HEAD]]}]} {
    if {[regexp {^[0-9a-fA-F]+$} $VERSION_GIT_SHORT_DEFAULT_CONST]} {
        scan $VERSION_GIT_SHORT_DEFAULT_CONST %x VERSION_GIT_DEFAULT_CONST
    }
}
catch {
    set VERSION_GIT_DESCRIBE_DEFAULT_CONST [string trim [exec git -C $SCRIPT_DIR describe --always --dirty --tags]]
}
set VERSION_GIT_HEX_DEFAULT_CONST [format "0x%08X" $VERSION_GIT_DEFAULT_CONST]
set VERSION_STRING_DEFAULT_CONST  [format "%d.%d.%d.%04d" \
    $VERSION_MAJOR_DEFAULT_CONST \
    $VERSION_MINOR_DEFAULT_CONST \
    $VERSION_PATCH_DEFAULT_CONST \
    $BUILD_DEFAULT_CONST]
set INSTANCE_ID_DEFAULT_CONST     0

# ========================================================================
# Module properties
# ========================================================================
set_module_property NAME                         mts_preprocessor
set_module_property DISPLAY_NAME                 "MuTRiG Timestamp Processor"
set_module_property VERSION                      $VERSION_STRING_DEFAULT_CONST
set_module_property DESCRIPTION                  "MuTRiG Timestamp Processor Mu3e IP Core"
set_module_property GROUP                        "Mu3e Data Plane/Modules"
set_module_property AUTHOR                       "Yifeng Wang"
set_module_property INTERNAL                     false
set_module_property OPAQUE_ADDRESS_MAP           true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     true
set_module_property REPORT_TO_TALKBACK           false
set_module_property ALLOW_GREYBOX_GENERATION     false
set_module_property REPORT_HIERARCHY             false
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property VALIDATION_CALLBACK          validate

# ========================================================================
# Helper
# ========================================================================
proc add_html_text {group_name item_name html_text} {
    add_display_item $group_name $item_name TEXT ""
    set_display_item_property $item_name DISPLAY_HINT html
    set_display_item_property $item_name TEXT $html_text
}

proc compute_derived_values {} {
    set channel_lo     [get_parameter_value ENABLED_CHANNEL_LO]
    set channel_hi     [get_parameter_value ENABLED_CHANNEL_HI]
    set enabled_count  [expr {$channel_hi - $channel_lo + 1}]
    set div_pipeline   [get_parameter_value LPM_DIV_PIPELINE]
    set pad_wait       [get_parameter_value PADDING_EOP_WAIT_CYCLE]
    set exp_latency    [get_parameter_value MUTRIG_BUFFER_EXPECTED_LATENCY_8N]
    set overflow_lookback [get_parameter_value MUTRIG_OVERFLOW_LOOKBACK_8N]
    set bank_name      [get_parameter_value BANK]
    set version_string [format "%d.%d.%d.%04d" \
        [get_parameter_value VERSION_MAJOR] \
        [get_parameter_value VERSION_MINOR] \
        [get_parameter_value VERSION_PATCH] \
        [get_parameter_value BUILD]]
    set version_git_hex [format "0x%08X" [get_parameter_value VERSION_GIT]]

    catch {
        set_display_item_property overview_html TEXT [format {<html>\
<b>Function</b><br/>\
Consumes <b>hit_type0</b> words from MuTRiG frame deassembly, decodes gray-coded timestamps,\
performs the 1.6 ns to 8 ns + remainder conversion, optionally derives E-T for long hits, and\
emits <b>hit_type1</b> words for downstream hit stacking.<br/><br/>\
<b>Data path</b><br/>\
<b>hit_type0_in</b> &rarr; gray decoder ROM &rarr; lapse / overflow correction &rarr; divider pipeline &rarr; <b>hit_type1_out</b><br/><br/>\
<b>Run-state contract</b><br/>\
<b>RUN_PREPARE</b> and <b>SYNC</b> are acknowledged only after the local reset/arm path reaches the requested state.<br/>\
By default the timestamp epoch remains reset throughout local RESET/SYNC. Set <b>USE_EXTERNAL_EPOCH_RESET</b> only when a synchronous integration-level epoch release must control the timestamp counters instead.<br/>\
<b>RUNNING</b> accepts new hits.<br/>\
<b>TERMINATING</b> drains the accepted packet tail, waits for the dedicated upstream <b>hit_type0_endofrun</b>\
pulse, and acknowledges only after one empty <b>hit_type1</b> close marker has been emitted per downstream lane.<br/><br/>\
<b>Configured slice</b><br/>\
Bank <b>%s</b>, enabled channel window <b>%d..%d</b> (%d channels), divider pipeline <b>%d</b>, padding wait\
<b>%d</b> cycles, expected latency <b>%d</b> 8 ns ticks, overflow lookback <b>%d</b> 8 ns ticks.</html>} \
            $bank_name \
            $channel_lo \
            $channel_hi \
            $enabled_count \
            $div_pipeline \
            $pad_wait \
            $exp_latency \
            $overflow_lookback]
    }
    catch {
        set_display_item_property timing_html TEXT {<html>\
<b>Timing-related parameters</b><br/>\
<b>LPM_DIV_PIPELINE</b> is packaged at the RTL default of <b>4</b> stages in this revision, matching the delivered source.<br/>\
<b>PADDING_EOP_WAIT_CYCLE</b> defines the end-of-run grace window used by the terminating drain logic.<br/>\
<b>MUTRIG_BUFFER_EXPECTED_LATENCY_8N</b> seeds the standalone timestamp-lapse window and the associated error reporting.<br/>\
<b>MUTRIG_OVERFLOW_LOOKBACK_8N</b> is a separate post-wrap disambiguation window used only to decide when a high MuTRiG timestamp belongs to the previous epoch.<br/>\
<b>USE_EXTERNAL_EPOCH_RESET</b> materializes a synchronous <b>epoch_reset</b> conduit and makes it the exclusive run-epoch reset source for both MTS and GTS counters. CSR soft reset remains effective in either mode.</html>}
    }
    catch {
        set_display_item_property debug_html TEXT {<html>\
<b>DEBUG</b><br/>\
Controls built-in report instrumentation and standalone observability. Non-zero values increase debug visibility; they do not add a backpressure model to <b>hit_type1_out</b>. Hit counters count accepted <b>hit_type0_in</b> valid transfers only.<br/><br/>\
<b>DEBUG = 0</b>: no optional debug conduits are materialized by Platform Designer; the HDL status and sidecar outputs are tied to zero.<br/>\
<b>DEBUG &gt;= 1</b>: adds <b>debug_status</b>, a 32-bit synthesizable status conduit with ready, accept, busy, state, occupancy, termination, and debug-level fields.<br/>\
<b>DEBUG &gt;= 2</b>: adds the 64-bit <b>hit_type0_sidecar</b> input conduit and <b>hit_type1_sidecar</b> output conduit. Metadata is sampled only with hit_type0 beats accepted into the datapath and is emitted only with delivered hit_type1 payload beats; terminate markers and locally dropped delay-error hits do not assert sidecar valid.</html>}
    }
    catch {
        set_display_item_property profile_html TEXT [format {<html>\
<b>Catalog revision</b><br/>\
Packaged as <b>%s</b>.<br/><br/>\
<b>Delivered behavior</b><br/>\
This image aligns the standalone timestamp processor with the run-sequence upgrade contract: <b>asi_ctrl_ready</b> is stateful,\
the upstream <b>endofrun</b> sideband drives the terminate-close path, the packaged divider depth matches the RTL default, and\
CONTROL_STATUS bit 5 can optionally trim timestamp-delay-error payload beats while the default still forwards them with the error sideband asserted. \
The DEBUG contract now adds optional synthesizable status and one-to-one hit metadata sidecar conduits without changing DEBUG=0 nominal payload behavior.<br/><br/>\
The optional external epoch-reset profile preserves the legacy RESET/SYNC behavior when disabled and exposes a synchronous conduit only when explicitly enabled.<br/><br/>\
<b>Packaging provenance</b><br/>\
Default git stamp <b>%s</b> (%s). Git describe: <b>%s</b>.</html>} \
            $version_string \
            $version_git_hex \
            $::VERSION_GIT_SHORT_DEFAULT_CONST \
            $::VERSION_GIT_DESCRIBE_DEFAULT_CONST]
    }
    catch {
        set_display_item_property versioning_html TEXT [format {<html>\
<b>VERSION encoding</b><br/>\
VERSION[31:24] = MAJOR, VERSION[23:16] = MINOR, VERSION[15:12] = PATCH, VERSION[11:0] = BUILD.<br/><br/>\
<b>Catalog identity</b><br/>\
UID default is <b>MTSP</b> (0x4D545350).<br/>\
Default <b>VERSION_GIT</b> = <b>%s</b> (%s). Git describe = <b>%s</b>.<br/>\
Enable <b>Override Git Stamp</b> to enter a custom value.<br/><br/>\
<b>Editability</b><br/>\
<b>IP_UID</b> and <b>INSTANCE_ID</b> remain integration-editable; version/build/date fields stay locked to the packaged image.</html>} \
            $version_git_hex \
            $::VERSION_GIT_SHORT_DEFAULT_CONST \
            $::VERSION_GIT_DESCRIBE_DEFAULT_CONST]
    }
    catch {
        set_display_item_property interfaces_html TEXT [format {<html>\
<b>Clocks and resets</b><br/>\
Single synchronous <b>clock_interface</b> domain with <b>reset_interface</b> associated to that clock. When <b>USE_EXTERNAL_EPOCH_RESET</b> is enabled, the input-only <b>epoch_reset</b> conduit is sampled synchronously in this same domain; it resets timestamp epoch state but does not reset the run-control FSM or CSR block.<br/><br/>\
<b>Control stream: run_ctrl</b><br/>\
9-bit one-hot run command. <b>asi_ctrl_ready</b> is low while RUN_PREPARE / SYNC / TERMINATING work is still outstanding and rises only when the local state has truly completed.<br/><br/>\
<b>Ingress stream: hit_type0_in</b><br/>\
45-bit payload = ASIC[44:41], channel[40:36], TCC[35:21], TFine[20:16], ECC[15:1], EFlag[0].\
The Type1 ASIC field is derived from the readyless mux slot in <b>channel[5:4]</b> plus BANK: UP maps slots 0..3 to ASIC0..3, DW/DOWN maps slots 0..3 to ASIC4..7.\
SOP/EOP delimit one MuTRiG frame. A dedicated <b>endofrun</b> pulse marks the last packet of the run; under TERMINATING the processor accepts tail packets until that pulse arrives, then drains and closes each downstream lane.<br/><br/>\
<b>Egress stream: hit_type1_out</b><br/>\
39-bit Type1 payload = ASIC[38:35], channel[34:30], TCC_8n[29:17], TCC_1n6[16:14], TFine[13:9], ET_1n6[8:0].\
<b>startofpacket</b> marks the first accepted beat for each enabled channel in a run. <b>endofpacket</b> marks the terminating boundary.\
<b>empty</b> is asserted only for the dedicated per-lane terminate marker. The current RTL exposes <b>aso_hit_type1_ready</b> for interface compatibility but does not stall on it.<br/><br/>\
<b>Streaming debug plane</b><br/>\
<b>hit_type1_extended_0</b> and <b>hit_type1_extended_1</b> are readyless 87-bit sources that carry data[86:39]=true hit ts[47:0] and data[38:0]=the Type1 payload. BANK=UP drives extended_0; BANK=DW/DOWN drives extended_1. These ports assert valid only for real payload beats, not terminate markers.<br/><br/>\
<b>Debug streams</b><br/>\
<b>debug_ts</b>, <b>debug_burst</b>, and <b>ts_delta</b> are observation-only outputs for standalone bring-up and profiling.<br/><br/>\
<b>Optional DEBUG conduits</b><br/>\
When <b>DEBUG &gt;= 1</b>, <b>debug_status</b> exports a 32-bit packed conduit: bit 0 input ready, bit 1 hit_type0 ready/valid transfer, bit 2 datapath-accepted hit, bit 3 hit_in_ok, bit 4 processor_allow_input, bit 5 input-pipeline busy, bit 6 divider-pipeline busy, bit 7 hit_out valid, bit 8 timestamp-delay error, bit 9 upstream end-of-run seen, bit 10 terminate marker pending, bit 11 control ready, bits 15:12 processor state, bits 19:16 run command state, bits 24:20 internal valid-stage occupancy, bits 28:25 terminate-lane sent mask, bits 31:29 DEBUG level.<br/>\
When <b>DEBUG &gt;= 2</b>, <b>hit_type0_sidecar</b> provides 64-bit metadata sampled with datapath-accepted hit_type0 beats and <b>hit_type1_sidecar</b> returns the same metadata with delivered hit_type1 payload beats. Sidecar valid is low for terminate markers and for delay-error payload beats dropped by CONTROL_STATUS bit 5.<br/><br/>\
<b>Configured channel window</b><br/>\
Enabled channel range <b>%d..%d</b> (%d channels).</html>} \
            $channel_lo \
            $channel_hi \
            $enabled_count]
    }
    catch {
        set_display_item_property regmap_html TEXT {<html><table border="1" cellpadding="3" width="100%">\
<tr><th>Word</th><th>Byte</th><th>Name</th><th>Access</th><th>Description</th></tr>\
<tr><td>0x00</td><td>0x000</td><td>CONTROL_STATUS</td><td>RW/RO</td><td>Mixed control / status word. Read bit 0 mirrors RUNNING state, while writes update control fields.</td></tr>\
<tr><td>0x01</td><td>0x004</td><td>DISCARD_HIT_CNT</td><td>RO</td><td>Count of hits rejected by hiterr filtering or by being presented in a disallowed run state.</td></tr>\
<tr><td>0x02</td><td>0x008</td><td>EXPECTED_LATENCY</td><td>RW</td><td>Expected MuTRiG buffering latency in 8 ns ticks.</td></tr>\
<tr><td>0x03</td><td>0x00C</td><td>TOTAL_HIT_CNT_HI</td><td>RO</td><td>Upper 16 bits of the running accepted-hit counter.</td></tr>\
<tr><td>0x04</td><td>0x010</td><td>TOTAL_HIT_CNT_LO</td><td>RO</td><td>Lower 32 bits of the running accepted-hit counter.</td></tr>\
</table><br/>\
<table border="1" cellpadding="3" width="100%">\
<tr><th>Word</th><th>Bits</th><th>Field</th><th>Access</th><th>Description</th></tr>\
<tr><td>0x00</td><td>[0]</td><td>go_or_running</td><td>RW/RO</td><td>Write: <b>csr.go</b>. Read: RUNNING state mirror, not the raw stored write bit.</td></tr>\
<tr><td>0x00</td><td>[1]</td><td>force_stop</td><td>RW</td><td>Manual stop gate on the input-accept path.</td></tr>\
<tr><td>0x00</td><td>[2]</td><td>soft_reset</td><td>RW</td><td>One-shot local counter / state reset request.</td></tr>\
<tr><td>0x00</td><td>[3]</td><td>bypass_lapse</td><td>RW</td><td>Bypass the MTS to GTS lapse correction path.</td></tr>\
<tr><td>0x00</td><td>[4]</td><td>discard_hiterr</td><td>RW</td><td>Reject hit_type0 beats with the configured hiterr bit set.</td></tr>\
<tr><td>0x00</td><td>[5]</td><td>drop_delay_error</td><td>RW</td><td>Drop hit_type1 payload beats whose timestamp-delay error sideband is asserted. Leave clear to forward error-marked hits to downstream filters and monitors.</td></tr>\
<tr><td>0x00</td><td>[6]</td><td>debug_overflow_base_arrival</td><td>RW</td><td>Debug only: replace direct emission GTS with the divided overflow base. The resulting subtraction is a phase coordinate, not physical hit lifetime. Keep clear in production.</td></tr>\
<tr><td>0x00</td><td>[29]</td><td>delay_ts_field_use_t</td><td>RW</td><td>Select T timestamp for delay calculation when set.</td></tr>\
<tr><td>0x00</td><td>[30]</td><td>derive_tot</td><td>RW</td><td>Enable long-hit E-T derivation.</td></tr>\
<tr><td>0x00</td><td>[31,28,27:7]</td><td>reserved</td><td>RW/RO</td><td>Reserved.</td></tr>\
</table></html>}
    }
}

proc add_debug_status_interface {} {
    add_interface debug_status conduit start
    set_interface_property debug_status associatedClock clock_interface
    set_interface_property debug_status associatedReset reset_interface
    set_interface_property debug_status ENABLED true
    add_interface_port debug_status coe_debug_status_data status Output 32
}

proc add_debug_sidecar_interfaces {} {
    add_interface hit_type0_sidecar conduit end
    set_interface_property hit_type0_sidecar associatedClock clock_interface
    set_interface_property hit_type0_sidecar associatedReset reset_interface
    set_interface_property hit_type0_sidecar ENABLED true
    add_interface_port hit_type0_sidecar coe_hit_type0_sidecar_data metadata Input 64
    add_interface_port hit_type0_sidecar coe_hit_type0_sidecar_valid valid Input 1

    add_interface hit_type1_sidecar conduit start
    set_interface_property hit_type1_sidecar associatedClock clock_interface
    set_interface_property hit_type1_sidecar associatedReset reset_interface
    set_interface_property hit_type1_sidecar ENABLED true
    add_interface_port hit_type1_sidecar coe_hit_type1_sidecar_data  metadata Output 64
    add_interface_port hit_type1_sidecar coe_hit_type1_sidecar_valid valid    Output 1
}

proc set_debug_interface_enable {debug_level} {
    set_interface_property debug_status ENABLED [expr {$debug_level >= 1}]
    set_interface_property hit_type0_sidecar ENABLED [expr {$debug_level >= 2}]
    set_interface_property hit_type1_sidecar ENABLED [expr {$debug_level >= 2}]
}

proc validate {} {
    compute_derived_values

    set frame_corrupt_bit [get_parameter_value FRAME_CORRPT_BIT_LOC]
    set crcerr_bit        [get_parameter_value CRCERR_BIT_LOC]
    set hiterr_bit        [get_parameter_value HITERR_BIT_LOC]
    set channel_lo        [get_parameter_value ENABLED_CHANNEL_LO]
    set channel_hi        [get_parameter_value ENABLED_CHANNEL_HI]
    set pad_wait          [get_parameter_value PADDING_EOP_WAIT_CYCLE]
    set div_pipeline      [get_parameter_value LPM_DIV_PIPELINE]
    set exp_latency       [get_parameter_value MUTRIG_BUFFER_EXPECTED_LATENCY_8N]
    set overflow_lookback [get_parameter_value MUTRIG_OVERFLOW_LOOKBACK_8N]
    set debug_level       [get_parameter_value DEBUG]
    set ip_uid            [get_parameter_value IP_UID]
    set build_value       [get_parameter_value BUILD]
    set ver_major         [get_parameter_value VERSION_MAJOR]
    set ver_minor         [get_parameter_value VERSION_MINOR]
    set ver_patch         [get_parameter_value VERSION_PATCH]
    set ver_date          [get_parameter_value VERSION_DATE]
    set ver_git           [get_parameter_value VERSION_GIT]
    set instance_id       [get_parameter_value INSTANCE_ID]

    foreach {name value} [list \
        FRAME_CORRPT_BIT_LOC $frame_corrupt_bit \
        CRCERR_BIT_LOC       $crcerr_bit \
        HITERR_BIT_LOC       $hiterr_bit \
    ] {
        if {$value < 0 || $value > 31} {
            send_message error "$name must stay in the range 0..31."
        }
    }
    if {$channel_lo < 0 || $channel_lo > 15} {
        send_message error "ENABLED_CHANNEL_LO must stay in the range 0..15."
    }
    if {$channel_hi < 0 || $channel_hi > 15} {
        send_message error "ENABLED_CHANNEL_HI must stay in the range 0..15."
    }
    if {$channel_hi < $channel_lo} {
        send_message error "ENABLED_CHANNEL_HI must be greater than or equal to ENABLED_CHANNEL_LO."
    }
    if {$pad_wait < 0 || $pad_wait > 4096} {
        send_message error "PADDING_EOP_WAIT_CYCLE must stay in the range 0..4096."
    }
    if {$div_pipeline < 0 || $div_pipeline > 16} {
        send_message error "LPM_DIV_PIPELINE must stay in the range 0..16."
    }
    if {$exp_latency < 0 || $exp_latency > 65535} {
        send_message error "MUTRIG_BUFFER_EXPECTED_LATENCY_8N must stay in the range 0..65535."
    }
    if {$overflow_lookback < 0 || $overflow_lookback > 6553} {
        send_message error "MUTRIG_OVERFLOW_LOOKBACK_8N must stay in the range 0..6553 so the 1.6 ns padding threshold remains non-negative."
    }
    if {$overflow_lookback > $exp_latency} {
        send_message warning "MUTRIG_OVERFLOW_LOOKBACK_8N is larger than MUTRIG_BUFFER_EXPECTED_LATENCY_8N; corrected hits may still be reported as timestamp-latency errors."
    }
    if {$debug_level < 0 || $debug_level > 4} {
        send_message error "DEBUG must stay in the range 0..4."
    }
    if {$ip_uid < 0 || $ip_uid > 2147483647} {
        send_message error "IP_UID must stay in the signed 31-bit range."
    }
    if {$build_value < 0 || $build_value > 4095} {
        send_message error "BUILD must stay in the range 0..4095."
    }
    if {$ver_major < 0 || $ver_major > 255} {
        send_message error "VERSION_MAJOR must stay in the range 0..255."
    }
    if {$ver_minor < 0 || $ver_minor > 255} {
        send_message error "VERSION_MINOR must stay in the range 0..255."
    }
    if {$ver_patch < 0 || $ver_patch > 15} {
        send_message error "VERSION_PATCH must stay in the range 0..15."
    }
    if {$ver_date < 0 || $ver_date > 2147483647} {
        send_message error "VERSION_DATE must stay in the signed 31-bit range."
    }
    if {$ver_git < 0 || $ver_git > 2147483647} {
        send_message error "VERSION_GIT must stay in the signed 31-bit range."
    }
    if {$instance_id < 0 || $instance_id > 2147483647} {
        send_message error "INSTANCE_ID must stay in the signed 31-bit range."
    }
}

proc elaborate {} {
    compute_derived_values
    set debug_level [get_parameter_value DEBUG]
    set bank_name [string toupper [get_parameter_value BANK]]

    set_parameter_property FRAME_CORRPT_BIT_LOC ENABLED false
    set_parameter_property CRCERR_BIT_LOC ENABLED false
    set_parameter_property HITERR_BIT_LOC ENABLED false
    set_parameter_property VERSION_MAJOR ENABLED false
    set_parameter_property VERSION_MINOR ENABLED false
    set_parameter_property VERSION_PATCH ENABLED false
    set_parameter_property BUILD ENABLED false
    set_parameter_property VERSION_DATE ENABLED false
    catch {set_parameter_property VERSION_GIT ENABLED [get_parameter_value GIT_STAMP_OVERRIDE]}

    set_debug_interface_enable $debug_level
    set_interface_property epoch_reset ENABLED [get_parameter_value USE_EXTERNAL_EPOCH_RESET]
    set_interface_property hit_type1_extended_0 ENABLED [expr {$bank_name eq "UP"}]
    set_interface_property hit_type1_extended_1 ENABLED [expr {$bank_name ne "UP"}]
    set_interface_property debug_ts ENABLED [expr {$debug_level >= 1}]
    set_interface_property debug_burst ENABLED [expr {$debug_level >= 1}]
    set_interface_property ts_delta ENABLED [expr {$debug_level >= 1}]
}

# ========================================================================
# File sets
# ========================================================================
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL mts_processor
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file mts_processor.vhd      VHDL    PATH mts_processor.vhd TOP_LEVEL_FILE
add_fileset_file dual_port_rom.v        VERILOG PATH dual_port_rom.v
add_fileset_file dual_port_rom_init.txt OTHER   PATH dual_port_rom_init.txt

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL mts_processor
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file mts_processor.vhd      VHDL    PATH mts_processor.vhd TOP_LEVEL_FILE
add_fileset_file dual_port_rom.v        VERILOG PATH dual_port_rom.v
add_fileset_file dual_port_rom_init.txt OTHER   PATH dual_port_rom_init.txt

# ========================================================================
# Parameters
# ========================================================================
add_parameter FRAME_CORRPT_BIT_LOC NATURAL 2
set_parameter_property FRAME_CORRPT_BIT_LOC DISPLAY_NAME "Frame Corrupt Bit"
set_parameter_property FRAME_CORRPT_BIT_LOC HDL_PARAMETER true
set_parameter_property FRAME_CORRPT_BIT_LOC VISIBLE false

add_parameter CRCERR_BIT_LOC NATURAL 1
set_parameter_property CRCERR_BIT_LOC DISPLAY_NAME "CRC Error Bit"
set_parameter_property CRCERR_BIT_LOC HDL_PARAMETER true
set_parameter_property CRCERR_BIT_LOC VISIBLE false

add_parameter HITERR_BIT_LOC NATURAL 0
set_parameter_property HITERR_BIT_LOC DISPLAY_NAME "Hit Error Bit"
set_parameter_property HITERR_BIT_LOC HDL_PARAMETER true
set_parameter_property HITERR_BIT_LOC VISIBLE false

add_parameter BANK STRING UP
set_parameter_property BANK DISPLAY_NAME "Bank Tag"
set_parameter_property BANK HDL_PARAMETER true
set_parameter_property BANK AFFECTS_ELABORATION true
set_parameter_property BANK DESCRIPTION "Label carried by debug messages and standalone profiling output."

add_parameter ENABLED_CHANNEL_LO NATURAL 0
set_parameter_property ENABLED_CHANNEL_LO DISPLAY_NAME "Enabled Channel Low"
set_parameter_property ENABLED_CHANNEL_LO ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
set_parameter_property ENABLED_CHANNEL_LO HDL_PARAMETER true

add_parameter ENABLED_CHANNEL_HI NATURAL 3
set_parameter_property ENABLED_CHANNEL_HI DISPLAY_NAME "Enabled Channel High"
set_parameter_property ENABLED_CHANNEL_HI ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
set_parameter_property ENABLED_CHANNEL_HI HDL_PARAMETER true

add_parameter PADDING_EOP_WAIT_CYCLE NATURAL $DEFAULT_PADDING_EOP_WAIT_CYCLE_CONST
set_parameter_property PADDING_EOP_WAIT_CYCLE DISPLAY_NAME "Terminate Padding Wait"
set_parameter_property PADDING_EOP_WAIT_CYCLE HDL_PARAMETER true
set_parameter_property PADDING_EOP_WAIT_CYCLE DESCRIPTION "Grace window, in cycles, for end-of-run drain / marker generation."

add_parameter LPM_DIV_PIPELINE NATURAL $DEFAULT_LPM_DIV_PIPELINE_CONST
set_parameter_property LPM_DIV_PIPELINE DISPLAY_NAME "Divider Pipeline Depth"
set_parameter_property LPM_DIV_PIPELINE HDL_PARAMETER true
set_parameter_property LPM_DIV_PIPELINE DESCRIPTION "Must match the RTL divider pipeline depth. Packaged default is 4."

add_parameter MUTRIG_BUFFER_EXPECTED_LATENCY_8N NATURAL $DEFAULT_EXPECTED_LATENCY_8N_CONST
set_parameter_property MUTRIG_BUFFER_EXPECTED_LATENCY_8N DISPLAY_NAME "Expected Buffer Latency (8 ns)"
set_parameter_property MUTRIG_BUFFER_EXPECTED_LATENCY_8N HDL_PARAMETER true
set_parameter_property MUTRIG_BUFFER_EXPECTED_LATENCY_8N DESCRIPTION "Timestamp-latency error threshold and CSR reset default, in 8 ns ticks."

add_parameter MUTRIG_OVERFLOW_LOOKBACK_8N NATURAL $DEFAULT_OVERFLOW_LOOKBACK_8N_CONST
set_parameter_property MUTRIG_OVERFLOW_LOOKBACK_8N DISPLAY_NAME "Overflow Lookback (8 ns)"
set_parameter_property MUTRIG_OVERFLOW_LOOKBACK_8N HDL_PARAMETER true
set_parameter_property MUTRIG_OVERFLOW_LOOKBACK_8N DESCRIPTION "Post-wrap epoch-disambiguation window, in 8 ns ticks. This is intentionally independent from the timestamp-error threshold."

add_parameter DEBUG NATURAL 1
set_parameter_property DEBUG DISPLAY_NAME "Debug Level"
set_parameter_property DEBUG HDL_PARAMETER true
set_parameter_property DEBUG AFFECTS_ELABORATION true
set_parameter_property DEBUG ALLOWED_RANGES {0 1 2 3 4}
set_parameter_property DEBUG DESCRIPTION "0 keeps optional debug conduits disabled and tied off in HDL; 1 adds debug_status; 2 and above adds one-to-one 64-bit hit sidecar propagation."

add_parameter DV_COUNTER_SEED_ENABLE NATURAL 0
set_parameter_property DV_COUNTER_SEED_ENABLE DISPLAY_NAME "DV Counter Seed Enable"
set_parameter_property DV_COUNTER_SEED_ENABLE HDL_PARAMETER true
set_parameter_property DV_COUNTER_SEED_ENABLE VISIBLE false
set_parameter_property DV_COUNTER_SEED_ENABLE DESCRIPTION "DV-only rollover accelerator. Leave at 0 for synthesis and normal packaged systems."

add_parameter USE_EXTERNAL_EPOCH_RESET BOOLEAN false
set_parameter_property USE_EXTERNAL_EPOCH_RESET DISPLAY_NAME "Use External Epoch Reset"
set_parameter_property USE_EXTERNAL_EPOCH_RESET HDL_PARAMETER true
set_parameter_property USE_EXTERNAL_EPOCH_RESET AFFECTS_ELABORATION true
set_parameter_property USE_EXTERNAL_EPOCH_RESET DESCRIPTION "Expose a synchronous epoch_reset conduit and use it, instead of local RESET/SYNC state, to reset the MTS/GTS timestamp epoch. CSR soft reset remains active."

add_parameter IP_UID INTEGER $IP_UID_DEFAULT_CONST
set_parameter_property IP_UID DISPLAY_NAME "IP UID"

add_parameter VERSION_MAJOR INTEGER $VERSION_MAJOR_DEFAULT_CONST
set_parameter_property VERSION_MAJOR DISPLAY_NAME "Version Major"

add_parameter VERSION_MINOR INTEGER $VERSION_MINOR_DEFAULT_CONST
set_parameter_property VERSION_MINOR DISPLAY_NAME "Version Minor"

add_parameter VERSION_PATCH INTEGER $VERSION_PATCH_DEFAULT_CONST
set_parameter_property VERSION_PATCH DISPLAY_NAME "Version Patch"

add_parameter BUILD INTEGER $BUILD_DEFAULT_CONST
set_parameter_property BUILD DISPLAY_NAME "Build"

add_parameter VERSION_DATE INTEGER $VERSION_DATE_DEFAULT_CONST
set_parameter_property VERSION_DATE DISPLAY_NAME "Version Date"

add_parameter GIT_STAMP_OVERRIDE BOOLEAN false
set_parameter_property GIT_STAMP_OVERRIDE DISPLAY_NAME "Override Git Stamp"

add_parameter VERSION_GIT INTEGER $VERSION_GIT_DEFAULT_CONST
set_parameter_property VERSION_GIT DISPLAY_NAME "Version Git"

add_parameter INSTANCE_ID INTEGER $INSTANCE_ID_DEFAULT_CONST
set_parameter_property INSTANCE_ID DISPLAY_NAME "Instance ID"

# ========================================================================
# Display items
# ========================================================================
add_display_item "" Configuration GROUP ""
add_html_text "Configuration" overview_html ""
add_display_item "Configuration" channel_group GROUP "Channel Window"
add_display_item "channel_group" BANK PARAMETER
add_display_item "channel_group" ENABLED_CHANNEL_LO PARAMETER
add_display_item "channel_group" ENABLED_CHANNEL_HI PARAMETER
add_display_item "Configuration" timing_group GROUP "Timing and Drain"
add_display_item "timing_group" PADDING_EOP_WAIT_CYCLE PARAMETER
add_display_item "timing_group" LPM_DIV_PIPELINE PARAMETER
add_display_item "timing_group" MUTRIG_BUFFER_EXPECTED_LATENCY_8N PARAMETER
add_display_item "timing_group" MUTRIG_OVERFLOW_LOOKBACK_8N PARAMETER
add_display_item "timing_group" USE_EXTERNAL_EPOCH_RESET PARAMETER
add_html_text "Configuration" timing_html ""
add_display_item "Configuration" debug_group GROUP "Debug"
add_display_item "debug_group" DEBUG PARAMETER
add_html_text "Configuration" debug_html ""

add_display_item "" Identity GROUP ""
add_html_text "Identity" profile_html ""
add_display_item "Identity" identity_group GROUP "Identity Fields"
add_display_item "identity_group" IP_UID PARAMETER
add_display_item "identity_group" INSTANCE_ID PARAMETER
add_display_item "Identity" version_group GROUP "Version Fields"
add_display_item "version_group" VERSION_MAJOR PARAMETER
add_display_item "version_group" VERSION_MINOR PARAMETER
add_display_item "version_group" VERSION_PATCH PARAMETER
add_display_item "version_group" BUILD PARAMETER
add_display_item "version_group" VERSION_DATE PARAMETER
add_display_item "version_group" GIT_STAMP_OVERRIDE PARAMETER
add_display_item "version_group" VERSION_GIT PARAMETER
add_html_text "Identity" versioning_html ""

add_display_item "" Interfaces GROUP ""
add_html_text "Interfaces" interfaces_html ""

add_display_item "" "Register Map" GROUP ""
add_html_text "Register Map" regmap_html ""

# ========================================================================
# Interfaces
# ========================================================================
add_interface csr avalon end
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clock_interface
set_interface_property csr associatedReset reset_interface
set_interface_property csr bitsPerSymbol 8
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr burstcountUnits WORDS
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr maximumPendingWriteTransactions 0
set_interface_property csr readLatency 1
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0
set_interface_property csr ENABLED true
add_interface_port csr avs_csr_readdata    readdata    Output 32
add_interface_port csr avs_csr_read        read        Input 1
add_interface_port csr avs_csr_address     address     Input 3
add_interface_port csr avs_csr_waitrequest waitrequest Output 1
add_interface_port csr avs_csr_write       write       Input 1
add_interface_port csr avs_csr_writedata   writedata   Input 32
set_interface_assignment csr embeddedsw.configuration.isFlash 0
set_interface_assignment csr embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment csr embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment csr embeddedsw.configuration.isPrintableDevice 0

add_interface clock_interface clock end
set_interface_property clock_interface clockRate 0
set_interface_property clock_interface ENABLED true
add_interface_port clock_interface i_clk clk Input 1

add_interface reset_interface reset end
set_interface_property reset_interface associatedClock clock_interface
set_interface_property reset_interface synchronousEdges DEASSERT
set_interface_property reset_interface ENABLED true
add_interface_port reset_interface i_rst reset Input 1

# Optional synchronous functional reset for timestamp epoch state only. This is
# a conduit, not a reset interface: it does not fan out to the FSM or CSR block.
add_interface epoch_reset conduit end
set_interface_property epoch_reset associatedClock clock_interface
set_interface_property epoch_reset associatedReset reset_interface
set_interface_property epoch_reset ENABLED false
add_interface_port epoch_reset coe_epoch_reset epoch_reset Input 1

add_interface run_ctrl avalon_streaming end
set_interface_property run_ctrl associatedClock clock_interface
set_interface_property run_ctrl associatedReset reset_interface
set_interface_property run_ctrl dataBitsPerSymbol 9
set_interface_property run_ctrl errorDescriptor ""
set_interface_property run_ctrl firstSymbolInHighOrderBits true
set_interface_property run_ctrl maxChannel 0
set_interface_property run_ctrl readyLatency 0
set_interface_property run_ctrl ENABLED true
add_interface_port run_ctrl asi_ctrl_data  data  Input 9
add_interface_port run_ctrl asi_ctrl_valid valid Input 1

add_interface hit_type0_in avalon_streaming end
set_interface_property hit_type0_in associatedClock clock_interface
set_interface_property hit_type0_in associatedReset reset_interface
set_interface_property hit_type0_in dataBitsPerSymbol 45
set_interface_property hit_type0_in errorDescriptor ""
set_interface_property hit_type0_in firstSymbolInHighOrderBits true
set_interface_property hit_type0_in maxChannel 63
set_interface_property hit_type0_in readyLatency 0
set_interface_property hit_type0_in ENABLED true
add_interface_port hit_type0_in asi_hit_type0_channel       channel       Input 6
add_interface_port hit_type0_in asi_hit_type0_startofpacket startofpacket Input 1
add_interface_port hit_type0_in asi_hit_type0_endofpacket   endofpacket   Input 1
add_interface_port hit_type0_in asi_hit_type0_endofrun      endofrun      Input 1
add_interface_port hit_type0_in asi_hit_type0_error         error         Input 3
add_interface_port hit_type0_in asi_hit_type0_data          data          Input 45
add_interface_port hit_type0_in asi_hit_type0_valid         valid         Input 1

add_interface hit_type1_out avalon_streaming start
set_interface_property hit_type1_out associatedClock clock_interface
set_interface_property hit_type1_out associatedReset reset_interface
set_interface_property hit_type1_out dataBitsPerSymbol 39
set_interface_property hit_type1_out errorDescriptor {"tserr"}
set_interface_property hit_type1_out firstSymbolInHighOrderBits true
set_interface_property hit_type1_out maxChannel 15
set_interface_property hit_type1_out readyLatency 0
set_interface_property hit_type1_out ENABLED true
add_interface_port hit_type1_out aso_hit_type1_data          data          Output 39
add_interface_port hit_type1_out aso_hit_type1_valid         valid         Output 1
add_interface_port hit_type1_out aso_hit_type1_ready         ready         Input 1
add_interface_port hit_type1_out aso_hit_type1_channel       channel       Output 4
add_interface_port hit_type1_out aso_hit_type1_endofpacket   endofpacket   Output 1
add_interface_port hit_type1_out aso_hit_type1_startofpacket startofpacket Output 1
add_interface_port hit_type1_out aso_hit_type1_empty         empty         Output 1
add_interface_port hit_type1_out aso_hit_type1_error         error         Output 1

add_interface hit_type1_extended_0 avalon_streaming start
set_interface_property hit_type1_extended_0 associatedClock clock_interface
set_interface_property hit_type1_extended_0 associatedReset reset_interface
set_interface_property hit_type1_extended_0 dataBitsPerSymbol 87
set_interface_property hit_type1_extended_0 errorDescriptor ""
set_interface_property hit_type1_extended_0 firstSymbolInHighOrderBits true
set_interface_property hit_type1_extended_0 maxChannel 0
set_interface_property hit_type1_extended_0 readyLatency 0
set_interface_property hit_type1_extended_0 ENABLED true
add_interface_port hit_type1_extended_0 aso_hit_type1_extended_0_data  data  Output 87
add_interface_port hit_type1_extended_0 aso_hit_type1_extended_0_valid valid Output 1

add_interface hit_type1_extended_1 avalon_streaming start
set_interface_property hit_type1_extended_1 associatedClock clock_interface
set_interface_property hit_type1_extended_1 associatedReset reset_interface
set_interface_property hit_type1_extended_1 dataBitsPerSymbol 87
set_interface_property hit_type1_extended_1 errorDescriptor ""
set_interface_property hit_type1_extended_1 firstSymbolInHighOrderBits true
set_interface_property hit_type1_extended_1 maxChannel 0
set_interface_property hit_type1_extended_1 readyLatency 0
set_interface_property hit_type1_extended_1 ENABLED true
add_interface_port hit_type1_extended_1 aso_hit_type1_extended_1_data  data  Output 87
add_interface_port hit_type1_extended_1 aso_hit_type1_extended_1_valid valid Output 1

# hit_type1_ts: 48-bit true hit timestamp on a separate conduit, fed directly to
# the V3 histogram_statistics_v2 type1_{up,down}_ts inputs (delay-mode entry).
# Coexists with hit_type1_extended_{0,1}; the two paths carry the same
# timestamp but in different framings. Merged from commit eb67302 on an
# upstream debug-plane backup branch.
add_interface hit_type1_ts conduit start
set_interface_property hit_type1_ts associatedClock clock_interface
set_interface_property hit_type1_ts associatedReset reset_interface
set_interface_property hit_type1_ts ENABLED true
add_interface_port hit_type1_ts coe_hit_type1_ts export Output 48

# hit_arrival_gts: selected 48-bit arrival co-sampled with hit_type1_ts on the
# hit_out beat. CONTROL_STATUS[6]=0 exports direct emission counter_gts_8n and
# therefore physical lifetime. Bit 6 selects an overflow-base debug coordinate
# only. This conduit rides the same clock as hit_type1_ts: no new CDC point.
add_interface hit_arrival_gts conduit start
set_interface_property hit_arrival_gts associatedClock clock_interface
set_interface_property hit_arrival_gts associatedReset reset_interface
set_interface_property hit_arrival_gts ENABLED true
add_interface_port hit_arrival_gts coe_hit_arrival_gts_8n export Output 48

# hit_type1_latency_8n: 48-bit modulo subtraction computed in MTS from selected
# arrival and the true hit timestamp on the same emitted beat. With the default
# direct-arrival selection it is positive physical hit lifetime. Downstream
# consumers trim/bin this value directly; no independent epoch is introduced.
add_interface hit_type1_latency_8n conduit start
set_interface_property hit_type1_latency_8n associatedClock clock_interface
set_interface_property hit_type1_latency_8n associatedReset reset_interface
set_interface_property hit_type1_latency_8n ENABLED true
add_interface_port hit_type1_latency_8n coe_hit_type1_latency_8n export Output 48

add_interface debug_ts avalon_streaming start
set_interface_property debug_ts associatedClock clock_interface
set_interface_property debug_ts associatedReset reset_interface
set_interface_property debug_ts dataBitsPerSymbol 16
set_interface_property debug_ts errorDescriptor ""
set_interface_property debug_ts firstSymbolInHighOrderBits true
set_interface_property debug_ts maxChannel 0
set_interface_property debug_ts readyLatency 0
set_interface_property debug_ts ENABLED false
add_interface_port debug_ts aso_debug_ts_valid valid Output 1
add_interface_port debug_ts aso_debug_ts_data  data  Output 16

add_interface debug_burst avalon_streaming start
set_interface_property debug_burst associatedClock clock_interface
set_interface_property debug_burst associatedReset reset_interface
set_interface_property debug_burst dataBitsPerSymbol 16
set_interface_property debug_burst errorDescriptor ""
set_interface_property debug_burst firstSymbolInHighOrderBits true
set_interface_property debug_burst ENABLED false
add_interface_port debug_burst aso_debug_burst_valid valid Output 1
add_interface_port debug_burst aso_debug_burst_data  data  Output 16

add_interface ts_delta avalon_streaming start
set_interface_property ts_delta associatedClock clock_interface
set_interface_property ts_delta associatedReset reset_interface
set_interface_property ts_delta dataBitsPerSymbol 16
set_interface_property ts_delta errorDescriptor ""
set_interface_property ts_delta firstSymbolInHighOrderBits true
set_interface_property ts_delta ENABLED false
add_interface_port ts_delta aso_ts_delta_valid valid Output 1
add_interface_port ts_delta aso_ts_delta_data  data  Output 16

add_debug_status_interface
add_debug_sidecar_interfaces
