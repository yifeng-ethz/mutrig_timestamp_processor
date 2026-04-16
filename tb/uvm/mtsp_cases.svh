  class mtsp_doc_case_test extends mtsp_base_test;
    `uvm_component_utils(mtsp_doc_case_test)

    string case_id;

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

    task automatic do_std_003_direct_running_entry_allowed();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
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

    task automatic do_std_031_running_accepts_clean_hit();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
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

    task automatic do_std_061_short_mode_zeroes_et();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.data[8:0] != 9'h000)
        `uvm_fatal("MTSP_CASE", "Short mode must drive ET_1n6=0")
    endtask

    task automatic do_std_063_tot_mode_positive_delta();
      int unsigned base_beats;
      mtsp_hit1_obs_item hit_obs;

      wait_for_reset_release();
      csr_write(3'd0, 32'h4000_0001);
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 'h0003, 'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null || hit_obs.data[8:0] == 9'h000)
        `uvm_fatal("MTSP_CASE", "ToT mode positive delta must produce nonzero ET")
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

    task automatic do_neg_021_hiterr_rejected_running();
      do_std_036_hiterr_discard_enabled();
    endtask

    task automatic do_neg_028_valid_beat_under_force_stop();
      do_std_038_force_stop_blocks_acceptance();
    endtask

    task automatic run_case_by_id();
      case (case_id)
        "STD_MTS_001_powerup_reset_idle": do_std_001_powerup_reset_idle();
        "STD_MTS_003_direct_running_entry_allowed": do_std_003_direct_running_entry_allowed();
        "STD_MTS_011_control_readback_after_reset": do_std_011_control_readback_after_reset();
        "STD_MTS_013_expected_latency_default_2000": do_std_013_expected_latency_default_2000();
        "STD_MTS_031_running_accepts_clean_hit": do_std_031_running_accepts_clean_hit();
        "STD_MTS_036_hiterr_discard_enabled": do_std_036_hiterr_discard_enabled();
        "STD_MTS_037_hiterr_discard_disabled": do_std_037_hiterr_discard_disabled();
        "STD_MTS_038_force_stop_blocks_acceptance": do_std_038_force_stop_blocks_acceptance();
        "STD_MTS_061_short_mode_zeroes_et": do_std_061_short_mode_zeroes_et();
        "STD_MTS_063_tot_mode_positive_delta": do_std_063_tot_mode_positive_delta();
        "STD_MTS_077_terminating_input_eop_forwards_output_eop": do_std_077_terminating_input_eop_forwards_output_eop();
        "STD_MTS_078_nonterminating_eop_not_forwarded": do_std_078_nonterminating_eop_not_forwarded();
        "CORNER_MTS_011_expected_latency_zero": do_corner_011_expected_latency_zero();
        "NEG_MTS_021_hiterr_rejected_running": do_neg_021_hiterr_rejected_running();
        "NEG_MTS_028_valid_beat_under_force_stop": do_neg_028_valid_beat_under_force_stop();
        default: run_generic_case();
      endcase
    endtask

    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      run_case_by_id();
      phase.drop_objection(this);
    endtask
  endclass
