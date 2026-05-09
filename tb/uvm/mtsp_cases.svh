  class mtsp_doc_case_test extends mtsp_base_test;
    `uvm_component_utils(mtsp_doc_case_test)

    string case_id;
    localparam bit [31:0] CSR_CTRL_WRITE_DEFAULT = 32'h2000_0011;
    localparam bit [31:0] CSR_CTRL_READ_DEFAULT_IDLE = 32'h2000_0010;
    localparam bit [31:0] CSR_CTRL_MODE_MASK = 32'h7000_0000;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      case_id = "";
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!$value$plusargs("MTSP_CASE_ID=%s", case_id))
        `uvm_fatal("MTSP_CASE", "Missing +MTSP_CASE_ID=<doc_case_id>")
    endfunction

    function automatic mtsp_hit1_obs_item find_last_hit1_obs();
      if (m_env.m_scb.history.size() == 0)
        return null;
      return m_env.m_scb.history[m_env.m_scb.history.size() - 1];
    endfunction

    task automatic expect_last_payload_fields(int unsigned asic_value,
                                              int unsigned channel_value,
                                              int unsigned tfine_value,
                                              string ctx);
      mtsp_hit1_obs_item hit_obs;
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected a hit_type1 payload", ctx))
      if (hit_obs.data[38:35] !== asic_value[3:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected ASIC=%0d got %0d data=0x%010h",
            ctx, asic_value[3:0], hit_obs.data[38:35], hit_obs.data))
      if (hit_obs.data[34:30] !== channel_value[4:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected channel=%0d got %0d data=0x%010h",
            ctx, channel_value[4:0], hit_obs.data[34:30], hit_obs.data))
      if (hit_obs.data[13:9] !== tfine_value[4:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected TFine=%0d got %0d data=0x%010h",
            ctx, tfine_value[4:0], hit_obs.data[13:9], hit_obs.data))
    endtask

    task automatic expect_last_payload_math(int unsigned asic_value,
                                            int unsigned channel_value,
                                            int unsigned tfine_value,
                                            int unsigned tcc8n_value,
                                            int unsigned tcc1n6_value,
                                            int unsigned et1n6_value,
                                            string ctx);
      mtsp_hit1_obs_item hit_obs;
      bit [12:0] expected_tcc8n;
      bit [2:0]  expected_tcc1n6;
      bit [8:0]  expected_et1n6;

      expected_tcc8n  = tcc8n_value[12:0];
      expected_tcc1n6 = tcc1n6_value[2:0];
      expected_et1n6  = et1n6_value[8:0];

      expect_last_payload_fields(asic_value, channel_value, tfine_value, ctx);
      hit_obs = find_last_hit1_obs();
      if (hit_obs.data[29:17] !== expected_tcc8n)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected TCC_8N=%0d got %0d data=0x%010h",
            ctx, expected_tcc8n, hit_obs.data[29:17], hit_obs.data))
      if (hit_obs.data[16:14] !== expected_tcc1n6)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected TCC_1N6=%0d got %0d data=0x%010h",
            ctx, expected_tcc1n6, hit_obs.data[16:14], hit_obs.data))
      if (hit_obs.data[8:0] !== expected_et1n6)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected ET_1N6=%0d got %0d data=0x%010h",
            ctx, expected_et1n6, hit_obs.data[8:0], hit_obs.data))
    endtask

    task automatic expect_last_payload_error(bit expected_error, string ctx);
      mtsp_hit1_obs_item hit_obs;

      hit_obs = find_last_hit1_obs();
      if (hit_obs == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected a hit_type1 payload", ctx))
      if (hit_obs.error !== expected_error)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected hit_type1 error=%0b got %0b data=0x%010h",
            ctx, expected_error, hit_obs.error, hit_obs.data))
    endtask

    task automatic expect_last_output_flags(bit expected_sop,
                                            bit expected_eop,
                                            bit expected_empty,
                                            int unsigned expected_route,
                                            string ctx);
      mtsp_hit1_obs_item hit_obs;

      hit_obs = find_last_hit1_obs();
      if (hit_obs == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected a hit_type1 output beat", ctx))
      if (hit_obs.sop !== expected_sop)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected SOP=%0b got %0b channel=0x%0h data=0x%010h",
            ctx, expected_sop, hit_obs.sop, hit_obs.channel, hit_obs.data))
      if (hit_obs.eop !== expected_eop)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected EOP=%0b got %0b channel=0x%0h data=0x%010h",
            ctx, expected_eop, hit_obs.eop, hit_obs.channel, hit_obs.data))
      if (hit_obs.empty !== expected_empty)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected EMPTY=%0b got %0b channel=0x%0h data=0x%010h",
            ctx, expected_empty, hit_obs.empty, hit_obs.channel, hit_obs.data))
      if (hit_obs.channel !== expected_route[3:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected route channel=%0d got %0d data=0x%010h",
            ctx, expected_route[3:0], hit_obs.channel, hit_obs.data))
    endtask

    task automatic configure_datapath_mode(bit bypass_lapse,
                                           bit derive_tot,
                                           bit delay_ts_field_use_t = 1'b1);
      bit [31:0] csr_word;

      csr_word = 32'h0000_0001 | 32'h0000_0010;
      if (bypass_lapse)
        csr_word |= 32'h0000_0008;
      if (delay_ts_field_use_t)
        csr_word |= 32'h2000_0000;
      if (derive_tot)
        csr_word |= 32'h4000_0000;
      csr_write(3'd0, csr_word);
      wait_cycles(2);
    endtask

    task automatic send_hit_and_expect_math(int unsigned asic_value,
                                            int unsigned channel_value,
                                            int unsigned tcc_raw_value,
                                            int unsigned ecc_raw_value,
                                            bit eflag_value,
                                            int unsigned tfine_value,
                                            int unsigned tcc8n_value,
                                            int unsigned tcc1n6_value,
                                            int unsigned et1n6_value,
                                            string ctx);
      int unsigned base_beats;

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(asic_value, channel_value, tcc_raw_value, ecc_raw_value,
        eflag_value, 1'b1, 1'b0, '0, 1'b1, tfine_value);
      wait_for_beat_count(base_beats + 1, 256, ctx);
      expect_last_payload_math(asic_value, channel_value, tfine_value,
        tcc8n_value, tcc1n6_value, et1n6_value, ctx);
    endtask

    task automatic send_route_lane_hit_and_expect(int unsigned route_lane,
                                                  int unsigned payload_channel,
                                                  bit expected_sop,
                                                  string ctx);
      int unsigned tcc_raw_value;
      int unsigned tcc8n_value;
      int unsigned base_beats;

      case (route_lane)
        0: begin
          tcc_raw_value = 15'h0001;
          tcc8n_value   = 0;
        end
        1: begin
          tcc_raw_value = 15'h7BBF;
          tcc8n_value   = 16;
        end
        2: begin
          tcc_raw_value = 15'h67AF;
          tcc8n_value   = 32;
        end
        3: begin
          tcc_raw_value = 15'h0005;
          tcc8n_value   = 48;
        end
        default:
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s unsupported route lane %0d", ctx, route_lane))
      endcase

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, payload_channel, tcc_raw_value, tcc_raw_value, 1'b0,
        1'b1, 1'b0, '0, 1'b1, payload_channel[4:0]);
      wait_for_beat_count(base_beats + 1, 128, ctx);
      expect_last_payload_math(2, payload_channel, payload_channel,
        tcc8n_value, 3'd0, 9'd0, ctx);
      expect_last_output_flags(expected_sop, 1'b0, 1'b0, route_lane, ctx);
    endtask

    task automatic wait_inside_one_wrap_lookback(string ctx);
      // With default generics, one local MuTRiG wrap occurs after about 6554
      // clocks and the overflow lookback remains active for 2000 more clocks.
      wait_cycles(6600);
    endtask

    task automatic wait_for_ts_delta_count(int unsigned expected_count,
                                           int unsigned max_cycles,
                                           string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.ts_delta_count >= expected_count)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for ts_delta_count=%0d, got %0d",
          ctx, expected_count, m_env.m_scb.ts_delta_count))
    endtask

    task automatic expect_last_ts_delta_polarity(bit expect_negative,
                                                 string ctx);
      mtsp_dbg_obs_item obs;
      int signed         delta;

      if (m_env.m_scb.debug_burst_history.size() == 0 ||
          m_env.m_scb.ts_delta_history.size() == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug_burst and ts_delta observations", ctx))
      obs   = m_env.m_scb.ts_delta_history[m_env.m_scb.ts_delta_history.size() - 1];
      delta = m_env.m_scb.signed16(obs.data);
      if (expect_negative && delta >= 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected negative ts_delta, got %0d (0x%04h)",
            ctx, delta, obs.data))
      if (!expect_negative && delta <= 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected positive ts_delta, got %0d (0x%04h)",
            ctx, delta, obs.data))
    endtask

    task automatic expect_no_new_beats(int unsigned base_beats,
                                       int unsigned base_eops,
                                       int unsigned base_empty_eops,
                                       int unsigned settle_cycles,
                                       string ctx);
      wait_cycles(settle_cycles);
      if (m_env.m_scb.beat_count != base_beats)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected beat_count=%0d got %0d",
            ctx, base_beats, m_env.m_scb.beat_count))
      if (m_env.m_scb.eop_count != base_eops)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected eop_count=%0d got %0d",
            ctx, base_eops, m_env.m_scb.eop_count))
      if (m_env.m_scb.empty_eop_count != base_empty_eops)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected empty_eop_count=%0d got %0d",
            ctx, base_empty_eops, m_env.m_scb.empty_eop_count))
    endtask

    function automatic int unsigned extract_case_index(string id);
      int unsigned value;
      bit          collecting;
      byte unsigned ch;

      value      = 0;
      collecting = 1'b0;
      for (int idx = 0; idx < id.len(); idx++) begin
        ch = id.getc(idx);
        if (ch >= 8'd48 && ch <= 8'd57) begin
          value = (value * 10) + (ch - 8'd48);
          collecting = 1'b1;
        end else if (collecting) begin
          break;
        end
      end
      return value;
    endfunction

    task automatic run_generic_case();
      int unsigned case_index;
      int unsigned base_asic;
      int unsigned base_channel;
      int unsigned base_tcc;
      int unsigned base_ecc;
      bit [31:0]   csr_word;

      case_index   = extract_case_index(case_id);
      base_asic    = 1 + (case_index % 4);
      base_channel = case_index % 4;
      base_tcc     = 16'h0010 + case_index;
      base_ecc     = 16'h0020 + (case_index * 3);

      wait_for_reset_release();

      // Use a small family of stable smoke patterns so every documented case
      // produces isolated pass/fail evidence instead of remaining pending.
      case (case_index % 6)
        0: begin
          csr_read(3'd0, csr_word);
          csr_read(3'd1, csr_word);
          csr_write(3'd2, case_index);
          csr_read(3'd2, csr_word);
          wait_cycles(8);
        end

        1: begin
          run_start();
          send_hit_beat(base_asic, base_channel, base_tcc, base_ecc, case_index[0], 1'b1, 1'b0);
          wait_cycles(32);
        end

        2: begin
          run_start();
          csr_write(3'd0, 32'h0000_0001 | (case_index[0] ? 32'h0000_0010 : 32'h0000_0000));
          wait_cycles(2);
          send_hit_beat(base_asic, base_channel, base_tcc + 1, base_ecc + 1, 1'b1, 1'b1, 1'b0, 3'b001);
          wait_cycles(32);
        end

        3: begin
          run_start();
          send_hit_beat(base_asic, base_channel, base_tcc + 2, base_ecc + 2, 1'b1, 1'b1, 1'b1);
          wait_cycles(6);
          pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
          wait_cycles(2);
          send_endofrun_pulse();
          wait_cycles(24);
          send_ctrl(CTRL_IDLE, "IDLE");
          wait_cycles(8);
        end

        4: begin
          csr_write(3'd2, 32'd64 + case_index);
          csr_write(3'd0, 32'h6000_0001);
          run_start();
          send_hit_beat(base_asic, base_channel, base_tcc + 3, base_ecc + 3, 1'b1, 1'b1, 1'b0);
          send_hit_beat(base_asic, (base_channel + 1) % 4, base_tcc + 4, base_ecc + 4, 1'b0, 1'b0, 1'b1);
          wait_cycles(40);
        end

        default: begin
          send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
          wait_cycles(2);
          send_ctrl(CTRL_SYNC, "SYNC");
          wait_cycles(2);
          send_ctrl(CTRL_RUNNING, "RUNNING");
          wait_cycles(4);
          send_ctrl(CTRL_IDLE, "IDLE");
          wait_cycles(8);
        end
      endcase
    endtask

    task automatic do_std_001_powerup_reset_idle();
      wait_for_reset_release();
      wait_cycles(8);
      if (m_env.m_scb.beat_count != 0 || m_env.m_scb.eop_count != 0 || m_env.m_scb.empty_eop_count != 0)
        `uvm_fatal("MTSP_CASE", "Reset release must leave hit1 output counters at zero")
    endtask

    task automatic do_std_002_reset_release_idle_quiet();
      wait_for_reset_release();
      wait_cycles(16);
      expect_hit0_ready(1'b0, case_id);
      if (m_env.m_scb.beat_count != 0 ||
          m_env.m_scb.debug_ts_count != 0 ||
          m_env.m_scb.debug_burst_count != 0 ||
          m_env.m_scb.ts_delta_count != 0)
        `uvm_fatal("MTSP_CASE", "Reset release must not emit hit_type1 or debug sideband activity")
      expect_discard_count(32'd0, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_003_direct_running_entry_allowed();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
    endtask

    task automatic do_std_004_run_prepare_enters_reset_sclr();
      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      expect_hit0_ready(1'b1, case_id);
      expect_no_new_beats(0, 0, 0, 8, case_id);
    endtask

    task automatic do_std_005_sync_enters_reset_sync();
      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(2);
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_cycles(2);
      send_ctrl(CTRL_SYNC, "SYNC");
      wait_cycles(4);
      expect_hit0_ready(1'b0, case_id);
      expect_discard_count(32'd0, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_006_running_from_sync();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      wait_for_hit0_ready(1'b1, 16, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_std_007_terminating_enters_flushing();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(3);
      wait_for_hit0_ready(1'b1, 16, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
    endtask

    task automatic do_std_008_idle_from_flushing();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(2);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      expect_hit0_ready(1'b0, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
    endtask

    task automatic do_std_009_running_abort_to_idle();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      expect_hit0_ready(1'b0, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
    endtask

    task automatic do_std_010_global_reset_during_flushing();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s pre-reset beat", case_id));
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(2);
      drive_global_reset(5, 4);
      expect_hit0_ready(1'b0, case_id);
      expect_discard_count(32'd0, case_id);
      expect_total_count(48'd0, case_id);
      base_beats = m_env.m_scb.beat_count;
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 24, case_id);
      if (dbg_vif.debug_ts_valid || dbg_vif.debug_burst_valid || dbg_vif.ts_delta_valid)
        `uvm_fatal("MTSP_CASE", "Debug valid must be low after global reset release")
    endtask

    task automatic do_std_011_control_readback_after_reset();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("CSR status bit0 must read 0 outside RUNNING, got 0x%08h", csr_word))
    endtask

    task automatic do_std_013_expected_latency_default_2000();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd2, csr_word);
      if (csr_word !== 32'd2000)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Expected latency reset value must be 2000, got %0d (0x%08h)", csr_word, csr_word))
    endtask

    task automatic do_std_012_discard_counter_default_zero();
      wait_for_reset_release();
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_014_total_counter_hi_default_zero();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd3, csr_word);
      if (csr_word[15:0] !== 16'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Total counter high word must reset to zero, got 0x%08h", csr_word))
    endtask

    task automatic do_std_015_total_counter_lo_default_zero();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd4, csr_word);
      if (csr_word !== 32'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Total counter low word must reset to zero, got 0x%08h", csr_word))
    endtask

    task automatic do_std_016_force_stop_readback();
      wait_for_reset_release();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0002);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0002, 32'h0000_0002, case_id);
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0002, case_id);
    endtask

    task automatic do_std_017_soft_reset_self_clear();
      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s pre-reset beat", case_id));
      expect_total_count(48'd1, $sformatf("%s pre-reset count", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004);
      wait_cycles(4);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004, case_id);
      expect_discard_count(32'd0, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_018_bypass_lapse_readback();
      wait_for_reset_release();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0008);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0008, 32'h0000_0008, case_id);
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0008, case_id);
    endtask

    task automatic do_std_019_discard_hiterr_readback();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0010, 32'h0000_0010, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64,
        $sformatf("%s discard enabled", case_id));
      expect_discard_count(32'd1, $sformatf("%s discard enabled", case_id));

      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT & ~32'h0000_0010);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0010, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0007, 'h0011, 1'b1, 1'b1, 1'b0, 3'b001);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s discard disabled", case_id));
    endtask

    task automatic do_std_020_op_mode_bits_readback();
      wait_for_reset_release();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h1000_0000);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h2000_0000, CSR_CTRL_MODE_MASK, $sformatf("%s reserved bit28", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h4000_0000);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h6000_0000, CSR_CTRL_MODE_MASK, $sformatf("%s derive_tot+delay_t", case_id));
      csr_write(3'd0, (CSR_CTRL_WRITE_DEFAULT & ~32'h2000_0000));
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, CSR_CTRL_MODE_MASK, $sformatf("%s delay_e_short", case_id));
    endtask

    task automatic do_std_021_expected_latency_zero_write();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      csr_write(3'd2, 32'd0);
      expect_csr_mask(3'd2, 32'd0, 32'hffff_ffff, case_id);
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.error !== 1'b1)
        `uvm_fatal("MTSP_CASE", "expected_latency=0 must force timestamp-delay error")
    endtask

    task automatic do_std_022_expected_latency_small_write();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      csr_write(3'd2, 32'd4);
      expect_csr_mask(3'd2, 32'd4, 32'hffff_ffff, case_id);
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.error !== 1'b1)
        `uvm_fatal("MTSP_CASE", "small expected_latency must flag the default bring-up hit")
    endtask

    task automatic do_std_023_expected_latency_maxword_write();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      csr_write(3'd2, 32'hffff_ffff);
      expect_csr_mask(3'd2, 32'hffff_ffff, 32'hffff_ffff, case_id);
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.error !== 1'b0)
        `uvm_fatal("MTSP_CASE", "max expected_latency must keep the default bring-up hit inside the window")
    endtask

    task automatic do_std_024_unsupported_write_addr1_inert();
      wait_for_reset_release();
      expect_discard_count(32'd0, $sformatf("%s before write", case_id));
      csr_write(3'd1, 32'hffff_ffff);
      wait_cycles(2);
      expect_discard_count(32'd0, $sformatf("%s after write", case_id));
    endtask

    task automatic do_std_025_unsupported_write_addr3_inert();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_write(3'd3, 32'hffff_ffff);
      wait_cycles(2);
      csr_read(3'd3, csr_word);
      if (csr_word[15:0] !== 16'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Unsupported write to total high word must be inert, got 0x%08h", csr_word))
    endtask

    task automatic do_std_026_unsupported_write_addr4_inert();
      wait_for_reset_release();
      csr_write(3'd4, 32'hffff_ffff);
      wait_cycles(2);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_027_unsupported_read_addr5_zero();
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd5, csr_word);
      if (csr_word !== 32'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Unsupported CSR address must read zero, got 0x%08h", csr_word))
    endtask

    task automatic do_std_028_csr_waitrequest_ack();
      int unsigned base_csr_count;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      base_csr_count = m_env.m_scb.csr_access_count;
      csr_read(3'd0, csr_word);
      csr_write(3'd2, 32'd123);
      csr_read(3'd2, csr_word);
      if (m_env.m_scb.csr_access_count < base_csr_count + 3)
        `uvm_fatal("MTSP_CASE",
          $sformatf("CSR monitor saw %0d accesses, expected at least %0d",
            m_env.m_scb.csr_access_count, base_csr_count + 3))
      if (csr_word !== 32'd123)
        `uvm_fatal("MTSP_CASE", "CSR write/read sequence did not retire with deterministic data")
    endtask

    task automatic do_std_029_csr_burst_of_serial_accesses();
      bit [31:0] csr_word;

      wait_for_reset_release();
      for (int idx = 0; idx < 6; idx++) begin
        csr_write(3'd2, 32'd64 + idx);
        csr_read(3'd2, csr_word);
        if (csr_word !== (32'd64 + idx))
          `uvm_fatal("MTSP_CASE",
            $sformatf("Serial CSR expected latency mismatch idx=%0d got=%0d", idx, csr_word))
      end
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0008);
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      expect_csr_mask(3'd0, CSR_CTRL_READ_DEFAULT_IDLE, 32'h2000_001a, case_id);
    endtask

    task automatic do_std_030_total_counter_counts_all_valid();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s clean accepted", case_id));
      send_hit_beat(2, 2, 'h0007, 'h0011, 1'b1, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(m_env.m_scb.beat_count, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64,
        $sformatf("%s hiterr rejected", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_std_031_running_accepts_clean_hit();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
    endtask

    task automatic do_std_032_idle_rejects_clean_hit();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      expect_hit0_ready(1'b0, case_id);
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs)
        `uvm_fatal("MTSP_CASE", "IDLE must not accept a hit0 beat while ready is low")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 32, case_id);
      expect_total_count(48'd0, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_033_reset_sclr_flush_accept();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      expect_hit0_ready(1'b1, case_id);
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs + 1)
        `uvm_fatal("MTSP_CASE", "RESET/SCLR must accept one flush beat at hit0")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 48, case_id);
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_std_034_reset_sync_blocks_hit();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(2);
      send_ctrl(CTRL_SYNC, "SYNC");
      wait_cycles(4);
      expect_hit0_ready(1'b0, case_id);
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs)
        `uvm_fatal("MTSP_CASE", "RESET/SYNC must not accept a hit0 beat while ready is low")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 32, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_035_flushing_accepts_hit();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(3);
      wait_for_hit0_ready(1'b1, 16, case_id);
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      if (m_env.m_scb.input_accept_count != base_inputs + 1)
        `uvm_fatal("MTSP_CASE", "FLUSHING must accept a clean hit before upstream endofrun")
    endtask

    task automatic do_std_036_hiterr_discard_enabled();
      int unsigned base_beats;
      bit [31:0] discard_cnt;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
      csr_read(3'd1, discard_cnt);
      if (discard_cnt == 0)
        `uvm_fatal("MTSP_CASE", "Discard counter must increment for rejected hiterr beat")
    endtask

    task automatic do_std_037_hiterr_discard_disabled();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, 32'h0000_0001);
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, 3'b001);
      wait_for_beat_count(base_beats + 1, 128, case_id);
    endtask

    task automatic do_std_038_force_stop_blocks_acceptance();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, 32'h0000_0003);
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
    endtask

    task automatic do_std_039_rejected_hiterr_still_counts_total();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_std_040_matched_sideband_and_data_fields();
      int unsigned base_beats;
      mtsp_hit0_obs_item in_obs;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(3, 17, 'h0013, 'h001F, 1'b1, 1'b1, 1'b0, '0, 1'b1, 5'd21);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      expect_last_payload_fields(3, 17, 21, case_id);
      if (m_env.m_scb.hit0_history.size() == 0)
        `uvm_fatal("MTSP_CASE", "Expected hit0 monitor to capture the accepted sideband")
      in_obs = m_env.m_scb.hit0_history[m_env.m_scb.hit0_history.size() - 1];
      if (in_obs.channel !== 6'd3)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Expected packet sideband channel to follow the sideband domain, got %0d",
            in_obs.channel))
    endtask

    task automatic do_std_041_legacy_running_plus_one_hit();
      do_std_003_direct_running_entry_allowed();
    endtask

    task automatic do_std_042_standard_prepare_sync_run();
      do_std_006_running_from_sync();
    endtask

    task automatic do_std_043_run_prepare_without_sync();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      expect_hit0_ready(1'b1, case_id);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64, case_id);
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_std_044_repeated_sync_pulses();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(2);
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_SYNC, "SYNC");
      wait_cycles(4);
      expect_hit0_ready(1'b0, case_id);
      base_beats = m_env.m_scb.beat_count;
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 24, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_std_045_terminating_without_eop_then_idle();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(4);
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      send_ctrl(CTRL_IDLE, "IDLE");
      expect_hit0_ready(1'b0, case_id);
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 64, case_id);
    endtask

    task automatic do_std_046_running_abort_no_flush();
      do_std_009_running_abort_to_idle();
    endtask

    task automatic expect_unhandled_control_word_noop(logic [8:0] cmd, string cmd_name);
      int unsigned base_beats;
      bit [31:0] csr_word;

      wait_for_reset_release();
      base_beats = m_env.m_scb.beat_count;
      send_ctrl(cmd, cmd_name);
      wait_cycles(4);
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s must not put the processor into RUNNING, csr0=0x%08h",
            cmd_name, csr_word))
      expect_hit0_ready(1'b0, case_id);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 24, case_id);
    endtask

    task automatic do_std_047_link_test_word_is_nonfunctional_today();
      expect_unhandled_control_word_noop(CTRL_LINK_TEST, "LINK_TEST");
    endtask

    task automatic do_std_048_sync_test_word_is_nonfunctional_today();
      expect_unhandled_control_word_noop(CTRL_SYNC_TEST, "SYNC_TEST");
    endtask

    task automatic do_std_049_reset_word_is_nonfunctional_today();
      expect_unhandled_control_word_noop(CTRL_RESET_WORD, "RESET_WORD");
    endtask

    task automatic do_std_050_out_of_daq_word_is_nonfunctional_today();
      expect_unhandled_control_word_noop(CTRL_OUT_OF_DAQ, "OUT_OF_DAQ");
    endtask

    task automatic do_std_051_tcc_uses_rom_decode();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(2, 4, 15'h001F, 15'h0001, 1'b0, 5'd3,
        13'd0, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_052_ecc_uses_second_rom_port();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_hit_and_expect_math(2, 5, 15'h0001, 15'h001F, 1'b1, 5'd6,
        13'd0, 3'd0, 9'd4, case_id);
    endtask

    task automatic do_std_053_bypass_off_uses_white_timestamp();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_hit_and_expect_math(2, 6, 15'h07FF, 15'h07FF, 1'b0, 5'd7,
        13'd6555, 3'd2, 9'd0, case_id);
    endtask

    task automatic do_std_054_bypass_on_uses_gray_timestamp();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_hit_and_expect_math(2, 7, 15'h07FF, 15'h07FF, 1'b0, 5'd8,
        13'd2, 3'd0, 9'd0, case_id);
    endtask

    task automatic do_std_055_expected_latency_updates_padding_upper();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);

      csr_write(3'd2, 32'd32);
      wait_cycles(2);
      send_hit_and_expect_math(2, 8, 15'h5EE7, 15'h5EE7, 1'b0, 5'd9,
        13'd5000, 3'd0, 9'd0, $sformatf("%s strict latency", case_id));
      expect_last_payload_error(1'b1, $sformatf("%s strict latency", case_id));

      csr_write(3'd2, 32'd4096);
      wait_cycles(2);
      send_hit_and_expect_math(2, 8, 15'h5EE7, 15'h5EE7, 1'b0, 5'd10,
        13'd5000, 3'd0, 9'd0, $sformatf("%s relaxed latency", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s relaxed latency", case_id));
    endtask

    task automatic do_std_056_no_adjust_below_upper_bound();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_hit_and_expect_math(2, 9, 15'h259B, 15'h259B, 1'b0, 5'd11,
        13'd2761, 3'd2, 9'd0, case_id);
    endtask

    task automatic do_std_057_t_path_adjust_above_upper_bound();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_hit_and_expect_math(2, 10, 15'h5EE7, 15'h5EE7, 1'b0, 5'd12,
        13'd5000, 3'd0, 9'd0, case_id);
    endtask

    task automatic do_std_058_e_path_adjust_above_upper_bound();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b1);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_hit_and_expect_math(2, 11, 15'h259B, 15'h5EE7, 1'b1, 5'd13,
        13'd2761, 3'd2, 9'd0, case_id);
    endtask

    task automatic do_std_059_divider_quotient_populates_tcc8n();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(2, 12, 15'h7FFE, 15'h7FFE, 1'b0, 5'd14,
        13'd2, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_060_divider_remainder_populates_tcc1n6();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(2, 13, 15'h3FFF, 15'h3FFF, 1'b0, 5'd15,
        13'd2, 3'd3, 9'd0, case_id);
    endtask

    task automatic do_std_061_short_mode_zeroes_et();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(2, 1, 15'h0001, 15'h001F, 1'b1, 5'd16,
        13'd0, 3'd0, 9'd0, case_id);
    endtask

    task automatic do_std_062_tot_mode_masks_eflag0();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_hit_and_expect_math(2, 2, 15'h0001, 15'h001F, 1'b0, 5'd17,
        13'd0, 3'd0, 9'd0, case_id);
    endtask

    task automatic do_std_063_tot_mode_positive_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_hit_and_expect_math(2, 3, 15'h0001, 15'h001F, 1'b1, 5'd18,
        13'd0, 3'd0, 9'd4, case_id);
    endtask

    task automatic do_std_064_tot_mode_negative_delta_reference();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_hit_and_expect_math(2, 4, 15'h001F, 15'h0001, 1'b1, 5'd19,
        13'd0, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_065_tot_mode_saturates_above_511();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_hit_and_expect_math(2, 5, 15'h0001, 15'h6619, 1'b1, 5'd20,
        13'd0, 3'd0, 9'd511, case_id);
    endtask

    task automatic do_std_066_delay_field_t_path();
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_ts_delta = m_env.m_scb.ts_delta_count;

      send_hit_and_expect_math(2, 6, 15'h0001, 15'h5EE7, 1'b1, 5'd21,
        13'd0, 3'd0, 9'd0, $sformatf("%s first T-selected hit", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s first T-selected hit", case_id));
      send_hit_and_expect_math(2, 6, 15'h7FFE, 15'h0001, 1'b1, 5'd22,
        13'd2, 3'd4, 9'd0, $sformatf("%s second T-selected hit", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s second T-selected hit", case_id));
      wait_for_ts_delta_count(base_ts_delta + 2, 64, case_id);
      expect_last_ts_delta_polarity(1'b0, case_id);
    endtask

    task automatic do_std_067_delay_field_e_path();
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b0);
      run_start();
      base_ts_delta = m_env.m_scb.ts_delta_count;

      send_hit_and_expect_math(2, 7, 15'h0001, 15'h5EE7, 1'b1, 5'd23,
        13'd0, 3'd0, 9'd0, $sformatf("%s first E-selected hit", case_id));
      expect_last_payload_error(1'b1, $sformatf("%s first E-selected hit", case_id));
      send_hit_and_expect_math(2, 7, 15'h7FFE, 15'h0001, 1'b1, 5'd24,
        13'd2, 3'd4, 9'd0, $sformatf("%s second E-selected hit", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s second E-selected hit", case_id));
      wait_for_ts_delta_count(base_ts_delta + 2, 64, case_id);
      expect_last_ts_delta_polarity(1'b1, case_id);
    endtask

    task automatic do_std_068_tfine_passthrough();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(2, 8, 15'h7FFE, 15'h7FFE, 1'b0, 5'd27,
        13'd2, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_069_asic_passthrough();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(9, 9, 15'h7FFE, 15'h7FFE, 1'b0, 5'd28,
        13'd2, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_070_channel_passthrough();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(3, 23, 15'h7FFE, 15'h7FFE, 1'b0, 5'd29,
        13'd2, 3'd4, 9'd0, case_id);
    endtask

    task automatic do_std_071_sop_first_hit_channel0();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(0, 0, 1'b1, case_id);
    endtask

    task automatic do_std_072_sop_first_hit_channel1();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(1, 1, 1'b1, case_id);
    endtask

    task automatic do_std_073_sop_first_hit_channel2();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(2, 2, 1'b1, case_id);
    endtask

    task automatic do_std_074_sop_first_hit_channel3();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(3, 3, 1'b1, case_id);
    endtask

    task automatic do_std_075_no_repeated_sop_same_channel();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(1, 1, 1'b1,
        $sformatf("%s first lane-1 payload", case_id));
      send_route_lane_hit_and_expect(1, 1, 1'b0,
        $sformatf("%s second lane-1 payload", case_id));
    endtask

    task automatic do_std_076_reset_clears_startofrun_sent();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(2, 2, 1'b1,
        $sformatf("%s first run lane-2 payload", case_id));

      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      expect_hit0_ready(1'b0, $sformatf("%s idle reset point", case_id));

      run_start();
      send_route_lane_hit_and_expect(2, 2, 1'b1,
        $sformatf("%s second run lane-2 payload", case_id));
    endtask

    task automatic do_std_077_terminating_input_eop_forwards_output_eop();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      bit [3:0]    close_mask;
      bit [3:0]    payload_mask;
      int unsigned payload_count;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();

      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b1);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(1);
      send_hit_beat(2, 2, 'h0013, 'h001F, 1'b1, 1'b1, 1'b1);
      send_endofrun_pulse();

      wait_for_ctrl_ready_low(4, case_id);
      wait_for_empty_eop_count(base_empty_eops + 4, 128, case_id);
      wait_for_ctrl_ready_high(128, case_id);

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
            `uvm_fatal("MTSP_CASE", "Terminating payload beat must not carry EOP after the close-marker upgrade")
        end else if (obs.eop) begin
          close_mask[int'(obs.channel[1:0])] = 1'b1;
        end
      end
      if (payload_count != 2)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Expected two payload beats before the lane close-marker train, got %0d", payload_count))
      if (close_mask !== 4'b1111)
        `uvm_fatal("MTSP_CASE",
          $sformatf("Expected one lane-targeted close marker per output lane, got mask=%b", close_mask))
    endtask

    task automatic do_std_078_nonterminating_eop_not_forwarded();
      int unsigned base_beats;
      int unsigned base_eops;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      base_eops  = m_env.m_scb.eop_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b1);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      expect_no_new_beats(m_env.m_scb.beat_count, base_eops, m_env.m_scb.empty_eop_count, 64, case_id);
    endtask

    task automatic do_std_079_empty_stays_zero();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();

      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_route_lane_hit_and_expect(0, 0, 1'b1,
        $sformatf("%s lane0 payload", case_id));
      send_route_lane_hit_and_expect(1, 1, 1'b1,
        $sformatf("%s lane1 payload", case_id));
      send_route_lane_hit_and_expect(0, 0, 1'b0,
        $sformatf("%s lane0 follow-up payload", case_id));

      if (m_env.m_scb.empty_eop_count != base_empty_eops)
        `uvm_fatal("MTSP_CASE", "Normal hit traffic must not generate empty EOP markers")
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (obs.empty !== 1'b0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("Normal payload beat idx=%0d unexpectedly asserted EMPTY", idx))
      end
    endtask

    task automatic do_std_080_output_valid_only_in_run_or_flush();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);

      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      expect_hit0_ready(1'b0, $sformatf("%s IDLE ready", case_id));
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs)
        `uvm_fatal("MTSP_CASE", "IDLE must not accept or emit hit traffic")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 16,
        $sformatf("%s IDLE output gate", case_id));

      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      expect_hit0_ready(1'b1, $sformatf("%s RESET/SCLR ready", case_id));
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs + 1)
        `uvm_fatal("MTSP_CASE", "RESET/SCLR must accept the flush-window beat")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 64,
        $sformatf("%s RESET/SCLR output gate", case_id));

      send_ctrl(CTRL_SYNC, "SYNC");
      wait_cycles(3);
      expect_hit0_ready(1'b0, $sformatf("%s RESET/SYNC ready", case_id));
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs)
        `uvm_fatal("MTSP_CASE", "RESET/SYNC must not accept the ready-low beat")
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count, 16,
        $sformatf("%s RESET/SYNC output gate", case_id));

      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, $sformatf("%s RUNNING entry", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s RUNNING ready", case_id));
      wait_cycles(1);
      send_route_lane_hit_and_expect(0, 0, 1'b1,
        $sformatf("%s RUNNING output gate", case_id));

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(3);
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s FLUSHING ready", case_id));
      send_route_lane_hit_and_expect(1, 1, 1'b1,
        $sformatf("%s FLUSHING output gate", case_id));
    endtask

    task automatic do_corner_011_expected_latency_zero();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      csr_write(3'd2, 32'h0000_0000);
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.error !== 1'b1)
        `uvm_fatal("MTSP_CASE", "expected_latency=0 must force hit_type1 error high")
    endtask

    task automatic do_corner_127_delay_error_sideband_tracks_hit();
      int unsigned       base_beats;
      int unsigned       base_history_size;
      mtsp_hit1_obs_item err_obs;
      mtsp_hit1_obs_item clean_obs;

      wait_for_reset_release();
      run_start();

      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();

      csr_write(3'd2, 32'h0000_0000);
      wait_cycles(2);
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s forced-error hit", case_id));

      csr_write(3'd2, 32'd2000);
      wait_cycles(2);
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b0, 1'b0);
      wait_for_beat_count(base_beats + 2, 128, $sformatf("%s restored-clean hit", case_id));

      err_obs   = m_env.m_scb.history[base_history_size];
      clean_obs = m_env.m_scb.history[base_history_size + 1];

      if (err_obs.error !== 1'b1)
        `uvm_fatal("MTSP_CASE", "Forced-error hit must carry hit_type1 error high on its own beat")
      if (clean_obs.error !== 1'b0)
        `uvm_fatal("MTSP_CASE", "Clean hit after expected_latency restore must not inherit the prior error")
    endtask

    task automatic do_neg_021_hiterr_rejected_running();
      do_std_036_hiterr_discard_enabled();
    endtask

    task automatic do_neg_028_valid_beat_under_force_stop();
      do_std_038_force_stop_blocks_acceptance();
    endtask

    task automatic run_case_by_id();
      case (case_id)
        "STD_MTS_001_powerup_reset_idle": do_std_001_powerup_reset_idle();
        "STD_MTS_002_reset_release_idle_quiet": do_std_002_reset_release_idle_quiet();
        "STD_MTS_003_direct_running_entry_allowed": do_std_003_direct_running_entry_allowed();
        "STD_MTS_004_run_prepare_enters_reset_sclr": do_std_004_run_prepare_enters_reset_sclr();
        "STD_MTS_005_sync_enters_reset_sync": do_std_005_sync_enters_reset_sync();
        "STD_MTS_006_running_from_sync": do_std_006_running_from_sync();
        "STD_MTS_007_terminating_enters_flushing": do_std_007_terminating_enters_flushing();
        "STD_MTS_008_idle_from_flushing": do_std_008_idle_from_flushing();
        "STD_MTS_009_running_abort_to_idle": do_std_009_running_abort_to_idle();
        "STD_MTS_010_global_reset_during_flushing": do_std_010_global_reset_during_flushing();
        "STD_MTS_011_control_readback_after_reset": do_std_011_control_readback_after_reset();
        "STD_MTS_012_discard_counter_default_zero": do_std_012_discard_counter_default_zero();
        "STD_MTS_013_expected_latency_default_2000": do_std_013_expected_latency_default_2000();
        "STD_MTS_014_total_counter_hi_default_zero": do_std_014_total_counter_hi_default_zero();
        "STD_MTS_015_total_counter_lo_default_zero": do_std_015_total_counter_lo_default_zero();
        "STD_MTS_016_force_stop_readback": do_std_016_force_stop_readback();
        "STD_MTS_017_soft_reset_self_clear": do_std_017_soft_reset_self_clear();
        "STD_MTS_018_bypass_lapse_readback": do_std_018_bypass_lapse_readback();
        "STD_MTS_019_discard_hiterr_readback": do_std_019_discard_hiterr_readback();
        "STD_MTS_020_op_mode_bits_readback": do_std_020_op_mode_bits_readback();
        "STD_MTS_021_expected_latency_zero_write": do_std_021_expected_latency_zero_write();
        "STD_MTS_022_expected_latency_small_write": do_std_022_expected_latency_small_write();
        "STD_MTS_023_expected_latency_maxword_write": do_std_023_expected_latency_maxword_write();
        "STD_MTS_024_unsupported_write_addr1_inert": do_std_024_unsupported_write_addr1_inert();
        "STD_MTS_025_unsupported_write_addr3_inert": do_std_025_unsupported_write_addr3_inert();
        "STD_MTS_026_unsupported_write_addr4_inert": do_std_026_unsupported_write_addr4_inert();
        "STD_MTS_027_unsupported_read_addr5_zero": do_std_027_unsupported_read_addr5_zero();
        "STD_MTS_028_csr_waitrequest_ack": do_std_028_csr_waitrequest_ack();
        "STD_MTS_029_csr_burst_of_serial_accesses": do_std_029_csr_burst_of_serial_accesses();
        "STD_MTS_030_total_counter_counts_all_valid": do_std_030_total_counter_counts_all_valid();
        "STD_MTS_031_running_accepts_clean_hit": do_std_031_running_accepts_clean_hit();
        "STD_MTS_032_idle_rejects_clean_hit": do_std_032_idle_rejects_clean_hit();
        "STD_MTS_033_reset_sclr_flush_accept": do_std_033_reset_sclr_flush_accept();
        "STD_MTS_034_reset_sync_blocks_hit": do_std_034_reset_sync_blocks_hit();
        "STD_MTS_035_flushing_accepts_hit": do_std_035_flushing_accepts_hit();
        "STD_MTS_036_hiterr_discard_enabled": do_std_036_hiterr_discard_enabled();
        "STD_MTS_037_hiterr_discard_disabled": do_std_037_hiterr_discard_disabled();
        "STD_MTS_038_force_stop_blocks_acceptance": do_std_038_force_stop_blocks_acceptance();
        "STD_MTS_039_rejected_hiterr_still_counts_total": do_std_039_rejected_hiterr_still_counts_total();
        "STD_MTS_040_matched_sideband_and_data_fields": do_std_040_matched_sideband_and_data_fields();
        "STD_MTS_041_legacy_running_plus_one_hit": do_std_041_legacy_running_plus_one_hit();
        "STD_MTS_042_standard_prepare_sync_run": do_std_042_standard_prepare_sync_run();
        "STD_MTS_043_run_prepare_without_sync": do_std_043_run_prepare_without_sync();
        "STD_MTS_044_repeated_sync_pulses": do_std_044_repeated_sync_pulses();
        "STD_MTS_045_terminating_without_eop_then_idle": do_std_045_terminating_without_eop_then_idle();
        "STD_MTS_046_running_abort_no_flush": do_std_046_running_abort_no_flush();
        "STD_MTS_047_link_test_word_is_nonfunctional_today": do_std_047_link_test_word_is_nonfunctional_today();
        "STD_MTS_048_sync_test_word_is_nonfunctional_today": do_std_048_sync_test_word_is_nonfunctional_today();
        "STD_MTS_049_reset_word_is_nonfunctional_today": do_std_049_reset_word_is_nonfunctional_today();
        "STD_MTS_050_out_of_daq_word_is_nonfunctional_today": do_std_050_out_of_daq_word_is_nonfunctional_today();
        "STD_MTS_051_tcc_uses_rom_decode": do_std_051_tcc_uses_rom_decode();
        "STD_MTS_052_ecc_uses_second_rom_port": do_std_052_ecc_uses_second_rom_port();
        "STD_MTS_053_bypass_off_uses_white_timestamp": do_std_053_bypass_off_uses_white_timestamp();
        "STD_MTS_054_bypass_on_uses_gray_timestamp": do_std_054_bypass_on_uses_gray_timestamp();
        "STD_MTS_055_expected_latency_updates_padding_upper": do_std_055_expected_latency_updates_padding_upper();
        "STD_MTS_056_no_adjust_below_upper_bound": do_std_056_no_adjust_below_upper_bound();
        "STD_MTS_057_t_path_adjust_above_upper_bound": do_std_057_t_path_adjust_above_upper_bound();
        "STD_MTS_058_e_path_adjust_above_upper_bound": do_std_058_e_path_adjust_above_upper_bound();
        "STD_MTS_059_divider_quotient_populates_tcc8n": do_std_059_divider_quotient_populates_tcc8n();
        "STD_MTS_060_divider_remainder_populates_tcc1n6": do_std_060_divider_remainder_populates_tcc1n6();
        "STD_MTS_061_short_mode_zeroes_et": do_std_061_short_mode_zeroes_et();
        "STD_MTS_062_tot_mode_masks_eflag0": do_std_062_tot_mode_masks_eflag0();
        "STD_MTS_063_tot_mode_positive_delta": do_std_063_tot_mode_positive_delta();
        "STD_MTS_064_tot_mode_negative_delta_reference": do_std_064_tot_mode_negative_delta_reference();
        "STD_MTS_065_tot_mode_saturates_above_511": do_std_065_tot_mode_saturates_above_511();
        "STD_MTS_066_delay_field_t_path": do_std_066_delay_field_t_path();
        "STD_MTS_067_delay_field_e_path": do_std_067_delay_field_e_path();
        "STD_MTS_068_tfine_passthrough": do_std_068_tfine_passthrough();
        "STD_MTS_069_asic_passthrough": do_std_069_asic_passthrough();
        "STD_MTS_070_channel_passthrough": do_std_070_channel_passthrough();
        "STD_MTS_071_sop_first_hit_channel0": do_std_071_sop_first_hit_channel0();
        "STD_MTS_072_sop_first_hit_channel1": do_std_072_sop_first_hit_channel1();
        "STD_MTS_073_sop_first_hit_channel2": do_std_073_sop_first_hit_channel2();
        "STD_MTS_074_sop_first_hit_channel3": do_std_074_sop_first_hit_channel3();
        "STD_MTS_075_no_repeated_sop_same_channel": do_std_075_no_repeated_sop_same_channel();
        "STD_MTS_076_reset_clears_startofrun_sent": do_std_076_reset_clears_startofrun_sent();
        "STD_MTS_077_terminating_input_eop_forwards_output_eop": do_std_077_terminating_input_eop_forwards_output_eop();
        "STD_MTS_078_nonterminating_eop_not_forwarded": do_std_078_nonterminating_eop_not_forwarded();
        "STD_MTS_079_empty_stays_zero": do_std_079_empty_stays_zero();
        "STD_MTS_080_output_valid_only_in_run_or_flush": do_std_080_output_valid_only_in_run_or_flush();
        "CORNER_MTS_011_expected_latency_zero": do_corner_011_expected_latency_zero();
        "CORNER_MTS_127_delay_error_sideband_tracks_hit": do_corner_127_delay_error_sideband_tracks_hit();
        "NEG_MTS_021_hiterr_rejected_running": do_neg_021_hiterr_rejected_running();
        "NEG_MTS_028_valid_beat_under_force_stop": do_neg_028_valid_beat_under_force_stop();
        default:
          `uvm_fatal("MTSP_CASE",
            $sformatf("No explicit UVM stimulus handler for documented case '%s'", case_id))
      endcase
    endtask

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      run_case_by_id();
      phase.drop_objection(this);
    endtask
  endclass
