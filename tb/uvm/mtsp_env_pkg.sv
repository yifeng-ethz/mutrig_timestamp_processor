`timescale 1ps/1ps

package mtsp_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_csr)
  `uvm_analysis_imp_decl(_hit0)
  `uvm_analysis_imp_decl(_hit1)
  `uvm_analysis_imp_decl(_dbg)
  `uvm_analysis_imp_decl(_ready)

  localparam logic [8:0] CTRL_IDLE        = 9'b000000001;
  localparam logic [8:0] CTRL_RUN_PREPARE = 9'b000000010;
  localparam logic [8:0] CTRL_SYNC        = 9'b000000100;
  localparam logic [8:0] CTRL_RUNNING     = 9'b000001000;
  localparam logic [8:0] CTRL_TERMINATING = 9'b000010000;
  localparam logic [8:0] CTRL_LINK_TEST   = 9'b000100000;
  localparam logic [8:0] CTRL_SYNC_TEST   = 9'b001000000;
  localparam logic [8:0] CTRL_RESET_WORD  = 9'b010000000;
  localparam logic [8:0] CTRL_OUT_OF_DAQ  = 9'b100000000;
  localparam time CLK_PERIOD_PS           = 8000ps;
  localparam time MONITOR_SAMPLE_SKEW_PS  = 1ps;

  typedef enum int unsigned {
    MTSP_DBG_TS,
    MTSP_DBG_BURST,
    MTSP_DBG_TS_DELTA
  } mtsp_dbg_kind_e;

  class mtsp_csr_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_csr_item)

    bit        is_write;
    bit [2:0]  address;
    bit [31:0] writedata;
    bit [31:0] readdata;
    int unsigned timeout_cycles;
    time       complete_time_ps;
    bit        hold_bus_after;

    function new(string name = "mtsp_csr_item");
      super.new(name);
      timeout_cycles   = 1000;
      complete_time_ps = 0;
      hold_bus_after   = 1'b0;
    endfunction
  endclass

  class mtsp_ctrl_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_ctrl_item)

    logic [8:0] cmd;
    int unsigned post_accept_delay_cycles;
    int unsigned timeout_cycles;
    bit          wait_for_ready;
    bit          hold_data_after;
    bit          drive_valid;
    string       state_name;
    time         accept_time_ps;

    function new(string name = "mtsp_ctrl_item");
      super.new(name);
      post_accept_delay_cycles = 0;
      timeout_cycles           = 10000;
      wait_for_ready           = 1'b1;
      hold_data_after          = 1'b0;
      drive_valid              = 1'b1;
      state_name               = "";
      accept_time_ps           = 0;
    endfunction
  endclass

  class mtsp_csr_obs_item extends uvm_object;
    `uvm_object_utils(mtsp_csr_obs_item)

    bit        is_write;
    bit [2:0]  address;
    bit [31:0] writedata;
    bit [31:0] readdata;
    time       time_ps;

    function new(string name = "mtsp_csr_obs_item");
      super.new(name);
    endfunction
  endclass

  class mtsp_hit0_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_hit0_item)

    bit [5:0]  channel;
    bit        sop;
    bit        eop;
    bit        endofrun;
    bit [2:0]  error;
    bit [44:0] data;
    bit        valid;
    bit        wait_for_ready;
    int unsigned timeout_cycles;
    time       accept_time_ps;

    function new(string name = "mtsp_hit0_item");
      super.new(name);
      valid            = 1'b1;
      wait_for_ready   = 1'b1;
      endofrun         = 1'b0;
      error            = '0;
      timeout_cycles   = 10000;
      accept_time_ps   = 0;
    endfunction
  endclass

  class mtsp_hit0_obs_item extends uvm_object;
    `uvm_object_utils(mtsp_hit0_obs_item)

    bit [5:0]  channel;
    bit        sop;
    bit        eop;
    bit        endofrun;
    bit [2:0]  error;
    bit [44:0] data;
    time       time_ps;

    function new(string name = "mtsp_hit0_obs_item");
      super.new(name);
    endfunction
  endclass

  class mtsp_hit1_obs_item extends uvm_object;
    `uvm_object_utils(mtsp_hit1_obs_item)

    bit [3:0]  channel;
    bit        sop;
    bit        eop;
    bit [38:0] data;
    bit        valid;
    bit        empty;
    bit        error;
    time       time_ps;

    function new(string name = "mtsp_hit1_obs_item");
      super.new(name);
    endfunction
  endclass

  class mtsp_ready_obs_item extends uvm_object;
    `uvm_object_utils(mtsp_ready_obs_item)

    logic ready;
    time  time_ps;

    function new(string name = "mtsp_ready_obs_item");
      super.new(name);
    endfunction
  endclass

  class mtsp_dbg_obs_item extends uvm_object;
    `uvm_object_utils(mtsp_dbg_obs_item)

    mtsp_dbg_kind_e kind;
    bit [15:0]      data;
    bit [31:0]      expected_latency;
    time            time_ps;

    function new(string name = "mtsp_dbg_obs_item");
      super.new(name);
      expected_latency = 32'd2000;
    endfunction
  endclass

  class mtsp_hit_trace_item extends uvm_object;
    `uvm_object_utils(mtsp_hit_trace_item)

    int unsigned seq_id;
    time         hit1_time_ps;
    time         debug_time_ps;
    bit [3:0]    channel;
    bit [38:0]   data;
    bit          hit1_error;
    bit [15:0]   debug_ts;
    int signed   debug_delta;
    bit [31:0]   expected_latency;
    bit          math_error;

    function new(string name = "mtsp_hit_trace_item");
      super.new(name);
    endfunction
  endclass

  class mtsp_csr_driver extends uvm_driver #(mtsp_csr_item);
    `uvm_component_utils(mtsp_csr_driver)

    virtual mtsp_csr_if.drv vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual mtsp_csr_if.drv)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_CSR_DRV", "Missing mtsp_csr_if.drv")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_csr_item item;
      int unsigned  wait_cycles;
      bit           bus_held_for_next;

      vif.address   <= '0;
      vif.read      <= 1'b0;
      vif.write     <= 1'b0;
      vif.writedata <= '0;
      bus_held_for_next = 1'b0;

      forever begin
        seq_item_port.get_next_item(item);

        if (bus_held_for_next)
          bus_held_for_next = 1'b0;
        else
          @(negedge vif.clk);
        vif.address   <= item.address;
        vif.writedata <= item.writedata;
        vif.write     <= item.is_write;
        vif.read      <= !item.is_write;

        wait_cycles = 0;
        do begin
          @(posedge vif.clk);
          #1ps;
          wait_cycles++;
          if (wait_cycles > item.timeout_cycles)
            `uvm_fatal("MTSP_CSR_TIMEOUT",
              $sformatf("Timed out waiting for CSR completion at address 0x%0h",
                item.address))
        end while (vif.waitrequest === 1'b1);

        if (!item.is_write) begin
          item.readdata = vif.readdata;
        end
        item.complete_time_ps = $time;

        if (item.hold_bus_after) begin
          bus_held_for_next = 1'b1;
        end else begin
          @(negedge vif.clk);
          vif.address   <= '0;
          vif.read      <= 1'b0;
          vif.write     <= 1'b0;
          vif.writedata <= '0;
        end
        seq_item_port.item_done();
      end
    endtask
  endclass

  class mtsp_csr_monitor extends uvm_monitor;
    `uvm_component_utils(mtsp_csr_monitor)

    virtual mtsp_csr_if.mon vif;
    uvm_analysis_port #(mtsp_csr_obs_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db#(virtual mtsp_csr_if.mon)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_CSR_MON", "Missing mtsp_csr_if.mon")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_csr_obs_item obs;

      forever begin
        @(posedge vif.clk);
        #1ps;
        if (vif.rst === 1'b1)
          continue;
        if ((vif.write === 1'b1 || vif.read === 1'b1) &&
            vif.waitrequest !== 1'b1) begin
          obs           = mtsp_csr_obs_item::type_id::create("csr_obs");
          obs.is_write  = vif.write;
          obs.address   = vif.address;
          obs.writedata = vif.writedata;
          obs.readdata  = vif.readdata;
          obs.time_ps   = $time;
          ap.write(obs);
        end
      end
    endtask
  endclass

  class mtsp_ctrl_driver extends uvm_driver #(mtsp_ctrl_item);
    `uvm_component_utils(mtsp_ctrl_driver)

    virtual mtsp_ctrl_if.drv vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual mtsp_ctrl_if.drv)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_CTRL_DRV", "Missing mtsp_ctrl_if.drv")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_ctrl_item item;
      int unsigned   wait_cycles;

      vif.data  <= CTRL_IDLE;
      vif.valid <= 1'b0;

      forever begin
        seq_item_port.get_next_item(item);
        vif.data  <= item.cmd;
        vif.valid <= item.drive_valid;

        if (item.wait_for_ready) begin
          wait_cycles = 0;
          do begin
            @(posedge vif.clk);
            wait_cycles++;
            if (wait_cycles > item.timeout_cycles)
              `uvm_fatal("MTSP_CTRL_TIMEOUT",
                $sformatf("Timed out waiting for %s ready after %0d cycles",
                  item.state_name, item.timeout_cycles))
          end while (vif.ready !== 1'b1);

          item.accept_time_ps = $time;
          vif.valid <= 1'b0;
          if (!item.hold_data_after)
            vif.data <= CTRL_IDLE;
        end else begin
          @(posedge vif.clk);
          item.accept_time_ps = $time;
          vif.valid <= 1'b0;
          if (!item.hold_data_after)
            vif.data <= CTRL_IDLE;
        end

        repeat (item.post_accept_delay_cycles)
          @(posedge vif.clk);

        seq_item_port.item_done();
      end
    endtask
  endclass

  class mtsp_hit0_driver extends uvm_driver #(mtsp_hit0_item);
    `uvm_component_utils(mtsp_hit0_driver)

    virtual mtsp_hit0_if.drv vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual mtsp_hit0_if.drv)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_HIT0_DRV", "Missing mtsp_hit0_if.drv")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_hit0_item item;
      int unsigned   wait_cycles;

      vif.channel  <= '0;
      vif.sop      <= 1'b0;
      vif.eop      <= 1'b0;
      vif.endofrun <= 1'b0;
      vif.error    <= '0;
      vif.data    <= '0;
      vif.valid   <= 1'b0;

      forever begin
        seq_item_port.get_next_item(item);

        if (item.wait_for_ready) begin
          wait_cycles = 0;
          while (vif.ready !== 1'b1) begin
            @(posedge vif.clk);
            wait_cycles++;
            if (wait_cycles > item.timeout_cycles)
              `uvm_fatal("MTSP_HIT0_TIMEOUT",
                $sformatf("Timed out waiting for hit0 ready after %0d cycles",
                  item.timeout_cycles))
          end
        end

        vif.channel  <= item.channel;
        vif.sop      <= item.sop;
        vif.eop      <= item.eop;
        vif.endofrun <= item.endofrun;
        vif.error    <= item.error;
        vif.data    <= item.data;
        vif.valid   <= item.valid;

        @(posedge vif.clk);
        item.accept_time_ps = $time;
        vif.channel  <= '0;
        vif.sop      <= 1'b0;
        vif.eop      <= 1'b0;
        vif.endofrun <= 1'b0;
        vif.error    <= '0;
        vif.data    <= '0;
        vif.valid   <= 1'b0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class mtsp_hit0_monitor extends uvm_monitor;
    `uvm_component_utils(mtsp_hit0_monitor)

    virtual mtsp_hit0_if.mon vif;
    uvm_analysis_port #(mtsp_hit0_obs_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db#(virtual mtsp_hit0_if.mon)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_HIT0_MON", "Missing mtsp_hit0_if.mon")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_hit0_obs_item obs;

      forever begin
        @(posedge vif.clk);
        if (vif.rst === 1'b1)
          continue;
        if (vif.valid === 1'b1 && vif.ready === 1'b1) begin
          obs          = mtsp_hit0_obs_item::type_id::create("hit0_obs");
          obs.channel  = vif.channel;
          obs.sop      = vif.sop;
          obs.eop      = vif.eop;
          obs.endofrun = vif.endofrun;
          obs.error    = vif.error;
          obs.data     = vif.data;
          obs.time_ps  = $time + MONITOR_SAMPLE_SKEW_PS;
          ap.write(obs);
        end
      end
    endtask
  endclass

  class mtsp_hit1_monitor extends uvm_monitor;
    `uvm_component_utils(mtsp_hit1_monitor)

    virtual mtsp_hit1_if.mon vif;
    uvm_analysis_port #(mtsp_hit1_obs_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db#(virtual mtsp_hit1_if.mon)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_HIT1_MON", "Missing mtsp_hit1_if.mon")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_hit1_obs_item obs;

      forever begin
        @(posedge vif.clk);
        #1ps;
        if (vif.rst === 1'b1)
          continue;
        if (vif.valid === 1'b1) begin
          obs         = mtsp_hit1_obs_item::type_id::create("hit1_obs");
          obs.channel = vif.channel;
          obs.sop     = vif.sop;
          obs.eop     = vif.eop;
          obs.data    = vif.data;
          obs.valid   = vif.valid;
          obs.empty   = vif.empty;
          obs.error   = vif.error;
          obs.time_ps = $time;
          ap.write(obs);
        end
      end
    endtask
  endclass

  class mtsp_hit1_ready_monitor extends uvm_monitor;
    `uvm_component_utils(mtsp_hit1_ready_monitor)

    virtual mtsp_hit1_if.mon vif;
    uvm_analysis_port #(mtsp_ready_obs_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db#(virtual mtsp_hit1_if.mon)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_READY_MON", "Missing mtsp_hit1_if.mon")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_ready_obs_item obs;

      forever begin
        @(posedge vif.clk);
        #1ps;
        if (vif.rst === 1'b1)
          continue;

        if ($isunknown(vif.ready)) begin
          obs         = mtsp_ready_obs_item::type_id::create("ready_obs");
          obs.ready   = vif.ready;
          obs.time_ps = $time;
          ap.write(obs);
          `uvm_warning("MTSP_READY_X",
            $sformatf("hit_type1 ready is unknown at %0t", $time))
        end
      end
    endtask
  endclass

  class mtsp_dbg_monitor extends uvm_monitor;
    `uvm_component_utils(mtsp_dbg_monitor)

    virtual mtsp_dbg_if.mon vif;
    uvm_analysis_port #(mtsp_dbg_obs_item) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      if (!uvm_config_db#(virtual mtsp_dbg_if.mon)::get(this, "", "vif", vif))
        `uvm_fatal("MTSP_DBG_MON", "Missing mtsp_dbg_if.mon")
    endfunction

    task run_phase(uvm_phase phase);
      mtsp_dbg_obs_item obs;

      forever begin
        @(posedge vif.clk);
        #1ps;
        if (vif.rst === 1'b1)
          continue;

        if (vif.debug_ts_valid === 1'b1) begin
          obs         = mtsp_dbg_obs_item::type_id::create("dbg_ts_obs");
          obs.kind    = MTSP_DBG_TS;
          obs.data    = vif.debug_ts_data;
          obs.time_ps = $time;
          ap.write(obs);
        end

        if (vif.debug_burst_valid === 1'b1) begin
          obs         = mtsp_dbg_obs_item::type_id::create("dbg_burst_obs");
          obs.kind    = MTSP_DBG_BURST;
          obs.data    = vif.debug_burst_data;
          obs.time_ps = $time;
          ap.write(obs);
        end

        if (vif.ts_delta_valid === 1'b1) begin
          obs         = mtsp_dbg_obs_item::type_id::create("ts_delta_obs");
          obs.kind    = MTSP_DBG_TS_DELTA;
          obs.data    = vif.ts_delta_data;
          obs.time_ps = $time;
          ap.write(obs);
        end
      end
    endtask
  endclass

  class mtsp_scoreboard extends uvm_component;
    `uvm_component_utils(mtsp_scoreboard)

    uvm_analysis_imp_csr  #(mtsp_csr_obs_item,  mtsp_scoreboard) csr_imp;
    uvm_analysis_imp_hit0 #(mtsp_hit0_obs_item, mtsp_scoreboard) hit0_imp;
    uvm_analysis_imp_hit1 #(mtsp_hit1_obs_item, mtsp_scoreboard) hit1_imp;
    uvm_analysis_imp_dbg  #(mtsp_dbg_obs_item,  mtsp_scoreboard) dbg_imp;
    uvm_analysis_imp_ready #(mtsp_ready_obs_item, mtsp_scoreboard) ready_imp;

    int unsigned beat_count;
    int unsigned csr_access_count;
    int unsigned payload_beat_count;
    int unsigned input_accept_count;
    int unsigned eop_count;
    int unsigned empty_eop_count;
    int unsigned debug_ts_count;
    int unsigned debug_burst_count;
    int unsigned ts_delta_count;
    int unsigned hit1_ready_unknown_count;
    int unsigned dual_path_pair_count;
    int unsigned trace_seq;
    bit [31:0]   expected_latency;
    bit          debug_path_required;

    time         last_eop_time_ps;
    bit          last_eop_empty;
    bit [38:0]   last_eop_data;

    mtsp_hit1_obs_item history[$];
    mtsp_csr_obs_item  csr_history[$];
    mtsp_hit0_obs_item hit0_history[$];
    mtsp_dbg_obs_item  debug_ts_history[$];
    mtsp_dbg_obs_item  debug_burst_history[$];
    mtsp_dbg_obs_item  ts_delta_history[$];
    mtsp_ready_obs_item ready_unknown_history[$];
    mtsp_hit_trace_item trace_history[$];

    mtsp_hit1_obs_item pending_hit1[$];
    mtsp_dbg_obs_item  pending_debug_ts[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      int debug_path_required_arg;
      int expected_latency_arg;

      super.build_phase(phase);
      csr_imp          = new("csr_imp", this);
      hit0_imp         = new("hit0_imp", this);
      hit1_imp         = new("hit1_imp", this);
      dbg_imp          = new("dbg_imp", this);
      ready_imp        = new("ready_imp", this);
      beat_count       = 0;
      csr_access_count = 0;
      payload_beat_count = 0;
      input_accept_count = 0;
      eop_count        = 0;
      empty_eop_count  = 0;
      debug_ts_count   = 0;
      debug_burst_count = 0;
      ts_delta_count   = 0;
      hit1_ready_unknown_count = 0;
      dual_path_pair_count = 0;
      trace_seq        = 0;
      expected_latency = 32'd2000;
      debug_path_required = 1'b1;
      if ($value$plusargs("MTSP_EXPECTED_LATENCY_RESET=%d", expected_latency_arg))
        expected_latency = expected_latency_arg[31:0];
      if ($value$plusargs("MTSP_DEBUG_PATH_REQUIRED=%d", debug_path_required_arg))
        debug_path_required = (debug_path_required_arg != 0);
      last_eop_time_ps = 0;
      last_eop_empty   = 1'b0;
      last_eop_data    = '0;
    endfunction

    function automatic int signed signed16(bit [15:0] value);
      bit signed [15:0] signed_value;
      signed_value = value;
      return signed_value;
    endfunction

    function automatic bit delay_math_error(bit [15:0] debug_ts,
                                            bit [31:0] latency);
      int signed       delta;
      longint unsigned latency_u;
      delta     = signed16(debug_ts);
      latency_u = latency;
      return !((delta > 0) && (longint'(delta) < latency_u));
    endfunction

    function void pair_debug_ts();
      mtsp_hit1_obs_item  hit;
      mtsp_dbg_obs_item   dbg;
      mtsp_hit_trace_item trace;

      while (pending_hit1.size() > 0 && pending_debug_ts.size() > 0) begin
        hit = pending_hit1.pop_front();
        dbg = pending_debug_ts.pop_front();

        trace                  = mtsp_hit_trace_item::type_id::create("hit_trace");
        trace.seq_id           = trace_seq++;
        trace.hit1_time_ps     = hit.time_ps;
        trace.debug_time_ps    = dbg.time_ps;
        trace.channel          = hit.channel;
        trace.data             = hit.data;
        trace.hit1_error       = hit.error;
        trace.debug_ts         = dbg.data;
        trace.debug_delta      = signed16(dbg.data);
        trace.expected_latency = dbg.expected_latency;
        trace.math_error       = delay_math_error(dbg.data, dbg.expected_latency);
        trace_history.push_back(trace);
        dual_path_pair_count++;

        if (hit.time_ps != dbg.time_ps)
          `uvm_error("MTSP_DUAL_PATH",
            $sformatf("hit/debug_ts alignment mismatch: hit_time=%0t debug_time=%0t seq=%0d",
              hit.time_ps, dbg.time_ps, trace.seq_id))

        if (hit.error !== trace.math_error)
          `uvm_error("MTSP_DELAY_MATH",
            $sformatf("hit_type1 error mismatch against debug_ts math: seq=%0d channel=%0h debug_ts=%0d expected_latency=%0d math_error=%0b hit_error=%0b data=0x%010h",
              trace.seq_id, hit.channel, trace.debug_delta, trace.expected_latency,
              trace.math_error, hit.error, hit.data))
      end
    endfunction

    function void write_csr(mtsp_csr_obs_item item);
      csr_history.push_back(item);
      csr_access_count++;
      if (item.is_write && item.address == 3'd2)
        expected_latency = item.writedata;
    endfunction

    function void write_hit0(mtsp_hit0_obs_item item);
      hit0_history.push_back(item);
      input_accept_count++;
    endfunction

    function void write_hit1(mtsp_hit1_obs_item item);
      history.push_back(item);
      beat_count++;
      if (!item.empty) begin
        payload_beat_count++;
        pending_hit1.push_back(item);
        pair_debug_ts();
      end
      if (item.eop) begin
        eop_count++;
        last_eop_time_ps = item.time_ps;
        last_eop_empty   = item.empty;
        last_eop_data    = item.data;
        if (item.empty)
          empty_eop_count++;
      end
    endfunction

    function void write_dbg(mtsp_dbg_obs_item item);
      item.expected_latency = expected_latency;
      case (item.kind)
        MTSP_DBG_TS: begin
          debug_ts_history.push_back(item);
          debug_ts_count++;
          pending_debug_ts.push_back(item);
          pair_debug_ts();
        end
        MTSP_DBG_BURST: begin
          debug_burst_history.push_back(item);
          debug_burst_count++;
        end
        MTSP_DBG_TS_DELTA: begin
          ts_delta_history.push_back(item);
          ts_delta_count++;
        end
        default: begin
          `uvm_error("MTSP_DBG", "Unknown debug observation kind")
        end
      endcase
    endfunction

    function void write_ready(mtsp_ready_obs_item item);
      ready_unknown_history.push_back(item);
      hit1_ready_unknown_count++;
    endfunction

    function void report_phase(uvm_phase phase);
      if (debug_path_required && payload_beat_count > 0 && debug_ts_count == 0)
        `uvm_error("MTSP_DUAL_PATH",
          "Normal hit output was observed but the debug_ts analysis path reported no samples")
      if (debug_path_required && (pending_hit1.size() != 0 || pending_debug_ts.size() != 0))
        `uvm_error("MTSP_DUAL_PATH",
          $sformatf("Unpaired normal/debug_ts samples remain: normal=%0d debug_ts=%0d",
            pending_hit1.size(), pending_debug_ts.size()))

      `uvm_info("MTSP_SCB",
        $sformatf("csr=%0d inputs=%0d beats=%0d payloads=%0d eops=%0d empty_eops=%0d debug_ts=%0d debug_burst=%0d ts_delta=%0d ready_x=%0d dual_path_pairs=%0d traces=%0d debug_path_required=%0b expected_latency=%0d",
          csr_access_count, input_accept_count, beat_count, payload_beat_count, eop_count,
          empty_eop_count, debug_ts_count, debug_burst_count, ts_delta_count,
          hit1_ready_unknown_count, dual_path_pair_count, trace_history.size(),
          debug_path_required, expected_latency),
        UVM_LOW)
    endfunction
  endclass

  class mtsp_env extends uvm_env;
    `uvm_component_utils(mtsp_env)

    uvm_sequencer #(mtsp_csr_item)  m_csr_sqr;
    uvm_sequencer #(mtsp_ctrl_item) m_ctrl_sqr;
    uvm_sequencer #(mtsp_hit0_item) m_hit0_sqr;
    mtsp_csr_driver                 m_csr_drv;
    mtsp_csr_monitor                m_csr_mon;
    mtsp_ctrl_driver                m_ctrl_drv;
    mtsp_hit0_driver                m_hit0_drv;
    mtsp_hit0_monitor               m_hit0_mon;
    mtsp_hit1_monitor               m_hit1_mon;
    mtsp_hit1_ready_monitor         m_ready_mon;
    mtsp_dbg_monitor                m_dbg_mon;
    mtsp_scoreboard                 m_scb;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_csr_sqr  = uvm_sequencer#(mtsp_csr_item)::type_id::create("m_csr_sqr", this);
      m_ctrl_sqr = uvm_sequencer#(mtsp_ctrl_item)::type_id::create("m_ctrl_sqr", this);
      m_hit0_sqr = uvm_sequencer#(mtsp_hit0_item)::type_id::create("m_hit0_sqr", this);
      m_csr_drv  = mtsp_csr_driver::type_id::create("m_csr_drv", this);
      m_csr_mon  = mtsp_csr_monitor::type_id::create("m_csr_mon", this);
      m_ctrl_drv = mtsp_ctrl_driver::type_id::create("m_ctrl_drv", this);
      m_hit0_drv = mtsp_hit0_driver::type_id::create("m_hit0_drv", this);
      m_hit0_mon = mtsp_hit0_monitor::type_id::create("m_hit0_mon", this);
      m_hit1_mon = mtsp_hit1_monitor::type_id::create("m_hit1_mon", this);
      m_ready_mon = mtsp_hit1_ready_monitor::type_id::create("m_ready_mon", this);
      m_dbg_mon  = mtsp_dbg_monitor::type_id::create("m_dbg_mon", this);
      m_scb      = mtsp_scoreboard::type_id::create("m_scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_csr_drv.seq_item_port.connect(m_csr_sqr.seq_item_export);
      m_ctrl_drv.seq_item_port.connect(m_ctrl_sqr.seq_item_export);
      m_hit0_drv.seq_item_port.connect(m_hit0_sqr.seq_item_export);
      m_csr_mon.ap.connect(m_scb.csr_imp);
      m_hit0_mon.ap.connect(m_scb.hit0_imp);
      m_hit1_mon.ap.connect(m_scb.hit1_imp);
      m_ready_mon.ap.connect(m_scb.ready_imp);
      m_dbg_mon.ap.connect(m_scb.dbg_imp);
    endfunction
  endclass

  class mtsp_csr_write_seq extends uvm_sequence #(mtsp_csr_item);
    `uvm_object_utils(mtsp_csr_write_seq)

    bit [2:0]  addr;
    bit [31:0] data;
    bit        hold_bus_after;

    function new(string name = "mtsp_csr_write_seq");
      super.new(name);
      hold_bus_after = 1'b0;
    endfunction

    task body();
      mtsp_csr_item item;
      item = mtsp_csr_item::type_id::create("csr_wr");
      start_item(item);
      item.is_write  = 1'b1;
      item.address   = addr;
      item.writedata = data;
      item.hold_bus_after = hold_bus_after;
      finish_item(item);
    endtask
  endclass

  class mtsp_csr_read_seq extends uvm_sequence #(mtsp_csr_item);
    `uvm_object_utils(mtsp_csr_read_seq)

    bit [2:0]  addr;
    bit [31:0] data;

    function new(string name = "mtsp_csr_read_seq");
      super.new(name);
      data = '0;
    endfunction

    task body();
      mtsp_csr_item item;
      item = mtsp_csr_item::type_id::create("csr_rd");
      start_item(item);
      item.is_write  = 1'b0;
      item.address   = addr;
      item.writedata = '0;
      finish_item(item);
      data = item.readdata;
    endtask
  endclass

  class mtsp_ctrl_seq extends uvm_sequence #(mtsp_ctrl_item);
    `uvm_object_utils(mtsp_ctrl_seq)

    logic [8:0] cmd;
    int unsigned post_accept_delay_cycles;
    int unsigned timeout_cycles;
    bit          wait_for_ready;
    bit          hold_data_after;
    bit          drive_valid;
    string       state_name;
    time         accept_time_ps;

    function new(string name = "mtsp_ctrl_seq");
      super.new(name);
      post_accept_delay_cycles = 0;
      timeout_cycles           = 10000;
      wait_for_ready           = 1'b1;
      hold_data_after          = 1'b0;
      drive_valid              = 1'b1;
      state_name               = "";
      accept_time_ps           = 0;
    endfunction

    task body();
      mtsp_ctrl_item item;
      item = mtsp_ctrl_item::type_id::create("ctrl_item");
      start_item(item);
      item.cmd                      = cmd;
      item.post_accept_delay_cycles = post_accept_delay_cycles;
      item.timeout_cycles           = timeout_cycles;
      item.wait_for_ready           = wait_for_ready;
      item.hold_data_after          = hold_data_after;
      item.drive_valid              = drive_valid;
      item.state_name               = state_name;
      finish_item(item);
      accept_time_ps = item.accept_time_ps;
    endtask
  endclass

  class mtsp_hit0_seq extends uvm_sequence #(mtsp_hit0_item);
    `uvm_object_utils(mtsp_hit0_seq)

    bit [5:0]  channel;
    bit        sop;
    bit        eop;
    bit        endofrun;
    bit [2:0]  error;
    bit [44:0] data;
    bit        valid;
    bit        wait_for_ready;
    time       accept_time_ps;

    function new(string name = "mtsp_hit0_seq");
      super.new(name);
      valid          = 1'b1;
      wait_for_ready = 1'b1;
      endofrun       = 1'b0;
      error          = '0;
      accept_time_ps = 0;
    endfunction

    task body();
      mtsp_hit0_item item;
      item = mtsp_hit0_item::type_id::create("hit0_item");
      start_item(item);
      item.channel  = channel;
      item.sop      = sop;
      item.eop      = eop;
      item.endofrun = endofrun;
      item.error    = error;
      item.data    = data;
      item.valid   = valid;
      item.wait_for_ready = wait_for_ready;
      finish_item(item);
      accept_time_ps = item.accept_time_ps;
    endtask
  endclass

  class mtsp_base_test extends uvm_test;
    `uvm_component_utils(mtsp_base_test)

    mtsp_env                 m_env;
    virtual mtsp_reset_if.drv rst_vif;
    virtual mtsp_ctrl_if.mon ctrl_vif;
    virtual mtsp_hit0_if.mon hit0_vif;
    virtual mtsp_hit1_if.drv hit1_drv_vif;
    virtual mtsp_dbg_if.mon  dbg_vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_env = mtsp_env::type_id::create("m_env", this);
      if (!uvm_config_db#(virtual mtsp_reset_if.drv)::get(this, "", "rst_vif", rst_vif))
        `uvm_fatal("MTSP_TEST", "Missing rst_vif")
      if (!uvm_config_db#(virtual mtsp_ctrl_if.mon)::get(this, "", "ctrl_vif", ctrl_vif))
        `uvm_fatal("MTSP_TEST", "Missing ctrl_vif")
      if (!uvm_config_db#(virtual mtsp_hit0_if.mon)::get(this, "", "hit0_vif", hit0_vif))
        `uvm_fatal("MTSP_TEST", "Missing hit0_vif")
      if (!uvm_config_db#(virtual mtsp_hit1_if.drv)::get(this, "", "hit1_drv_vif", hit1_drv_vif))
        `uvm_fatal("MTSP_TEST", "Missing hit1_drv_vif")
      if (!uvm_config_db#(virtual mtsp_dbg_if.mon)::get(this, "", "dbg_vif", dbg_vif))
        `uvm_fatal("MTSP_TEST", "Missing dbg_vif")
    endfunction

    task automatic wait_cycles(int unsigned cycles);
      repeat (cycles)
        @(posedge ctrl_vif.clk);
    endtask

    task automatic wait_for_reset_release();
      while (ctrl_vif.rst !== 1'b0)
        @(posedge ctrl_vif.clk);
      wait_cycles(2);
    endtask

    task automatic drive_global_reset(int unsigned assert_cycles = 4,
                                      int unsigned release_cycles = 2);
      rst_vif.rst <= 1'b1;
      repeat (assert_cycles)
        @(posedge rst_vif.clk);
      rst_vif.rst <= 1'b0;
      repeat (release_cycles)
        @(posedge rst_vif.clk);
    endtask

    task automatic set_hit1_ready(bit ready_value);
      hit1_drv_vif.ready <= ready_value;
      @(posedge hit1_drv_vif.clk);
    endtask

    task automatic toggle_hit1_ready_for(int unsigned cycles);
      for (int unsigned idx = 0; idx < cycles; idx++) begin
        hit1_drv_vif.ready <= idx[0];
        @(posedge hit1_drv_vif.clk);
      end
      hit1_drv_vif.ready <= 1'b1;
    endtask

    task automatic csr_write(bit [2:0] addr, bit [31:0] data);
      mtsp_csr_write_seq seq;
      seq      = mtsp_csr_write_seq::type_id::create($sformatf("csr_wr_%0t", $time));
      seq.addr = addr;
      seq.data = data;
      seq.start(m_env.m_csr_sqr);
    endtask

    task automatic csr_read(bit [2:0] addr, output bit [31:0] data);
      mtsp_csr_read_seq seq;
      seq      = mtsp_csr_read_seq::type_id::create($sformatf("csr_rd_%0t", $time));
      seq.addr = addr;
      seq.start(m_env.m_csr_sqr);
      data = seq.data;
    endtask

    task automatic csr_write_then_read_no_idle(bit [2:0] wr_addr,
                                               bit [31:0] wr_data,
                                               bit [2:0] rd_addr,
                                               output bit [31:0] rd_data);
      mtsp_csr_write_seq wr_seq;
      mtsp_csr_read_seq  rd_seq;

      wr_seq                = mtsp_csr_write_seq::type_id::create($sformatf("csr_wr_hold_%0t", $time));
      wr_seq.addr           = wr_addr;
      wr_seq.data           = wr_data;
      wr_seq.hold_bus_after = 1'b1;
      wr_seq.start(m_env.m_csr_sqr);

      rd_seq      = mtsp_csr_read_seq::type_id::create($sformatf("csr_rd_no_idle_%0t", $time));
      rd_seq.addr = rd_addr;
      rd_seq.start(m_env.m_csr_sqr);
      rd_data = rd_seq.data;
    endtask

    task automatic expect_csr_mask(bit [2:0] addr,
                                   bit [31:0] expected,
                                   bit [31:0] mask,
                                   string ctx);
      bit [31:0] csr_word;
      csr_read(addr, csr_word);
      if ((csr_word & mask) !== (expected & mask))
        `uvm_fatal("MTSP_CSR",
          $sformatf("%s addr=%0d expected(masked)=0x%08h got=0x%08h mask=0x%08h",
            ctx, addr, expected & mask, csr_word, mask))
    endtask

    task automatic read_total_count(output bit [47:0] total_count);
      bit [31:0] hi_word;
      bit [31:0] lo_word;
      csr_read(3'd3, hi_word);
      csr_read(3'd4, lo_word);
      total_count = {hi_word[15:0], lo_word};
    endtask

    task automatic seed_total_count_dv(bit [47:0] seed_value, string ctx);
      csr_write(3'd3, {16'd0, seed_value[47:32]});
      wait_cycles(2);
      csr_write(3'd4, seed_value[31:0]);
      wait_cycles(2);
      expect_total_count(seed_value, ctx);
    endtask

    task automatic expect_total_count(bit [47:0] expected, string ctx);
      bit [47:0] total_count;
      read_total_count(total_count);
      if (total_count !== expected)
        `uvm_fatal("MTSP_CSR",
          $sformatf("%s expected total_count=%0d got %0d",
            ctx, expected, total_count))
    endtask

    task automatic expect_discard_count(bit [31:0] expected, string ctx);
      bit [31:0] discard_count;
      csr_read(3'd1, discard_count);
      if (discard_count !== expected)
        `uvm_fatal("MTSP_CSR",
          $sformatf("%s expected discard_count=%0d got %0d",
            ctx, expected, discard_count))
    endtask

    task automatic expect_hit0_ready(bit expected, string ctx);
      if (hit0_vif.ready !== expected)
        `uvm_fatal("MTSP_READY",
          $sformatf("%s expected hit0 ready=%0b got %0b",
            ctx, expected, hit0_vif.ready))
    endtask

    task automatic wait_for_hit0_ready(bit expected,
                                       int unsigned max_cycles,
                                       string ctx);
      repeat (max_cycles) begin
        if (hit0_vif.ready === expected)
          return;
        @(posedge hit0_vif.clk);
      end
      `uvm_fatal("MTSP_READY",
        $sformatf("%s timed out waiting for hit0 ready=%0b, got %0b",
          ctx, expected, hit0_vif.ready))
    endtask

    task automatic send_ctrl_and_capture(logic [8:0] cmd, string state_name,
                                         output time accept_time_ps,
                                         input int unsigned post_accept_delay_cycles = 0);
      mtsp_ctrl_seq seq;
      seq                          = mtsp_ctrl_seq::type_id::create($sformatf("ctrl_seq_%s_%0t", state_name, $time));
      seq.cmd                      = cmd;
      seq.state_name               = state_name;
      seq.post_accept_delay_cycles = post_accept_delay_cycles;
      seq.wait_for_ready           = 1'b1;
      seq.start(m_env.m_ctrl_sqr);
      accept_time_ps = seq.accept_time_ps;
    endtask

    task automatic send_ctrl(logic [8:0] cmd, string state_name,
                             int unsigned post_accept_delay_cycles = 0);
      time ignored_time;
      send_ctrl_and_capture(cmd, state_name, ignored_time, post_accept_delay_cycles);
    endtask

    task automatic wait_for_running_status(int unsigned max_polls,
                                           string ctx);
      bit [31:0] csr_word;
      repeat (max_polls) begin
        csr_read(3'd0, csr_word);
        if (csr_word[0] === 1'b1)
          return;
        wait_cycles(1);
      end
      `uvm_fatal("MTSP_RUN",
        $sformatf("%s timed out waiting for CSR running status bit", ctx))
    endtask

    task automatic pulse_ctrl(logic [8:0] cmd, string state_name);
      mtsp_ctrl_seq seq;
      seq                = mtsp_ctrl_seq::type_id::create($sformatf("ctrl_pulse_%s_%0t", state_name, $time));
      seq.cmd            = cmd;
      seq.state_name     = state_name;
      seq.wait_for_ready = 1'b0;
      seq.start(m_env.m_ctrl_sqr);
    endtask

    task automatic pulse_ctrl_hold_data(logic [8:0] cmd, string state_name);
      mtsp_ctrl_seq seq;
      seq                 = mtsp_ctrl_seq::type_id::create($sformatf("ctrl_hold_%s_%0t", state_name, $time));
      seq.cmd             = cmd;
      seq.state_name      = state_name;
      seq.wait_for_ready  = 1'b0;
      seq.hold_data_after = 1'b1;
      seq.start(m_env.m_ctrl_sqr);
    endtask

    task automatic drive_ctrl_data_gap(logic [8:0] cmd, string state_name);
      mtsp_ctrl_seq seq;
      seq                 = mtsp_ctrl_seq::type_id::create($sformatf("ctrl_gap_%s_%0t", state_name, $time));
      seq.cmd             = cmd;
      seq.state_name      = state_name;
      seq.wait_for_ready  = 1'b0;
      seq.hold_data_after = 1'b1;
      seq.drive_valid     = 1'b0;
      seq.start(m_env.m_ctrl_sqr);
    endtask

    task automatic run_start();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, "run_start");
      wait_for_hit0_ready(1'b1, 16, "run_start");
      wait_cycles(1);
    endtask

    task automatic send_hit_beat_with_sideband(int unsigned sideband_channel,
                                               int unsigned asic_value,
                                               int unsigned channel_value,
                                               int unsigned tcc_raw_value,
                                               int unsigned ecc_raw_value,
                                               bit eflag_value,
                                               bit sop_value,
                                               bit eop_value,
                                               bit [2:0] error_value = '0,
                                               bit wait_for_ready = 1'b1,
                                               int unsigned tfine_value = 0);
      mtsp_hit0_seq seq;
      bit [44:0]    hit_word;

      hit_word             = '0;
      hit_word[44:41]      = asic_value[3:0];
      hit_word[40:36]      = channel_value[4:0];
      hit_word[35:21]      = tcc_raw_value[14:0];
      hit_word[20:16]      = tfine_value[4:0];
      hit_word[15:1]       = ecc_raw_value[14:0];
      hit_word[0]          = eflag_value;

      seq                  = mtsp_hit0_seq::type_id::create($sformatf("hit0_seq_%0t", $time));
      seq.channel          = sideband_channel[5:0];
      seq.sop              = sop_value;
      seq.eop              = eop_value;
      seq.endofrun         = 1'b0;
      seq.error            = error_value;
      seq.data             = hit_word;
      seq.valid            = 1'b1;
      seq.wait_for_ready   = wait_for_ready;
      seq.start(m_env.m_hit0_sqr);
    endtask

    task automatic send_hit_beat(int unsigned asic_value,
                                 int unsigned channel_value,
                                 int unsigned tcc_raw_value,
                                 int unsigned ecc_raw_value,
                                 bit eflag_value,
                                 bit sop_value,
                                 bit eop_value,
                                 bit [2:0] error_value = '0,
                                 bit wait_for_ready = 1'b1,
                                 int unsigned tfine_value = 0);
      send_hit_beat_with_sideband({2'b00, asic_value[3:0]},
        asic_value, channel_value, tcc_raw_value, ecc_raw_value,
        eflag_value, sop_value, eop_value, error_value, wait_for_ready,
        tfine_value);
    endtask

    task automatic send_endofrun_pulse();
      mtsp_hit0_seq seq;
      seq            = mtsp_hit0_seq::type_id::create($sformatf("endofrun_%0t", $time));
      seq.channel    = '0;
      seq.sop        = 1'b0;
      seq.eop        = 1'b0;
      seq.endofrun   = 1'b1;
      seq.data       = '0;
      seq.valid      = 1'b0;
      seq.start(m_env.m_hit0_sqr);
    endtask

    task automatic wait_for_eop_count(int unsigned expected_eops,
                                      int unsigned max_cycles,
                                      string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.eop_count >= expected_eops)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for eop_count=%0d, got %0d",
          ctx, expected_eops, m_env.m_scb.eop_count))
    endtask

    task automatic wait_for_empty_eop_count(int unsigned expected_empty_eops,
                                            int unsigned max_cycles,
                                            string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.empty_eop_count >= expected_empty_eops)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for empty_eop_count=%0d, got %0d",
          ctx, expected_empty_eops, m_env.m_scb.empty_eop_count))
    endtask

    task automatic wait_for_beat_count(int unsigned expected_beats,
                                       int unsigned max_cycles,
                                       string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.beat_count >= expected_beats)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for beat_count=%0d, got %0d",
          ctx, expected_beats, m_env.m_scb.beat_count))
    endtask

    task automatic wait_for_ctrl_ready_low(int unsigned max_cycles, string ctx);
      repeat (max_cycles) begin
        @(posedge ctrl_vif.clk);
        if (ctrl_vif.ready === 1'b0)
          return;
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for ctrl_ready to deassert", ctx))
    endtask

    task automatic wait_for_ctrl_ready_high(int unsigned max_cycles, string ctx);
      repeat (max_cycles) begin
        @(posedge ctrl_vif.clk);
        if (ctrl_vif.ready === 1'b1)
          return;
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for ctrl_ready to assert", ctx))
    endtask

    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      server = uvm_report_server::get_server();
      if (server.get_severity_count(UVM_FATAL) == 0 &&
          server.get_severity_count(UVM_ERROR) == 0)
        $display("*** TEST PASSED ***");
      else
        $display("*** TEST FAILED ***");
    endfunction
  endclass

  class COMBO_MTSP_001_terminate_contract_test extends mtsp_base_test;
    `uvm_component_utils(COMBO_MTSP_001_terminate_contract_test)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      int unsigned base_beat_count;
      int unsigned base_eop_count;
      int unsigned base_empty_eop_count;
      int unsigned base_history_size;
      bit [3:0]    close_mask;
      bit [3:0]    payload_mask;
      int unsigned payload_count;
      phase.raise_objection(this);

      wait_for_reset_release();
      run_start();

      base_beat_count      = m_env.m_scb.beat_count;
      base_eop_count       = m_env.m_scb.eop_count;
      base_empty_eop_count = m_env.m_scb.empty_eop_count;
      base_history_size    = m_env.m_scb.history.size();

      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b1);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(1);
      send_hit_beat(2, 2, 'h0013, 'h001F, 1'b1, 1'b1, 1'b1);
      send_endofrun_pulse();

      wait_for_ctrl_ready_low(4, "Active TERMINATING ready deassert");
      wait_for_empty_eop_count(base_empty_eop_count + 4, 128,
        "Active TERMINATING close-marker train");
      wait_for_ctrl_ready_high(128, "Active TERMINATING ready restore");

      if (m_env.m_scb.beat_count < base_beat_count + 6)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit two payload beats plus four close markers, got beats=%0d base=%0d",
            m_env.m_scb.beat_count, base_beat_count))
      if (m_env.m_scb.eop_count < base_eop_count + 4)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit four close-marker EOPs, got eops=%0d base=%0d",
            m_env.m_scb.eop_count, base_eop_count))

      close_mask    = '0;
      payload_mask  = '0;
      payload_count = 0;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (!obs.empty) begin
          payload_count++;
          payload_mask[int'(obs.channel[1:0])] = 1'b1;
          if (obs.eop !== 1'b0)
            `uvm_fatal("MTSP_TEST", "Payload beat must not carry the terminate EOP anymore")
        end else if (obs.eop) begin
          close_mask[int'(obs.channel[1:0])] = 1'b1;
          if (payload_mask[int'(obs.channel[1:0])]) begin
            if (obs.sop !== 1'b0)
              `uvm_fatal("MTSP_TEST", "Payload lane close marker must not reassert SOP")
          end else begin
            if (obs.sop !== 1'b1)
              `uvm_fatal("MTSP_TEST", "Idle-lane close markers must carry SOP+EOP")
          end
        end
      end
      if (payload_count != 2)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate run must emit exactly two payload beats, got %0d", payload_count))
      if (close_mask !== 4'b1111)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit one close marker per lane, got mask=%b", close_mask))

      send_ctrl(CTRL_IDLE, "IDLE");
      run_start();

      base_eop_count       = m_env.m_scb.eop_count;
      base_empty_eop_count = m_env.m_scb.empty_eop_count;
      base_history_size    = m_env.m_scb.history.size();

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();

      wait_for_ctrl_ready_low(4, "Idle TERMINATING ready deassert");
      wait_for_empty_eop_count(base_empty_eop_count + 4, 128,
        "Idle-close marker train");
      wait_for_ctrl_ready_high(128, "Idle TERMINATING ready restore");

      if (m_env.m_scb.eop_count < base_eop_count + 4)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Idle terminate must emit four close-marker EOPs, got eops=%0d base=%0d",
            m_env.m_scb.eop_count, base_eop_count))

      close_mask = '0;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (obs.eop) begin
          if (obs.empty !== 1'b1 || obs.sop !== 1'b1)
            `uvm_fatal("MTSP_TEST", "Idle terminate must emit SOP+EOP empty close markers only")
          close_mask[int'(obs.channel[1:0])] = 1'b1;
        end else if (obs.valid) begin
          `uvm_fatal("MTSP_TEST", "Idle terminate must not emit payload beats")
        end
      end
      if (close_mask !== 4'b1111)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Idle terminate must emit one close marker per lane, got mask=%b", close_mask))

      send_ctrl(CTRL_IDLE, "IDLE");
      phase.drop_objection(this);
    endtask
  endclass

  `include "mtsp_cases.svh"
endpackage
