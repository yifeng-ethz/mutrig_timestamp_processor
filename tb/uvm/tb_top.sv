`timescale 1ps/1ps

module tb_top;
  import uvm_pkg::*;
  import mtsp_env_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 1'b0;
  logic rst = 1'b1;

  always #(CLK_PERIOD_PS/2) clk = ~clk;

  initial begin
    rst = 1'b1;
    #(10 * CLK_PERIOD_PS);
    rst = 1'b0;
  end

  mtsp_csr_if  csr_if(.clk(clk), .rst(rst));
  mtsp_ctrl_if ctrl_if(.clk(clk), .rst(rst));
  mtsp_hit0_if hit0_if(.clk(clk), .rst(rst));
  mtsp_hit1_if hit1_if(.clk(clk), .rst(rst));

  logic        debug_ts_valid;
  logic [15:0] debug_ts_data;
  logic        debug_burst_valid;
  logic [15:0] debug_burst_data;
  logic        ts_delta_valid;
  logic [15:0] ts_delta_data;

  assign hit1_if.ready = 1'b1;

  mts_processor dut (
    .avs_csr_readdata            (csr_if.readdata),
    .avs_csr_read                (csr_if.read),
    .avs_csr_address             (csr_if.address),
    .avs_csr_waitrequest         (csr_if.waitrequest),
    .avs_csr_write               (csr_if.write),
    .avs_csr_writedata           (csr_if.writedata),
    .asi_hit_type0_channel       (hit0_if.channel),
    .asi_hit_type0_startofpacket (hit0_if.sop),
    .asi_hit_type0_endofpacket   (hit0_if.eop),
    .asi_hit_type0_error         (hit0_if.error),
    .asi_hit_type0_data          (hit0_if.data),
    .asi_hit_type0_valid         (hit0_if.valid),
    .asi_hit_type0_ready         (hit0_if.ready),
    .aso_hit_type1_channel       (hit1_if.channel),
    .aso_hit_type1_startofpacket (hit1_if.sop),
    .aso_hit_type1_endofpacket   (hit1_if.eop),
    .aso_hit_type1_data          (hit1_if.data),
    .aso_hit_type1_valid         (hit1_if.valid),
    .aso_hit_type1_ready         (hit1_if.ready),
    .aso_hit_type1_empty         (hit1_if.empty),
    .aso_hit_type1_error         (hit1_if.error),
    .asi_ctrl_data               (ctrl_if.data),
    .asi_ctrl_valid              (ctrl_if.valid),
    .asi_ctrl_ready              (ctrl_if.ready),
    .aso_debug_ts_valid          (debug_ts_valid),
    .aso_debug_ts_data           (debug_ts_data),
    .aso_debug_burst_valid       (debug_burst_valid),
    .aso_debug_burst_data        (debug_burst_data),
    .aso_ts_delta_valid          (ts_delta_valid),
    .aso_ts_delta_data           (ts_delta_data),
    .i_rst                       (rst),
    .i_clk                       (clk)
  );

  property p_hit1_sop_requires_valid;
    @(posedge clk) disable iff (rst)
      hit1_if.sop |-> hit1_if.valid;
  endproperty

  property p_empty_requires_eop;
    @(posedge clk) disable iff (rst)
      hit1_if.empty |-> (hit1_if.valid && hit1_if.eop);
  endproperty

  assert property (p_hit1_sop_requires_valid)
    else $error("hit_type1 SOP asserted without valid");

  assert property (p_empty_requires_eop)
    else $error("hit_type1 empty asserted without valid EOP");

  initial begin
    uvm_config_db#(virtual mtsp_csr_if.drv)::set(
      null, "uvm_test_top.m_env.m_csr_drv", "vif", csr_if);
    uvm_config_db#(virtual mtsp_ctrl_if.drv)::set(
      null, "uvm_test_top.m_env.m_ctrl_drv", "vif", ctrl_if);
    uvm_config_db#(virtual mtsp_hit0_if.drv)::set(
      null, "uvm_test_top.m_env.m_hit0_drv", "vif", hit0_if);
    uvm_config_db#(virtual mtsp_hit1_if.mon)::set(
      null, "uvm_test_top.m_env.m_hit1_mon", "vif", hit1_if);
    uvm_config_db#(virtual mtsp_ctrl_if.mon)::set(
      null, "uvm_test_top", "ctrl_vif", ctrl_if);

    run_test();
  end

  initial begin
    #(3_000_000ns);
    `uvm_fatal("TB_TOP", "Global timeout reached")
  end
endmodule
