`timescale 1ps/1ps

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
  logic [2:0]  error;
  logic [44:0] data;
  logic        valid;
  logic        ready;

  modport drv (
    output channel, sop, eop, error, data, valid,
    input  ready, clk, rst
  );

  modport mon (
    input channel, sop, eop, error, data, valid, ready, clk, rst
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

  modport drv (
    output ready,
    input  channel, sop, eop, data, valid, empty, error, clk, rst
  );

  modport mon (
    input channel, sop, eop, data, valid, ready, empty, error, clk, rst
  );
endinterface
