`timescale 1ns/1ps

// File    : mts_processor_gate_smoke_tb.sv
// Author  : Yifeng Wang (yifenwan@phys.ethz.ch)
// Version : 26.5.0
// Date    : 20260716
// Change  : Add an external-port-only RTL/post-fit signature comparison.
//
// The DUT is instantiated without generic overrides. The same test therefore
// exercises the delivered standalone wrapper and its flattened Quartus model.
// No internal DUT hierarchy is referenced.
module mts_processor_gate_smoke_tb;
    localparam int unsigned CLK_PERIOD_NS_CONST = 8;
    localparam int unsigned WARMUP_CYCLES_CONST = 64;
    localparam int unsigned SAMPLE_CYCLES_CONST = 4096;
    localparam int unsigned TIMEOUT_CYCLES_CONST =
        WARMUP_CYCLES_CONST + SAMPLE_CYCLES_CONST + 1024;

    logic        clk = 1'b0;
    logic [31:0] activity_probe;

    mts_processor_syn_top dut (
        .clk            (clk),
        .activity_probe (activity_probe)
    );

    always #(CLK_PERIOD_NS_CONST / 2) clk = ~clk;

    function automatic logic [31:0] signature_step(
        input logic [31:0] signature,
        input logic [31:0] sample,
        input int unsigned sample_index
    );
        logic [31:0] signature_v_rotated;

        signature_v_rotated = {signature[26:0], signature[31:27]};
        return signature_v_rotated ^ sample ^ sample_index ^ 32'h9e37_79b9;
    endfunction

    initial begin : signature_collector
        logic [31:0] signature_v;
        int unsigned sample_v_index;

        signature_v = 32'h4d54_5350;
        repeat (WARMUP_CYCLES_CONST) @(posedge clk);

        for (sample_v_index = 0;
             sample_v_index < SAMPLE_CYCLES_CONST;
             sample_v_index++) begin
            @(posedge clk);
            #1ps;
            if ($isunknown(activity_probe)) begin
                $fatal(1,
                    "activity_probe contains X/Z at sample %0d: 0x%08h",
                    sample_v_index,
                    activity_probe);
            end
            signature_v = signature_step(
                signature_v,
                activity_probe,
                sample_v_index);
        end

        $display("MTS_GATE_SMOKE_SIGNATURE=%08h", signature_v);
        $display("*** TEST PASSED ***");
        $finish;
    end

    initial begin : timeout_guard
        repeat (TIMEOUT_CYCLES_CONST) @(posedge clk);
        $fatal(1, "MTS gate smoke timed out");
    end
endmodule
