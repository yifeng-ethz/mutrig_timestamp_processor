`timescale 1ps/1ps

interface mtsp_reset_if(input logic clk);
  logic rst;

  modport drv (
    output rst,
    input  clk
  );

  modport mon (
    input rst, clk
  );
endinterface

interface mtsp_csr_if(input logic clk, input logic rst);
  logic [2:0]  address;
  logic        read;
  logic        write;
  logic [31:0] writedata;
  logic [31:0] readdata;
  logic        waitrequest;

  modport drv (
    output address, read, write, writedata,
    input  readdata, waitrequest, clk, rst
  );

  modport mon (
    input address, read, write, writedata, readdata, waitrequest, clk, rst
  );
endinterface

interface mtsp_ctrl_if(input logic clk, input logic rst);
  logic [8:0] data;
  logic       valid;
  logic       ready;

  modport drv (
    output data, valid,
    input  ready, clk, rst
  );

  modport mon (
    input data, valid, ready, clk, rst
  );
endinterface

interface mtsp_hit0_if(input logic clk, input logic rst);
  logic [5:0]  channel;
  logic        sop;
  logic        eop;
  logic        endofrun;
  logic [2:0]  error;
  logic [44:0] data;
  logic        valid;
  logic        ready;

  modport drv (
    output channel, sop, eop, endofrun, error, data, valid,
    input  ready, clk, rst
  );

  modport mon (
    input channel, sop, eop, endofrun, error, data, valid, ready, clk, rst
  );
endinterface

interface mtsp_hit1_if(input logic clk, input logic rst);
  logic [3:0]  channel;
  logic        sop;
  logic        eop;
  logic [38:0] data;
  logic        valid;
  logic        ready;
  logic        empty;
  logic        error;
  logic [47:0] ts;
  logic [47:0] arrival_gts;
  logic [47:0] latency;

  modport drv (
    output ready,
    input  channel, sop, eop, data, valid, empty, error,
           ts, arrival_gts, latency, clk, rst
  );

  modport mon (
    input channel, sop, eop, data, valid, ready, empty, error,
          ts, arrival_gts, latency, clk, rst
  );
endinterface

interface mtsp_dbg_if(input logic clk, input logic rst);
  logic        debug_ts_valid;
  logic [15:0] debug_ts_data;
  logic        debug_burst_valid;
  logic [15:0] debug_burst_data;
  logic        ts_delta_valid;
  logic [15:0] ts_delta_data;

  modport mon (
    input debug_ts_valid, debug_ts_data,
          debug_burst_valid, debug_burst_data,
          ts_delta_valid, ts_delta_data,
          clk, rst
  );
endinterface
