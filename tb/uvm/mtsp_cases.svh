  class mtsp_doc_case_test extends mtsp_base_test;
    `uvm_component_utils(mtsp_doc_case_test)

    string case_id;
    localparam bit [31:0] CSR_CTRL_WRITE_DEFAULT = 32'h2000_0011;
    localparam bit [31:0] CSR_CTRL_READ_DEFAULT_IDLE = 32'h2000_0010;
    localparam bit [31:0] CSR_CTRL_MODE_MASK = 32'h7000_0000;
    localparam int unsigned MTSP_OVERFLOW_TIME_1N6 = 32767;
    localparam int unsigned MTSP_OVERFLOW_PADDING_UPPER_1N6 = 22766;
    bit          raw_by_decoded_loaded;
    int unsigned raw_by_decoded[int unsigned];

    function new(string name, uvm_component parent);
      super.new(name, parent);
      case_id = "";
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      raw_by_decoded_loaded = 1'b0;
      if (!$value$plusargs("MTSP_CASE_ID=%s", case_id))
        `uvm_fatal("MTSP_CASE", "Missing +MTSP_CASE_ID=<doc_case_id>")
    endfunction

    function automatic mtsp_hit1_obs_item find_last_hit1_obs();
      if (m_env.m_scb.history.size() == 0)
        return null;
      return m_env.m_scb.history[m_env.m_scb.history.size() - 1];
    endfunction

    function automatic mtsp_hit0_obs_item find_last_hit0_obs();
      if (m_env.m_scb.hit0_history.size() == 0)
        return null;
      return m_env.m_scb.hit0_history[m_env.m_scb.hit0_history.size() - 1];
    endfunction

    function automatic mtsp_hit_trace_item find_last_trace();
      if (m_env.m_scb.trace_history.size() == 0)
        return null;
      return m_env.m_scb.trace_history[m_env.m_scb.trace_history.size() - 1];
    endfunction

    task automatic load_rom_inverse();
      int          fd;
      int          parsed;
      string       line;
      int unsigned raw_value;
      bit [14:0]   decoded_value;

      if (raw_by_decoded_loaded)
        return;

      fd = $fopen("dual_port_rom_init.txt", "r");
      if (fd == 0)
        `uvm_fatal("MTSP_ROM", "Could not open dual_port_rom_init.txt from simulation working directory")

      raw_by_decoded.delete();
      while ($fgets(line, fd)) begin
        raw_value     = '0;
        decoded_value = '0;
        parsed = $sscanf(line, "@%h %b", raw_value, decoded_value);
        if (parsed == 2)
          raw_by_decoded[int'(decoded_value)] = raw_value;
      end
      $fclose(fd);

      raw_by_decoded_loaded = 1'b1;
      if (!raw_by_decoded.exists(0) || !raw_by_decoded.exists(80))
        `uvm_fatal("MTSP_ROM", "ROM inverse table did not contain required decoded timestamp anchors")
    endtask

    task automatic lookup_raw_for_quotient(int unsigned quotient,
                                           int unsigned remainder,
                                           output int unsigned raw_value,
                                           input string ctx);
      int unsigned decoded_value;

      if (remainder > 4)
        `uvm_fatal("MTSP_ROM",
          $sformatf("%s illegal divide-by-5 remainder %0d", ctx, remainder))

      decoded_value = (quotient * 5) + remainder;
      if (decoded_value > 32767)
        `uvm_fatal("MTSP_ROM",
          $sformatf("%s decoded timestamp %0d is outside the 15-bit ROM range",
            ctx, decoded_value))

      load_rom_inverse();
      if (!raw_by_decoded.exists(decoded_value))
        `uvm_fatal("MTSP_ROM",
          $sformatf("%s no raw symbol found for decoded timestamp %0d",
            ctx, decoded_value))
      raw_value = raw_by_decoded[decoded_value];
    endtask

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

    task automatic wait_for_trace_count(int unsigned expected_count,
                                        int unsigned max_cycles,
                                        string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.trace_history.size() >= expected_count)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for trace_count=%0d, got %0d",
          ctx, expected_count, m_env.m_scb.trace_history.size()))
    endtask

    task automatic wait_for_input_count(int unsigned expected_count,
                                        int unsigned max_cycles,
                                        string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.hit0_history.size() >= expected_count)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for input_count=%0d, got %0d",
          ctx, expected_count, m_env.m_scb.hit0_history.size()))
    endtask

    task automatic expect_last_trace_delta(int signed min_delta,
                                           int signed max_delta,
                                           bit expected_error,
                                           string ctx);
      mtsp_hit_trace_item trace;

      trace = find_last_trace();
      if (trace == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected a paired normal/debug trace", ctx))
      if (trace.hit1_time_ps != trace.debug_time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected aligned normal/debug trace times, hit=%0t debug=%0t",
            ctx, trace.hit1_time_ps, trace.debug_time_ps))
      if (trace.debug_delta < min_delta || trace.debug_delta > max_delta)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug_delta in [%0d,%0d], got %0d",
            ctx, min_delta, max_delta, trace.debug_delta))
      if (trace.math_error !== expected_error || trace.hit1_error !== expected_error)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected error=%0b, got math_error=%0b hit_error=%0b debug_delta=%0d expected_latency=%0d",
            ctx, expected_error, trace.math_error, trace.hit1_error,
            trace.debug_delta, trace.expected_latency))
      `uvm_info("MTSP_TRACE",
        $sformatf("%s trace seq=%0d hit_time=%0t debug_time=%0t route=%0d debug_delta=%0d expected_latency=%0d error=%0b data=0x%010h",
          ctx, trace.seq_id, trace.hit1_time_ps, trace.debug_time_ps,
          trace.channel, trace.debug_delta, trace.expected_latency,
          trace.hit1_error, trace.data),
        UVM_LOW)
    endtask

    task automatic expect_last_trace_pair(string ctx);
      mtsp_hit_trace_item trace;

      trace = find_last_trace();
      if (trace == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected a paired normal/debug trace", ctx))
      if (trace.hit1_time_ps != trace.debug_time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected aligned normal/debug trace times, hit=%0t debug=%0t",
            ctx, trace.hit1_time_ps, trace.debug_time_ps))
      `uvm_info("MTSP_TRACE",
        $sformatf("%s trace seq=%0d hit_time=%0t debug_time=%0t route=%0d debug_delta=%0d expected_latency=%0d math_error=%0b hit_error=%0b data=0x%010h",
          ctx, trace.seq_id, trace.hit1_time_ps, trace.debug_time_ps,
          trace.channel, trace.debug_delta, trace.expected_latency,
          trace.math_error, trace.hit1_error, trace.data),
        UVM_LOW)
    endtask

    task automatic expect_trace_pair_at(int unsigned trace_idx, string ctx);
      mtsp_hit_trace_item trace;

      if (trace_idx >= m_env.m_scb.trace_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace index %0d, size=%0d",
            ctx, trace_idx, m_env.m_scb.trace_history.size()))
      trace = m_env.m_scb.trace_history[trace_idx];
      if (trace.hit1_time_ps != trace.debug_time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected aligned normal/debug trace times, hit=%0t debug=%0t",
            ctx, trace.hit1_time_ps, trace.debug_time_ps))
      `uvm_info("MTSP_TRACE",
        $sformatf("%s trace seq=%0d hit_time=%0t debug_time=%0t route=%0d debug_delta=%0d expected_latency=%0d math_error=%0b hit_error=%0b data=0x%010h",
          ctx, trace.seq_id, trace.hit1_time_ps, trace.debug_time_ps,
          trace.channel, trace.debug_delta, trace.expected_latency,
          trace.math_error, trace.hit1_error, trace.data),
        UVM_LOW)
    endtask

    task automatic expect_trace_error_at(int unsigned trace_idx,
                                         bit expected_error,
                                         string ctx);
      mtsp_hit_trace_item trace;

      if (trace_idx >= m_env.m_scb.trace_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace index %0d, size=%0d",
            ctx, trace_idx, m_env.m_scb.trace_history.size()))
      trace = m_env.m_scb.trace_history[trace_idx];
      if (trace.math_error !== expected_error || trace.hit1_error !== expected_error)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected error=%0b, got math_error=%0b hit_error=%0b debug_delta=%0d expected_latency=%0d",
            ctx, expected_error, trace.math_error, trace.hit1_error,
            trace.debug_delta, trace.expected_latency))
    endtask

    task automatic expect_trace_math_self_consistent_at(int unsigned trace_idx,
                                                        string ctx);
      mtsp_hit_trace_item trace;

      if (trace_idx >= m_env.m_scb.trace_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace index %0d, size=%0d",
            ctx, trace_idx, m_env.m_scb.trace_history.size()))
      trace = m_env.m_scb.trace_history[trace_idx];
      if (trace.math_error !== trace.hit1_error)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace math/hit error agreement, got math_error=%0b hit_error=%0b debug_delta=%0d expected_latency=%0d",
            ctx, trace.math_error, trace.hit1_error, trace.debug_delta,
            trace.expected_latency))
    endtask

    task automatic expect_trace_expected_latency_at(int unsigned trace_idx,
                                                    int unsigned expected_latency,
                                                    string ctx);
      mtsp_hit_trace_item trace;

      if (trace_idx >= m_env.m_scb.trace_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace index %0d, size=%0d",
            ctx, trace_idx, m_env.m_scb.trace_history.size()))
      trace = m_env.m_scb.trace_history[trace_idx];
      if (trace.expected_latency !== expected_latency[31:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace latency=%0d got %0d",
            ctx, expected_latency, trace.expected_latency))
    endtask

    task automatic read_dut_hdl(string path,
                                output uvm_hdl_data_t value,
                                input string ctx);
      if (!uvm_hdl_read(path, value))
        `uvm_fatal("MTSP_HDL",
          $sformatf("%s could not read DUT HDL path %s", ctx, path))
    endtask

    task automatic read_dut_bit(string path,
                                output bit value,
                                input string ctx);
      uvm_hdl_data_t hdl_value;

      read_dut_hdl(path, hdl_value, ctx);
      value = hdl_value[0];
    endtask

    task automatic read_dut_uint(string path,
                                 output int unsigned value,
                                 input string ctx);
      uvm_hdl_data_t hdl_value;

      read_dut_hdl(path, hdl_value, ctx);
      value = hdl_value[31:0];
    endtask

    task automatic expect_payload_math_at(int unsigned history_idx,
                                          int unsigned asic_value,
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

      if (history_idx >= m_env.m_scb.history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected history index %0d, size=%0d",
            ctx, history_idx, m_env.m_scb.history.size()))
      hit_obs = m_env.m_scb.history[history_idx];
      if (hit_obs.empty)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected payload beat", ctx))

      expected_tcc8n  = tcc8n_value[12:0];
      expected_tcc1n6 = tcc1n6_value[2:0];
      expected_et1n6  = et1n6_value[8:0];

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

    task automatic expect_payload_error_at(int unsigned history_idx,
                                           bit expected_error,
                                           string ctx);
      mtsp_hit1_obs_item hit_obs;

      if (history_idx >= m_env.m_scb.history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected history index %0d, size=%0d",
            ctx, history_idx, m_env.m_scb.history.size()))
      hit_obs = m_env.m_scb.history[history_idx];
      if (hit_obs.empty)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected payload beat", ctx))
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

    task automatic expect_last_input_to_output_latency(int unsigned expected_cycles,
                                                       string ctx);
      mtsp_hit0_obs_item in_obs;
      mtsp_hit1_obs_item hit_obs;
      time               latency_ps;
      int unsigned       observed_cycles;

      in_obs  = find_last_hit0_obs();
      hit_obs = find_last_hit1_obs();
      if (in_obs == null || hit_obs == null)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected accepted hit0 and hit1 observations for latency check", ctx))
      if (hit_obs.time_ps <= in_obs.time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s non-positive input/output latency hit0=%0t hit1=%0t",
            ctx, in_obs.time_ps, hit_obs.time_ps))
      latency_ps      = hit_obs.time_ps - in_obs.time_ps;
      observed_cycles = int'(latency_ps / CLK_PERIOD_PS);
      if ((latency_ps % CLK_PERIOD_PS) != 0 || observed_cycles != expected_cycles)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected latency %0d cycles, got %0d cycles (%0t ps)",
            ctx, expected_cycles, observed_cycles, latency_ps))
      `uvm_info("MTSP_LATENCY",
        $sformatf("%s hit0=%0t hit1=%0t latency_cycles=%0d",
          ctx, in_obs.time_ps, hit_obs.time_ps, observed_cycles),
        UVM_LOW)
    endtask

    task automatic expect_last_trace_expected_latency(int unsigned expected_latency,
                                                      string ctx);
      mtsp_hit_trace_item trace;

      trace = find_last_trace();
      if (trace == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected paired trace metadata", ctx))
      if (trace.expected_latency != expected_latency[31:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace latency=%0d got %0d",
            ctx, expected_latency, trace.expected_latency))
    endtask

    task automatic expect_close_markers_since(int unsigned base_history_size,
                                              bit [3:0] expected_close_mask,
                                              int unsigned expected_payloads,
                                              string ctx);
      bit [3:0]    close_mask;
      int unsigned payload_count;

      close_mask    = '0;
      payload_count = 0;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (!obs.empty) begin
          payload_count++;
        end else if (obs.eop) begin
          close_mask[int'(obs.channel[1:0])] = 1'b1;
        end
      end
      if (payload_count != expected_payloads)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payloads after history base, got %0d",
            ctx, expected_payloads, payload_count))
      if (close_mask !== expected_close_mask)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected close mask=%b got %b",
            ctx, expected_close_mask, close_mask))
    endtask

    task automatic expect_output_flags_at(int unsigned history_idx,
                                          bit expected_sop,
                                          bit expected_eop,
                                          bit expected_empty,
                                          int unsigned expected_route,
                                          string ctx);
      mtsp_hit1_obs_item hit_obs;

      if (history_idx >= m_env.m_scb.history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected history index %0d, size=%0d",
            ctx, history_idx, m_env.m_scb.history.size()))
      hit_obs = m_env.m_scb.history[history_idx];
      if (hit_obs.sop !== expected_sop || hit_obs.eop !== expected_eop ||
          hit_obs.empty !== expected_empty || hit_obs.channel !== expected_route[3:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected sop/eop/empty/route=%0b/%0b/%0b/%0d, got %0b/%0b/%0b/%0d data=0x%010h",
            ctx, expected_sop, expected_eop, expected_empty,
            expected_route[3:0], hit_obs.sop, hit_obs.eop, hit_obs.empty,
            hit_obs.channel, hit_obs.data))
    endtask

    task automatic expect_close_markers_detail_since(int unsigned base_history_size,
                                                     bit [3:0] expected_close_mask,
                                                     bit [3:0] expected_sop_mask,
                                                     int unsigned expected_marker_count,
                                                     int unsigned expected_payloads,
                                                     string ctx);
      bit [3:0]    close_mask;
      bit [3:0]    sop_mask;
      int unsigned marker_count;
      int unsigned payload_count;

      close_mask    = '0;
      sop_mask      = '0;
      marker_count  = 0;
      payload_count = 0;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (obs.empty && obs.eop) begin
          marker_count++;
          close_mask[int'(obs.channel[1:0])] = 1'b1;
          if (obs.sop)
            sop_mask[int'(obs.channel[1:0])] = 1'b1;
        end else if (!obs.empty) begin
          payload_count++;
        end
      end
      if (payload_count != expected_payloads)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payloads after history base, got %0d",
            ctx, expected_payloads, payload_count))
      if (marker_count != expected_marker_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d empty close markers, got %0d",
            ctx, expected_marker_count, marker_count))
      if (close_mask !== expected_close_mask)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected close mask=%b got %b",
            ctx, expected_close_mask, close_mask))
      if (sop_mask !== expected_sop_mask)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected close SOP mask=%b got %b",
            ctx, expected_sop_mask, sop_mask))
    endtask

    task automatic configure_datapath_mode(bit bypass_lapse,
                                           bit derive_tot,
                                           bit delay_ts_field_use_t = 1'b1);
      csr_write(3'd0, datapath_mode_word(bypass_lapse, derive_tot,
        delay_ts_field_use_t));
      wait_cycles(2);
    endtask

    function automatic bit [31:0] datapath_mode_word(bit bypass_lapse,
                                                     bit derive_tot,
                                                     bit delay_ts_field_use_t);
      bit [31:0] csr_word;

      csr_word = 32'h0000_0001 | 32'h0000_0010;
      if (bypass_lapse)
        csr_word |= 32'h0000_0008;
      if (delay_ts_field_use_t)
        csr_word |= 32'h2000_0000;
      if (derive_tot)
        csr_word |= 32'h4000_0000;
      return csr_word;
    endfunction

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

    task automatic send_quotient_hit_and_capture(int unsigned quotient,
                                                 int unsigned remainder,
                                                 int unsigned asic_value,
                                                 int unsigned channel_value,
                                                 int unsigned tfine_value,
                                                 output int signed observed_delta,
                                                 input string ctx);
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      mtsp_hit_trace_item trace;

      lookup_raw_for_quotient(quotient, remainder, raw_value, ctx);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(asic_value, channel_value, raw_value, raw_value, 1'b0,
        1'b1, 1'b0, '0, 1'b1, tfine_value);
      wait_for_beat_count(base_beats + 1, 128, ctx);
      wait_for_trace_count(base_traces + 1, 128, ctx);
      expect_last_payload_math(asic_value, channel_value, tfine_value,
        quotient, remainder, 9'd0, ctx);

      trace = find_last_trace();
      if (trace == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s missing normal/debug trace", ctx))
      observed_delta = trace.debug_delta;
      expect_last_trace_pair(ctx);
    endtask

    task automatic send_dual_quotient_hit_and_expect(int unsigned t_quotient,
                                                     int unsigned t_remainder,
                                                     int unsigned e_quotient,
                                                     int unsigned e_remainder,
                                                     int unsigned asic_value,
                                                     int unsigned channel_value,
                                                     bit eflag_value,
                                                     int unsigned tfine_value,
                                                     int unsigned et1n6_value,
                                                     bit sop_value,
                                                     string ctx);
      int unsigned t_raw_value;
      int unsigned e_raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      lookup_raw_for_quotient(t_quotient, t_remainder, t_raw_value,
        $sformatf("%s T symbol", ctx));
      lookup_raw_for_quotient(e_quotient, e_remainder, e_raw_value,
        $sformatf("%s E symbol", ctx));

      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(asic_value, channel_value, t_raw_value, e_raw_value,
        eflag_value, sop_value, 1'b0, '0, 1'b1, tfine_value);
      wait_for_beat_count(base_beats + 1, 128, ctx);
      wait_for_trace_count(base_traces + 1, 128, ctx);
      expect_last_payload_math(asic_value, channel_value, tfine_value,
        t_quotient, t_remainder, et1n6_value, ctx);
      expect_last_trace_pair(ctx);
    endtask

    task automatic send_smoke_hit_and_expect_et(int unsigned tcc_raw_value,
                                                int unsigned ecc_raw_value,
                                                bit eflag_value,
                                                int unsigned expected_et,
                                                string ctx);
      int unsigned base_beats;
      int unsigned base_traces;
      mtsp_hit1_obs_item hit_obs;

      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 1, tcc_raw_value, ecc_raw_value, eflag_value,
        1'b1, 1'b0, '0, 1'b1, 5'd0);
      wait_for_beat_count(base_beats + 1, 128, ctx);
      wait_for_trace_count(base_traces + 1, 128, ctx);
      hit_obs = find_last_hit1_obs();
      if (hit_obs == null)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected smoke payload", ctx))
      if (hit_obs.data[8:0] !== expected_et[8:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected smoke ET_1N6=%0d got %0d data=0x%010h",
            ctx, expected_et[8:0], hit_obs.data[8:0], hit_obs.data))
      expect_last_trace_pair(ctx);
    endtask

    task automatic calibrate_next_output_arrival(output int signed predicted_arrival,
                                                 input string ctx);
      int signed first_arrival;
      int signed second_arrival;
      int signed spacing;

      send_quotient_hit_and_capture(0, 0, 2, 0, 0, first_arrival,
        $sformatf("%s calibration hit 0", ctx));
      send_quotient_hit_and_capture(0, 0, 2, 0, 1, second_arrival,
        $sformatf("%s calibration hit 1", ctx));

      spacing = second_arrival - first_arrival;
      if (spacing <= 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected positive calibration spacing, first=%0d second=%0d",
            ctx, first_arrival, second_arrival))
      predicted_arrival = second_arrival + spacing;
      `uvm_info("MTSP_TRACE",
        $sformatf("%s calibrated next arrival=%0d from first=%0d second=%0d spacing=%0d",
          ctx, predicted_arrival, first_arrival, second_arrival, spacing),
        UVM_LOW)
    endtask

    task automatic send_hit_for_debug_delta(int signed target_delta,
                                            bit expected_error,
                                            string ctx);
      int signed   predicted_arrival;
      int signed   target_quotient_signed;
      int unsigned target_quotient;
      int signed   observed_delta;

      calibrate_next_output_arrival(predicted_arrival,
        $sformatf("%s calibration", ctx));
      target_quotient_signed = predicted_arrival - target_delta;
      if (target_quotient_signed < 0 || target_quotient_signed > 6553)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s target quotient %0d is outside ROM-backed range for target_delta=%0d predicted_arrival=%0d",
            ctx, target_quotient_signed, target_delta, predicted_arrival))
      target_quotient = target_quotient_signed;
      send_quotient_hit_and_capture(target_quotient, 0, 2, 0, 5'd26,
        observed_delta, ctx);
      expect_last_trace_delta(target_delta, target_delta, expected_error, ctx);
    endtask

    task automatic send_route_lane_hit_and_expect(int unsigned route_lane,
                                                  int unsigned payload_channel,
                                                  bit expected_sop,
                                                  string ctx,
                                                  bit input_eop = 1'b0);
      int unsigned tcc_raw_value;
      int unsigned tcc8n_value;
      int unsigned base_beats;
      int unsigned base_traces;

      case (route_lane)
        0: tcc8n_value = 0;
        1: tcc8n_value = 16;
        2: tcc8n_value = 32;
        3: tcc8n_value = 48;
        default:
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s unsupported route lane %0d", ctx, route_lane))
      endcase

      lookup_raw_for_quotient(tcc8n_value, 0, tcc_raw_value, ctx);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, payload_channel, tcc_raw_value, tcc_raw_value, 1'b0,
        1'b1, input_eop, '0, 1'b1, payload_channel[4:0]);
      wait_for_beat_count(base_beats + 1, 128, ctx);
      wait_for_trace_count(base_traces + 1, 128, ctx);
      expect_last_payload_math(2, payload_channel, payload_channel,
        tcc8n_value, 3'd0, 9'd0, ctx);
      expect_last_output_flags(expected_sop, 1'b0, 1'b0, route_lane, ctx);
      expect_last_trace_pair(ctx);
    endtask

    task automatic send_decoded_hit_and_expect_math(int unsigned t_quotient,
                                                    int unsigned t_remainder,
                                                    int unsigned e_quotient,
                                                    int unsigned e_remainder,
                                                    int unsigned asic_value,
                                                    int unsigned channel_value,
                                                    bit eflag_value,
                                                    int unsigned tfine_value,
                                                    int unsigned expected_tcc8n,
                                                    int unsigned expected_tcc1n6,
                                                    int unsigned expected_et1n6,
                                                    bit sop_value,
                                                    string ctx);
      int unsigned t_raw_value;
      int unsigned e_raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      lookup_raw_for_quotient(t_quotient, t_remainder, t_raw_value,
        $sformatf("%s T decoded symbol", ctx));
      lookup_raw_for_quotient(e_quotient, e_remainder, e_raw_value,
        $sformatf("%s E decoded symbol", ctx));

      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(asic_value, channel_value, t_raw_value, e_raw_value,
        eflag_value, sop_value, 1'b0, '0, 1'b1, tfine_value);
      wait_for_beat_count(base_beats + 1, 256, ctx);
      wait_for_trace_count(base_traces + 1, 256, ctx);
      expect_last_payload_math(asic_value, channel_value, tfine_value,
        expected_tcc8n, expected_tcc1n6, expected_et1n6, ctx);
      expect_last_trace_pair(ctx);
    endtask

    task automatic expect_wrap_burst_classes_since(int unsigned base_history_size,
                                                   int unsigned expected_count,
                                                   int unsigned pre_q,
                                                   int unsigned pre_r,
                                                   int unsigned pulse_q,
                                                   int unsigned pulse_r,
                                                   int unsigned post_q,
                                                   int unsigned post_r,
                                                   int unsigned min_pulse_count,
                                                   int unsigned max_pulse_count,
                                                   string ctx);
      int unsigned pre_count;
      int unsigned pulse_count;
      int unsigned post_count;
      int unsigned other_count;

      pre_count   = 0;
      pulse_count = 0;
      post_count  = 0;
      other_count = 0;

      if (m_env.m_scb.history.size() < base_history_size + expected_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d burst outputs from history base %0d, got size=%0d",
            ctx, expected_count, base_history_size, m_env.m_scb.history.size()))

      for (int idx = 0; idx < expected_count; idx++) begin
        mtsp_hit1_obs_item obs;
        bit [12:0] q;
        bit [2:0]  r;

        obs = m_env.m_scb.history[base_history_size + idx];
        if (obs.empty)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s burst idx=%0d unexpectedly empty", ctx, idx))
        q = obs.data[29:17];
        r = obs.data[16:14];
        if (q === pre_q[12:0] && r === pre_r[2:0]) begin
          pre_count++;
        end else if (q === pulse_q[12:0] && r === pulse_r[2:0]) begin
          pulse_count++;
        end else if (q === post_q[12:0] && r === post_r[2:0]) begin
          post_count++;
        end else begin
          other_count++;
          `uvm_info("MTSP_WRAP",
            $sformatf("%s burst idx=%0d unmatched q/r=%0d/%0d data=0x%010h",
              ctx, idx, q, r, obs.data),
            UVM_LOW)
        end
      end

      if (pulse_count < min_pulse_count || pulse_count > max_pulse_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected pulse class count in [%0d,%0d], got %0d (pre=%0d post=%0d other=%0d)",
            ctx, min_pulse_count, max_pulse_count, pulse_count,
            pre_count, post_count, other_count))
      if (pre_count == 0 || post_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected both pre-wrap and post-wrap classes, got pre=%0d post=%0d pulse=%0d other=%0d",
            ctx, pre_count, post_count, pulse_count, other_count))
      if (other_count != 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s saw %0d outputs outside the expected wrap classes",
            ctx, other_count))
    endtask

    task automatic wait_inside_one_wrap_lookback(string ctx);
      // With default generics, one local MuTRiG wrap occurs after about 6554
      // clocks and the overflow lookback remains active for 2000 more clocks.
      wait_cycles(6600);
    endtask

    function automatic int unsigned overflow_decoded_value(int unsigned quotient,
                                                           int unsigned remainder);
      return (quotient * 5) + remainder;
    endfunction

    function automatic bit overflow_adjust_eligible(int unsigned quotient,
                                                    int unsigned remainder);
      return overflow_decoded_value(quotient, remainder) >
             MTSP_OVERFLOW_PADDING_UPPER_1N6;
    endfunction

    function automatic int unsigned overflow_expected_decoded(int unsigned wrap_count,
                                                              int unsigned quotient,
                                                              int unsigned remainder,
                                                              bit adjust);
      int unsigned decoded_value;
      int unsigned base_value;

      decoded_value = overflow_decoded_value(quotient, remainder);
      base_value    = wrap_count * MTSP_OVERFLOW_TIME_1N6;
      if (adjust)
        return decoded_value + base_value - MTSP_OVERFLOW_TIME_1N6;
      return decoded_value + base_value;
    endfunction

    function automatic int unsigned expected_et_from_decoded(bit derive_tot,
                                                             bit eflag_value,
                                                             int unsigned t_decoded,
                                                             int unsigned e_decoded);
      int unsigned delta;

      if (!derive_tot || !eflag_value || e_decoded < t_decoded)
        return 0;
      delta = e_decoded - t_decoded;
      if (delta > 511)
        return 511;
      return delta;
    endfunction

    task automatic wait_for_overflow_lookback_at_count(int unsigned wrap_count,
                                                       int unsigned max_cycles,
                                                       string ctx);
      int unsigned observed_wraps;
      int unsigned lookback_count;
      bit          will_happen;

      repeat (max_cycles) begin
        read_dut_uint("/tb_top/dut/counter_ov_cnt", observed_wraps,
          $sformatf("%s overflow-count sample", ctx));
        read_dut_uint("/tb_top/dut/fpga_overflow_lookback_cnt", lookback_count,
          $sformatf("%s overflow-lookback sample", ctx));
        read_dut_bit("/tb_top/dut/fpga_overflow_will_happen", will_happen,
          $sformatf("%s overflow-will-happen sample", ctx));
        if (observed_wraps >= wrap_count &&
            (lookback_count != 0 || will_happen))
          return;
        @(posedge ctrl_vif.clk);
      end

      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for overflow wrap_count=%0d with active lookback",
          ctx, wrap_count))
    endtask

    task automatic send_overflow_hit_and_expect(int unsigned wrap_count,
                                                int unsigned t_quotient,
                                                int unsigned t_remainder,
                                                int unsigned e_quotient,
                                                int unsigned e_remainder,
                                                bit derive_tot,
                                                bit bypass_lapse,
                                                bit eflag_value,
                                                int unsigned asic_value,
                                                int unsigned channel_value,
                                                int unsigned tfine_value,
                                                bit sop_value,
                                                bit check_error,
                                                bit expected_error,
                                                string ctx);
      int unsigned t_raw_value;
      int unsigned e_raw_value;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned expected_t_decoded;
      int unsigned expected_e_decoded;
      int unsigned expected_t_q;
      int unsigned expected_t_r;
      int unsigned expected_et;
      bit          t_adjust;
      bit          e_adjust;

      lookup_raw_for_quotient(t_quotient, t_remainder, t_raw_value,
        $sformatf("%s T overflow symbol", ctx));
      lookup_raw_for_quotient(e_quotient, e_remainder, e_raw_value,
        $sformatf("%s E overflow symbol", ctx));

      t_adjust = (!bypass_lapse) &&
                 overflow_adjust_eligible(t_quotient, t_remainder);
      e_adjust = (!bypass_lapse) &&
                 overflow_adjust_eligible(e_quotient, e_remainder);
      if (bypass_lapse) begin
        expected_t_decoded = overflow_decoded_value(t_quotient, t_remainder);
        expected_e_decoded = overflow_decoded_value(e_quotient, e_remainder);
      end else begin
        expected_t_decoded = overflow_expected_decoded(wrap_count, t_quotient,
          t_remainder, t_adjust);
        expected_e_decoded = overflow_expected_decoded(wrap_count, e_quotient,
          e_remainder, e_adjust);
      end
      expected_t_q = expected_t_decoded / 5;
      expected_t_r = expected_t_decoded % 5;
      expected_et  = expected_et_from_decoded(derive_tot, eflag_value,
        expected_t_decoded, expected_e_decoded);

      base_inputs  = m_env.m_scb.hit0_history.size();
      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();
      send_hit_beat(asic_value, channel_value, t_raw_value, e_raw_value,
        eflag_value, sop_value, 1'b0, '0, 1'b1, tfine_value);
      wait_for_input_count(base_inputs + 1, 128, ctx);
      wait_for_beat_count(base_beats + 1, 512, ctx);
      wait_for_trace_count(base_traces + 1, 512, ctx);
      expect_payload_math_at(base_history, asic_value, channel_value,
        tfine_value, expected_t_q, expected_t_r, expected_et, ctx);
      expect_trace_pair_at(base_traces, ctx);
      if (check_error)
        expect_trace_error_at(base_traces, expected_error, ctx);
      else
        expect_trace_math_self_consistent_at(base_traces, ctx);
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

    task automatic wait_for_debug_burst_count(int unsigned expected_count,
                                              int unsigned max_cycles,
                                              string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.debug_burst_count >= expected_count)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for debug_burst_count=%0d, got %0d",
          ctx, expected_count, m_env.m_scb.debug_burst_count))
    endtask

    task automatic expect_debug_valids_low(string ctx);
      if (dbg_vif.debug_ts_valid || dbg_vif.debug_burst_valid || dbg_vif.ts_delta_valid)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug valids low, got debug_ts=%0b debug_burst=%0b ts_delta=%0b",
            ctx, dbg_vif.debug_ts_valid, dbg_vif.debug_burst_valid,
            dbg_vif.ts_delta_valid))
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

    task automatic expect_last_ts_delta_range(int signed min_delta,
                                              int signed max_delta,
                                              string ctx);
      mtsp_dbg_obs_item obs;
      int signed         delta;

      if (m_env.m_scb.ts_delta_history.size() == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected a ts_delta observation", ctx))
      obs   = m_env.m_scb.ts_delta_history[m_env.m_scb.ts_delta_history.size() - 1];
      delta = m_env.m_scb.signed16(obs.data);
      if (delta < min_delta || delta > max_delta)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected ts_delta in [%0d,%0d], got %0d (0x%04h)",
            ctx, min_delta, max_delta, delta, obs.data))
    endtask

    task automatic expect_last_debug_burst_arrival_min(int unsigned min_arrival_hi,
                                                       string ctx);
      mtsp_dbg_obs_item obs;
      int unsigned       arrival_hi;

      if (m_env.m_scb.debug_burst_history.size() == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected a debug_burst observation", ctx))
      obs        = m_env.m_scb.debug_burst_history[m_env.m_scb.debug_burst_history.size() - 1];
      arrival_hi = obs.data[7:0];
      if (arrival_hi < min_arrival_hi)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug_burst arrival high byte >= %0d, got %0d (0x%04h)",
            ctx, min_arrival_hi, arrival_hi, obs.data))
    endtask

    task automatic expect_last_debug_burst_timestamp_hi(bit [7:0] expected_ts_hi,
                                                        string ctx);
      mtsp_dbg_obs_item obs;
      bit [7:0]         timestamp_hi;

      if (m_env.m_scb.debug_burst_history.size() == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected a debug_burst observation", ctx))
      obs          = m_env.m_scb.debug_burst_history[m_env.m_scb.debug_burst_history.size() - 1];
      timestamp_hi = obs.data[15:8];
      if (timestamp_hi !== expected_ts_hi)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug_burst timestamp high byte 0x%02h, got 0x%02h (data=0x%04h)",
            ctx, expected_ts_hi, timestamp_hi, obs.data))
    endtask

    task automatic send_two_quotient_hits_and_expect_delta(int unsigned first_quotient,
                                                           int unsigned second_quotient,
                                                           int signed expected_delta,
                                                           string ctx);
      int signed   observed_delta;
      int unsigned base_ts_delta;

      base_ts_delta = m_env.m_scb.ts_delta_count;
      send_quotient_hit_and_capture(first_quotient, 0, 2, 0, 5'd9,
        observed_delta, $sformatf("%s first hit", ctx));
      send_quotient_hit_and_capture(second_quotient, 0, 2, 0, 5'd10,
        observed_delta, $sformatf("%s second hit", ctx));
      wait_for_ts_delta_count(base_ts_delta + 2, 64, ctx);
      expect_last_ts_delta_range(expected_delta, expected_delta, ctx);
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

    task automatic expect_hit0_spacing(int unsigned start_index,
                                       int unsigned count,
                                       int unsigned expected_cycles,
                                       string ctx);
      time         delta_ps;
      int unsigned observed_cycles;

      if (count < 2)
        return;
      if (m_env.m_scb.hit0_history.size() < start_index + count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d hit0 observations from index %0d, got %0d",
            ctx, count, start_index, m_env.m_scb.hit0_history.size()))
      for (int idx = 1; idx < count; idx++) begin
        delta_ps = m_env.m_scb.hit0_history[start_index + idx].time_ps -
                   m_env.m_scb.hit0_history[start_index + idx - 1].time_ps;
        observed_cycles = int'(delta_ps / CLK_PERIOD_PS);
        if ((delta_ps % CLK_PERIOD_PS) != 0 || observed_cycles != expected_cycles)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s expected hit0 spacing %0d cycles at local idx=%0d, got %0d cycles (%0t ps)",
              ctx, expected_cycles, idx, observed_cycles, delta_ps))
      end
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

    task automatic do_corner_001_reset_release_with_ctrl_valid();
      int unsigned base_beats;
      bit [31:0]   csr_word;

      rst_vif.rst <= 1'b1;
      wait_cycles(2);
      fork
        pulse_ctrl(CTRL_RUNNING, "RUNNING_at_reset_release");
        begin
          @(posedge rst_vif.clk);
          rst_vif.rst <= 1'b0;
        end
      join
      wait_cycles(3);
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s reset-release control pulse must not enter RUNNING, csr0=0x%08h",
            case_id, csr_word))
      expect_hit0_ready(1'b0, $sformatf("%s reset ignored first command", case_id));

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count,
        16, $sformatf("%s no stale RUNNING after reset", case_id));

      send_ctrl(CTRL_RUNNING, "RUNNING_after_reset_release");
      wait_for_running_status(64, $sformatf("%s legal command after reset", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s legal command ready", case_id));
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s first legal post-reset hit", case_id));
      expect_last_trace_pair($sformatf("%s post-reset trace", case_id));
    endtask

    task automatic do_corner_002_running_and_first_hit_same_cycle();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      expect_hit0_ready(1'b0, $sformatf("%s pre-start ready", case_id));
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      fork
        pulse_ctrl(CTRL_RUNNING, "RUNNING_same_cycle_hit");
        send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      join
      wait_cycles(4);
      if (m_env.m_scb.input_accept_count != base_inputs)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s same-cycle first hit must not be accepted before RUNNING ready rises",
            case_id))
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count,
        16, $sformatf("%s same-cycle first hit no output", case_id));

      wait_for_running_status(64, $sformatf("%s RUNNING status after start edge", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s ready after start edge", case_id));
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s first accepted hit one cycle later", case_id));
      expect_last_trace_pair($sformatf("%s accepted post-start trace", case_id));
    endtask

    task automatic do_corner_003_terminate_on_final_eop_cycle();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      fork
        pulse_ctrl(CTRL_TERMINATING, "TERMINATING_same_cycle_eop");
        send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b1);
      join
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s final EOP payload trace", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s final EOP close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_004_idle_on_output_valid_cycle();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_cycles(9);
      pulse_ctrl(CTRL_IDLE, "IDLE_on_output_valid_cycle");
      wait_for_beat_count(base_beats + 1, 32,
        $sformatf("%s output survives coincident IDLE", case_id));
      expect_last_trace_pair($sformatf("%s coincident IDLE output trace", case_id));
      wait_cycles(4);
      expect_hit0_ready(1'b0, $sformatf("%s IDLE after output", case_id));
    endtask

    task automatic do_corner_005_prepare_then_immediate_idle();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      send_ctrl(CTRL_IDLE, "IDLE_after_prepare");
      wait_cycles(4);
      expect_hit0_ready(1'b0, $sformatf("%s ready low after prepare abort", case_id));
      expect_total_count(48'd0, $sformatf("%s counters clean after prepare abort", case_id));
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, '0, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count,
        24, $sformatf("%s prepare abort output quiet", case_id));
    endtask

    task automatic do_corner_006_sync_then_immediate_running();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING_immediate_after_sync");
      wait_for_running_status(64, $sformatf("%s immediate running status", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s immediate running ready", case_id));
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s post-sync hit", case_id));
      expect_total_count(48'd1, $sformatf("%s post-sync count", case_id));
      expect_last_trace_pair($sformatf("%s post-sync trace", case_id));
    endtask

    task automatic do_corner_007_back_to_back_running_words();
      int unsigned base_beats;

      wait_for_reset_release();
      send_ctrl(CTRL_RUNNING, "RUNNING_first");
      send_ctrl(CTRL_RUNNING, "RUNNING_second");
      wait_for_running_status(64, $sformatf("%s repeated running status", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s repeated running ready", case_id));
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s repeated running hit", case_id));
      expect_total_count(48'd1, $sformatf("%s repeated running counter", case_id));
      expect_last_trace_pair($sformatf("%s repeated running trace", case_id));
    endtask

    task automatic do_corner_008_back_to_back_terminating_words();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING_first");
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING_second");
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s repeated terminate close markers", case_id));
      wait_cycles(16);
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1111, 4, 0,
        $sformatf("%s no duplicate close markers", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s repeated terminate ready restore", case_id));
    endtask

    task automatic do_corner_009_illegal_ctrl_word_while_active();
      int unsigned base_beats;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_RUNNING | CTRL_TERMINATING, "ILLEGAL_MULTI_HOT");
      wait_cycles(4);
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s illegal active control word must leave processor RUNNING, csr0=0x%08h",
            case_id, csr_word))
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s illegal word input ready", case_id));
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s legal hit after illegal word", case_id));
      expect_last_trace_pair($sformatf("%s illegal word containment trace", case_id));
    endtask

    task automatic do_corner_010_stale_ctrl_data_with_valid_gap();
      int unsigned base_beats;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      run_start();
      drive_ctrl_data_gap(CTRL_IDLE, "IDLE_data_valid_gap");
      wait_cycles(4);
      if (ctrl_vif.valid !== 1'b0 || ctrl_vif.data !== CTRL_IDLE)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected stale IDLE data with valid low, valid=%0b data=%09b",
            case_id, ctrl_vif.valid, ctrl_vif.data))
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s stale IDLE data with valid low must not abort RUNNING, csr0=0x%08h",
            case_id, csr_word))
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s hit after valid gap", case_id));
      expect_last_trace_pair($sformatf("%s valid gap trace", case_id));
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
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      base_empty_eops = m_env.m_scb.empty_eop_count;
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers before IDLE", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restored before IDLE", case_id));
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
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s empty close markers", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restored before IDLE", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
      send_ctrl(CTRL_IDLE, "IDLE");
      expect_hit0_ready(1'b0, case_id);
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

    task automatic do_std_081_route_lane0();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(0, 0, 1'b1, case_id);
    endtask

    task automatic do_std_082_route_lane1();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(1, 1, 1'b1, case_id);
    endtask

    task automatic do_std_083_route_lane2();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(2, 2, 1'b1, case_id);
    endtask

    task automatic do_std_084_route_lane3();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(3, 3, 1'b1, case_id);
    endtask

    task automatic do_std_085_error_low_in_range();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd2, observed_delta, case_id);
      expect_last_payload_error(1'b0, case_id);
      expect_last_trace_delta(1, 1999, 1'b0, case_id);
    endtask

    task automatic do_std_086_error_high_at_zero();
      int signed   predicted_arrival;
      int signed   observed_delta;
      int unsigned target_quotient;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      calibrate_next_output_arrival(predicted_arrival, case_id);
      if (predicted_arrival < 0 || predicted_arrival > 6553)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s calibrated quotient %0d is outside the ROM-backed range",
            case_id, predicted_arrival))
      target_quotient = predicted_arrival;
      send_quotient_hit_and_capture(target_quotient, 0, 2, 1, 5'd3,
        observed_delta, case_id);
      expect_last_payload_error(1'b1, case_id);
      expect_last_trace_delta(0, 0, 1'b1, case_id);
    endtask

    task automatic do_std_087_error_high_for_negative();
      int signed   predicted_arrival;
      int signed   observed_delta;
      int unsigned target_quotient;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      calibrate_next_output_arrival(predicted_arrival, case_id);
      if (predicted_arrival < 0 || predicted_arrival > 6537)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s calibrated quotient %0d leaves no room for ahead-of-arrival hit",
            case_id, predicted_arrival))
      target_quotient = predicted_arrival + 16;
      send_quotient_hit_and_capture(target_quotient, 0, 2, 2, 5'd4,
        observed_delta, case_id);
      expect_last_payload_error(1'b1, case_id);
      expect_last_trace_delta(-32768, -1, 1'b1, case_id);
    endtask

    task automatic do_std_088_error_high_at_or_above_limit();
      int signed   predicted_arrival;
      int signed   observed_delta;
      int unsigned target_quotient;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      wait_cycles(2);
      run_start();
      calibrate_next_output_arrival(predicted_arrival, case_id);
      if (predicted_arrival < 4 || predicted_arrival > 6553)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s calibrated quotient %0d cannot produce the expected-latency edge",
            case_id, predicted_arrival))
      target_quotient = predicted_arrival - 4;
      send_quotient_hit_and_capture(target_quotient, 0, 2, 3, 5'd5,
        observed_delta, case_id);
      expect_last_payload_error(1'b1, case_id);
      expect_last_trace_delta(4, 32767, 1'b1, case_id);
    endtask

    task automatic do_std_089_debug_ts_valid_alignment();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd6, observed_delta, case_id);
      expect_last_payload_error(1'b0, case_id);
      expect_last_trace_delta(1, 1999, 1'b0, case_id);
    endtask

    task automatic do_std_090_delay_field_changes_error_source();
      int unsigned t_raw;
      int unsigned e_raw;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      lookup_raw_for_quotient(0, 0, t_raw, $sformatf("%s T timestamp", case_id));
      lookup_raw_for_quotient(2000, 0, e_raw, $sformatf("%s E timestamp", case_id));

      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 4, t_raw, e_raw, 1'b1, 1'b1, 1'b0, '0, 1'b1, 5'd7);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s T-selected run", case_id));
      wait_for_trace_count(base_traces + 1, 128, $sformatf("%s T-selected run", case_id));
      expect_last_payload_math(2, 4, 5'd7, 13'd0, 3'd0, 9'd0,
        $sformatf("%s T-selected run", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s T-selected run", case_id));
      expect_last_trace_delta(1, 1999, 1'b0, $sformatf("%s T-selected run", case_id));

      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      configure_datapath_mode(1'b1, 1'b0, 1'b0);
      run_start();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 4, t_raw, e_raw, 1'b1, 1'b1, 1'b0, '0, 1'b1, 5'd8);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s E-selected run", case_id));
      wait_for_trace_count(base_traces + 1, 128, $sformatf("%s E-selected run", case_id));
      expect_last_payload_math(2, 4, 5'd8, 13'd0, 3'd0, 9'd0,
        $sformatf("%s E-selected run", case_id));
      expect_last_payload_error(1'b1, $sformatf("%s E-selected run", case_id));
      expect_last_trace_delta(-32768, -1, 1'b1, $sformatf("%s E-selected run", case_id));
    endtask

    task automatic do_std_091_debug_burst_only_running();
      int signed   observed_delta;
      int unsigned base_debug_burst;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_debug_burst = m_env.m_scb.debug_burst_count;

      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(8);
      if (m_env.m_scb.debug_burst_count != base_debug_burst)
        `uvm_fatal("MTSP_CASE", "IDLE must not emit debug_burst samples")

      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_cycles(32);
      if (m_env.m_scb.debug_burst_count != base_debug_burst)
        `uvm_fatal("MTSP_CASE", "RESET/SCLR flush traffic must not emit debug_burst samples")

      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, case_id);
      wait_for_hit0_ready(1'b1, 16, case_id);
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd11, observed_delta,
        $sformatf("%s RUNNING debug_burst hit", case_id));
      wait_for_debug_burst_count(base_debug_burst + 1, 64, case_id);
    endtask

    task automatic do_std_092_ts_delta_only_running();
      int signed   observed_delta;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_ts_delta = m_env.m_scb.ts_delta_count;

      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0, '0, 1'b0);
      wait_cycles(8);
      if (m_env.m_scb.ts_delta_count != base_ts_delta)
        `uvm_fatal("MTSP_CASE", "IDLE must not emit ts_delta samples")

      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(3);
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_cycles(32);
      if (m_env.m_scb.ts_delta_count != base_ts_delta)
        `uvm_fatal("MTSP_CASE", "RESET/SCLR flush traffic must not emit ts_delta samples")

      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, case_id);
      wait_for_hit0_ready(1'b1, 16, case_id);
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd12, observed_delta,
        $sformatf("%s RUNNING ts_delta hit", case_id));
      wait_for_ts_delta_count(base_ts_delta + 1, 64, case_id);
    endtask

    task automatic do_std_093_first_running_hit_warms_history();
      int signed   observed_delta;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_ts_delta = m_env.m_scb.ts_delta_count;
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd13, observed_delta, case_id);
      wait_for_ts_delta_count(base_ts_delta + 1, 64, case_id);
      expect_last_ts_delta_range(0, 0, case_id);
    endtask

    task automatic do_std_094_positive_timestamp_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(0, 20, 20, case_id);
    endtask

    task automatic do_std_095_negative_timestamp_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(20, 0, -20, case_id);
    endtask

    task automatic do_std_096_zero_timestamp_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(20, 20, 0, case_id);
    endtask

    task automatic do_std_097_positive_signmag_conversion();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(0, 25, 25, case_id);
    endtask

    task automatic do_std_098_negative_signmag_conversion();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(25, 0, -25, case_id);
    endtask

    task automatic do_std_099_arrival_delta_uses_gts();
      int signed   observed_delta;
      int unsigned base_ts_delta;
      int unsigned base_debug_burst;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      send_quotient_hit_and_capture(20, 0, 2, 0, 5'd14, observed_delta,
        $sformatf("%s first equal-timestamp hit", case_id));
      wait_cycles(80);
      send_quotient_hit_and_capture(20, 0, 2, 0, 5'd15, observed_delta,
        $sformatf("%s delayed equal-timestamp hit", case_id));
      wait_for_ts_delta_count(base_ts_delta + 2, 64, case_id);
      wait_for_debug_burst_count(base_debug_burst + 2, 64, case_id);
      expect_last_ts_delta_range(0, 0, case_id);
      expect_last_debug_burst_arrival_min(4, case_id);
    endtask

    task automatic do_std_100_debug_streams_clear_outside_running();
      int signed   observed_delta;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd16, observed_delta,
        $sformatf("%s first running hit", case_id));
      send_quotient_hit_and_capture(20, 0, 2, 0, 5'd17, observed_delta,
        $sformatf("%s second running hit", case_id));
      wait_for_ts_delta_count(2, 64, case_id);

      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      expect_debug_valids_low(case_id);
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      wait_cycles(16);
      expect_debug_valids_low(case_id);
      if (m_env.m_scb.debug_ts_count != base_debug_ts ||
          m_env.m_scb.debug_burst_count != base_debug_burst ||
          m_env.m_scb.ts_delta_count != base_ts_delta)
        `uvm_fatal("MTSP_CASE", "Debug streams must not advance after leaving RUNNING")
    endtask

    task automatic start_legacy_smoke_mode();
      wait_for_reset_release();
      csr_write(3'd0, 32'h4000_0001);
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, case_id);
      wait_for_hit0_ready(1'b1, 16, case_id);
      wait_cycles(1);
    endtask

    task automatic do_std_101_replay_smoke_positive_et();
      start_legacy_smoke_mode();
      send_smoke_hit_and_expect_et(15'h0003, 15'h000F, 1'b1, 9'd2, case_id);
    endtask

    task automatic do_std_102_replay_smoke_eflag_zero();
      start_legacy_smoke_mode();
      send_smoke_hit_and_expect_et(15'h0003, 15'h000F, 1'b0, 9'd0, case_id);
    endtask

    task automatic do_std_103_replay_smoke_clamp_vector();
      start_legacy_smoke_mode();
      send_smoke_hit_and_expect_et(15'h000F, 15'h0003, 1'b1, 9'd0,
        $sformatf("%s negative clamp", case_id));
      send_smoke_hit_and_expect_et(15'h0001, 15'h0000, 1'b1, 9'd511,
        $sformatf("%s saturation clamp", case_id));
    endtask

    task automatic do_std_104_discard_counter_matches_rejections();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s clean accepted", case_id));
      expect_last_trace_pair($sformatf("%s clean accepted", case_id));

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0, 3'b001);
      send_hit_beat(2, 2, 15'h0007, 15'h0007, 1'b0, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, case_id);
      expect_total_count(48'd3, case_id);
      expect_discard_count(32'd2, case_id);
    endtask

    task automatic do_std_105_total_counter_matches_all_valid();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s clean accepted", case_id));
      expect_last_trace_pair($sformatf("%s clean accepted", case_id));

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0, 3'b001);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, $sformatf("%s rejected hiterr", case_id));

      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT & ~32'h0000_0010);
      wait_cycles(2);
      send_hit_beat(2, 2, 15'h0007, 15'h0007, 1'b0, 1'b1, 1'b0, 3'b001);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s accepted hiterr", case_id));
      expect_last_trace_pair($sformatf("%s accepted hiterr", case_id));
      expect_total_count(48'd3, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_std_106_total_counter_hi_rollover();
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      seed_total_count_dv(48'h0000_ffff_ffff,
        $sformatf("%s seed low word at rollover edge", case_id));

      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s rollover hit output", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s rollover hit debug trace", case_id));
      expect_last_trace_pair($sformatf("%s rollover hit trace pair", case_id));
      expect_total_count(48'h0001_0000_0000,
        $sformatf("%s high word increment after low wrap", case_id));
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_107_soft_reset_clears_counters();
      do_std_017_soft_reset_self_clear();
    endtask

    task automatic do_std_108_sync_clears_counters();
      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s pre-sync traffic", case_id));
      expect_total_count(48'd1, $sformatf("%s pre-sync count", case_id));

      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(2);
      send_ctrl(CTRL_SYNC, "SYNC");
      wait_cycles(4);
      expect_total_count(48'd0, $sformatf("%s post-sync count", case_id));
      expect_discard_count(32'd0, $sformatf("%s post-sync discard", case_id));
    endtask

    task automatic do_std_109_running_status_bit_semantics();
      wait_for_reset_release();
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
        $sformatf("%s IDLE status", case_id));
      run_start();
      expect_csr_mask(3'd0, 32'h0000_0001, 32'h0000_0001,
        $sformatf("%s RUNNING status", case_id));
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(4);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
        $sformatf("%s post-IDLE status", case_id));
    endtask

    task automatic do_std_110_force_stop_persists_until_cleared();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0002);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0002, 32'h0000_0002,
        $sformatf("%s force_stop set", case_id));

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, $sformatf("%s force_stop blocked", case_id));
      expect_csr_mask(3'd0, 32'h0000_0002, 32'h0000_0002,
        $sformatf("%s force_stop persisted", case_id));

      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0002,
        $sformatf("%s force_stop cleared", case_id));
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, $sformatf("%s acceptance restored", case_id));
      expect_last_trace_pair($sformatf("%s acceptance restored", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_std_111_compile_rtl_default_div_pipeline();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 1, 2, 0, 5'd18, observed_delta, case_id);
      expect_last_input_to_output_latency(10, case_id);
    endtask

    task automatic do_std_112_compile_packaged_div_pipeline();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 1, 2, 0, 5'd19, observed_delta, case_id);
      expect_last_input_to_output_latency(8, case_id);
    endtask

    task automatic prove_enabled_window_bookkeeping(int unsigned inside_sideband,
                                                    int unsigned outside_sideband,
                                                    string ctx);
      int unsigned base_beats;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();

      base_beats        = m_env.m_scb.beat_count;
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_hit_beat(outside_sideband, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s outside-window open packet", ctx));
      expect_last_trace_pair($sformatf("%s outside-window payload", ctx));
      expect_last_payload_error(1'b0, $sformatf("%s outside-window payload", ctx));
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_ctrl_ready_low(4, $sformatf("%s outside-window terminate", ctx));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s outside-window close markers", ctx));
      wait_for_ctrl_ready_high(128, $sformatf("%s outside-window ready restore", ctx));
      expect_close_markers_since(base_history_size, 4'b1111, 1,
        $sformatf("%s outside-window drain", ctx));

      send_ctrl(CTRL_IDLE, "IDLE");
      run_start();

      base_beats        = m_env.m_scb.beat_count;
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_hit_beat(inside_sideband, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s inside-window open packet", ctx));
      expect_last_trace_pair($sformatf("%s inside-window first payload", ctx));
      expect_last_payload_error(1'b0, $sformatf("%s inside-window first payload", ctx));
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s inside-window tail ready", ctx));
      send_hit_beat(inside_sideband, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      wait_for_beat_count(base_beats + 2, 128,
        $sformatf("%s inside-window eop tail", ctx));
      expect_last_trace_pair($sformatf("%s inside-window eop payload", ctx));
      expect_last_payload_error(1'b0, $sformatf("%s inside-window eop payload", ctx));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s inside-window close markers", ctx));
      wait_for_ctrl_ready_high(128, $sformatf("%s inside-window ready restore", ctx));
      expect_close_markers_since(base_history_size, 4'b1111, 2,
        $sformatf("%s inside-window drain", ctx));
    endtask

    task automatic do_std_113_single_enabled_channel_window();
      prove_enabled_window_bookkeeping(0, 1, case_id);
    endtask

    task automatic do_std_114_upper_enabled_window();
      prove_enabled_window_bookkeeping(2, 1, case_id);
    endtask

    task automatic do_std_115_remapped_hiterr_bit();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, 3'b001);
      wait_for_beat_count(1, 128, $sformatf("%s old hiterr bit ignored", case_id));
      expect_last_trace_pair($sformatf("%s old hiterr bit ignored", case_id));
      expect_total_count(48'd1, $sformatf("%s old bit total", case_id));
      expect_discard_count(32'd0, $sformatf("%s old bit discard", case_id));

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b1, 1'b0, 3'b100);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count, m_env.m_scb.empty_eop_count,
        64, $sformatf("%s remapped hiterr discarded", case_id));
      expect_total_count(48'd2, $sformatf("%s remapped bit total", case_id));
      expect_discard_count(32'd1, $sformatf("%s remapped bit discard", case_id));
    endtask

    task automatic do_std_116_remapped_crcerr_still_inert();
      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, 3'b100);
      wait_for_beat_count(1, 128, case_id);
      expect_last_trace_pair(case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_117_remapped_frame_corrupt_still_inert();
      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, 3'b010);
      wait_for_beat_count(1, 128, case_id);
      expect_last_trace_pair(case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_118_changed_latency_generic_at_power_on();
      bit [31:0] csr_word;
      int signed observed_delta;

      wait_for_reset_release();
      csr_read(3'd2, csr_word);
      if (csr_word !== 32'd128)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected power-on expected_latency CSR=128 got %0d",
            case_id, csr_word))
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd20, observed_delta, case_id);
      expect_last_trace_expected_latency(128, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_std_119_bank_string_is_debug_only();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_quotient_hit_and_capture(0, 2, 2, 0, 5'd21, observed_delta, case_id);
      expect_last_payload_error(1'b0, case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_120_debug_zero_is_functionally_equivalent();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      lookup_raw_for_quotient(0, 3, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b0, '0, 1'b1, 5'd22);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_payload_math(2, 0, 22, 0, 3, 9'd0, case_id);
      expect_last_trace_pair(case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_std_121_preterminate_hit_still_drains();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b0, '0, 1'b1, 5'd23);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_payload_math(2, 0, 23, 0, 0, 9'd0, case_id);
      expect_last_trace_pair(case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_std_122_terminating_eop_and_hit_emit_final_boundary();
      do_std_077_terminating_input_eop_forwards_output_eop();
    endtask

    task automatic do_std_123_flushing_accepts_more_hits_today();
      int unsigned base_inputs;
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_hit0_ready(1'b1, 16, case_id);
      base_inputs = m_env.m_scb.input_accept_count;
      base_beats  = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      expect_last_trace_pair(case_id);
      if (m_env.m_scb.input_accept_count != base_inputs + 1)
        `uvm_fatal("MTSP_CASE", "FLUSHING must accept one clean tail hit before upstream endofrun")
    endtask

    task automatic do_std_124_flushing_quiet_without_hits();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, case_id);
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 64, case_id);
      if (ctrl_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE", "FLUSHING without upstream endofrun must keep ctrl ready low")
    endtask

    task automatic do_std_125_ctrl_ready_high_through_terminate();
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s terminate close markers", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_std_126_ctrl_ready_high_through_prepare_and_sync();
      wait_for_reset_release();
      pulse_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_for_ctrl_ready_low(4, $sformatf("%s RUN_PREPARE ready low", case_id));
      wait_for_ctrl_ready_high(16, $sformatf("%s RUN_PREPARE ready restore", case_id));
      pulse_ctrl(CTRL_SYNC, "SYNC");
      wait_for_ctrl_ready_low(4, $sformatf("%s SYNC ready low", case_id));
      wait_for_ctrl_ready_high(16, $sformatf("%s SYNC ready restore", case_id));
    endtask

    task automatic do_std_127_upgrade_case_stateful_ready_on_terminate();
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b1);
      wait_for_beat_count(1, 128, $sformatf("%s pre-terminate payload", case_id));
      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_cycles(8);
      if (ctrl_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE", "TERMINATING must hold ready low until upstream endofrun and local close markers")
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close marker drain", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_std_128_upgrade_case_terminal_boundary_without_extra_hits();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s empty close marker train", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
    endtask

    task automatic do_std_129_upgrade_case_idle_after_boundary_only();
      int unsigned base_empty_eops;
      time         idle_accept_time;

      wait_for_reset_release();
      run_start();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_ctrl_and_capture(CTRL_IDLE, "IDLE", idle_accept_time);
      if (m_env.m_scb.empty_eop_count < base_empty_eops + 4)
        `uvm_fatal("MTSP_CASE", "IDLE command must not be accepted before close markers complete")
      if (idle_accept_time < m_env.m_scb.last_eop_time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("IDLE accepted before terminal boundary: idle=%0t last_eop=%0t",
            idle_accept_time, m_env.m_scb.last_eop_time_ps))
    endtask

    task automatic do_std_130_full_standard_sequence_baseline();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_inputs;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      send_ctrl(CTRL_SYNC, "SYNC");
      send_ctrl(CTRL_RUNNING, "RUNNING");
      wait_for_running_status(64, case_id);
      wait_for_hit0_ready(1'b1, 16, case_id);
      wait_cycles(1);

      base_inputs = m_env.m_scb.input_accept_count;
      send_route_lane_hit_and_expect(0, 0, 1'b1,
        $sformatf("%s lane0 packet", case_id), 1'b1);
      send_route_lane_hit_and_expect(1, 1, 1'b1,
        $sformatf("%s lane1 packet", case_id), 1'b1);
      send_route_lane_hit_and_expect(2, 2, 1'b1,
        $sformatf("%s lane2 packet", case_id), 1'b1);
      wait_cycles(8);
      send_route_lane_hit_and_expect(3, 3, 1'b1,
        $sformatf("%s lane3 packet", case_id), 1'b1);
      if (m_env.m_scb.input_accept_count != base_inputs + 4)
        `uvm_fatal("MTSP_CASE", "Baseline sequence must have four monitored hit0 accepts")

      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close marker train", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
      send_ctrl(CTRL_IDLE, "IDLE");
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
        $sformatf("%s post-IDLE status", case_id));
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

    task automatic do_corner_012_expected_latency_one();
      int signed   predicted_arrival;
      int signed   observed_delta;
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      mtsp_hit_trace_item trace;

      wait_for_reset_release();
      csr_write(3'd2, 32'd1);
      expect_csr_mask(3'd2, 32'd1, 32'hffff_ffff, case_id);
      run_start();

      calibrate_next_output_arrival(predicted_arrival,
        $sformatf("%s threshold calibration", case_id));
      if (predicted_arrival <= 1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s cannot craft debug_delta=1 from predicted arrival %0d",
            case_id, predicted_arrival))

      lookup_raw_for_quotient(predicted_arrival - 1, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 3, raw_value, raw_value, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s equality-threshold hit", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s equality-threshold trace", case_id));
      expect_last_trace_delta(1, 1, 1'b1,
        $sformatf("%s expected_latency=1 strict upper equality", case_id));
      trace = find_last_trace();
      if (trace == null)
        `uvm_fatal("MTSP_CASE", "Missing equality-threshold trace after wait")
      observed_delta = trace.debug_delta;
      if (observed_delta !== 1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s internal sanity expected debug_delta=1 got %0d",
            case_id, observed_delta))
    endtask

    task automatic do_corner_013_expected_latency_large_16bit_value();
      int signed observed_delta;

      wait_for_reset_release();
      csr_write(3'd2, 32'h0000_ffff);
      expect_csr_mask(3'd2, 32'h0000_ffff, 32'hffff_ffff, case_id);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd13, observed_delta, case_id);
      expect_last_trace_expected_latency(32'h0000_ffff, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_014_expected_latency_all_ones();
      int signed observed_delta;

      wait_for_reset_release();
      csr_write(3'd2, 32'hffff_ffff);
      expect_csr_mask(3'd2, 32'hffff_ffff, 32'hffff_ffff, case_id);
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd14, observed_delta, case_id);
      expect_last_trace_expected_latency(32'hffff_ffff, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_015_reserved_opmode_bit28_only();
      int signed observed_delta;

      wait_for_reset_release();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h1000_0000);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h2000_0000, CSR_CTRL_MODE_MASK,
        $sformatf("%s reserved bit28 readback", case_id));
      run_start();
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd15, observed_delta, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_016_multi_field_control_write();
      wait_for_reset_release();
      csr_write(3'd0, 32'h6000_001f);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h6000_001a, 32'h6000_001e,
        $sformatf("%s packed control field settle", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h2000_0010, 32'h6000_001e,
        $sformatf("%s restored default control fields", case_id));
    endtask

    task automatic do_corner_017_read_during_soft_reset_window();
      bit [31:0] csr_word;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 1, 'h0003, 'h000f, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s pre-reset payload", case_id));
      expect_total_count(48'd1, $sformatf("%s pre-reset count", case_id));

      csr_write_then_read_no_idle(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004,
        3'd0, csr_word);
      if (csr_word[2] !== 1'b1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s no-idle soft_reset read expected bit2=1 got csr0=0x%08h",
            case_id, csr_word))
      expect_total_count(48'd0, $sformatf("%s immediate counter clear", case_id));

      wait_cycles(2);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004,
        $sformatf("%s soft_reset self-clear", case_id));
      expect_discard_count(32'd0, case_id);
      expect_total_count(48'd0, case_id);
    endtask

    task automatic do_corner_018_counter_read_on_low_word_rollover();
      bit [31:0]   hi_raw_before;
      bit [31:0]   hi_raw_after;
      bit [31:0]   lo_after;
      bit [15:0]   hi_before;
      bit [15:0]   hi_after;
      bit [47:0]   recovered_total;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      seed_total_count_dv(48'h0000_ffff_ffff,
        $sformatf("%s seed low word at rollover edge", case_id));

      csr_read(3'd3, hi_raw_before);
      hi_before = hi_raw_before[15:0];

      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s rollover hit output", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s rollover hit debug trace", case_id));

      csr_read(3'd4, lo_after);
      csr_read(3'd3, hi_raw_after);
      hi_after = hi_raw_after[15:0];

      if (hi_before !== 16'h0000 || lo_after !== 32'h0000_0000 ||
          hi_after !== 16'h0001)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s rollover read edge mismatch hi_before=0x%04h lo_after=0x%08h hi_after=0x%04h",
            case_id, hi_before, lo_after, hi_after))

      recovered_total = (hi_before == hi_after) ?
        {hi_before, lo_after} : {hi_after, lo_after};
      if (recovered_total !== 48'h0001_0000_0000)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s coherent high-low-high recovery expected 0x000100000000 got 0x%012h",
            case_id, recovered_total))

      expect_last_trace_pair($sformatf("%s rollover hit trace pair", case_id));
      expect_total_count(recovered_total,
        $sformatf("%s final coherent counter read", case_id));
    endtask

    task automatic do_corner_019_csr_access_in_flushing();
      bit [31:0]   csr_word;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      csr_write(3'd2, 32'd321);
      csr_read(3'd2, csr_word);
      if (csr_word !== 32'd321)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected flushing CSR latency readback 321 got %0d",
            case_id, csr_word))
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s FLUSHING must not report RUNNING status, csr0=0x%08h",
            case_id, csr_word))

      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers after flushing CSR access", case_id));
      wait_for_ctrl_ready_high(128,
        $sformatf("%s ready restore after flushing CSR access", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
    endtask

    task automatic do_corner_020_polling_unsupported_addr7();
      bit [31:0]   csr_word;
      int unsigned base_csr_count;

      wait_for_reset_release();
      base_csr_count = m_env.m_scb.csr_access_count;
      for (int idx = 0; idx < 8; idx++) begin
        csr_read(3'd7, csr_word);
        if (csr_word !== 32'd0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s unsupported addr7 poll idx=%0d expected zero got 0x%08h",
              case_id, idx, csr_word))
      end
      if (m_env.m_scb.csr_access_count < base_csr_count + 8)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected at least eight CSR monitor observations, got %0d from base %0d",
            case_id, m_env.m_scb.csr_access_count, base_csr_count))
      expect_total_count(48'd0, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_corner_021_plain_hit_no_markers();
      int unsigned       raw_value;
      int unsigned       base_beats;
      int unsigned       base_traces;
      int unsigned       base_eops;
      int unsigned       base_inputs;
      mtsp_hit0_obs_item in_obs;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      base_eops   = m_env.m_scb.eop_count;
      base_inputs = m_env.m_scb.hit0_history.size();

      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b0, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      in_obs = m_env.m_scb.hit0_history[base_inputs];
      if (in_obs.sop !== 1'b0 || in_obs.eop !== 1'b0)
        `uvm_fatal("MTSP_CASE", "Plain hit input unexpectedly carried SOP/EOP")
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);
      if (m_env.m_scb.eop_count != base_eops)
        `uvm_fatal("MTSP_CASE", "Plain hit must not create an output EOP marker")
    endtask

    task automatic do_corner_022_sop_only_beat();
      int unsigned       raw_value;
      int unsigned       base_beats;
      int unsigned       base_traces;
      int unsigned       base_eops;
      int unsigned       base_inputs;
      mtsp_hit0_obs_item in_obs;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      base_eops   = m_env.m_scb.eop_count;
      base_inputs = m_env.m_scb.hit0_history.size();

      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      in_obs = m_env.m_scb.hit0_history[base_inputs];
      if (in_obs.sop !== 1'b1 || in_obs.eop !== 1'b0)
        `uvm_fatal("MTSP_CASE", "SOP-only input marker mismatch")
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);
      if (m_env.m_scb.eop_count != base_eops)
        `uvm_fatal("MTSP_CASE", "SOP-only hit must not create an output EOP marker")
    endtask

    task automatic do_corner_023_eop_only_beat();
      int unsigned raw_open;
      int unsigned raw_close;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_open, case_id);
      lookup_raw_for_quotient(1, 0, raw_close, case_id);
      base_beats        = m_env.m_scb.beat_count;
      base_traces       = m_env.m_scb.trace_history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();

      send_hit_beat(2, 0, raw_open, raw_open, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s opening beat", case_id));
      send_hit_beat(2, 1, raw_close, raw_close, 1'b0, 1'b0, 1'b1);
      wait_for_beat_count(base_beats + 2, 128,
        $sformatf("%s eop-only closing beat", case_id));
      wait_for_trace_count(base_traces + 2, 128, case_id);
      expect_last_output_flags(1'b0, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers after eop-only close", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 2, case_id);
    endtask

    task automatic do_corner_024_single_beat_packet();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats        = m_env.m_scb.beat_count;
      base_traces       = m_env.m_scb.trace_history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();

      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b1);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers after single-beat packet", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
    endtask

    task automatic do_corner_025_zero_gap_hits();
      int unsigned raw_value[3];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      for (int idx = 0; idx < 3; idx++)
        lookup_raw_for_quotient(idx, 0, raw_value[idx], case_id);

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_traces       = m_env.m_scb.trace_history.size();
      base_history_size = m_env.m_scb.history.size();

      for (int idx = 0; idx < 3; idx++)
        send_hit_beat(2, idx, raw_value[idx], raw_value[idx], 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx);

      wait_for_beat_count(base_beats + 3, 128, case_id);
      wait_for_trace_count(base_traces + 3, 128, case_id);
      expect_hit0_spacing(base_inputs, 3, 1, case_id);
      for (int idx = 0; idx < 3; idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[base_history_size + idx];
        if (obs.data[34:30] !== idx[4:0] || obs.data[16:14] !== 3'd0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s zero-gap output idx=%0d field mismatch data=0x%010h",
              case_id, idx, obs.data))
      end
      expect_last_trace_pair(case_id);
    endtask

    task automatic do_corner_026_one_cycle_gap_hits();
      int unsigned raw0;
      int unsigned raw1;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw0, case_id);
      lookup_raw_for_quotient(1, 0, raw1, case_id);
      base_inputs = m_env.m_scb.hit0_history.size();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();

      send_hit_beat(2, 0, raw0, raw0, 1'b0, 1'b1, 1'b0);
      wait_cycles(1);
      send_hit_beat(2, 1, raw1, raw1, 1'b0, 1'b0, 1'b0);
      wait_for_beat_count(base_beats + 2, 128, case_id);
      wait_for_trace_count(base_traces + 2, 128, case_id);
      expect_hit0_spacing(base_inputs, 2, 2, case_id);
      expect_last_output_flags(1'b0, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);
    endtask

    task automatic do_corner_027_long_gap_then_hit();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      expect_debug_valids_low($sformatf("%s before sparse gap", case_id));
      wait_cycles(128);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 1, $sformatf("%s sparse idle", case_id));
      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_trace_pair(case_id);
      expect_last_payload_error(1'b0, case_id);
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_corner_028_max_payload_fields();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_hit_and_expect_math(15, 31, 15'h7ffe, 15'h7ffe, 1'b1, 5'd31,
        13'd2, 3'd4, 9'd0, case_id);
      expect_last_trace_pair(case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
    endtask

    task automatic do_corner_029_nonzero_mux_bits_in_sideband();
      int unsigned       raw_value;
      int unsigned       base_inputs;
      int unsigned       base_beats;
      int unsigned       base_traces;
      mtsp_hit0_obs_item in_obs;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_inputs = m_env.m_scb.hit0_history.size();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat_with_sideband(6'b10_0010, 2, 3, raw_value, raw_value,
        1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      in_obs = m_env.m_scb.hit0_history[base_inputs];
      if (in_obs.channel !== 6'b10_0010)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected full sideband channel 0x%02h got 0x%02h",
            case_id, 6'b10_0010, in_obs.channel))
      expect_last_payload_fields(2, 3, 0, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);
    endtask

    task automatic do_corner_030_sideband_channel_outside_enabled_window();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      base_beats        = m_env.m_scb.beat_count;
      base_traces       = m_env.m_scb.trace_history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();

      send_hit_beat_with_sideband(6'd5, 5, 4, raw_value, raw_value,
        1'b0, 1'b1, 1'b1);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_payload_fields(5, 4, 0, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_trace_pair(case_id);

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers outside sideband window", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
    endtask

    task automatic do_corner_031_t_gray_equal_padding_upper();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_decoded_hit_and_expect_math(4553, 1, 4553, 1, 2, 0, 1'b0,
        5'd1, 11106, 3, 0, 1'b1,
        $sformatf("%s T equal upper no subtract", case_id));
    endtask

    task automatic do_corner_032_t_gray_one_above_upper();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_decoded_hit_and_expect_math(4553, 2, 4553, 2, 2, 1, 1'b0,
        5'd2, 4553, 2, 0, 1'b1,
        $sformatf("%s T one above upper subtracts", case_id));
    endtask

    task automatic do_corner_033_e_gray_equal_padding_upper();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b1);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_decoded_hit_and_expect_math(4553, 2, 4553, 1, 2, 2, 1'b1,
        5'd3, 4553, 2, 511, 1'b1,
        $sformatf("%s E equal upper no subtract", case_id));
    endtask

    task automatic do_corner_034_e_gray_one_above_upper();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b1);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      send_decoded_hit_and_expect_math(4553, 2, 4553, 2, 2, 3, 1'b1,
        5'd4, 4553, 2, 0, 1'b1,
        $sformatf("%s E one above upper subtracts", case_id));
    endtask

    task automatic do_corner_035_mts_counter_wrap_pulse();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned pulse_count;
      int unsigned pulse_counter;
      bit          will_happen;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      pulse_count   = 0;
      pulse_counter = 0;
      for (int idx = 0; idx < 7000; idx++) begin
        @(posedge ctrl_vif.clk);
        read_dut_bit("/tb_top/dut/fpga_overflow_will_happen", will_happen,
          $sformatf("%s wrap pulse sample", case_id));
        if (will_happen) begin
          int unsigned counter_value;
          pulse_count++;
          read_dut_uint("/tb_top/dut/counter_mts_1n6", counter_value,
            $sformatf("%s wrap counter sample", case_id));
          pulse_counter = counter_value;
        end
      end
      if (pulse_count != 1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected exactly one wrap-pulse sample, got %0d",
            case_id, pulse_count))
      if (pulse_counter < 32762 || pulse_counter > 32766)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s wrap pulse at unexpected local counter=%0d",
            case_id, pulse_counter))

      base_beats   = m_env.m_scb.beat_count;
      base_traces  = m_env.m_scb.trace_history.size();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      send_hit_beat(2, 4, raw_value, raw_value, 1'b0, 1'b1, 1'b0,
        '0, 1'b1, 5'd4);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_trace_pair($sformatf("%s post-wrap normal/debug pair", case_id));
    endtask

    task automatic do_corner_036_overflow_lookback_expiry();
      int unsigned lookback_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      for (int idx = 0; idx < 7000; idx++) begin
        @(posedge ctrl_vif.clk);
        read_dut_uint("/tb_top/dut/fpga_overflow_lookback_cnt", lookback_count,
          $sformatf("%s wait for lookback active", case_id));
        if (lookback_count != 0)
          break;
      end
      if (lookback_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s never observed nonzero overflow lookback", case_id))
      send_decoded_hit_and_expect_math(5000, 0, 5000, 0, 2, 4, 1'b0,
        5'd5, 5000, 0, 0, 1'b1,
        $sformatf("%s active lookback subtracts", case_id));
      for (int idx = 0; idx < 2200; idx++) begin
        @(posedge ctrl_vif.clk);
        read_dut_uint("/tb_top/dut/fpga_overflow_lookback_cnt", lookback_count,
          $sformatf("%s wait for lookback expiry", case_id));
        if (lookback_count == 0)
          break;
      end
      if (lookback_count != 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s lookback did not expire, count=%0d",
            case_id, lookback_count))
      send_decoded_hit_and_expect_math(5000, 0, 5000, 0, 2, 5, 1'b0,
        5'd6, 11553, 2, 0, 1'b0,
        $sformatf("%s expired lookback no longer subtracts", case_id));
    endtask

    task automatic do_corner_037_lpm_multi_valid_masks_adjust();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      bit          busy;
      bit          active;
      bit          saw_busy_and_active;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      lookup_raw_for_quotient(5000, 0, raw_value, case_id);
      wait_cycles(6520);

      base_beats          = m_env.m_scb.beat_count;
      base_history        = m_env.m_scb.history.size();
      base_traces         = m_env.m_scb.trace_history.size();
      saw_busy_and_active = 1'b0;
      for (int idx = 0; idx < 80; idx++) begin
        send_hit_beat(2, idx[4:0], raw_value, raw_value, 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx[4:0]);
        read_dut_bit("/tb_top/dut/hit_div_busy", busy,
          $sformatf("%s dense burst busy sample", case_id));
        read_dut_bit("/tb_top/dut/overflow_adjust_active", active,
          $sformatf("%s dense burst active sample", case_id));
        if (busy && active)
          saw_busy_and_active = 1'b1;
      end

      wait_for_beat_count(base_beats + 80, 512, case_id);
      wait_for_trace_count(base_traces + 80, 512, case_id);
      if (!saw_busy_and_active)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s never observed divider busy while overflow adjust active",
            case_id))
      for (int idx = 0; idx < 80; idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[base_history + idx];
        if (obs.data[29:17] !== 13'd5000 || obs.data[16:14] !== 3'd0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s burst idx=%0d expected adjusted q/r=5000/0 got %0d/%0d data=0x%010h",
              case_id, idx, obs.data[29:17], obs.data[16:14], obs.data))
      end
      expect_trace_pair_at(base_traces + 79,
        $sformatf("%s continuous wrap burst normal/debug pair", case_id));
    endtask

    task automatic do_corner_038_bypass_toggle_before_hit();
      int unsigned raw_value;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      lookup_raw_for_quotient(2, 0, raw_value, case_id);

      csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1));
      wait_cycles(1);
      send_hit_and_expect_math(2, 6, raw_value, raw_value, 1'b0, 5'd7,
        2, 0, 0, $sformatf("%s bypass sampled before hit", case_id));
      expect_last_trace_pair(case_id);
    endtask

    task automatic do_corner_039_bypass_toggle_after_hit_accept();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_inputs;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);
      lookup_raw_for_quotient(2, 0, raw_value, case_id);

      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();
      base_inputs  = m_env.m_scb.hit0_history.size();
      send_hit_beat(2, 7, raw_value, raw_value, 1'b0, 1'b1, 1'b0,
        '0, 1'b1, 5'd8);
      csr_write(3'd0, datapath_mode_word(1'b0, 1'b0, 1'b1));
      send_hit_beat(2, 8, raw_value, raw_value, 1'b0, 1'b1, 1'b0,
        '0, 1'b1, 5'd9);

      wait_for_input_count(base_inputs + 2, 64, case_id);
      wait_for_beat_count(base_beats + 2, 256, case_id);
      wait_for_trace_count(base_traces + 2, 256, case_id);
      expect_payload_math_at(base_history, 2, 7, 8, 2, 0, 0,
        $sformatf("%s first accepted hit keeps bypass-on mode", case_id));
      expect_payload_math_at(base_history + 1, 2, 8, 9, 6555, 2, 0,
        $sformatf("%s second hit uses bypass-off mode", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s first hit normal/debug pair", case_id));
      expect_trace_pair_at(base_traces + 1,
        $sformatf("%s second hit normal/debug pair", case_id));
    endtask

    task automatic do_corner_040_latency_write_at_overflow_boundary();
      int unsigned base_history;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0);
      run_start();
      wait_inside_one_wrap_lookback(case_id);

      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();
      send_decoded_hit_and_expect_math(5000, 0, 5000, 0, 2, 9, 1'b0,
        5'd10, 5000, 0, 0, 1'b1,
        $sformatf("%s default-latency overflow payload", case_id));
      expect_trace_expected_latency_at(base_traces, 2000,
        $sformatf("%s default trace latency", case_id));

      csr_write(3'd2, 32'd4096);
      wait_cycles(2);
      send_decoded_hit_and_expect_math(5000, 0, 5000, 0, 2, 10, 1'b0,
        5'd11, 5000, 0, 0, 1'b0,
        $sformatf("%s relaxed-latency overflow payload", case_id));
      expect_payload_math_at(base_history + 1, 2, 10, 11, 5000, 0, 0,
        $sformatf("%s latency write does not change padding math", case_id));
      expect_trace_expected_latency_at(base_traces + 1, 4096,
        $sformatf("%s relaxed trace latency", case_id));
    endtask

    task automatic do_corner_041_remainder_zero_case();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_quotient_hit_and_capture(8, 0, 2, 0, 5'd1, observed_delta, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_042_remainder_one_case();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_quotient_hit_and_capture(8, 1, 2, 1, 5'd2, observed_delta, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_043_remainder_two_case();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_quotient_hit_and_capture(8, 2, 2, 2, 5'd3, observed_delta, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_044_remainder_three_case();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_quotient_hit_and_capture(8, 3, 2, 3, 5'd4, observed_delta, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_045_remainder_four_case();
      int signed observed_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_quotient_hit_and_capture(8, 4, 2, 4, 5'd5, observed_delta, case_id);
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_046_route_bits_00();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(0, 0, 1'b1, case_id);
    endtask

    task automatic do_corner_047_route_bits_01();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(1, 1, 1'b1, case_id);
    endtask

    task automatic do_corner_048_route_bits_10();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(2, 2, 1'b1, case_id);
    endtask

    task automatic do_corner_049_route_bits_11();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(3, 3, 1'b1, case_id);
    endtask

    task automatic do_corner_050_route_change_across_boundary();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_dual_quotient_hit_and_expect(15, 0, 15, 0, 2, 15, 1'b0, 5'd6,
        9'd0, 1'b1, $sformatf("%s route0 side of boundary", case_id));
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s route0 side of boundary", case_id));
      send_dual_quotient_hit_and_expect(16, 0, 16, 0, 2, 16, 1'b0, 5'd6,
        9'd0, 1'b1, $sformatf("%s route1 side of boundary", case_id));
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 1,
        $sformatf("%s route1 side of boundary", case_id));
    endtask

    task automatic do_corner_051_short_mode_with_eflag_high();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 4, 0, 2, 5, 1'b1, 5'd7,
        9'd0, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_052_tot_mode_eflag_zero_large_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 600, 0, 2, 6, 1'b0, 5'd8,
        9'd0, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_053_tot_mode_smallest_positive_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 0, 1, 2, 7, 1'b1, 5'd9,
        9'd1, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_054_tot_mode_largest_unsaturated_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 102, 0, 2, 8, 1'b1, 5'd10,
        9'd510, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_055_tot_mode_first_saturated_delta();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 102, 2, 2, 9, 1'b1, 5'd11,
        9'd511, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_056_tot_mode_negative_delta_case();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(4, 0, 0, 0, 2, 10, 1'b1, 5'd12,
        9'd0, 1'b1, case_id);
      expect_last_payload_error(1'b0, case_id);
    endtask

    task automatic do_corner_057_toggle_derive_tot_between_hits();
      int unsigned t_raw_value;
      int unsigned e_raw_value;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      lookup_raw_for_quotient(0, 0, t_raw_value,
        $sformatf("%s T symbol", case_id));
      lookup_raw_for_quotient(0, 4, e_raw_value,
        $sformatf("%s E symbol", case_id));

      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();

      send_hit_beat(2, 11, t_raw_value, e_raw_value, 1'b1, 1'b1, 1'b0,
        '0, 1'b1, 5'd13);
      csr_write(3'd0, datapath_mode_word(1'b1, 1'b1, 1'b1));
      send_hit_beat(2, 12, t_raw_value, e_raw_value, 1'b1, 1'b1, 1'b0,
        '0, 1'b1, 5'd14);

      wait_for_beat_count(base_beats + 2, 256, case_id);
      wait_for_trace_count(base_traces + 2, 256, case_id);
      expect_payload_math_at(base_history, 2, 11, 13, 0, 0, 0,
        $sformatf("%s first hit sampled short mode", case_id));
      expect_payload_math_at(base_history + 1, 2, 12, 14, 0, 0, 4,
        $sformatf("%s second hit sampled ToT mode", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s first hit normal/debug pair", case_id));
      expect_trace_pair_at(base_traces + 1,
        $sformatf("%s second hit normal/debug pair", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_corner_058_toggle_delay_field_between_hits();
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();

      send_hit_beat(2, 13, 15'h0001, 15'h5ee7, 1'b1, 1'b1, 1'b0,
        '0, 1'b1, 5'd15);
      csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b0));
      send_hit_beat(2, 14, 15'h0001, 15'h5ee7, 1'b1, 1'b1, 1'b0,
        '0, 1'b1, 5'd16);

      wait_for_beat_count(base_beats + 2, 256, case_id);
      wait_for_trace_count(base_traces + 2, 256, case_id);
      expect_payload_math_at(base_history, 2, 13, 15, 0, 0, 0,
        $sformatf("%s first hit payload", case_id));
      expect_payload_error_at(base_history, 1'b0,
        $sformatf("%s first hit sampled T delay", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s first hit normal/debug pair", case_id));
      expect_trace_error_at(base_traces, 1'b0,
        $sformatf("%s first hit debug math sampled T delay", case_id));
      expect_payload_math_at(base_history + 1, 2, 14, 16, 0, 0, 0,
        $sformatf("%s second hit payload", case_id));
      expect_payload_error_at(base_history + 1, 1'b1,
        $sformatf("%s second hit sampled E delay", case_id));
      expect_trace_pair_at(base_traces + 1,
        $sformatf("%s second hit normal/debug pair", case_id));
      expect_trace_error_at(base_traces + 1, 1'b1,
        $sformatf("%s second hit debug math sampled E delay", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_corner_059_toggle_eflag_between_hits();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 4, 0, 2, 11, 1'b0, 5'd13,
        9'd0, 1'b1, $sformatf("%s eflag masked hit", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s eflag masked hit", case_id));
      send_dual_quotient_hit_and_expect(0, 0, 0, 4, 2, 11, 1'b1, 5'd14,
        9'd4, 1'b0, $sformatf("%s eflag calculated hit", case_id));
      expect_last_payload_error(1'b0, $sformatf("%s eflag calculated hit", case_id));
    endtask

    task automatic do_corner_060_tfine_extremes();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_dual_quotient_hit_and_expect(0, 0, 0, 0, 2, 12, 1'b0, 5'd0,
        9'd0, 1'b1, $sformatf("%s tfine zero", case_id));
      expect_last_output_flags(1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s tfine zero", case_id));
      send_dual_quotient_hit_and_expect(1, 0, 1, 0, 2, 12, 1'b0, 5'd31,
        9'd0, 1'b0, $sformatf("%s tfine max", case_id));
      expect_last_output_flags(1'b0, 1'b0, 1'b0, 0,
        $sformatf("%s tfine max", case_id));
    endtask

    task automatic do_corner_061_first_sop_channel0_after_reset();
      do_std_071_sop_first_hit_channel0();
    endtask

    task automatic do_corner_062_first_sop_channel3_after_reset();
      do_std_074_sop_first_hit_channel3();
    endtask

    task automatic do_corner_063_first_hit_disabled_channel_no_sop();
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);

      base_beats        = m_env.m_scb.beat_count;
      base_traces       = m_env.m_scb.trace_history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_hit_beat_with_sideband(0, 2, 0, raw_value, raw_value, 1'b0,
        1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s disabled-sideband payload", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s disabled-sideband trace", case_id));
      expect_payload_math_at(base_history_size, 2, 0, 0, 0, 0, 0,
        $sformatf("%s disabled-sideband payload math", case_id));
      expect_output_flags_at(base_history_size, 1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s route-lane SOP is independent of input window", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s disabled-sideband normal/debug pair", case_id));

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s disabled-sideband close markers", case_id));
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1110,
        4, 1, $sformatf("%s disabled-sideband did not hold input packet open",
        case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_064_interleaved_channels_no_repeat_sop();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      send_route_lane_hit_and_expect(1, 1, 1'b1,
        $sformatf("%s first lane-1 payload", case_id));
      send_route_lane_hit_and_expect(2, 2, 1'b1,
        $sformatf("%s first lane-2 payload", case_id));
      send_route_lane_hit_and_expect(1, 1, 1'b0,
        $sformatf("%s repeated lane-1 payload", case_id));
    endtask

    task automatic do_corner_065_single_terminating_eop_pulse();
      int unsigned raw_value;
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));

      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b0, 1'b1);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s terminating EOP payload trace", case_id));
      expect_payload_math_at(base_history_size, 2, 0, 0, 0, 0, 0,
        $sformatf("%s terminating EOP payload math", case_id));
      expect_output_flags_at(base_history_size, 1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s payload does not carry terminal EOP", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s terminating EOP normal/debug pair", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s terminating EOP close marker train", case_id));
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1110,
        4, 1, $sformatf("%s one close marker per route lane", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_066_eop_pipe_without_valid_alignment();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));

      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s no-valid close marker train", case_id));
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1111,
        4, 0, $sformatf("%s no payload-valid alignment required", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_067_nonterminating_eop_is_local_only();
      do_std_078_nonterminating_eop_not_forwarded();
    endtask

    task automatic do_corner_068_output_eop_with_ready_low();
      do_corner_104_output_ready_low_on_eop();
    endtask

    task automatic do_corner_069_sop_and_eop_same_output_beat();
      int unsigned raw_value;
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      lookup_raw_for_quotient(0, 0, raw_value, case_id);

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, raw_value, raw_value, 1'b0, 1'b1, 1'b1);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s single-beat SOP/EOP payload trace", case_id));
      expect_output_flags_at(base_history_size, 1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s payload SOP without terminal EOP", case_id));
      expect_trace_pair_at(base_traces,
        $sformatf("%s single-beat SOP/EOP normal/debug pair", case_id));

      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers after first payload", case_id));
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1110,
        4, 1, $sformatf("%s SOP/EOP overlap only on unseen empty markers", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_070_empty_zero_on_all_output_classes();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0);
      run_start();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 8,
        $sformatf("%s quiet RUNNING interval", case_id));

      base_history_size = m_env.m_scb.history.size();
      send_route_lane_hit_and_expect(0, 0, 1'b1,
        $sformatf("%s SOP payload", case_id));
      send_route_lane_hit_and_expect(0, 0, 1'b0,
        $sformatf("%s ordinary payload", case_id));
      send_route_lane_hit_and_expect(0, 0, 1'b0,
        $sformatf("%s input-EOP payload", case_id), 1'b1);
      expect_output_flags_at(base_history_size, 1'b1, 1'b0, 1'b0, 0,
        $sformatf("%s SOP payload empty low", case_id));
      expect_output_flags_at(base_history_size + 1, 1'b0, 1'b0, 1'b0, 0,
        $sformatf("%s ordinary payload empty low", case_id));
      expect_output_flags_at(base_history_size + 2, 1'b0, 1'b0, 1'b0, 0,
        $sformatf("%s input-EOP payload empty low", case_id));

      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s terminal empty markers", case_id));
      expect_close_markers_detail_since(base_history_size, 4'b1111, 4'b1110,
        4, 3, $sformatf("%s terminal markers carry empty high", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_071_debug_ts_minus_one();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(-1, 1'b1, case_id);
    endtask

    task automatic do_corner_072_debug_ts_zero();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(0, 1'b1, case_id);
    endtask

    task automatic do_corner_073_debug_ts_plus_one();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(1, 1'b0, case_id);
    endtask

    task automatic do_corner_074_debug_ts_expected_minus_one();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(3, 1'b0, case_id);
    endtask

    task automatic do_corner_075_debug_ts_expected_exact();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(4, 1'b1, case_id);
    endtask

    task automatic do_corner_076_debug_ts_expected_plus_one();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd4);
      run_start();
      send_hit_for_debug_delta(5, 1'b1, case_id);
    endtask

    task automatic do_corner_077_t_vs_e_path_error_flip();
      do_std_090_delay_field_changes_error_source();
    endtask

    task automatic do_corner_078_debug_burst_positive_trim_edge();
      int unsigned base_debug_burst;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_debug_burst = m_env.m_scb.debug_burst_count;
      send_two_quotient_hits_and_expect_delta(0, 16, 16, case_id);
      wait_for_debug_burst_count(base_debug_burst + 2, 64, case_id);
      expect_last_debug_burst_timestamp_hi(8'h01, case_id);
    endtask

    task automatic do_corner_079_debug_burst_negative_trim_edge();
      int unsigned base_debug_burst;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_debug_burst = m_env.m_scb.debug_burst_count;
      send_two_quotient_hits_and_expect_delta(16, 0, -16, case_id);
      wait_for_debug_burst_count(base_debug_burst + 2, 64, case_id);
      expect_last_debug_burst_timestamp_hi(8'h81, case_id);
    endtask

    task automatic do_corner_080_ts_delta_zero_boundary();
      int unsigned base_debug_burst;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_debug_burst = m_env.m_scb.debug_burst_count;
      send_two_quotient_hits_and_expect_delta(20, 20, 0, case_id);
      wait_for_debug_burst_count(base_debug_burst + 2, 64, case_id);
      expect_last_debug_burst_timestamp_hi(8'h00, case_id);
    endtask

    task automatic do_corner_081_force_stop_same_cycle_as_valid();
      int unsigned raw0;
      int unsigned raw1;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      lookup_raw_for_quotient(0, 0, raw0, $sformatf("%s first hit", case_id));
      lookup_raw_for_quotient(1, 0, raw1, $sformatf("%s blocked hit", case_id));
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();

      fork
        csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0002);
        send_hit_beat(2, 0, raw0, raw0, 1'b0, 1'b1, 1'b0);
      join

      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s same-cycle accepted hit", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s same-cycle accepted trace", case_id));
      expect_last_payload_math(2, 0, 0, 0, 0, 0,
        $sformatf("%s same-cycle accepted hit", case_id));
      expect_last_payload_error(1'b0,
        $sformatf("%s same-cycle accepted hit", case_id));
      expect_csr_mask(3'd0, 32'h0000_0002, 32'h0000_0002,
        $sformatf("%s force_stop set", case_id));

      send_hit_beat(2, 1, raw1, raw1, 1'b0, 1'b0, 1'b0);
      expect_no_new_beats(base_beats + 1, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, $sformatf("%s later force_stop block", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_corner_082_force_stop_clear_before_next_hit();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0002);
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, $sformatf("%s force_stop blocked", case_id));
      expect_total_count(48'd1, $sformatf("%s blocked total", case_id));
      expect_discard_count(32'd1, $sformatf("%s blocked discard", case_id));

      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      wait_cycles(1);
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s clear-before-hit payload", case_id));
      expect_last_trace_pair($sformatf("%s clear-before-hit payload", case_id));
      expect_total_count(48'd2, case_id);
      expect_discard_count(32'd1, case_id);
    endtask

    task automatic do_corner_083_soft_reset_while_running_idle_pipe();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004);
      wait_cycles(3);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004,
        $sformatf("%s soft_reset self-clear", case_id));
      expect_total_count(48'd0, case_id);
      expect_discard_count(32'd0, case_id);

      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s post-soft-reset hit", case_id));
      expect_last_trace_pair($sformatf("%s post-soft-reset hit", case_id));
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_corner_084_soft_reset_with_inflight_beats();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_traces     = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004);
      wait_cycles(2);
      expect_total_count(48'd0,
        $sformatf("%s counter clear during in-flight soft_reset", case_id));
      expect_discard_count(32'd0,
        $sformatf("%s discard clear during in-flight soft_reset", case_id));
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 128,
        $sformatf("%s in-flight payload flushed by soft_reset", case_id));
      if (m_env.m_scb.trace_history.size() != base_traces)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s soft_reset emitted a debug trace for flushed in-flight payload: base=%0d now=%0d",
            case_id, base_traces, m_env.m_scb.trace_history.size()))

      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b0, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s post-reset counter restart hit", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s post-reset trace restart", case_id));
      expect_last_trace_pair($sformatf("%s post-reset counter restart hit",
        case_id));
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_corner_085_soft_reset_in_flushing();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004);
      wait_cycles(2);
      expect_total_count(48'd0, $sformatf("%s flushing soft reset total", case_id));
      expect_discard_count(32'd0, $sformatf("%s flushing soft reset discard", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close markers after flushing soft reset", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s ready restore", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
    endtask

    task automatic do_corner_086_global_reset_with_pending_term_eop();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b1);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      drive_global_reset(5, 4);
      expect_hit0_ready(1'b0, case_id);
      expect_total_count(48'd0, case_id);
      expect_discard_count(32'd0, case_id);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 64, case_id);
    endtask

    task automatic do_corner_087_global_reset_with_debug_history();
      int signed   observed_delta;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      send_two_quotient_hits_and_expect_delta(0, 20, 20,
        $sformatf("%s pre-reset history", case_id));
      drive_global_reset(5, 4);

      run_start();
      base_ts_delta = m_env.m_scb.ts_delta_count;
      send_quotient_hit_and_capture(0, 0, 2, 0, 5'd27, observed_delta,
        $sformatf("%s post-reset first hit", case_id));
      wait_for_ts_delta_count(base_ts_delta + 1, 64,
        $sformatf("%s post-reset first delta", case_id));
      expect_last_ts_delta_range(0, 0,
        $sformatf("%s post-reset first delta", case_id));
    endtask

    task automatic do_corner_088_prepare_after_soft_reset();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(1, 128, $sformatf("%s pre-reset hit", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0004);
      wait_cycles(3);
      expect_total_count(48'd0, $sformatf("%s after soft reset", case_id));
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);

      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s prepared after soft reset", case_id));
      expect_last_trace_pair($sformatf("%s prepared after soft reset", case_id));
      expect_total_count(48'd1, case_id);
    endtask

    task automatic do_corner_089_sync_after_force_stop_cycle();
      int unsigned base_beats;

      wait_for_reset_release();
      run_start();
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT | 32'h0000_0002);
      wait_cycles(2);
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0001, 15'h0001, 1'b0, 1'b1, 1'b0);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 32, $sformatf("%s force_stop blocked", case_id));
      csr_write(3'd0, CSR_CTRL_WRITE_DEFAULT);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);

      run_start();
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 1, 15'h0003, 15'h0003, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s sync after force_stop hit", case_id));
      expect_last_trace_pair($sformatf("%s sync after force_stop hit", case_id));
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_corner_090_idle_during_sclr_flush();
      int unsigned base_beats;

      wait_for_reset_release();
      base_beats = m_env.m_scb.beat_count;
      send_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_cycles(1);
      pulse_ctrl(CTRL_IDLE, "IDLE_while_sclr");
      wait_cycles(4);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(3);
      expect_hit0_ready(1'b0, case_id);
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 24, case_id);
      expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
        $sformatf("%s final IDLE status", case_id));
    endtask

    task automatic send_hit_beat_with_sideband_time(int unsigned sideband_channel,
                                                    int unsigned asic_value,
                                                    int unsigned channel_value,
                                                    int unsigned tcc_raw_value,
                                                    int unsigned ecc_raw_value,
                                                    bit eflag_value,
                                                    bit sop_value,
                                                    bit eop_value,
                                                    output time accept_time_ps,
                                                    input bit [2:0] error_value = '0,
                                                    input bit wait_for_ready = 1'b1,
                                                    input int unsigned tfine_value = 0);
      mtsp_hit0_seq seq;
      bit [44:0]    hit_word;

      hit_word             = '0;
      hit_word[44:41]      = asic_value[3:0];
      hit_word[40:36]      = channel_value[4:0];
      hit_word[35:21]      = tcc_raw_value[14:0];
      hit_word[20:16]      = tfine_value[4:0];
      hit_word[15:1]       = ecc_raw_value[14:0];
      hit_word[0]          = eflag_value;

      seq                  = mtsp_hit0_seq::type_id::create($sformatf("hit0_time_seq_%0t", $time));
      seq.channel          = sideband_channel[5:0];
      seq.sop              = sop_value;
      seq.eop              = eop_value;
      seq.endofrun         = 1'b0;
      seq.error            = error_value;
      seq.data             = hit_word;
      seq.valid            = 1'b1;
      seq.wait_for_ready   = wait_for_ready;
      seq.start(m_env.m_hit0_sqr);
      accept_time_ps       = seq.accept_time_ps + 1ps;
    endtask

    task automatic expect_first_empty_eop_latency_since(int unsigned base_history_size,
                                                        time         base_time_ps,
                                                        int unsigned expected_cycles,
                                                        string       ctx);
      time               latency_ps;
      int unsigned       observed_cycles;

      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (obs.empty && obs.eop) begin
          if (obs.time_ps <= base_time_ps)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s empty EOP time %0t not after base %0t",
                ctx, obs.time_ps, base_time_ps))
          latency_ps      = obs.time_ps - base_time_ps;
          observed_cycles = int'(latency_ps / CLK_PERIOD_PS);
          if ((latency_ps % CLK_PERIOD_PS) != 0 || observed_cycles != expected_cycles)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected first empty EOP latency %0d cycles, got %0d cycles (%0t ps)",
                ctx, expected_cycles, observed_cycles, latency_ps))
          `uvm_info("MTSP_LATENCY",
            $sformatf("%s accepted_hit=%0t first_empty_eop=%0t latency_cycles=%0d",
              ctx, base_time_ps, obs.time_ps, observed_cycles),
            UVM_LOW)
          return;
        end
      end
      `uvm_fatal("MTSP_CASE",
        $sformatf("%s did not observe an empty EOP after history base %0d",
          ctx, base_history_size))
    endtask

    task automatic prove_terminating_eop_delay(int unsigned expected_cycles,
                                               string ctx);
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;
      time         accepted_time_ps;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", ctx));

      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat_with_sideband_time(2, 2, 0, 15'h0003, 15'h000F,
        1'b1, 1'b1, 1'b1, accepted_time_ps);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s draining payload trace", ctx));
      expect_last_trace_pair($sformatf("%s draining payload trace", ctx));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s close marker train", ctx));
      expect_first_empty_eop_latency_since(base_history_size, accepted_time_ps,
        expected_cycles, ctx);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", ctx));
    endtask

    task automatic do_corner_091_single_channel_window_index0();
      prove_enabled_window_bookkeeping(0, 1, case_id);
    endtask

    task automatic do_corner_092_single_channel_window_index3();
      prove_enabled_window_bookkeeping(3, 2, case_id);
    endtask

    task automatic do_corner_093_middle_window_indexing();
      prove_enabled_window_bookkeeping(1, 3, case_id);
    endtask

    task automatic do_corner_094_packaged_div_pipeline_delay();
      prove_terminating_eop_delay(9, case_id);
    endtask

    task automatic do_corner_095_rtl_div_pipeline_delay();
      prove_terminating_eop_delay(11, case_id);
    endtask

    task automatic do_corner_096_zero_default_latency_generic();
      bit [31:0] csr_word;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      csr_read(3'd2, csr_word);
      if (csr_word !== 32'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected power-on expected_latency CSR=0 got %0d",
            case_id, csr_word))
      run_start();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128, case_id);
      wait_for_trace_count(base_traces + 1, 128, case_id);
      expect_last_trace_expected_latency(0, case_id);
      expect_last_payload_error(1'b1, case_id);
    endtask

    task automatic do_corner_097_one_tick_default_latency_generic();
      bit [31:0] csr_word;
      int signed   predicted_arrival;
      int unsigned raw_value;
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      csr_read(3'd2, csr_word);
      if (csr_word !== 32'd1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected power-on expected_latency CSR=1 got %0d",
            case_id, csr_word))
      run_start();

      calibrate_next_output_arrival(predicted_arrival,
        $sformatf("%s threshold calibration", case_id));
      if (predicted_arrival <= 1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s cannot craft debug_delta=1 from predicted arrival %0d",
            case_id, predicted_arrival))

      lookup_raw_for_quotient(predicted_arrival - 1, 0, raw_value, case_id);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 3, raw_value, raw_value, 1'b0, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s generic equality-threshold hit", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s generic equality-threshold trace", case_id));
      expect_last_trace_expected_latency(1, case_id);
      expect_last_trace_delta(1, 1, 1'b1,
        $sformatf("%s default expected_latency=1 strict upper equality", case_id));
    endtask

    task automatic do_corner_098_remapped_hiterr_to_bit2();
      do_std_115_remapped_hiterr_bit();
    endtask

    task automatic do_corner_099_frame_corrupt_bit_still_inert();
      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0, 3'b100);
      wait_for_beat_count(1, 128, case_id);
      expect_last_trace_pair(case_id);
      expect_total_count(48'd1, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_corner_100_padding_eop_wait_still_inert();
      do_std_128_upgrade_case_terminal_boundary_without_extra_hits();
    endtask

    task automatic do_corner_101_output_ready_low_single_beat();
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      set_hit1_ready(1'b0);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s ready-low payload", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s ready-low trace", case_id));
      expect_last_trace_pair($sformatf("%s ready-low payload", case_id));
      if (hit1_drv_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE", "hit_type1 ready must remain low during single-beat observation")
      set_hit1_ready(1'b1);
    endtask

    task automatic do_corner_102_output_ready_low_multi_beat();
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      set_hit1_ready(1'b0);
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b0, 1'b0);
      wait_for_beat_count(base_beats + 2, 128,
        $sformatf("%s ready-low payloads", case_id));
      wait_for_trace_count(base_traces + 2, 128,
        $sformatf("%s ready-low traces", case_id));
      expect_last_trace_pair($sformatf("%s ready-low second payload", case_id));
      if (hit1_drv_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE", "hit_type1 ready must remain low during multi-beat observation")
      set_hit1_ready(1'b1);
    endtask

    task automatic do_corner_103_output_ready_toggle_every_cycle();
      int unsigned base_beats;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      base_beats  = m_env.m_scb.beat_count;
      base_traces = m_env.m_scb.trace_history.size();
      fork
        toggle_hit1_ready_for(96);
        begin
          send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
          send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b0, 1'b0);
          wait_for_beat_count(base_beats + 2, 128,
            $sformatf("%s toggled-ready payloads", case_id));
          wait_for_trace_count(base_traces + 2, 128,
            $sformatf("%s toggled-ready traces", case_id));
          expect_last_trace_pair($sformatf("%s toggled-ready second payload", case_id));
        end
      join
      set_hit1_ready(1'b1);
    endtask

    task automatic do_corner_104_output_ready_low_on_eop();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      set_hit1_ready(1'b0);
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s ready-low close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0,
        $sformatf("%s ready-low close markers", case_id));
      if (hit1_drv_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE", "hit_type1 ready must remain low during close-marker observation")
      set_hit1_ready(1'b1);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_105_output_ready_unknown_monitor_trap();
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_ready_unknown;
      mtsp_ready_obs_item ready_obs;

      wait_for_reset_release();
      run_start();
      base_beats         = m_env.m_scb.beat_count;
      base_traces        = m_env.m_scb.trace_history.size();
      base_ready_unknown = m_env.m_scb.hit1_ready_unknown_count;

      hit1_drv_vif.ready <= 1'bx;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s ready-X output still observed", case_id));
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s ready-X debug trace", case_id));

      if (m_env.m_scb.hit1_ready_unknown_count <= base_ready_unknown)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected ready-X analysis-port evidence", case_id))
      ready_obs = m_env.m_scb.ready_unknown_history[
        m_env.m_scb.ready_unknown_history.size() - 1];
      if (!$isunknown(ready_obs.ready))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ready monitor reported a non-unknown value %0b",
            case_id, ready_obs.ready))
      expect_last_trace_pair($sformatf("%s ready-X trace pair", case_id));
      hit1_drv_vif.ready <= 1'b1;
      wait_cycles(2);
    endtask

    task automatic do_corner_106_input_ready_high_in_flushing();
      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, case_id);
    endtask

    task automatic do_corner_107_input_ready_low_in_idle();
      do_std_032_idle_rejects_clean_hit();
    endtask

    task automatic do_corner_108_input_ready_high_in_reset_sclr();
      do_std_033_reset_sclr_flush_accept();
    endtask

    task automatic do_corner_109_input_ready_low_in_reset_sync();
      do_std_034_reset_sync_blocks_hit();
    endtask

    task automatic do_corner_110_output_quiet_outside_running_flush();
      do_std_080_output_valid_only_in_run_or_flush();
    endtask

    task automatic expect_empty_close_markers_sop_since(int unsigned base_history_size,
                                                        bit          expected_sop,
                                                        string       ctx);
      int unsigned marker_count;

      marker_count = 0;
      for (int idx = base_history_size; idx < m_env.m_scb.history.size(); idx++) begin
        mtsp_hit1_obs_item obs;
        obs = m_env.m_scb.history[idx];
        if (obs.empty && obs.eop) begin
          marker_count++;
          if (obs.sop !== expected_sop)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s close marker lane=%0d expected SOP=%0b got %0b",
                ctx, obs.channel, expected_sop, obs.sop))
        end
      end
      if (marker_count == 0)
        `uvm_fatal("MTSP_CASE", $sformatf("%s expected close markers", ctx))
    endtask

    task automatic do_corner_111_terminate_with_no_packet_open();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      base_beats        = m_env.m_scb.beat_count;
      base_eops         = m_env.m_scb.eop_count;
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 32,
        $sformatf("%s no close marker before upstream endofrun", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s empty close marker train", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
      expect_empty_close_markers_sop_since(base_history_size, 1'b1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_112_terminate_one_cycle_before_eop();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_cycles(1);
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s one-cycle-before-eop payload trace", case_id));
      expect_last_trace_pair($sformatf("%s one-cycle-before-eop payload trace", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s one-cycle-before-eop close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_113_terminate_same_cycle_as_eop();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      fork
        pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
        send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      join
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s same-cycle-eop payload trace", case_id));
      expect_last_trace_pair($sformatf("%s same-cycle-eop payload trace", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s same-cycle-eop close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_114_terminate_one_cycle_after_eop();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      wait_for_trace_count(m_env.m_scb.trace_history.size() + 1, 128,
        $sformatf("%s pre-terminate eop payload trace", case_id));
      wait_cycles(1);
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s post-eop terminate close markers", case_id));
      if (m_env.m_scb.trace_history.size() != base_traces)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected no new payload trace after post-EOP terminate, got %0d from base %0d",
            case_id, m_env.m_scb.trace_history.size(), base_traces))
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_115_idle_before_eop_delay_matures();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      pulse_ctrl(CTRL_IDLE, "IDLE_before_eop_delay");
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s idle-before-delay payload trace", case_id));
      expect_last_trace_pair($sformatf("%s idle-before-delay payload trace", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s idle-before-delay close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_116_multiple_eops_in_flushing();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b0, 1'b1);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 2, 128,
        $sformatf("%s multi-eop payload traces", case_id));
      expect_last_trace_pair($sformatf("%s multi-eop second payload", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s multi-eop close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 2, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_117_packet_open_then_abort();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_trace_count(1, 128, $sformatf("%s open-packet payload", case_id));
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      expect_hit0_ready(1'b0, $sformatf("%s aborted idle ready", case_id));

      run_start();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s post-abort close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 0, case_id);
      expect_empty_close_markers_sop_since(base_history_size, 1'b1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_118_terminating_eop_disabled_sideband_channel();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat_with_sideband(5, 2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s outside-window eop payload trace", case_id));
      expect_last_trace_pair($sformatf("%s outside-window eop payload trace", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s outside-window close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_119_flushing_accepts_non_eop_hits();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b0);
      send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b0, 1'b0);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 2, 128,
        $sformatf("%s non-eop flushing payload traces", case_id));
      expect_last_trace_pair($sformatf("%s non-eop flushing second payload", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s non-eop flushing close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 2, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_120_upgrade_ready_should_wait_for_drain();
      do_std_127_upgrade_case_stateful_ready_on_terminate();
    endtask

    task automatic do_corner_121_prepare_ready_gap_upgrade();
      wait_for_reset_release();
      pulse_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_for_ctrl_ready_low(4, $sformatf("%s prepare ready low", case_id));
      wait_for_ctrl_ready_high(16, $sformatf("%s prepare ready restore", case_id));
      expect_hit0_ready(1'b1, $sformatf("%s prepare opens flush-ready window", case_id));
    endtask

    task automatic do_corner_122_sync_ready_gap_upgrade();
      wait_for_reset_release();
      pulse_ctrl(CTRL_RUN_PREPARE, "RUN_PREPARE");
      wait_for_ctrl_ready_low(4, $sformatf("%s prepare ready low", case_id));
      wait_for_ctrl_ready_high(16, $sformatf("%s prepare ready restore", case_id));
      pulse_ctrl(CTRL_SYNC, "SYNC");
      wait_for_ctrl_ready_low(4, $sformatf("%s sync ready low", case_id));
      wait_for_ctrl_ready_high(16, $sformatf("%s sync ready restore", case_id));
      expect_hit0_ready(1'b0, $sformatf("%s sync keeps hit input blocked", case_id));
    endtask

    task automatic do_corner_123_flushing_ready_gap_upgrade();
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s flushing ready low", case_id));
      wait_cycles(8);
      if (ctrl_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s flushing must keep ctrl ready low until upstream endofrun",
            case_id))
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s flushing close-marker drain", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s flushing ready restore", case_id));
    endtask

    task automatic do_corner_124_missing_synthetic_boundary_upgrade();
      do_std_128_upgrade_case_terminal_boundary_without_extra_hits();
    endtask

    task automatic do_corner_125_eop_alignment_hole_upgrade();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s terminal EOP payload trace", case_id));
      wait_cycles(3);
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s terminal boundary after delayed EOP", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_126_crcerr_ignore_upgrade_gap();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1, 3'b010);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s CRCERR-inert payload trace", case_id));
      expect_last_trace_pair($sformatf("%s CRCERR-inert payload trace", case_id));
      expect_discard_count(32'd0, $sformatf("%s CRCERR remains inert", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s CRCERR-inert close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_127_frame_corrupt_ignore_upgrade_gap();
      int unsigned base_empty_eops;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1, 3'b100);
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s frame-corrupt-inert payload trace", case_id));
      expect_last_trace_pair($sformatf("%s frame-corrupt-inert payload trace", case_id));
      expect_discard_count(32'd0, $sformatf("%s frame-corrupt remains inert", case_id));
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s frame-corrupt-inert close markers", case_id));
      expect_close_markers_since(base_history_size, 4'b1111, 1, case_id);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_128_accept_command_vs_complete_work_upgrade();
      int unsigned base_empty_eops;
      time         terminate_accept_time;

      wait_for_reset_release();
      run_start();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      send_ctrl_and_capture(CTRL_TERMINATING, "TERMINATING", terminate_accept_time);
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      if (m_env.m_scb.empty_eop_count != base_empty_eops)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s terminate command alone must not complete boundary work",
            case_id))
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s work completion after endofrun", case_id));
      if (terminate_accept_time >= m_env.m_scb.last_eop_time_ps)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s terminate accept time must precede terminal boundary: accept=%0t last_eop=%0t",
            case_id, terminate_accept_time, m_env.m_scb.last_eop_time_ps))
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_129_one_boundary_per_run_upgrade();
      int unsigned base_empty_eops;
      int unsigned base_history_size;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", case_id));
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      base_history_size = m_env.m_scb.history.size();
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b0, 1'b1);
      send_hit_beat(2, 1, 15'h0013, 15'h001F, 1'b1, 1'b0, 1'b1);
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 128,
        $sformatf("%s one terminal boundary", case_id));
      wait_cycles(16);
      if (m_env.m_scb.empty_eop_count != base_empty_eops + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected exactly four close markers, got %0d new markers",
            case_id, m_env.m_scb.empty_eop_count - base_empty_eops))
      expect_close_markers_since(base_history_size, 4'b1111, 2,
        $sformatf("%s one terminal boundary detail", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore", case_id));
    endtask

    task automatic do_corner_130_idle_after_boundary_upgrade();
      do_std_129_upgrade_case_idle_after_boundary_only();
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

    function automatic int unsigned stress_t_quotient(int unsigned idx);
      return idx % 64;
    endfunction

    function automatic int unsigned stress_t_remainder(int unsigned idx);
      return idx % 5;
    endfunction

    function automatic int unsigned stress_t_decoded(int unsigned idx);
      return (stress_t_quotient(idx) * 5) + stress_t_remainder(idx);
    endfunction

    function automatic int unsigned stress_e_decoded(int unsigned idx,
                                                     bit derive_tot);
      if (!derive_tot)
        return stress_t_decoded(idx);
      return stress_t_decoded(idx) + 1 + (idx % 7);
    endfunction

    function automatic int unsigned stress_e_quotient(int unsigned idx,
                                                      bit derive_tot);
      return stress_e_decoded(idx, derive_tot) / 5;
    endfunction

    function automatic int unsigned stress_e_remainder(int unsigned idx,
                                                       bit derive_tot);
      return stress_e_decoded(idx, derive_tot) % 5;
    endfunction

    function automatic bit stress_eflag(int unsigned idx, bit derive_tot);
      if (derive_tot)
        return 1'b1;
      return idx[0];
    endfunction

    function automatic int unsigned stress_expected_et(int unsigned idx,
                                                       bit derive_tot);
      int signed delta;

      if (!derive_tot || !stress_eflag(idx, derive_tot))
        return 0;
      delta = int'(stress_e_decoded(idx, derive_tot)) -
              int'(stress_t_decoded(idx));
      if (delta <= 0)
        return 0;
      if (delta > 511)
        return 511;
      return int'(delta);
    endfunction

    function automatic int unsigned stress_asic(int unsigned idx);
      return 2 + (idx % 2);
    endfunction

    function automatic int unsigned stress_channel(int unsigned idx);
      return idx % 32;
    endfunction

    function automatic int unsigned stress_tfine(int unsigned idx);
      return idx % 32;
    endfunction

    task automatic send_stress_hit(int unsigned idx,
                                   bit derive_tot,
                                   bit sop_value,
                                   bit eop_value,
                                   bit [2:0] error_value,
                                   string ctx);
      int unsigned t_raw_value;
      int unsigned e_raw_value;

      lookup_raw_for_quotient(stress_t_quotient(idx), stress_t_remainder(idx),
        t_raw_value, $sformatf("%s stress T symbol idx=%0d", ctx, idx));
      lookup_raw_for_quotient(stress_e_quotient(idx, derive_tot),
        stress_e_remainder(idx, derive_tot), e_raw_value,
        $sformatf("%s stress E symbol idx=%0d", ctx, idx));
      send_hit_beat(stress_asic(idx), stress_channel(idx), t_raw_value,
        e_raw_value, stress_eflag(idx, derive_tot), sop_value, eop_value,
        error_value, 1'b1, stress_tfine(idx));
    endtask

    task automatic expect_stress_payload_at(int unsigned history_idx,
                                            int unsigned trace_idx,
                                            int unsigned stimulus_idx,
                                            bit derive_tot,
                                            string ctx);
      expect_payload_math_at(history_idx, stress_asic(stimulus_idx),
        stress_channel(stimulus_idx), stress_tfine(stimulus_idx),
        stress_t_quotient(stimulus_idx), stress_t_remainder(stimulus_idx),
        stress_expected_et(stimulus_idx, derive_tot), ctx);
      expect_trace_pair_at(trace_idx, ctx);
      expect_trace_error_at(trace_idx, 1'b0, ctx);
    endtask

    function automatic int unsigned stress_discard_count(int unsigned hit_count,
                                                         int unsigned hiterr_period,
                                                         bit discard_hiterr);
      int unsigned count;

      count = 0;
      if (hiterr_period == 0 || !discard_hiterr)
        return 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        if (((idx + 1) % hiterr_period) == 0)
          count++;
      end
      return count;
    endfunction

    task automatic expect_stress_stream_since(int unsigned base_history_size,
                                              int unsigned base_traces,
                                              int unsigned hit_count,
                                              bit derive_tot,
                                              int unsigned hiterr_period,
                                              bit discard_hiterr,
                                              string ctx);
      int unsigned emitted_idx;

      emitted_idx = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit dropped;

        dropped = (hiterr_period != 0) &&
                  (((idx + 1) % hiterr_period) == 0) &&
                  discard_hiterr;
        if (!dropped) begin
          expect_stress_payload_at(base_history_size + emitted_idx,
            base_traces + emitted_idx, idx, derive_tot,
            $sformatf("%s payload idx=%0d", ctx, idx));
          emitted_idx++;
        end
      end
    endtask

    task automatic run_stress_stream_case(int unsigned hit_count,
                                          int unsigned gap_cycles,
                                          bit derive_tot,
                                          bit bypass_lapse,
                                          bit delay_ts_field_use_t,
                                          int unsigned burst_len,
                                          int unsigned burst_gap_cycles,
                                          int unsigned hiterr_period,
                                          bit discard_hiterr,
                                          bit ready_low,
                                          string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned expected_discards;
      int unsigned expected_payloads;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      configure_datapath_mode(bypass_lapse, derive_tot, delay_ts_field_use_t);
      run_start();
      if (!discard_hiterr) begin
        csr_word = datapath_mode_word(bypass_lapse, derive_tot,
          delay_ts_field_use_t) & ~32'h0000_0010;
        csr_write(3'd0, csr_word);
        wait_cycles(2);
      end

      hit1_drv_vif.ready <= ready_low ? 1'b0 : 1'b1;
      wait_cycles(1);

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      expected_discards = stress_discard_count(hit_count, hiterr_period,
        discard_hiterr);
      expected_payloads = hit_count - expected_discards;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [2:0] error_value;

        error_value = '0;
        if (hiterr_period != 0 && (((idx + 1) % hiterr_period) == 0))
          error_value = 3'b001;
        send_stress_hit(idx, derive_tot, idx == 0, 1'b0, error_value, ctx);
        if (gap_cycles != 0)
          wait_cycles(gap_cycles);
        if (burst_len != 0 && ((idx + 1) % burst_len) == 0 &&
            (idx + 1) != hit_count)
          wait_cycles(burst_gap_cycles);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_beat_count(base_beats + expected_payloads, hit_count + 1024,
        ctx);
      wait_for_trace_count(base_traces + expected_payloads, hit_count + 1024,
        ctx);
      expect_stress_stream_since(base_history_size, base_traces, hit_count,
        derive_tot, hiterr_period, discard_hiterr, ctx);

      if (burst_len == 0)
        expect_hit0_spacing(base_inputs, hit_count, 1 + gap_cycles, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(expected_discards, ctx);

      hit1_drv_vif.ready <= 1'b1;
      wait_cycles(2);
    endtask

    task automatic expect_stress_toggle_derive_since(int unsigned base_history_size,
                                                     int unsigned base_traces,
                                                     int unsigned hit_count,
                                                     int unsigned toggle_idx,
                                                     string ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit derive_value;

        derive_value = (idx >= toggle_idx);
        expect_stress_payload_at(base_history_size + idx, base_traces + idx,
          idx, derive_value, $sformatf("%s payload idx=%0d", ctx, idx));
      end
    endtask

    task automatic run_stress_toggle_derive_case(int unsigned hit_count,
                                                 int unsigned toggle_idx,
                                                 string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        if (idx == toggle_idx) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b1, 1'b1));
          wait_cycles(2);
        end
        send_stress_hit(idx, (idx >= toggle_idx), idx == 0, 1'b0, '0, ctx);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      expect_stress_toggle_derive_since(base_history_size, base_traces,
        hit_count, toggle_idx, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_stress_toggle_delay_case(int unsigned hit_count,
                                                int unsigned toggle_idx,
                                                string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b1, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        if (idx == toggle_idx) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b1, 1'b0));
          wait_cycles(2);
        end
        send_stress_hit(idx, 1'b1, idx == 0, 1'b0, '0, ctx);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++)
        expect_stress_payload_at(base_history_size + idx, base_traces + idx,
          idx, 1'b1, $sformatf("%s payload idx=%0d", ctx, idx));
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_stress_bypass_stream_case(bit bypass_lapse,
                                                 int unsigned hit_count,
                                                 string ctx);
      int unsigned raw_value;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned expected_q;
      int unsigned expected_r;

      wait_for_reset_release();
      configure_datapath_mode(bypass_lapse, 1'b0, 1'b1);
      run_start();
      wait_inside_one_wrap_lookback(ctx);
      lookup_raw_for_quotient(2, 0, raw_value, ctx);

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      expected_q        = bypass_lapse ? 2 : 6555;
      expected_r        = bypass_lapse ? 0 : 2;

      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_hit_beat(stress_asic(idx), stress_channel(idx), raw_value,
          raw_value, 1'b0, idx == 0, 1'b0, '0, 1'b1, stress_tfine(idx));

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit expected_error;

        expected_error = bypass_lapse;
        expect_payload_math_at(base_history_size + idx, stress_asic(idx),
          stress_channel(idx), stress_tfine(idx), expected_q, expected_r, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, expected_error,
          $sformatf("%s trace error idx=%0d", ctx, idx));
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_stress_bypass_packet_toggle_case(int unsigned packet_count,
                                                        int unsigned hits_per_packet,
                                                        string ctx);
      int unsigned raw_value;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned hit_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      wait_inside_one_wrap_lookback(ctx);
      lookup_raw_for_quotient(2, 0, raw_value, ctx);

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      hit_count         = packet_count * hits_per_packet;

      for (int unsigned pkt = 0; pkt < packet_count; pkt++) begin
        bit bypass_value;

        bypass_value = pkt[0];
        csr_write(3'd0, datapath_mode_word(bypass_value, 1'b0, 1'b1));
        wait_cycles(2);
        for (int unsigned beat = 0; beat < hits_per_packet; beat++) begin
          int unsigned idx;

          idx = (pkt * hits_per_packet) + beat;
          send_hit_beat(stress_asic(idx), stress_channel(idx), raw_value,
            raw_value, 1'b0, beat == 0, beat == hits_per_packet - 1, '0,
            1'b1, stress_tfine(idx));
        end
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned pkt;
        bit          bypass_value;
        int unsigned expected_q;
        int unsigned expected_r;

        pkt          = idx / hits_per_packet;
        bypass_value = pkt[0];
        expected_q   = bypass_value ? 2 : 6555;
        expected_r   = bypass_value ? 0 : 2;
        expect_payload_math_at(base_history_size + idx, stress_asic(idx),
          stress_channel(idx), stress_tfine(idx), expected_q, expected_r, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, bypass_value,
          $sformatf("%s trace error idx=%0d", ctx, idx));
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_stress_latency_rewrite_case(int unsigned phase_hits,
                                                   string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned hit_count;
      int unsigned latencies[4];

      latencies[0] = 1;
      latencies[1] = 4096;
      latencies[2] = 2;
      latencies[3] = 4096;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      hit_count         = phase_hits * 4;

      for (int unsigned phase = 0; phase < 4; phase++) begin
        csr_write(3'd2, latencies[phase]);
        wait_cycles(2);
        for (int unsigned beat = 0; beat < phase_hits; beat++) begin
          int unsigned idx;

          idx = (phase * phase_hits) + beat;
          send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, ctx);
        end
        wait_for_beat_count(base_beats + ((phase + 1) * phase_hits),
          phase_hits + 1024, $sformatf("%s phase %0d", ctx, phase));
        wait_for_trace_count(base_traces + ((phase + 1) * phase_hits),
          phase_hits + 1024, $sformatf("%s phase %0d", ctx, phase));
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned phase;
        bit          expected_error;

        phase          = idx / phase_hits;
        expected_error = (latencies[phase] < 16);
        expect_payload_math_at(base_history_size + idx, stress_asic(idx),
          stress_channel(idx), stress_tfine(idx), stress_t_quotient(idx),
          stress_t_remainder(idx), stress_expected_et(idx, 1'b0),
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_expected_latency_at(base_traces + idx, latencies[phase],
          $sformatf("%s latency idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, expected_error,
          $sformatf("%s error idx=%0d", ctx, idx));
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    localparam int unsigned PROFILE_PATTERN_RR_ENABLED    = 0;
    localparam int unsigned PROFILE_PATTERN_HOT_CH0       = 1;
    localparam int unsigned PROFILE_PATTERN_HOT_CH3       = 2;
    localparam int unsigned PROFILE_PATTERN_PAYLOAD_SWEEP = 3;
    localparam int unsigned PROFILE_PATTERN_ASIC_SWEEP    = 4;
    localparam int unsigned PROFILE_PATTERN_SINGLE_PACKET = 5;
    localparam int unsigned PROFILE_PATTERN_MULTI_PACKET  = 6;
    localparam int unsigned PROFILE_PATTERN_MUX_BITS      = 7;

    function automatic int unsigned profile_route_from_q(int unsigned quotient);
      return (quotient >> 4) & 3;
    endfunction

    function automatic int unsigned profile_route_quotient(int unsigned route,
                                                           int unsigned idx);
      return ((route & 3) * 16) + (idx % 16);
    endfunction

    task automatic profile_pattern_fields(int unsigned pattern,
                                          int unsigned idx,
                                          output int unsigned sideband_channel,
                                          output int unsigned asic_value,
                                          output int unsigned channel_value,
                                          output int unsigned quotient,
                                          output int unsigned remainder,
                                          output bit sop_value,
                                          output bit eop_value,
                                          output int unsigned tfine_value,
                                          input string ctx);
      sideband_channel = 0;
      asic_value       = 2;
      channel_value    = idx % 32;
      quotient         = idx % 64;
      remainder        = idx % 5;
      sop_value        = (idx == 0);
      eop_value        = 1'b0;
      tfine_value      = idx % 32;

      case (pattern)
        PROFILE_PATTERN_RR_ENABLED: begin
          sideband_channel = idx % 4;
          channel_value    = idx % 4;
          quotient         = profile_route_quotient(idx % 4, idx / 4);
          sop_value        = (idx < 4);
        end
        PROFILE_PATTERN_HOT_CH0: begin
          sideband_channel = 0;
          channel_value    = 0;
          quotient         = profile_route_quotient(0, idx);
        end
        PROFILE_PATTERN_HOT_CH3: begin
          sideband_channel = 3;
          channel_value    = 3;
          quotient         = profile_route_quotient(3, idx);
        end
        PROFILE_PATTERN_PAYLOAD_SWEEP: begin
          sideband_channel = 2;
          asic_value       = 2;
          channel_value    = idx % 32;
        end
        PROFILE_PATTERN_ASIC_SWEEP: begin
          sideband_channel = 0;
          asic_value       = idx % 16;
          channel_value    = 7;
        end
        PROFILE_PATTERN_SINGLE_PACKET: begin
          sideband_channel = idx % 4;
          channel_value    = idx % 4;
          sop_value        = 1'b1;
          eop_value        = 1'b1;
        end
        PROFILE_PATTERN_MULTI_PACKET: begin
          sideband_channel = (idx / 4) % 4;
          channel_value    = sideband_channel;
          sop_value        = ((idx % 4) == 0);
          eop_value        = ((idx % 4) == 3);
        end
        PROFILE_PATTERN_MUX_BITS: begin
          sideband_channel = 6'b10_0000 | (idx % 4);
          channel_value    = idx % 4;
          sop_value        = (idx == 0);
        end
        default:
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s unsupported profile pattern %0d", ctx, pattern))
      endcase
    endtask

    task automatic send_profile_hit(int unsigned sideband_channel,
                                    int unsigned asic_value,
                                    int unsigned channel_value,
                                    int unsigned quotient,
                                    int unsigned remainder,
                                    bit sop_value,
                                    bit eop_value,
                                    bit [2:0] error_value,
                                    int unsigned tfine_value,
                                    string ctx);
      int unsigned raw_value;

      lookup_raw_for_quotient(quotient, remainder, raw_value, ctx);
      send_hit_beat_with_sideband(sideband_channel, asic_value, channel_value,
        raw_value, raw_value, 1'b0, sop_value, eop_value, error_value, 1'b1,
        tfine_value);
    endtask

    task automatic expect_hit0_fields_at(int unsigned input_idx,
                                         int unsigned sideband_channel,
                                         bit sop_value,
                                         bit eop_value,
                                         bit [2:0] error_value,
                                         string ctx);
      mtsp_hit0_obs_item hit_obs;

      if (input_idx >= m_env.m_scb.hit0_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected input index %0d, size=%0d",
            ctx, input_idx, m_env.m_scb.hit0_history.size()))
      hit_obs = m_env.m_scb.hit0_history[input_idx];
      if (hit_obs.channel !== sideband_channel[5:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected sideband channel=0x%02h got 0x%02h",
            ctx, sideband_channel[5:0], hit_obs.channel))
      if (hit_obs.sop !== sop_value || hit_obs.eop !== eop_value ||
          hit_obs.error !== error_value)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected input sop/eop/error=%0b/%0b/%0h got %0b/%0b/%0h",
            ctx, sop_value, eop_value, error_value, hit_obs.sop, hit_obs.eop,
            hit_obs.error))
    endtask

    task automatic expect_profile_payload_at(int unsigned history_idx,
                                             int unsigned trace_idx,
                                             int unsigned asic_value,
                                             int unsigned channel_value,
                                             int unsigned tfine_value,
                                             int unsigned quotient,
                                             int unsigned remainder,
                                             int unsigned route_value,
                                             bit expected_sop,
                                             string ctx);
      mtsp_hit1_obs_item hit_obs;

      expect_payload_math_at(history_idx, asic_value, channel_value,
        tfine_value, quotient, remainder, 0, ctx);
      hit_obs = m_env.m_scb.history[history_idx];
      if (hit_obs.channel !== route_value[3:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected route=%0d got %0d data=0x%010h",
            ctx, route_value[3:0], hit_obs.channel, hit_obs.data))
      if (hit_obs.sop !== expected_sop || hit_obs.eop !== 1'b0 ||
          hit_obs.empty !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected output sop/eop/empty=%0b/0/0 got %0b/%0b/%0b",
            ctx, expected_sop, hit_obs.sop, hit_obs.eop, hit_obs.empty))
      expect_trace_pair_at(trace_idx, ctx);
      expect_trace_math_self_consistent_at(trace_idx, ctx);
    endtask

    task automatic run_profile_variance_case(int unsigned hit_count,
                                             int unsigned pattern,
                                             string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      bit          route_seen[4];

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned sideband_channel;
        int unsigned asic_value;
        int unsigned channel_value;
        int unsigned quotient;
        int unsigned remainder;
        int unsigned tfine_value;
        bit          sop_value;
        bit          eop_value;

        profile_pattern_fields(pattern, idx, sideband_channel, asic_value,
          channel_value, quotient, remainder, sop_value, eop_value,
          tfine_value, ctx);
        send_profile_hit(sideband_channel, asic_value, channel_value,
          quotient, remainder, sop_value, eop_value, '0, tfine_value,
          $sformatf("%s profile hit idx=%0d", ctx, idx));
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);

      foreach (route_seen[route])
        route_seen[route] = 1'b0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned sideband_channel;
        int unsigned asic_value;
        int unsigned channel_value;
        int unsigned quotient;
        int unsigned remainder;
        int unsigned route_value;
        int unsigned tfine_value;
        bit          sop_value;
        bit          eop_value;
        bit          expected_sop;

        profile_pattern_fields(pattern, idx, sideband_channel, asic_value,
          channel_value, quotient, remainder, sop_value, eop_value,
          tfine_value, ctx);
        route_value  = profile_route_from_q(quotient);
        expected_sop = !route_seen[route_value];
        route_seen[route_value] = 1'b1;
        expect_hit0_fields_at(base_inputs + idx, sideband_channel, sop_value,
          eop_value, '0, $sformatf("%s input idx=%0d", ctx, idx));
        expect_profile_payload_at(base_history_size + idx, base_traces + idx,
          asic_value, channel_value, tfine_value, quotient, remainder,
          route_value, expected_sop, $sformatf("%s payload idx=%0d", ctx, idx));
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic read_total_count_coherent(output bit [47:0] total_count,
                                             input string ctx);
      bit [31:0] hi_before;
      bit [31:0] hi_after;
      bit [31:0] lo_word;

      csr_read(3'd3, hi_before);
      csr_read(3'd4, lo_word);
      csr_read(3'd3, hi_after);
      if (hi_before[31:16] !== 16'd0 || hi_after[31:16] !== 16'd0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected zero-extended total-count high read, got before=0x%08h after=0x%08h",
            ctx, hi_before, hi_after))
      total_count = (hi_before[15:0] == hi_after[15:0]) ?
        {hi_before[15:0], lo_word} : {hi_after[15:0], lo_word};
    endtask

    task automatic poll_total_count_monotonic(int unsigned sample_count,
                                              int unsigned interval_cycles,
                                              bit [47:0] max_expected,
                                              string ctx);
      bit [47:0] last_total;
      bit [47:0] total_count;

      last_total = '0;
      for (int unsigned sample = 0; sample < sample_count; sample++) begin
        wait_cycles(interval_cycles);
        read_total_count_coherent(total_count,
          $sformatf("%s total poll sample=%0d", ctx, sample));
        if (total_count < last_total)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s total counter moved backwards at sample %0d: last=%0d now=%0d",
              ctx, sample, last_total, total_count))
        if (total_count > max_expected)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s total counter exceeded max at sample %0d: got=%0d max=%0d",
              ctx, sample, total_count, max_expected))
        last_total = total_count;
      end
    endtask

    task automatic run_discard_counter_monotonic_case(int unsigned hit_count,
                                                      string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      bit [31:0]   last_discard;
      bit [31:0]   discard_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs    = m_env.m_scb.hit0_history.size();
      base_beats     = m_env.m_scb.beat_count;
      base_eops      = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      last_discard   = 32'd0;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, 3'b001, ctx);
        if (((idx + 1) % 128) == 0) begin
          csr_read(3'd1, discard_count);
          if (discard_count < last_discard)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s discard counter moved backwards at idx=%0d: last=%0d now=%0d",
                ctx, idx, last_discard, discard_count))
          if (discard_count > (idx + 1))
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s discard counter exceeded accepted hit count at idx=%0d: got=%0d",
                ctx, idx, discard_count))
          last_discard = discard_count;
        end
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 256, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(hit_count[31:0], ctx);
    endtask

    task automatic run_counter_poll_snapshot_case(int unsigned hit_count,
                                                  int unsigned sample_count,
                                                  int unsigned interval_cycles,
                                                  string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      fork
        begin
          for (int unsigned idx = 0; idx < hit_count; idx++)
            send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, ctx);
        end
        begin
          poll_total_count_monotonic(sample_count, interval_cycles, hit_count,
            ctx);
        end
      join

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      expect_stress_stream_since(base_history_size, base_traces, hit_count,
        1'b0, 0, 1'b1, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_soft_reset_periodic_soak_case(int unsigned phases,
                                                     int unsigned hits_per_phase,
                                                     int unsigned interval_cycles,
                                                     string ctx);
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      for (int unsigned phase = 0; phase < phases; phase++) begin
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history_size;
        int unsigned base_traces;

        wait_for_hit0_ready(1'b1, 64,
          $sformatf("%s phase %0d hit ready", ctx, phase));
        base_inputs       = m_env.m_scb.hit0_history.size();
        base_beats        = m_env.m_scb.beat_count;
        base_history_size = m_env.m_scb.history.size();
        base_traces       = m_env.m_scb.trace_history.size();

        for (int unsigned beat = 0; beat < hits_per_phase; beat++) begin
          int unsigned idx;

          idx = beat;
          send_stress_hit(idx, 1'b0, beat == 0, 1'b0, '0,
            $sformatf("%s phase %0d", ctx, phase));
        end

        wait_for_input_count(base_inputs + hits_per_phase,
          hits_per_phase + 512, $sformatf("%s phase %0d inputs", ctx, phase));
        wait_for_beat_count(base_beats + hits_per_phase,
          hits_per_phase + 1024, $sformatf("%s phase %0d beats", ctx, phase));
        wait_for_trace_count(base_traces + hits_per_phase,
          hits_per_phase + 1024, $sformatf("%s phase %0d traces", ctx, phase));
        for (int unsigned beat = 0; beat < hits_per_phase; beat++) begin
          int unsigned idx;

          idx = beat;
          expect_stress_payload_at(base_history_size + beat,
            base_traces + beat, idx, 1'b0,
            $sformatf("%s phase %0d payload beat=%0d", ctx, phase, beat));
        end
        expect_total_count(hits_per_phase, $sformatf("%s phase %0d count",
          ctx, phase));

        wait_cycles(interval_cycles);
        csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1) | 32'h0000_0004);
        wait_cycles(4);
        expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004,
          $sformatf("%s phase %0d soft_reset self-clear", ctx, phase));
        expect_total_count(48'd0,
          $sformatf("%s phase %0d post-soft-reset total", ctx, phase));
        expect_discard_count(32'd0,
          $sformatf("%s phase %0d post-soft-reset discard", ctx, phase));
      end
    endtask

    task automatic run_global_reset_periodic_recovery_case(int unsigned phases,
                                                           int unsigned hits_per_phase,
                                                           string ctx);
      for (int unsigned phase = 0; phase < phases; phase++) begin
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history_size;
        int unsigned base_traces;

        drive_global_reset(4, 4);
        wait_for_reset_release();
        configure_datapath_mode(1'b1, 1'b0, 1'b1);
        run_start();

        base_inputs       = m_env.m_scb.hit0_history.size();
        base_beats        = m_env.m_scb.beat_count;
        base_history_size = m_env.m_scb.history.size();
        base_traces       = m_env.m_scb.trace_history.size();

        for (int unsigned beat = 0; beat < hits_per_phase; beat++) begin
          int unsigned idx;

          idx = beat;
          send_stress_hit(idx, 1'b0, beat == 0, 1'b0, '0,
            $sformatf("%s phase %0d", ctx, phase));
        end

        wait_for_input_count(base_inputs + hits_per_phase,
          hits_per_phase + 512, $sformatf("%s phase %0d inputs", ctx, phase));
        wait_for_beat_count(base_beats + hits_per_phase,
          hits_per_phase + 1024, $sformatf("%s phase %0d beats", ctx, phase));
        wait_for_trace_count(base_traces + hits_per_phase,
          hits_per_phase + 1024, $sformatf("%s phase %0d traces", ctx, phase));
        for (int unsigned beat = 0; beat < hits_per_phase; beat++) begin
          int unsigned idx;

          idx = beat;
          expect_stress_payload_at(base_history_size + beat,
            base_traces + beat, idx, 1'b0,
            $sformatf("%s phase %0d payload beat=%0d", ctx, phase, beat));
        end
        expect_total_count(hits_per_phase, $sformatf("%s phase %0d total",
          ctx, phase));
        expect_discard_count(32'd0, $sformatf("%s phase %0d discard",
          ctx, phase));
      end

      drive_global_reset(4, 4);
      wait_for_reset_release();
      expect_total_count(48'd0, $sformatf("%s final reset total", ctx));
      expect_discard_count(32'd0, $sformatf("%s final reset discard", ctx));
    endtask

    task automatic run_control_sequence_repeated_case(bit direct_running,
                                                      int unsigned iterations,
                                                      string ctx);
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        if (direct_running) begin
          send_ctrl(CTRL_RUNNING, $sformatf("DIRECT_RUNNING_%0d", iter));
          wait_for_running_status(64,
            $sformatf("%s direct-running iter=%0d", ctx, iter));
          wait_for_hit0_ready(1'b1, 16,
            $sformatf("%s direct-running ready iter=%0d", ctx, iter));
        end else begin
          run_start();
        end
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_%0d", iter));
        wait_cycles(2);
        expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
          $sformatf("%s post-idle iter=%0d", ctx, iter));
      end

      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 16, ctx);
      expect_total_count(48'd0, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_force_stop_periodic_case(int unsigned block_count,
                                                int unsigned block_size,
                                                string ctx);
      int unsigned hit_count;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned emitted_idx;

      hit_count = block_count * block_size;
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit force_drop;

        force_drop = (((idx + 1) % block_size) == 0);
        if (force_drop) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1) |
            32'h0000_0002);
          wait_cycles(2);
        end
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, ctx);
        if (force_drop) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1));
          wait_cycles(2);
        end
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count - block_count,
        hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count - block_count,
        hit_count + 2048, ctx);

      emitted_idx = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit force_drop;

        force_drop = (((idx + 1) % block_size) == 0);
        if (!force_drop) begin
          expect_stress_payload_at(base_history_size + emitted_idx,
            base_traces + emitted_idx, idx, 1'b0,
            $sformatf("%s payload idx=%0d", ctx, idx));
          emitted_idx++;
        end
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(block_count[31:0], ctx);
    endtask

    task automatic run_csr_poll_under_load_case(int unsigned hit_count,
                                                int unsigned poll_count,
                                                int unsigned interval_cycles,
                                                string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_csr_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_csr_count    = m_env.m_scb.csr_access_count;

      fork
        begin
          for (int unsigned idx = 0; idx < hit_count; idx++)
            send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, ctx);
        end
        begin
          for (int unsigned poll = 0; poll < poll_count; poll++) begin
            bit [31:0] csr_word;
            bit [47:0] total_snapshot;

            wait_cycles(interval_cycles);
            csr_read(3'd0, csr_word);
            if (csr_word[0] !== 1'b1)
              `uvm_fatal("MTSP_CASE",
                $sformatf("%s poll %0d expected RUNNING status, csr0=0x%08h",
                  ctx, poll, csr_word))
            csr_read(3'd1, csr_word);
            if (csr_word !== 32'd0)
              `uvm_fatal("MTSP_CASE",
                $sformatf("%s poll %0d expected zero discard, got %0d",
                  ctx, poll, csr_word))
            csr_read(3'd2, csr_word);
            if (csr_word !== 32'd2000)
              `uvm_fatal("MTSP_CASE",
                $sformatf("%s poll %0d expected latency=2000, got %0d",
                  ctx, poll, csr_word))
            read_total_count_coherent(total_snapshot,
              $sformatf("%s poll %0d total snapshot", ctx, poll));
            if (total_snapshot > hit_count)
              `uvm_fatal("MTSP_CASE",
                $sformatf("%s poll %0d total snapshot exceeded hit count: %0d",
                  ctx, poll, total_snapshot))
          end
        end
      join

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      expect_stress_stream_since(base_history_size, base_traces, hit_count,
        1'b0, 0, 1'b1, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
      if (m_env.m_scb.csr_access_count < base_csr_count + (poll_count * 6))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected at least %0d CSR monitor observations, got %0d from base %0d",
            ctx, poll_count * 6, m_env.m_scb.csr_access_count,
            base_csr_count))
    endtask

    task automatic do_stress_001_line_rate_short_mode();
      run_stress_stream_case(64, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_002_line_rate_tot_mode();
      run_stress_stream_case(64, 0, 1'b1, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_003_every_other_cycle_stream();
      run_stress_stream_case(64, 1, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_004_burst_of_eight_pattern();
      run_stress_stream_case(64, 0, 1'b0, 1'b1, 1'b1, 8, 2, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_005_clean_hiterr_free_soak();
      run_stress_stream_case(128, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_006_mixed_hiterr_soak_keep_disabled();
      run_stress_stream_case(128, 0, 1'b0, 1'b1, 1'b1, 0, 0, 8, 1'b0,
        1'b0, case_id);
    endtask

    task automatic do_stress_007_mixed_hiterr_soak_discard_enabled();
      run_stress_stream_case(128, 0, 1'b0, 1'b1, 1'b1, 0, 0, 8, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_008_sustained_output_ready_high();
      run_stress_stream_case(64, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_009_sustained_output_ready_low();
      run_stress_stream_case(64, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b1, case_id);
    endtask

    task automatic do_stress_010_flushing_after_large_backlog();
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned hit_count;

      hit_count = 33;
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;

      for (int unsigned idx = 0; idx < hit_count - 1; idx++)
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, case_id);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", case_id));
      send_stress_hit(hit_count - 1, 1'b0, 1'b0, 1'b1, '0, case_id);
      send_endofrun_pulse();

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, case_id);
      wait_for_beat_count(base_beats + hit_count + 4, hit_count + 1024,
        case_id);
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024,
        case_id);
      wait_for_empty_eop_count(base_empty_eops + 4, hit_count + 1024,
        case_id);
      expect_stress_stream_since(base_history_size, base_traces, hit_count,
        1'b0, 0, 1'b1, case_id);
      expect_close_markers_since(base_history_size, 4'b1111, hit_count,
        $sformatf("%s close markers after loaded flush", case_id));
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore",
        case_id));
      expect_total_count(hit_count, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_011_long_run_short_mode();
      run_stress_stream_case(256, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_012_long_run_tot_mode();
      run_stress_stream_case(256, 0, 1'b1, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_013_toggle_derive_tot_every_256_hits();
      run_stress_toggle_derive_case(512, 256, case_id);
    endtask

    task automatic do_stress_014_long_run_delay_field_t();
      run_stress_stream_case(256, 0, 1'b1, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_015_long_run_delay_field_e();
      run_stress_stream_case(256, 0, 1'b1, 1'b1, 1'b0, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_016_toggle_delay_field_every_256_hits();
      run_stress_toggle_delay_case(512, 256, case_id);
    endtask

    task automatic do_stress_017_long_run_bypass_off();
      run_stress_bypass_stream_case(1'b0, 64, case_id);
    endtask

    task automatic do_stress_018_long_run_bypass_on();
      run_stress_bypass_stream_case(1'b1, 64, case_id);
    endtask

    task automatic do_stress_019_toggle_bypass_between_packets();
      run_stress_bypass_packet_toggle_case(4, 8, case_id);
    endtask

    task automatic do_stress_020_rewrite_expected_latency_mid_run();
      run_stress_latency_rewrite_case(16, case_id);
    endtask

    task automatic do_stress_021_round_robin_enabled_channels();
      run_profile_variance_case(128, PROFILE_PATTERN_RR_ENABLED, case_id);
    endtask

    task automatic do_stress_022_hotspot_channel0();
      run_profile_variance_case(64, PROFILE_PATTERN_HOT_CH0, case_id);
    endtask

    task automatic do_stress_023_hotspot_channel3();
      run_profile_variance_case(64, PROFILE_PATTERN_HOT_CH3, case_id);
    endtask

    task automatic do_stress_024_dense_payload_channel_sweep();
      run_profile_variance_case(128, PROFILE_PATTERN_PAYLOAD_SWEEP, case_id);
    endtask

    task automatic do_stress_025_dense_asic_id_sweep();
      run_profile_variance_case(128, PROFILE_PATTERN_ASIC_SWEEP, case_id);
    endtask

    task automatic do_stress_026_single_beat_packet_stream();
      run_profile_variance_case(64, PROFILE_PATTERN_SINGLE_PACKET, case_id);
    endtask

    task automatic do_stress_027_multi_beat_packet_stream();
      run_profile_variance_case(64, PROFILE_PATTERN_MULTI_PACKET, case_id);
    endtask

    task automatic do_stress_028_periodic_hiterr_every_16th();
      run_stress_stream_case(256, 0, 1'b0, 1'b1, 1'b1, 0, 0, 16, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_029_periodic_hiterr_keep_mode();
      run_stress_stream_case(256, 0, 1'b0, 1'b1, 1'b1, 0, 0, 16, 1'b0,
        1'b0, case_id);
    endtask

    task automatic do_stress_030_nonzero_mux_bits_under_load();
      run_profile_variance_case(64, PROFILE_PATTERN_MUX_BITS, case_id);
    endtask

    task automatic do_stress_031_discard_counter_monotonic_1k();
      run_discard_counter_monotonic_case(1024, case_id);
    endtask

    task automatic do_stress_032_total_counter_monotonic_1k();
      run_stress_stream_case(1024, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_033_mixed_accept_reject_counter_soak();
      run_stress_stream_case(1024, 0, 1'b0, 1'b1, 1'b1, 0, 0, 8, 1'b1,
        1'b0, case_id);
    endtask

    task automatic do_stress_034_hi_lo_snapshot_polling();
      run_counter_poll_snapshot_case(512, 16, 32, case_id);
    endtask

    task automatic do_stress_035_soft_reset_every_10k_cycles();
      run_soft_reset_periodic_soak_case(3, 16, 10000, case_id);
    endtask

    task automatic do_stress_036_global_reset_periodic_recovery();
      run_global_reset_periodic_recovery_case(3, 16, case_id);
    endtask

    task automatic do_stress_037_standard_run_sequence_repeated_100x();
      run_control_sequence_repeated_case(1'b0, 100, case_id);
    endtask

    task automatic do_stress_038_direct_running_sequence_repeated_100x();
      run_control_sequence_repeated_case(1'b1, 100, case_id);
    endtask

    task automatic do_stress_039_force_stop_pulse_every_100_hits();
      run_force_stop_periodic_case(5, 100, case_id);
    endtask

    task automatic do_stress_040_csr_poll_every_32_cycles();
      run_csr_poll_under_load_case(256, 8, 32, case_id);
    endtask

    task automatic do_stress_041_single_overflow_run();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      send_overflow_hit_and_expect(0, 16, 0, 16, 0, 1'b0, 1'b0, 1'b0,
        2, 0, 0, 1'b1, 1'b0, 1'b0,
        $sformatf("%s pre-overflow reference", case_id));
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      send_overflow_hit_and_expect(1, 4553, 1, 4553, 1, 1'b0, 1'b0, 1'b0,
        2, 1, 1, 1'b0, 1'b0, 1'b0,
        $sformatf("%s equal-upper no-adjust hit", case_id));
      send_overflow_hit_and_expect(1, 4553, 2, 4553, 2, 1'b0, 1'b0, 1'b0,
        2, 2, 2, 1'b0, 1'b0, 1'b0,
        $sformatf("%s one-above-upper adjust hit", case_id));
      expect_total_count(48'd3, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_042_many_overflow_run();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      for (int unsigned wrap = 1; wrap <= 3; wrap++) begin
        wait_for_overflow_lookback_at_count(wrap, 9000,
          $sformatf("%s overflow wrap=%0d", case_id, wrap));
        send_overflow_hit_and_expect(wrap, 5000, 0, 5000, 0, 1'b0, 1'b0,
          1'b0, 2, wrap, wrap[4:0], wrap == 1, 1'b0, 1'b0,
          $sformatf("%s adjusted hit wrap=%0d", case_id, wrap));
      end
      expect_total_count(48'd3, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_043_hits_just_below_upper_across_overflow();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      for (int unsigned wrap = 1; wrap <= 2; wrap++) begin
        wait_for_overflow_lookback_at_count(wrap, 9000,
          $sformatf("%s overflow wrap=%0d", case_id, wrap));
        send_overflow_hit_and_expect(wrap, 4553, 0, 4553, 0, 1'b0, 1'b0,
          1'b0, 2, wrap * 2, 3, wrap == 1, 1'b0, 1'b0,
          $sformatf("%s below-upper hit wrap=%0d", case_id, wrap));
        send_overflow_hit_and_expect(wrap, 4553, 1, 4553, 1, 1'b0, 1'b0,
          1'b0, 2, (wrap * 2) + 1, 4, 1'b0, 1'b0, 1'b0,
          $sformatf("%s equal-upper hit wrap=%0d", case_id, wrap));
      end
      expect_total_count(48'd4, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_044_hits_just_above_upper_across_overflow();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      for (int unsigned wrap = 1; wrap <= 2; wrap++) begin
        wait_for_overflow_lookback_at_count(wrap, 9000,
          $sformatf("%s overflow wrap=%0d", case_id, wrap));
        send_overflow_hit_and_expect(wrap, 4553, 2, 4553, 2, 1'b0, 1'b0,
          1'b0, 2, wrap * 2, 5, wrap == 1, 1'b0, 1'b0,
          $sformatf("%s one-above-upper hit wrap=%0d", case_id, wrap));
        send_overflow_hit_and_expect(wrap, 4553, 3, 4553, 3, 1'b0, 1'b0,
          1'b0, 2, (wrap * 2) + 1, 6, 1'b0, 1'b0, 1'b0,
          $sformatf("%s two-above-upper hit wrap=%0d", case_id, wrap));
      end
      expect_total_count(48'd4, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_045_mixed_t_and_e_adjust_eligibility();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b1, 1'b1);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      send_overflow_hit_and_expect(1, 4553, 0, 4553, 1, 1'b1, 1'b0, 1'b1,
        2, 0, 7, 1'b1, 1'b0, 1'b0,
        $sformatf("%s neither path adjusts", case_id));
      send_overflow_hit_and_expect(1, 4553, 2, 4553, 1, 1'b1, 1'b0, 1'b1,
        2, 1, 8, 1'b0, 1'b0, 1'b0,
        $sformatf("%s T-only adjustment", case_id));
      send_overflow_hit_and_expect(1, 4553, 1, 4553, 2, 1'b1, 1'b0, 1'b1,
        2, 2, 9, 1'b0, 1'b0, 1'b0,
        $sformatf("%s E-only adjustment", case_id));
      send_overflow_hit_and_expect(1, 4553, 2, 4553, 3, 1'b1, 1'b0, 1'b1,
        2, 3, 10, 1'b0, 1'b0, 1'b0,
        $sformatf("%s both paths adjust", case_id));
      expect_total_count(48'd4, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_046_bypass_off_overflow_soak();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      for (int unsigned idx = 0; idx < 16; idx++)
        send_overflow_hit_and_expect(1, 5000 + (idx % 4), idx % 5,
          5000 + (idx % 4), idx % 5, 1'b0, 1'b0, 1'b0, 2,
          idx % 32, idx % 32, idx == 0, 1'b0, 1'b0,
          $sformatf("%s bypass-off overflow idx=%0d", case_id, idx));
      expect_total_count(48'd16, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_047_bypass_on_overflow_soak();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      for (int unsigned idx = 0; idx < 16; idx++)
        send_overflow_hit_and_expect(1, 5000 + (idx % 4), idx % 5,
          5000 + (idx % 4), idx % 5, 1'b0, 1'b1, 1'b0, 2,
          idx % 32, idx % 32, idx == 0, 1'b0, 1'b0,
          $sformatf("%s bypass-on overflow idx=%0d", case_id, idx));
      expect_total_count(48'd16, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_048_small_expected_latency_overflow();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      csr_write(3'd2, 32'd1);
      wait_cycles(2);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      for (int unsigned idx = 0; idx < 4; idx++)
        send_overflow_hit_and_expect(1, 5000 + idx, 0, 5000 + idx, 0,
          1'b0, 1'b0, 1'b0, 2, idx, idx[4:0], idx == 0, 1'b1, 1'b1,
          $sformatf("%s small-latency overflow idx=%0d", case_id, idx));
      expect_total_count(48'd4, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_049_large_expected_latency_overflow();
      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      csr_write(3'd2, 32'h0000_ffff);
      wait_cycles(2);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      for (int unsigned idx = 0; idx < 4; idx++)
        send_overflow_hit_and_expect(1, 5000 + idx, 0, 5000 + idx, 0,
          1'b0, 1'b0, 1'b0, 2, idx, idx[4:0], idx == 0, 1'b1, 1'b0,
          $sformatf("%s large-latency overflow idx=%0d", case_id, idx));
      expect_total_count(48'd4, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_stress_050_dense_divider_launch_overflow();
      int unsigned raw_value;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      bit          busy;
      bit          active;
      bit          saw_busy_and_active;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", case_id));
      lookup_raw_for_quotient(5000, 0, raw_value, case_id);

      base_inputs          = m_env.m_scb.hit0_history.size();
      base_beats           = m_env.m_scb.beat_count;
      base_history         = m_env.m_scb.history.size();
      base_traces          = m_env.m_scb.trace_history.size();
      saw_busy_and_active  = 1'b0;
      for (int unsigned idx = 0; idx < 96; idx++) begin
        send_hit_beat(2, idx % 32, raw_value, raw_value, 1'b0, idx == 0,
          1'b0, '0, 1'b1, idx[4:0]);
        read_dut_bit("/tb_top/dut/hit_div_busy", busy,
          $sformatf("%s dense overflow busy idx=%0d", case_id, idx));
        read_dut_bit("/tb_top/dut/overflow_adjust_active", active,
          $sformatf("%s dense overflow active idx=%0d", case_id, idx));
        if (busy && active)
          saw_busy_and_active = 1'b1;
      end

      wait_for_input_count(base_inputs + 96, 512, case_id);
      wait_for_beat_count(base_beats + 96, 2048, case_id);
      wait_for_trace_count(base_traces + 96, 2048, case_id);
      if (!saw_busy_and_active)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s never observed divider busy during overflow adjust",
            case_id))
      for (int unsigned idx = 0; idx < 96; idx++) begin
        expect_payload_math_at(base_history + idx, 2, idx % 32, idx[4:0],
          5000, 0, 0,
          $sformatf("%s dense overflow payload idx=%0d", case_id, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s dense overflow trace idx=%0d", case_id, idx));
        expect_trace_math_self_consistent_at(base_traces + idx,
          $sformatf("%s dense overflow trace math idx=%0d", case_id, idx));
      end
      expect_total_count(48'd96, case_id);
      expect_discard_count(32'd0, case_id);
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
        "STD_MTS_081_route_lane0": do_std_081_route_lane0();
        "STD_MTS_082_route_lane1": do_std_082_route_lane1();
        "STD_MTS_083_route_lane2": do_std_083_route_lane2();
        "STD_MTS_084_route_lane3": do_std_084_route_lane3();
        "STD_MTS_085_error_low_in_range": do_std_085_error_low_in_range();
        "STD_MTS_086_error_high_at_zero": do_std_086_error_high_at_zero();
        "STD_MTS_087_error_high_for_negative": do_std_087_error_high_for_negative();
        "STD_MTS_088_error_high_at_or_above_limit": do_std_088_error_high_at_or_above_limit();
        "STD_MTS_089_debug_ts_valid_alignment": do_std_089_debug_ts_valid_alignment();
        "STD_MTS_090_delay_field_changes_error_source": do_std_090_delay_field_changes_error_source();
        "STD_MTS_091_debug_burst_only_running": do_std_091_debug_burst_only_running();
        "STD_MTS_092_ts_delta_only_running": do_std_092_ts_delta_only_running();
        "STD_MTS_093_first_running_hit_warms_history": do_std_093_first_running_hit_warms_history();
        "STD_MTS_094_positive_timestamp_delta": do_std_094_positive_timestamp_delta();
        "STD_MTS_095_negative_timestamp_delta": do_std_095_negative_timestamp_delta();
        "STD_MTS_096_zero_timestamp_delta": do_std_096_zero_timestamp_delta();
        "STD_MTS_097_positive_signmag_conversion": do_std_097_positive_signmag_conversion();
        "STD_MTS_098_negative_signmag_conversion": do_std_098_negative_signmag_conversion();
        "STD_MTS_099_arrival_delta_uses_gts": do_std_099_arrival_delta_uses_gts();
        "STD_MTS_100_debug_streams_clear_outside_running": do_std_100_debug_streams_clear_outside_running();
        "STD_MTS_101_replay_smoke_positive_et": do_std_101_replay_smoke_positive_et();
        "STD_MTS_102_replay_smoke_eflag_zero": do_std_102_replay_smoke_eflag_zero();
        "STD_MTS_103_replay_smoke_clamp_vector": do_std_103_replay_smoke_clamp_vector();
        "STD_MTS_104_discard_counter_matches_rejections": do_std_104_discard_counter_matches_rejections();
        "STD_MTS_105_total_counter_matches_all_valid": do_std_105_total_counter_matches_all_valid();
        "STD_MTS_106_total_counter_hi_rollover": do_std_106_total_counter_hi_rollover();
        "STD_MTS_107_soft_reset_clears_counters": do_std_107_soft_reset_clears_counters();
        "STD_MTS_108_sync_clears_counters": do_std_108_sync_clears_counters();
        "STD_MTS_109_running_status_bit_semantics": do_std_109_running_status_bit_semantics();
        "STD_MTS_110_force_stop_persists_until_cleared": do_std_110_force_stop_persists_until_cleared();
        "STD_MTS_111_compile_rtl_default_div_pipeline": do_std_111_compile_rtl_default_div_pipeline();
        "STD_MTS_112_compile_packaged_div_pipeline": do_std_112_compile_packaged_div_pipeline();
        "STD_MTS_113_single_enabled_channel_window": do_std_113_single_enabled_channel_window();
        "STD_MTS_114_upper_enabled_window": do_std_114_upper_enabled_window();
        "STD_MTS_115_remapped_hiterr_bit": do_std_115_remapped_hiterr_bit();
        "STD_MTS_116_remapped_crcerr_still_inert": do_std_116_remapped_crcerr_still_inert();
        "STD_MTS_117_remapped_frame_corrupt_still_inert": do_std_117_remapped_frame_corrupt_still_inert();
        "STD_MTS_118_changed_latency_generic_at_power_on": do_std_118_changed_latency_generic_at_power_on();
        "STD_MTS_119_bank_string_is_debug_only": do_std_119_bank_string_is_debug_only();
        "STD_MTS_120_debug_zero_is_functionally_equivalent": do_std_120_debug_zero_is_functionally_equivalent();
        "STD_MTS_121_preterminate_hit_still_drains": do_std_121_preterminate_hit_still_drains();
        "STD_MTS_122_terminating_eop_and_hit_emit_final_boundary": do_std_122_terminating_eop_and_hit_emit_final_boundary();
        "STD_MTS_123_flushing_accepts_more_hits_today": do_std_123_flushing_accepts_more_hits_today();
        "STD_MTS_124_flushing_quiet_without_hits": do_std_124_flushing_quiet_without_hits();
        "STD_MTS_125_ctrl_ready_high_through_terminate": do_std_125_ctrl_ready_high_through_terminate();
        "STD_MTS_126_ctrl_ready_high_through_prepare_and_sync": do_std_126_ctrl_ready_high_through_prepare_and_sync();
        "STD_MTS_127_upgrade_case_stateful_ready_on_terminate": do_std_127_upgrade_case_stateful_ready_on_terminate();
        "STD_MTS_128_upgrade_case_terminal_boundary_without_extra_hits": do_std_128_upgrade_case_terminal_boundary_without_extra_hits();
        "STD_MTS_129_upgrade_case_idle_after_boundary_only": do_std_129_upgrade_case_idle_after_boundary_only();
        "STD_MTS_130_full_standard_sequence_baseline": do_std_130_full_standard_sequence_baseline();
        "CORNER_MTS_001_reset_release_with_ctrl_valid": do_corner_001_reset_release_with_ctrl_valid();
        "CORNER_MTS_002_running_and_first_hit_same_cycle": do_corner_002_running_and_first_hit_same_cycle();
        "CORNER_MTS_003_terminate_on_final_eop_cycle": do_corner_003_terminate_on_final_eop_cycle();
        "CORNER_MTS_004_idle_on_output_valid_cycle": do_corner_004_idle_on_output_valid_cycle();
        "CORNER_MTS_005_prepare_then_immediate_idle": do_corner_005_prepare_then_immediate_idle();
        "CORNER_MTS_006_sync_then_immediate_running": do_corner_006_sync_then_immediate_running();
        "CORNER_MTS_007_back_to_back_running_words": do_corner_007_back_to_back_running_words();
        "CORNER_MTS_008_back_to_back_terminating_words": do_corner_008_back_to_back_terminating_words();
        "CORNER_MTS_009_illegal_ctrl_word_while_active": do_corner_009_illegal_ctrl_word_while_active();
        "CORNER_MTS_010_stale_ctrl_data_with_valid_gap": do_corner_010_stale_ctrl_data_with_valid_gap();
        "CORNER_MTS_011_expected_latency_zero": do_corner_011_expected_latency_zero();
        "CORNER_MTS_012_expected_latency_one": do_corner_012_expected_latency_one();
        "CORNER_MTS_013_expected_latency_large_16bit_value": do_corner_013_expected_latency_large_16bit_value();
        "CORNER_MTS_014_expected_latency_all_ones": do_corner_014_expected_latency_all_ones();
        "CORNER_MTS_015_reserved_opmode_bit28_only": do_corner_015_reserved_opmode_bit28_only();
        "CORNER_MTS_016_multi_field_control_write": do_corner_016_multi_field_control_write();
        "CORNER_MTS_017_read_during_soft_reset_window": do_corner_017_read_during_soft_reset_window();
        "CORNER_MTS_018_counter_read_on_low_word_rollover": do_corner_018_counter_read_on_low_word_rollover();
        "CORNER_MTS_019_csr_access_in_flushing": do_corner_019_csr_access_in_flushing();
        "CORNER_MTS_020_polling_unsupported_addr7": do_corner_020_polling_unsupported_addr7();
        "CORNER_MTS_021_plain_hit_no_markers": do_corner_021_plain_hit_no_markers();
        "CORNER_MTS_022_sop_only_beat": do_corner_022_sop_only_beat();
        "CORNER_MTS_023_eop_only_beat": do_corner_023_eop_only_beat();
        "CORNER_MTS_024_single_beat_packet": do_corner_024_single_beat_packet();
        "CORNER_MTS_025_zero_gap_hits": do_corner_025_zero_gap_hits();
        "CORNER_MTS_026_one_cycle_gap_hits": do_corner_026_one_cycle_gap_hits();
        "CORNER_MTS_027_long_gap_then_hit": do_corner_027_long_gap_then_hit();
        "CORNER_MTS_028_max_payload_fields": do_corner_028_max_payload_fields();
        "CORNER_MTS_029_nonzero_mux_bits_in_sideband": do_corner_029_nonzero_mux_bits_in_sideband();
        "CORNER_MTS_030_sideband_channel_outside_enabled_window": do_corner_030_sideband_channel_outside_enabled_window();
        "CORNER_MTS_031_t_gray_equal_padding_upper": do_corner_031_t_gray_equal_padding_upper();
        "CORNER_MTS_032_t_gray_one_above_upper": do_corner_032_t_gray_one_above_upper();
        "CORNER_MTS_033_e_gray_equal_padding_upper": do_corner_033_e_gray_equal_padding_upper();
        "CORNER_MTS_034_e_gray_one_above_upper": do_corner_034_e_gray_one_above_upper();
        "CORNER_MTS_035_mts_counter_wrap_pulse": do_corner_035_mts_counter_wrap_pulse();
        "CORNER_MTS_036_overflow_lookback_expiry": do_corner_036_overflow_lookback_expiry();
        "CORNER_MTS_037_lpm_multi_valid_masks_adjust": do_corner_037_lpm_multi_valid_masks_adjust();
        "CORNER_MTS_038_bypass_toggle_before_hit": do_corner_038_bypass_toggle_before_hit();
        "CORNER_MTS_039_bypass_toggle_after_hit_accept": do_corner_039_bypass_toggle_after_hit_accept();
        "CORNER_MTS_040_latency_write_at_overflow_boundary": do_corner_040_latency_write_at_overflow_boundary();
        "CORNER_MTS_041_remainder_zero_case": do_corner_041_remainder_zero_case();
        "CORNER_MTS_042_remainder_one_case": do_corner_042_remainder_one_case();
        "CORNER_MTS_043_remainder_two_case": do_corner_043_remainder_two_case();
        "CORNER_MTS_044_remainder_three_case": do_corner_044_remainder_three_case();
        "CORNER_MTS_045_remainder_four_case": do_corner_045_remainder_four_case();
        "CORNER_MTS_046_route_bits_00": do_corner_046_route_bits_00();
        "CORNER_MTS_047_route_bits_01": do_corner_047_route_bits_01();
        "CORNER_MTS_048_route_bits_10": do_corner_048_route_bits_10();
        "CORNER_MTS_049_route_bits_11": do_corner_049_route_bits_11();
        "CORNER_MTS_050_route_change_across_boundary": do_corner_050_route_change_across_boundary();
        "CORNER_MTS_051_short_mode_with_eflag_high": do_corner_051_short_mode_with_eflag_high();
        "CORNER_MTS_052_tot_mode_eflag_zero_large_delta": do_corner_052_tot_mode_eflag_zero_large_delta();
        "CORNER_MTS_053_tot_mode_smallest_positive_delta": do_corner_053_tot_mode_smallest_positive_delta();
        "CORNER_MTS_054_tot_mode_largest_unsaturated_delta": do_corner_054_tot_mode_largest_unsaturated_delta();
        "CORNER_MTS_055_tot_mode_first_saturated_delta": do_corner_055_tot_mode_first_saturated_delta();
        "CORNER_MTS_056_tot_mode_negative_delta_case": do_corner_056_tot_mode_negative_delta_case();
        "CORNER_MTS_057_toggle_derive_tot_between_hits": do_corner_057_toggle_derive_tot_between_hits();
        "CORNER_MTS_058_toggle_delay_field_between_hits": do_corner_058_toggle_delay_field_between_hits();
        "CORNER_MTS_059_toggle_eflag_between_hits": do_corner_059_toggle_eflag_between_hits();
        "CORNER_MTS_060_tfine_extremes": do_corner_060_tfine_extremes();
        "CORNER_MTS_061_first_sop_channel0_after_reset": do_corner_061_first_sop_channel0_after_reset();
        "CORNER_MTS_062_first_sop_channel3_after_reset": do_corner_062_first_sop_channel3_after_reset();
        "CORNER_MTS_063_first_hit_disabled_channel_no_sop": do_corner_063_first_hit_disabled_channel_no_sop();
        "CORNER_MTS_064_interleaved_channels_no_repeat_sop": do_corner_064_interleaved_channels_no_repeat_sop();
        "CORNER_MTS_065_single_terminating_eop_pulse": do_corner_065_single_terminating_eop_pulse();
        "CORNER_MTS_066_eop_pipe_without_valid_alignment": do_corner_066_eop_pipe_without_valid_alignment();
        "CORNER_MTS_067_nonterminating_eop_is_local_only": do_corner_067_nonterminating_eop_is_local_only();
        "CORNER_MTS_068_output_eop_with_ready_low": do_corner_068_output_eop_with_ready_low();
        "CORNER_MTS_069_sop_and_eop_same_output_beat": do_corner_069_sop_and_eop_same_output_beat();
        "CORNER_MTS_070_empty_zero_on_all_output_classes": do_corner_070_empty_zero_on_all_output_classes();
        "CORNER_MTS_071_debug_ts_minus_one": do_corner_071_debug_ts_minus_one();
        "CORNER_MTS_072_debug_ts_zero": do_corner_072_debug_ts_zero();
        "CORNER_MTS_073_debug_ts_plus_one": do_corner_073_debug_ts_plus_one();
        "CORNER_MTS_074_debug_ts_expected_minus_one": do_corner_074_debug_ts_expected_minus_one();
        "CORNER_MTS_075_debug_ts_expected_exact": do_corner_075_debug_ts_expected_exact();
        "CORNER_MTS_076_debug_ts_expected_plus_one": do_corner_076_debug_ts_expected_plus_one();
        "CORNER_MTS_077_t_vs_e_path_error_flip": do_corner_077_t_vs_e_path_error_flip();
        "CORNER_MTS_078_debug_burst_positive_trim_edge": do_corner_078_debug_burst_positive_trim_edge();
        "CORNER_MTS_079_debug_burst_negative_trim_edge": do_corner_079_debug_burst_negative_trim_edge();
        "CORNER_MTS_080_ts_delta_zero_boundary": do_corner_080_ts_delta_zero_boundary();
        "CORNER_MTS_081_force_stop_same_cycle_as_valid": do_corner_081_force_stop_same_cycle_as_valid();
        "CORNER_MTS_082_force_stop_clear_before_next_hit": do_corner_082_force_stop_clear_before_next_hit();
        "CORNER_MTS_083_soft_reset_while_running_idle_pipe": do_corner_083_soft_reset_while_running_idle_pipe();
        "CORNER_MTS_084_soft_reset_with_inflight_beats": do_corner_084_soft_reset_with_inflight_beats();
        "CORNER_MTS_085_soft_reset_in_flushing": do_corner_085_soft_reset_in_flushing();
        "CORNER_MTS_086_global_reset_with_pending_term_eop": do_corner_086_global_reset_with_pending_term_eop();
        "CORNER_MTS_087_global_reset_with_debug_history": do_corner_087_global_reset_with_debug_history();
        "CORNER_MTS_088_prepare_after_soft_reset": do_corner_088_prepare_after_soft_reset();
        "CORNER_MTS_089_sync_after_force_stop_cycle": do_corner_089_sync_after_force_stop_cycle();
        "CORNER_MTS_090_idle_during_sclr_flush": do_corner_090_idle_during_sclr_flush();
        "CORNER_MTS_091_single_channel_window_index0": do_corner_091_single_channel_window_index0();
        "CORNER_MTS_092_single_channel_window_index3": do_corner_092_single_channel_window_index3();
        "CORNER_MTS_093_middle_window_indexing": do_corner_093_middle_window_indexing();
        "CORNER_MTS_094_packaged_div_pipeline_delay": do_corner_094_packaged_div_pipeline_delay();
        "CORNER_MTS_095_rtl_div_pipeline_delay": do_corner_095_rtl_div_pipeline_delay();
        "CORNER_MTS_096_zero_default_latency_generic": do_corner_096_zero_default_latency_generic();
        "CORNER_MTS_097_one_tick_default_latency_generic": do_corner_097_one_tick_default_latency_generic();
        "CORNER_MTS_098_remapped_hiterr_to_bit2": do_corner_098_remapped_hiterr_to_bit2();
        "CORNER_MTS_099_frame_corrupt_bit_still_inert": do_corner_099_frame_corrupt_bit_still_inert();
        "CORNER_MTS_100_padding_eop_wait_still_inert": do_corner_100_padding_eop_wait_still_inert();
        "CORNER_MTS_101_output_ready_low_single_beat": do_corner_101_output_ready_low_single_beat();
        "CORNER_MTS_102_output_ready_low_multi_beat": do_corner_102_output_ready_low_multi_beat();
        "CORNER_MTS_103_output_ready_toggle_every_cycle": do_corner_103_output_ready_toggle_every_cycle();
        "CORNER_MTS_104_output_ready_low_on_eop": do_corner_104_output_ready_low_on_eop();
        "CORNER_MTS_105_output_ready_unknown_monitor_trap": do_corner_105_output_ready_unknown_monitor_trap();
        "CORNER_MTS_106_input_ready_high_in_flushing": do_corner_106_input_ready_high_in_flushing();
        "CORNER_MTS_107_input_ready_low_in_idle": do_corner_107_input_ready_low_in_idle();
        "CORNER_MTS_108_input_ready_high_in_reset_sclr": do_corner_108_input_ready_high_in_reset_sclr();
        "CORNER_MTS_109_input_ready_low_in_reset_sync": do_corner_109_input_ready_low_in_reset_sync();
        "CORNER_MTS_110_output_quiet_outside_running_flush": do_corner_110_output_quiet_outside_running_flush();
        "CORNER_MTS_111_terminate_with_no_packet_open": do_corner_111_terminate_with_no_packet_open();
        "CORNER_MTS_112_terminate_one_cycle_before_eop": do_corner_112_terminate_one_cycle_before_eop();
        "CORNER_MTS_113_terminate_same_cycle_as_eop": do_corner_113_terminate_same_cycle_as_eop();
        "CORNER_MTS_114_terminate_one_cycle_after_eop": do_corner_114_terminate_one_cycle_after_eop();
        "CORNER_MTS_115_idle_before_eop_delay_matures": do_corner_115_idle_before_eop_delay_matures();
        "CORNER_MTS_116_multiple_eops_in_flushing": do_corner_116_multiple_eops_in_flushing();
        "CORNER_MTS_117_packet_open_then_abort": do_corner_117_packet_open_then_abort();
        "CORNER_MTS_118_terminating_eop_disabled_sideband_channel": do_corner_118_terminating_eop_disabled_sideband_channel();
        "CORNER_MTS_119_flushing_accepts_non_eop_hits": do_corner_119_flushing_accepts_non_eop_hits();
        "CORNER_MTS_120_upgrade_ready_should_wait_for_drain": do_corner_120_upgrade_ready_should_wait_for_drain();
        "CORNER_MTS_121_prepare_ready_gap_upgrade": do_corner_121_prepare_ready_gap_upgrade();
        "CORNER_MTS_122_sync_ready_gap_upgrade": do_corner_122_sync_ready_gap_upgrade();
        "CORNER_MTS_123_flushing_ready_gap_upgrade": do_corner_123_flushing_ready_gap_upgrade();
        "CORNER_MTS_124_missing_synthetic_boundary_upgrade": do_corner_124_missing_synthetic_boundary_upgrade();
        "CORNER_MTS_125_eop_alignment_hole_upgrade": do_corner_125_eop_alignment_hole_upgrade();
        "CORNER_MTS_126_crcerr_ignore_upgrade_gap": do_corner_126_crcerr_ignore_upgrade_gap();
        "CORNER_MTS_127_frame_corrupt_ignore_upgrade_gap": do_corner_127_frame_corrupt_ignore_upgrade_gap();
        "CORNER_MTS_128_accept_command_vs_complete_work_upgrade": do_corner_128_accept_command_vs_complete_work_upgrade();
        "CORNER_MTS_129_one_boundary_per_run_upgrade": do_corner_129_one_boundary_per_run_upgrade();
        "CORNER_MTS_130_idle_after_boundary_upgrade": do_corner_130_idle_after_boundary_upgrade();
        "CORNER_MTS_127_delay_error_sideband_tracks_hit": do_corner_127_delay_error_sideband_tracks_hit();
        "NEG_MTS_021_hiterr_rejected_running": do_neg_021_hiterr_rejected_running();
        "NEG_MTS_028_valid_beat_under_force_stop": do_neg_028_valid_beat_under_force_stop();
        "STRESS_MTS_001_line_rate_short_mode": do_stress_001_line_rate_short_mode();
        "STRESS_MTS_002_line_rate_tot_mode": do_stress_002_line_rate_tot_mode();
        "STRESS_MTS_003_every_other_cycle_stream": do_stress_003_every_other_cycle_stream();
        "STRESS_MTS_004_burst_of_eight_pattern": do_stress_004_burst_of_eight_pattern();
        "STRESS_MTS_005_clean_hiterr_free_soak": do_stress_005_clean_hiterr_free_soak();
        "STRESS_MTS_006_mixed_hiterr_soak_keep_disabled": do_stress_006_mixed_hiterr_soak_keep_disabled();
        "STRESS_MTS_007_mixed_hiterr_soak_discard_enabled": do_stress_007_mixed_hiterr_soak_discard_enabled();
        "STRESS_MTS_008_sustained_output_ready_high": do_stress_008_sustained_output_ready_high();
        "STRESS_MTS_009_sustained_output_ready_low": do_stress_009_sustained_output_ready_low();
        "STRESS_MTS_010_flushing_after_large_backlog": do_stress_010_flushing_after_large_backlog();
        "STRESS_MTS_011_long_run_short_mode": do_stress_011_long_run_short_mode();
        "STRESS_MTS_012_long_run_tot_mode": do_stress_012_long_run_tot_mode();
        "STRESS_MTS_013_toggle_derive_tot_every_256_hits": do_stress_013_toggle_derive_tot_every_256_hits();
        "STRESS_MTS_014_long_run_delay_field_t": do_stress_014_long_run_delay_field_t();
        "STRESS_MTS_015_long_run_delay_field_e": do_stress_015_long_run_delay_field_e();
        "STRESS_MTS_016_toggle_delay_field_every_256_hits": do_stress_016_toggle_delay_field_every_256_hits();
        "STRESS_MTS_017_long_run_bypass_off": do_stress_017_long_run_bypass_off();
        "STRESS_MTS_018_long_run_bypass_on": do_stress_018_long_run_bypass_on();
        "STRESS_MTS_019_toggle_bypass_between_packets": do_stress_019_toggle_bypass_between_packets();
        "STRESS_MTS_020_rewrite_expected_latency_mid_run": do_stress_020_rewrite_expected_latency_mid_run();
        "STRESS_MTS_021_round_robin_enabled_channels": do_stress_021_round_robin_enabled_channels();
        "STRESS_MTS_022_hotspot_channel0": do_stress_022_hotspot_channel0();
        "STRESS_MTS_023_hotspot_channel3": do_stress_023_hotspot_channel3();
        "STRESS_MTS_024_dense_payload_channel_sweep": do_stress_024_dense_payload_channel_sweep();
        "STRESS_MTS_025_dense_asic_id_sweep": do_stress_025_dense_asic_id_sweep();
        "STRESS_MTS_026_single_beat_packet_stream": do_stress_026_single_beat_packet_stream();
        "STRESS_MTS_027_multi_beat_packet_stream": do_stress_027_multi_beat_packet_stream();
        "STRESS_MTS_028_periodic_hiterr_every_16th": do_stress_028_periodic_hiterr_every_16th();
        "STRESS_MTS_029_periodic_hiterr_keep_mode": do_stress_029_periodic_hiterr_keep_mode();
        "STRESS_MTS_030_nonzero_mux_bits_under_load": do_stress_030_nonzero_mux_bits_under_load();
        "STRESS_MTS_031_discard_counter_monotonic_1k": do_stress_031_discard_counter_monotonic_1k();
        "STRESS_MTS_032_total_counter_monotonic_1k": do_stress_032_total_counter_monotonic_1k();
        "STRESS_MTS_033_mixed_accept_reject_counter_soak": do_stress_033_mixed_accept_reject_counter_soak();
        "STRESS_MTS_034_hi_lo_snapshot_polling": do_stress_034_hi_lo_snapshot_polling();
        "STRESS_MTS_035_soft_reset_every_10k_cycles": do_stress_035_soft_reset_every_10k_cycles();
        "STRESS_MTS_036_global_reset_periodic_recovery": do_stress_036_global_reset_periodic_recovery();
        "STRESS_MTS_037_standard_run_sequence_repeated_100x": do_stress_037_standard_run_sequence_repeated_100x();
        "STRESS_MTS_038_direct_running_sequence_repeated_100x": do_stress_038_direct_running_sequence_repeated_100x();
        "STRESS_MTS_039_force_stop_pulse_every_100_hits": do_stress_039_force_stop_pulse_every_100_hits();
        "STRESS_MTS_040_csr_poll_every_32_cycles": do_stress_040_csr_poll_every_32_cycles();
        "STRESS_MTS_041_single_overflow_run": do_stress_041_single_overflow_run();
        "STRESS_MTS_042_many_overflow_run": do_stress_042_many_overflow_run();
        "STRESS_MTS_043_hits_just_below_upper_across_overflow": do_stress_043_hits_just_below_upper_across_overflow();
        "STRESS_MTS_044_hits_just_above_upper_across_overflow": do_stress_044_hits_just_above_upper_across_overflow();
        "STRESS_MTS_045_mixed_t_and_e_adjust_eligibility": do_stress_045_mixed_t_and_e_adjust_eligibility();
        "STRESS_MTS_046_bypass_off_overflow_soak": do_stress_046_bypass_off_overflow_soak();
        "STRESS_MTS_047_bypass_on_overflow_soak": do_stress_047_bypass_on_overflow_soak();
        "STRESS_MTS_048_small_expected_latency_overflow": do_stress_048_small_expected_latency_overflow();
        "STRESS_MTS_049_large_expected_latency_overflow": do_stress_049_large_expected_latency_overflow();
        "STRESS_MTS_050_dense_divider_launch_overflow": do_stress_050_dense_divider_launch_overflow();
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
