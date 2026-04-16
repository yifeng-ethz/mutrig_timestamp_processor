`timescale 1ps/1ps

package mtsp_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_hit1)

  localparam logic [8:0] CTRL_IDLE        = 9'b000000001;
  localparam logic [8:0] CTRL_RUN_PREPARE = 9'b000000010;
  localparam logic [8:0] CTRL_SYNC        = 9'b000000100;
  localparam logic [8:0] CTRL_RUNNING     = 9'b000001000;
  localparam logic [8:0] CTRL_TERMINATING = 9'b000010000;
  localparam time CLK_PERIOD_PS           = 8000ps;

  class mtsp_csr_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_csr_item)

    bit        is_write;
    bit [2:0]  address;
    bit [31:0] writedata;
    bit [31:0] readdata;
    int unsigned timeout_cycles;
    time       complete_time_ps;

    function new(string name = "mtsp_csr_item");
      super.new(name);
      timeout_cycles   = 1000;
      complete_time_ps = 0;
    endfunction
  endclass

  class mtsp_ctrl_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_ctrl_item)

    logic [8:0] cmd;
    int unsigned post_accept_delay_cycles;
    int unsigned timeout_cycles;
    bit          wait_for_ready;
    string       state_name;
    time         accept_time_ps;

    function new(string name = "mtsp_ctrl_item");
      super.new(name);
      post_accept_delay_cycles = 0;
      timeout_cycles           = 10000;
      wait_for_ready           = 1'b1;
      state_name               = "";
      accept_time_ps           = 0;
    endfunction
  endclass

  class mtsp_hit0_item extends uvm_sequence_item;
    `uvm_object_utils(mtsp_hit0_item)

    bit [5:0]  channel;
    bit        sop;
    bit        eop;
    bit [2:0]  error;
    bit [44:0] data;
    bit        valid;
    int unsigned timeout_cycles;
    time       accept_time_ps;

    function new(string name = "mtsp_hit0_item");
      super.new(name);
      valid            = 1'b1;
      error            = '0;
      timeout_cycles   = 10000;
      accept_time_ps   = 0;
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

      vif.address   <= '0;
      vif.read      <= 1'b0;
      vif.write     <= 1'b0;
      vif.writedata <= '0;

      forever begin
        seq_item_port.get_next_item(item);

        @(posedge vif.clk);
        vif.address   <= item.address;
        vif.writedata <= item.writedata;
        vif.write     <= item.is_write;
        vif.read      <= !item.is_write;

        wait_cycles = 0;
        while (vif.waitrequest === 1'b1) begin
          @(posedge vif.clk);
          wait_cycles++;
          if (wait_cycles > item.timeout_cycles)
            `uvm_fatal("MTSP_CSR_TIMEOUT",
              $sformatf("Timed out waiting for CSR completion at address 0x%0h",
                item.address))
        end

        if (!item.is_write)
          item.readdata = vif.readdata;
        item.complete_time_ps = $time;

        @(posedge vif.clk);
        vif.address   <= '0;
        vif.read      <= 1'b0;
        vif.write     <= 1'b0;
        vif.writedata <= '0;
        seq_item_port.item_done();
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
        vif.valid <= 1'b1;

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
          vif.data  <= CTRL_IDLE;
        end else begin
          @(posedge vif.clk);
          item.accept_time_ps = $time;
          vif.valid <= 1'b0;
          vif.data  <= CTRL_IDLE;
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

      vif.channel <= '0;
      vif.sop     <= 1'b0;
      vif.eop     <= 1'b0;
      vif.error   <= '0;
      vif.data    <= '0;
      vif.valid   <= 1'b0;

      forever begin
        seq_item_port.get_next_item(item);

        wait_cycles = 0;
        while (vif.ready !== 1'b1) begin
          @(posedge vif.clk);
          wait_cycles++;
          if (wait_cycles > item.timeout_cycles)
            `uvm_fatal("MTSP_HIT0_TIMEOUT",
              $sformatf("Timed out waiting for hit0 ready after %0d cycles",
                item.timeout_cycles))
        end

        vif.channel <= item.channel;
        vif.sop     <= item.sop;
        vif.eop     <= item.eop;
        vif.error   <= item.error;
        vif.data    <= item.data;
        vif.valid   <= item.valid;

        @(posedge vif.clk);
        item.accept_time_ps = $time;
        vif.channel <= '0;
        vif.sop     <= 1'b0;
        vif.eop     <= 1'b0;
        vif.error   <= '0;
        vif.data    <= '0;
        vif.valid   <= 1'b0;
        seq_item_port.item_done();
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

  class mtsp_scoreboard extends uvm_component;
    `uvm_component_utils(mtsp_scoreboard)

    uvm_analysis_imp_hit1 #(mtsp_hit1_obs_item, mtsp_scoreboard) hit1_imp;

    int unsigned beat_count;
    int unsigned eop_count;
    int unsigned empty_eop_count;

    time         last_eop_time_ps;
    bit          last_eop_empty;
    bit [38:0]   last_eop_data;

    mtsp_hit1_obs_item history[$];

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      hit1_imp         = new("hit1_imp", this);
      beat_count       = 0;
      eop_count        = 0;
      empty_eop_count  = 0;
      last_eop_time_ps = 0;
      last_eop_empty   = 1'b0;
      last_eop_data    = '0;
    endfunction

    function void write_hit1(mtsp_hit1_obs_item item);
      history.push_back(item);
      beat_count++;
      if (item.eop) begin
        eop_count++;
        last_eop_time_ps = item.time_ps;
        last_eop_empty   = item.empty;
        last_eop_data    = item.data;
        if (item.empty)
          empty_eop_count++;
      end
    endfunction

    function void report_phase(uvm_phase phase);
      `uvm_info("MTSP_SCB",
        $sformatf("beats=%0d eops=%0d empty_eops=%0d",
          beat_count, eop_count, empty_eop_count),
        UVM_LOW)
    endfunction
  endclass

  class mtsp_env extends uvm_env;
    `uvm_component_utils(mtsp_env)

    uvm_sequencer #(mtsp_csr_item)  m_csr_sqr;
    uvm_sequencer #(mtsp_ctrl_item) m_ctrl_sqr;
    uvm_sequencer #(mtsp_hit0_item) m_hit0_sqr;
    mtsp_csr_driver                 m_csr_drv;
    mtsp_ctrl_driver                m_ctrl_drv;
    mtsp_hit0_driver                m_hit0_drv;
    mtsp_hit1_monitor               m_hit1_mon;
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
      m_ctrl_drv = mtsp_ctrl_driver::type_id::create("m_ctrl_drv", this);
      m_hit0_drv = mtsp_hit0_driver::type_id::create("m_hit0_drv", this);
      m_hit1_mon = mtsp_hit1_monitor::type_id::create("m_hit1_mon", this);
      m_scb      = mtsp_scoreboard::type_id::create("m_scb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_csr_drv.seq_item_port.connect(m_csr_sqr.seq_item_export);
      m_ctrl_drv.seq_item_port.connect(m_ctrl_sqr.seq_item_export);
      m_hit0_drv.seq_item_port.connect(m_hit0_sqr.seq_item_export);
      m_hit1_mon.ap.connect(m_scb.hit1_imp);
    endfunction
  endclass

  class mtsp_csr_write_seq extends uvm_sequence #(mtsp_csr_item);
    `uvm_object_utils(mtsp_csr_write_seq)

    bit [2:0]  addr;
    bit [31:0] data;

    function new(string name = "mtsp_csr_write_seq");
      super.new(name);
    endfunction

    task body();
      mtsp_csr_item item;
      item = mtsp_csr_item::type_id::create("csr_wr");
      start_item(item);
      item.is_write  = 1'b1;
      item.address   = addr;
      item.writedata = data;
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
    string       state_name;
    time         accept_time_ps;

    function new(string name = "mtsp_ctrl_seq");
      super.new(name);
      post_accept_delay_cycles = 0;
      timeout_cycles           = 10000;
      wait_for_ready           = 1'b1;
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
    bit [2:0]  error;
    bit [44:0] data;
    bit        valid;
    time       accept_time_ps;

    function new(string name = "mtsp_hit0_seq");
      super.new(name);
      valid          = 1'b1;
      error          = '0;
      accept_time_ps = 0;
    endfunction

    task body();
      mtsp_hit0_item item;
      item = mtsp_hit0_item::type_id::create("hit0_item");
      start_item(item);
      item.channel = channel;
      item.sop     = sop;
      item.eop     = eop;
      item.error   = error;
      item.data    = data;
      item.valid   = valid;
      finish_item(item);
      accept_time_ps = item.accept_time_ps;
    endtask
  endclass

  class mtsp_base_test extends uvm_test;
    `uvm_component_utils(mtsp_base_test)

    mtsp_env                 m_env;
    virtual mtsp_ctrl_if.mon ctrl_vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_env = mtsp_env::type_id::create("m_env", this);
      if (!uvm_config_db#(virtual mtsp_ctrl_if.mon)::get(this, "", "ctrl_vif", ctrl_vif))
        `uvm_fatal("MTSP_TEST", "Missing ctrl_vif")
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

    task automatic pulse_ctrl(logic [8:0] cmd, string state_name);
      mtsp_ctrl_seq seq;
      seq                = mtsp_ctrl_seq::type_id::create($sformatf("ctrl_pulse_%s_%0t", state_name, $time));
      seq.cmd            = cmd;
      seq.state_name     = state_name;
      seq.wait_for_ready = 1'b0;
      seq.start(m_env.m_ctrl_sqr);
    endtask

    task automatic run_start();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_cycles(2);
    endtask

    task automatic send_hit_beat(int unsigned asic_value,
                                 int unsigned channel_value,
                                 int unsigned tcc_raw_value,
                                 int unsigned ecc_raw_value,
                                 bit eflag_value,
                                 bit sop_value,
                                 bit eop_value,
                                 bit [2:0] error_value = '0);
      mtsp_hit0_seq seq;
      bit [44:0]    hit_word;

      hit_word             = '0;
      hit_word[44:41]      = asic_value[3:0];
      hit_word[40:36]      = channel_value[4:0];
      hit_word[35:21]      = tcc_raw_value[14:0];
      hit_word[20:16]      = '0;
      hit_word[15:1]       = ecc_raw_value[14:0];
      hit_word[0]          = eflag_value;

      seq                  = mtsp_hit0_seq::type_id::create($sformatf("hit0_seq_%0t", $time));
      seq.channel          = {2'b00, asic_value[3:0]};
      seq.sop              = sop_value;
      seq.eop              = eop_value;
      seq.error            = error_value;
      seq.data             = hit_word;
      seq.valid            = 1'b1;
      seq.start(m_env.m_hit0_sqr);
    endtask

    task automatic send_synthetic_eop();
      mtsp_hit0_seq seq;
      seq         = mtsp_hit0_seq::type_id::create($sformatf("synth_eop_%0t", $time));
      seq.channel = '0;
      seq.sop     = 1'b0;
      seq.eop     = 1'b1;
      seq.data    = '0;
      seq.valid   = 1'b0;
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
      int          payload_lane;
      phase.raise_objection(this);

      wait_for_reset_release();
      run_start();

      base_beat_count      = m_env.m_scb.beat_count;
      base_eop_count       = m_env.m_scb.eop_count;
      base_empty_eop_count = m_env.m_scb.empty_eop_count;
      base_history_size    = m_env.m_scb.history.size();

      fork
        begin
          pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
        end
        begin
          wait_cycles(1);
          send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b1);
        end
      join

      wait_for_ctrl_ready_low(4, "Active TERMINATING ready deassert");
      wait_for_empty_eop_count(base_empty_eop_count + 4, 128,
        "Active TERMINATING close-marker train");
      wait_for_ctrl_ready_high(128, "Active TERMINATING ready restore");

      if (m_env.m_scb.beat_count < base_beat_count + 5)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit one payload beat plus four close markers, got beats=%0d base=%0d",
            m_env.m_scb.beat_count, base_beat_count))
      if (m_env.m_scb.eop_count < base_eop_count + 4)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit four close-marker EOPs, got eops=%0d base=%0d",
            m_env.m_scb.eop_count, base_eop_count))

      close_mask   = '0;
      payload_lane = -1;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (!obs.empty) begin
          payload_lane = int'(obs.channel[1:0]);
          if (obs.eop !== 1'b0)
            `uvm_fatal("MTSP_TEST", "Payload beat must not carry the terminate EOP anymore")
        end else if (obs.eop) begin
          close_mask[int'(obs.channel[1:0])] = 1'b1;
          if (payload_lane == int'(obs.channel[1:0])) begin
            if (obs.sop !== 1'b0)
              `uvm_fatal("MTSP_TEST", "Payload lane close marker must not reassert SOP")
          end else begin
            if (obs.sop !== 1'b1)
              `uvm_fatal("MTSP_TEST", "Idle-lane close markers must carry SOP+EOP")
          end
        end
      end
      if (payload_lane < 0)
        `uvm_fatal("MTSP_TEST", "Active terminate run did not emit a payload beat")
      if (close_mask !== 4'b1111)
        `uvm_fatal("MTSP_TEST",
          $sformatf("Active terminate must emit one close marker per lane, got mask=%b", close_mask))

      send_ctrl(CTRL_IDLE, "IDLE");
      run_start();

      base_eop_count       = m_env.m_scb.eop_count;
      base_empty_eop_count = m_env.m_scb.empty_eop_count;
      base_history_size    = m_env.m_scb.history.size();

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");

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
