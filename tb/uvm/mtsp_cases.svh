  class mtsp_doc_case_test extends mtsp_base_test;
    `uvm_component_utils(mtsp_doc_case_test)

    string case_id;
    localparam bit [31:0] CSR_CTRL_WRITE_DEFAULT = 32'h2000_0011;
    localparam bit [31:0] CSR_CTRL_READ_DEFAULT_IDLE = 32'h2000_0010;
    localparam bit [31:0] CSR_CTRL_MODE_MASK = 32'h7000_0000;
    localparam int unsigned MTSP_OVERFLOW_TIME_1N6 = 32767;
    localparam int unsigned MTSP_OVERFLOW_PADDING_UPPER_1N6 = 22766;
    localparam int unsigned SMOKE_VEC_POSITIVE = 0;
    localparam int unsigned SMOKE_VEC_EFLAG_ZERO = 1;
    localparam int unsigned SMOKE_VEC_NEGATIVE_CLAMP = 2;
    localparam int unsigned SMOKE_VEC_SATURATION = 3;
    localparam int unsigned SMOKE_PATTERN_POSITIVE = 0;
    localparam int unsigned SMOKE_PATTERN_EFLAG_ZERO = 1;
    localparam int unsigned SMOKE_PATTERN_CLAMP_PAIR = 2;
    localparam int unsigned SMOKE_PATTERN_ALL = 3;
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

    task automatic expect_trace_delta_at(int unsigned trace_idx,
                                         int signed min_delta,
                                         int signed max_delta,
                                         bit expected_error,
                                         string ctx);
      mtsp_hit_trace_item trace;

      if (trace_idx >= m_env.m_scb.trace_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected trace index %0d, size=%0d",
            ctx, trace_idx, m_env.m_scb.trace_history.size()))
      trace = m_env.m_scb.trace_history[trace_idx];
      if (trace.debug_delta < min_delta || trace.debug_delta > max_delta)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected debug_delta in [%0d,%0d], got %0d",
            ctx, min_delta, max_delta, trace.debug_delta))
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

    task automatic smoke_vector_params(int unsigned kind,
                                       output int unsigned tcc_raw_value,
                                       output int unsigned ecc_raw_value,
                                       output bit eflag_value,
                                       output int unsigned expected_tcc8n,
                                       output int unsigned expected_tcc1n6,
                                       output int unsigned expected_et1n6,
                                       string ctx);
      case (kind)
        SMOKE_VEC_POSITIVE: begin
          tcc_raw_value   = 15'h0003;
          ecc_raw_value   = 15'h000F;
          eflag_value     = 1'b1;
          expected_tcc8n  = 0;
          expected_tcc1n6 = 1;
          expected_et1n6  = 2;
        end
        SMOKE_VEC_EFLAG_ZERO: begin
          tcc_raw_value   = 15'h0003;
          ecc_raw_value   = 15'h000F;
          eflag_value     = 1'b0;
          expected_tcc8n  = 0;
          expected_tcc1n6 = 1;
          expected_et1n6  = 0;
        end
        SMOKE_VEC_NEGATIVE_CLAMP: begin
          tcc_raw_value   = 15'h000F;
          ecc_raw_value   = 15'h0003;
          eflag_value     = 1'b1;
          expected_tcc8n  = 0;
          expected_tcc1n6 = 3;
          expected_et1n6  = 0;
        end
        SMOKE_VEC_SATURATION: begin
          tcc_raw_value   = 15'h0001;
          ecc_raw_value   = 15'h0000;
          eflag_value     = 1'b1;
          expected_tcc8n  = 0;
          expected_tcc1n6 = 0;
          expected_et1n6  = 511;
        end
        default:
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s unsupported smoke vector kind %0d", ctx, kind))
      endcase
    endtask

    function automatic int unsigned smoke_pattern_len(int unsigned pattern);
      case (pattern)
        SMOKE_PATTERN_POSITIVE,
        SMOKE_PATTERN_EFLAG_ZERO: return 1;
        SMOKE_PATTERN_CLAMP_PAIR: return 2;
        SMOKE_PATTERN_ALL: return 4;
        default: return 0;
      endcase
    endfunction

    function automatic int unsigned smoke_pattern_kind(int unsigned pattern,
                                                       int unsigned pos);
      case (pattern)
        SMOKE_PATTERN_POSITIVE: return SMOKE_VEC_POSITIVE;
        SMOKE_PATTERN_EFLAG_ZERO: return SMOKE_VEC_EFLAG_ZERO;
        SMOKE_PATTERN_CLAMP_PAIR: begin
          if (pos == 0)
            return SMOKE_VEC_NEGATIVE_CLAMP;
          return SMOKE_VEC_SATURATION;
        end
        SMOKE_PATTERN_ALL: begin
          case (pos)
            0: return SMOKE_VEC_POSITIVE;
            1: return SMOKE_VEC_EFLAG_ZERO;
            2: return SMOKE_VEC_NEGATIVE_CLAMP;
            default: return SMOKE_VEC_SATURATION;
          endcase
        end
        default: return SMOKE_VEC_POSITIVE;
      endcase
    endfunction

    task automatic write_smoke_mode(bit bypass_lapse,
                                    bit delay_ts_field_use_t);
      bit [31:0] csr_word;

      csr_word = 32'h4000_0001;
      if (bypass_lapse)
        csr_word |= 32'h0000_0008;
      if (delay_ts_field_use_t)
        csr_word |= 32'h2000_0000;
      csr_write(3'd0, csr_word);
      wait_cycles(2);
    endtask

    task automatic start_smoke_stress_run(bit standard_sequence,
                                          bit bypass_lapse,
                                          bit delay_ts_field_use_t,
                                          bit ready_low,
                                          bit wait_for_wrap,
                                          string ctx);
      wait_for_reset_release();
      write_smoke_mode(bypass_lapse, delay_ts_field_use_t);
      if (standard_sequence) begin
        run_start();
      end else begin
        send_ctrl(CTRL_RUNNING, "RUNNING");
        wait_for_running_status(64, ctx);
        wait_for_hit0_ready(1'b1, 16, ctx);
        wait_cycles(1);
      end
      hit1_drv_vif.ready <= ready_low ? 1'b0 : 1'b1;
      wait_cycles(1);
      if (wait_for_wrap)
        wait_inside_one_wrap_lookback(ctx);
    endtask

    task automatic send_smoke_vector_kind(int unsigned kind,
                                          int unsigned seq_idx,
                                          string ctx);
      int unsigned tcc_raw_value;
      int unsigned ecc_raw_value;
      int unsigned expected_tcc8n;
      int unsigned expected_tcc1n6;
      int unsigned expected_et1n6;
      bit          eflag_value;

      smoke_vector_params(kind, tcc_raw_value, ecc_raw_value, eflag_value,
        expected_tcc8n, expected_tcc1n6, expected_et1n6, ctx);
      send_hit_beat(2, 1, tcc_raw_value, ecc_raw_value, eflag_value,
        seq_idx == 0, 1'b0, '0, 1'b1, 0);
    endtask

    task automatic expect_smoke_vector_kind_at(int unsigned history_idx,
                                               int unsigned trace_idx,
                                               int unsigned kind,
                                               string ctx);
      int unsigned tcc_raw_value;
      int unsigned ecc_raw_value;
      int unsigned expected_tcc8n;
      int unsigned expected_tcc1n6;
      int unsigned expected_et1n6;
      bit          eflag_value;

      smoke_vector_params(kind, tcc_raw_value, ecc_raw_value, eflag_value,
        expected_tcc8n, expected_tcc1n6, expected_et1n6, ctx);
      expect_payload_math_at(history_idx, 2, 1, 0, expected_tcc8n,
        expected_tcc1n6, expected_et1n6, ctx);
      expect_trace_pair_at(trace_idx, ctx);
      expect_trace_math_self_consistent_at(trace_idx, ctx);
      expect_trace_expected_latency_at(trace_idx, 2000, ctx);
    endtask

    task automatic run_smoke_replay_case(int unsigned repeat_count,
                                         int unsigned pattern,
                                         bit standard_sequence,
                                         bit bypass_lapse,
                                         bit delay_ts_field_use_t,
                                         bit ready_low,
                                         bit wait_for_wrap,
                                         int unsigned expected_latency_cycles,
                                         string ctx);
      int unsigned pattern_count;
      int unsigned expected_payloads;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned base_dual_pairs;
      int unsigned seq_idx;

      pattern_count = smoke_pattern_len(pattern);
      if (pattern_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s unsupported smoke replay pattern %0d", ctx, pattern))
      expected_payloads = repeat_count * pattern_count;

      start_smoke_stress_run(standard_sequence, bypass_lapse,
        delay_ts_field_use_t, ready_low, wait_for_wrap, ctx);

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      base_dual_pairs  = m_env.m_scb.dual_path_pair_count;
      seq_idx          = 0;

      for (int unsigned rep = 0; rep < repeat_count; rep++) begin
        for (int unsigned pos = 0; pos < pattern_count; pos++) begin
          send_smoke_vector_kind(smoke_pattern_kind(pattern, pos), seq_idx,
            $sformatf("%s rep=%0d pos=%0d", ctx, rep, pos));
          seq_idx++;
        end
      end

      wait_for_input_count(base_inputs + expected_payloads,
        expected_payloads + 2048, ctx);
      wait_for_beat_count(base_beats + expected_payloads,
        expected_payloads + 4096, ctx);
      wait_for_trace_count(base_traces + expected_payloads,
        expected_payloads + 4096, ctx);
      wait_for_debug_ts_count(base_debug_ts + expected_payloads,
        expected_payloads + 1024, ctx);
      wait_for_debug_burst_count(base_debug_burst + expected_payloads,
        expected_payloads + 1024, ctx);
      wait_for_ts_delta_count(base_ts_delta + expected_payloads,
        expected_payloads + 1024, ctx);
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, expected_payloads, expected_payloads, expected_payloads,
        ctx);
      if (m_env.m_scb.dual_path_pair_count != base_dual_pairs + expected_payloads)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new dual-path trace pairs, got %0d from base %0d",
            ctx, expected_payloads,
            m_env.m_scb.dual_path_pair_count - base_dual_pairs,
            base_dual_pairs))

      seq_idx = 0;
      for (int unsigned rep = 0; rep < repeat_count; rep++) begin
        for (int unsigned pos = 0; pos < pattern_count; pos++) begin
          expect_smoke_vector_kind_at(base_history_size + seq_idx,
            base_traces + seq_idx, smoke_pattern_kind(pattern, pos),
            $sformatf("%s payload rep=%0d pos=%0d", ctx, rep, pos));
          seq_idx++;
        end
      end

      if (expected_latency_cycles != 0)
        expect_latency_cycles_since(base_inputs, base_history_size,
          expected_payloads, expected_latency_cycles, ctx);
      expect_total_count(expected_payloads, ctx);
      expect_discard_count(32'd0, ctx);
      hit1_drv_vif.ready <= 1'b1;
      wait_cycles(2);
    endtask

    localparam int unsigned SINK_READY_HIGH        = 0;
    localparam int unsigned SINK_READY_LOW         = 1;
    localparam int unsigned SINK_READY_TOGGLE_1010 = 2;
    localparam int unsigned SINK_READY_LOW_ON_SOP  = 3;
    localparam int unsigned SINK_READY_LOW_ON_EOP  = 4;
    localparam int unsigned SINK_READY_DENSE_LOW   = 5;
    localparam int unsigned SINK_READY_FLUSH_LOW   = 6;
    localparam int unsigned SINK_READY_RANDOM      = 7;
    localparam int unsigned SINK_READY_RESET_LOW   = 8;

    function automatic bit sink_ready_value(input int unsigned pattern,
                                            input int unsigned cycle_idx);
      bit [31:0] prbs;

      prbs = (cycle_idx * 32'd1103515245) + 32'd12345;
      case (pattern)
        SINK_READY_HIGH:        return 1'b1;
        SINK_READY_LOW:         return 1'b0;
        SINK_READY_TOGGLE_1010: return !cycle_idx[0];
        SINK_READY_LOW_ON_SOP:  return (cycle_idx < 96) ? 1'b0 : 1'b1;
        SINK_READY_DENSE_LOW:   return 1'b0;
        SINK_READY_FLUSH_LOW:   return 1'b0;
        SINK_READY_RESET_LOW:   return 1'b0;
        SINK_READY_RANDOM:      return prbs[3];
        default:                return 1'b1;
      endcase
    endfunction

    task automatic expect_ready_observation_since(input int unsigned base_history,
                                                  input int unsigned sample_count,
                                                  input int unsigned pattern,
                                                  input string ctx);
      int unsigned low_count;
      int unsigned high_count;
      int unsigned sop_low_count;
      int unsigned eop_low_count;
      int unsigned empty_eop_low_count;

      if (base_history + sample_count > m_env.m_scb.history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d ready-sampled outputs from base %0d, size=%0d",
            ctx, sample_count, base_history, m_env.m_scb.history.size()))

      low_count            = 0;
      high_count           = 0;
      sop_low_count        = 0;
      eop_low_count        = 0;
      empty_eop_low_count  = 0;
      for (int unsigned idx = 0; idx < sample_count; idx++) begin
        mtsp_hit1_obs_item obs;

        obs = m_env.m_scb.history[base_history + idx];
        if ($isunknown(obs.ready))
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s output idx=%0d sampled unknown sink ready",
              ctx, idx))
        if (obs.ready === 1'b0)
          low_count++;
        else if (obs.ready === 1'b1)
          high_count++;
        if (obs.sop && obs.ready === 1'b0)
          sop_low_count++;
        if (obs.eop && obs.ready === 1'b0)
          eop_low_count++;
        if (obs.empty && obs.eop && obs.ready === 1'b0)
          empty_eop_low_count++;
      end

      case (pattern)
        SINK_READY_HIGH: begin
          if (low_count != 0 || high_count != sample_count)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected all %0d outputs ready-high, got high=%0d low=%0d",
                ctx, sample_count, high_count, low_count))
        end
        SINK_READY_LOW,
        SINK_READY_DENSE_LOW,
        SINK_READY_FLUSH_LOW,
        SINK_READY_RESET_LOW: begin
          if (low_count != sample_count)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected all %0d outputs ready-low, got high=%0d low=%0d",
                ctx, sample_count, high_count, low_count))
        end
        SINK_READY_TOGGLE_1010,
        SINK_READY_RANDOM: begin
          if (low_count == 0 || high_count == 0)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected mixed ready observations, got high=%0d low=%0d",
                ctx, high_count, low_count))
        end
        SINK_READY_LOW_ON_SOP: begin
          if (sop_low_count == 0)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected at least one SOP output sampled with ready low",
                ctx))
        end
        SINK_READY_LOW_ON_EOP: begin
          if (eop_low_count == 0 || empty_eop_low_count == 0)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s expected close EOP marker sampled with ready low, eop_low=%0d empty_eop_low=%0d",
                ctx, eop_low_count, empty_eop_low_count))
        end
        default: begin
        end
      endcase

      `uvm_info("MTSP_SINK_READY",
        $sformatf("%s ready evidence outputs=%0d high=%0d low=%0d sop_low=%0d eop_low=%0d empty_eop_low=%0d",
          ctx, sample_count, high_count, low_count, sop_low_count,
          eop_low_count, empty_eop_low_count),
        UVM_LOW)
    endtask

    task automatic expect_sink_phase_equivalent(input int unsigned base_history_a,
                                                input int unsigned base_history_b,
                                                input int unsigned base_traces_a,
                                                input int unsigned base_traces_b,
                                                input int unsigned base_debug_ts_a,
                                                input int unsigned base_debug_ts_b,
                                                input int unsigned base_debug_burst_a,
                                                input int unsigned base_debug_burst_b,
                                                input int unsigned base_ts_delta_a,
                                                input int unsigned base_ts_delta_b,
                                                input int unsigned sample_count,
                                                input string ctx);
      if (base_history_a + sample_count > m_env.m_scb.history.size() ||
          base_history_b + sample_count > m_env.m_scb.history.size() ||
          base_traces_a + sample_count > m_env.m_scb.trace_history.size() ||
          base_traces_b + sample_count > m_env.m_scb.trace_history.size() ||
          base_debug_ts_a + sample_count > m_env.m_scb.debug_ts_history.size() ||
          base_debug_ts_b + sample_count > m_env.m_scb.debug_ts_history.size() ||
          base_debug_burst_a + sample_count > m_env.m_scb.debug_burst_history.size() ||
          base_debug_burst_b + sample_count > m_env.m_scb.debug_burst_history.size() ||
          base_ts_delta_a + sample_count > m_env.m_scb.ts_delta_history.size() ||
          base_ts_delta_b + sample_count > m_env.m_scb.ts_delta_history.size())
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s cannot compare %0d samples from selected baselines",
            ctx, sample_count))

      for (int unsigned idx = 0; idx < sample_count; idx++) begin
        mtsp_hit1_obs_item  hit_a;
        mtsp_hit1_obs_item  hit_b;
        mtsp_hit_trace_item trace_a;
        mtsp_hit_trace_item trace_b;
        mtsp_dbg_obs_item   dbg_a;
        mtsp_dbg_obs_item   dbg_b;

        hit_a = m_env.m_scb.history[base_history_a + idx];
        hit_b = m_env.m_scb.history[base_history_b + idx];
        if (hit_a.channel !== hit_b.channel || hit_a.sop !== hit_b.sop ||
            hit_a.eop !== hit_b.eop || hit_a.data !== hit_b.data ||
            hit_a.empty !== hit_b.empty || hit_a.error !== hit_b.error)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s normal path mismatch idx=%0d a={ch=%0h sop=%0b eop=%0b empty=%0b err=%0b data=0x%010h} b={ch=%0h sop=%0b eop=%0b empty=%0b err=%0b data=0x%010h}",
              ctx, idx, hit_a.channel, hit_a.sop, hit_a.eop, hit_a.empty,
              hit_a.error, hit_a.data, hit_b.channel, hit_b.sop, hit_b.eop,
              hit_b.empty, hit_b.error, hit_b.data))

        trace_a = m_env.m_scb.trace_history[base_traces_a + idx];
        trace_b = m_env.m_scb.trace_history[base_traces_b + idx];
        if (trace_a.channel !== trace_b.channel || trace_a.data !== trace_b.data ||
            trace_a.hit1_error !== trace_b.hit1_error ||
            trace_a.debug_ts !== trace_b.debug_ts ||
            trace_a.debug_delta != trace_b.debug_delta ||
            trace_a.expected_latency !== trace_b.expected_latency ||
            trace_a.math_error !== trace_b.math_error)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s paired normal/debug trace mismatch idx=%0d",
              ctx, idx))

        dbg_a = m_env.m_scb.debug_ts_history[base_debug_ts_a + idx];
        dbg_b = m_env.m_scb.debug_ts_history[base_debug_ts_b + idx];
        if (dbg_a.data !== dbg_b.data)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s debug_ts mismatch idx=%0d a=0x%04h b=0x%04h",
              ctx, idx, dbg_a.data, dbg_b.data))
        dbg_a = m_env.m_scb.debug_burst_history[base_debug_burst_a + idx];
        dbg_b = m_env.m_scb.debug_burst_history[base_debug_burst_b + idx];
        if (dbg_a.data !== dbg_b.data)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s debug_burst mismatch idx=%0d a=0x%04h b=0x%04h",
              ctx, idx, dbg_a.data, dbg_b.data))
        dbg_a = m_env.m_scb.ts_delta_history[base_ts_delta_a + idx];
        dbg_b = m_env.m_scb.ts_delta_history[base_ts_delta_b + idx];
        if (dbg_a.data !== dbg_b.data)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s ts_delta mismatch idx=%0d a=0x%04h b=0x%04h",
              ctx, idx, dbg_a.data, dbg_b.data))
      end
    endtask

    task automatic run_sink_smoke_replay_phase(input int unsigned repeat_count,
                                               input int unsigned ready_pattern,
                                               output int unsigned base_history_size,
                                               output int unsigned base_traces,
                                               output int unsigned base_debug_ts,
                                               output int unsigned base_debug_burst,
                                               output int unsigned base_ts_delta,
                                               output int unsigned expected_payloads,
                                               input string ctx);
      int unsigned pattern_count;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_dual_pairs;
      int unsigned seq_idx;
      bit          ready_done;

      pattern_count = smoke_pattern_len(SMOKE_PATTERN_ALL);
      expected_payloads = repeat_count * pattern_count;

      wait_for_reset_release();
      write_smoke_mode(1'b0, 1'b0);
      hit1_drv_vif.ready <= sink_ready_value(ready_pattern, 0);
      wait_cycles(1);
      run_start();

      ready_done = 1'b0;
      fork
        begin : sink_ready_loop
          int unsigned cycle_idx;

          cycle_idx = 0;
          while (!ready_done) begin
            hit1_drv_vif.ready <= sink_ready_value(ready_pattern, cycle_idx);
            cycle_idx++;
            @(posedge hit1_drv_vif.clk);
          end
        end
      join_none

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_debug_ts     = m_env.m_scb.debug_ts_count;
      base_debug_burst  = m_env.m_scb.debug_burst_count;
      base_ts_delta     = m_env.m_scb.ts_delta_count;
      base_dual_pairs   = m_env.m_scb.dual_path_pair_count;
      seq_idx           = 0;

      for (int unsigned rep = 0; rep < repeat_count; rep++) begin
        for (int unsigned pos = 0; pos < pattern_count; pos++) begin
          send_smoke_vector_kind(smoke_pattern_kind(SMOKE_PATTERN_ALL, pos),
            seq_idx, $sformatf("%s rep=%0d pos=%0d", ctx, rep, pos));
          seq_idx++;
        end
      end

      wait_for_input_count(base_inputs + expected_payloads,
        expected_payloads + 2048, ctx);
      wait_for_beat_count(base_beats + expected_payloads,
        expected_payloads + 4096, ctx);
      wait_for_trace_count(base_traces + expected_payloads,
        expected_payloads + 4096, ctx);
      wait_for_debug_ts_count(base_debug_ts + expected_payloads,
        expected_payloads + 1024, ctx);
      wait_for_debug_burst_count(base_debug_burst + expected_payloads,
        expected_payloads + 1024, ctx);
      wait_for_ts_delta_count(base_ts_delta + expected_payloads,
        expected_payloads + 1024, ctx);
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, expected_payloads, expected_payloads,
        expected_payloads, ctx);
      if (m_env.m_scb.dual_path_pair_count != base_dual_pairs + expected_payloads)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new dual-path trace pairs, got %0d from base %0d",
            ctx, expected_payloads,
            m_env.m_scb.dual_path_pair_count - base_dual_pairs,
            base_dual_pairs))

      seq_idx = 0;
      for (int unsigned rep = 0; rep < repeat_count; rep++) begin
        for (int unsigned pos = 0; pos < pattern_count; pos++) begin
          expect_smoke_vector_kind_at(base_history_size + seq_idx,
            base_traces + seq_idx, smoke_pattern_kind(SMOKE_PATTERN_ALL, pos),
            $sformatf("%s payload rep=%0d pos=%0d", ctx, rep, pos));
          seq_idx++;
        end
      end
      expect_latency_cycles_since(base_inputs, base_history_size,
        expected_payloads, 10, ctx);
      expect_total_count(expected_payloads, ctx);
      expect_discard_count(32'd0, ctx);
      expect_ready_observation_since(base_history_size, expected_payloads,
        ready_pattern, ctx);

      ready_done = 1'b1;
      wait_cycles(2);
      hit1_drv_vif.ready <= 1'b1;
    endtask

    task automatic run_sink_terminate_eop_ready_case(input int unsigned hit_count,
                                                     input string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned base_dual_pairs;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      set_hit1_ready(1'b1);

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history     = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      base_dual_pairs  = m_env.m_scb.dual_path_pair_count;
      base_empty_eops  = m_env.m_scb.empty_eop_count;

      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_run_control_payload(idx, idx % 4, idx < 4,
          idx == hit_count - 1, base_history, base_traces, idx,
          $sformatf("%s pre-terminate idx=%0d", ctx, idx));

      set_hit1_ready(1'b0);
      finish_termination_after_payloads(base_history, base_empty_eops,
        hit_count, ctx);
      set_hit1_ready(1'b1);

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 1024,
        ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 1024, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 1024,
        ctx);
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      if (m_env.m_scb.dual_path_pair_count != base_dual_pairs + hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new dual-path trace pairs, got %0d",
            ctx, hit_count, m_env.m_scb.dual_path_pair_count - base_dual_pairs))
      if (m_env.m_scb.beat_count != base_beats + hit_count + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payload/marker beats, got %0d",
            ctx, hit_count + 4, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d",
            ctx, hit_count, m_env.m_scb.trace_history.size() - base_traces))
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
      expect_ready_observation_since(base_history, hit_count + 4,
        SINK_READY_LOW_ON_EOP, ctx);
    endtask

    task automatic run_sink_smoke_replay_case(input int unsigned repeat_count,
                                              input int unsigned ready_pattern,
                                              input string ctx);
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned expected_payloads;

      run_sink_smoke_replay_phase(repeat_count, ready_pattern, base_history,
        base_traces, base_debug_ts, base_debug_burst, base_ts_delta,
        expected_payloads, ctx);
    endtask

    task automatic run_smoke_soft_reset_case(int unsigned iterations,
                                             string ctx);
      int unsigned pattern_count;

      pattern_count = smoke_pattern_len(SMOKE_PATTERN_ALL);
      start_smoke_stress_run(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, ctx);

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history_size;
        int unsigned base_traces;
        int unsigned base_debug_ts;
        int unsigned base_debug_burst;
        int unsigned base_ts_delta;
        int unsigned base_dual_pairs;

        wait_for_hit0_ready(1'b1, 64,
          $sformatf("%s iter=%0d hit ready", ctx, iter));
        base_inputs       = m_env.m_scb.hit0_history.size();
        base_beats        = m_env.m_scb.beat_count;
        base_history_size = m_env.m_scb.history.size();
        base_traces       = m_env.m_scb.trace_history.size();
        base_debug_ts     = m_env.m_scb.debug_ts_count;
        base_debug_burst  = m_env.m_scb.debug_burst_count;
        base_ts_delta     = m_env.m_scb.ts_delta_count;
        base_dual_pairs   = m_env.m_scb.dual_path_pair_count;

        for (int unsigned pos = 0; pos < pattern_count; pos++)
          send_smoke_vector_kind(smoke_pattern_kind(SMOKE_PATTERN_ALL, pos),
            pos, $sformatf("%s iter=%0d pos=%0d", ctx, iter, pos));

        wait_for_input_count(base_inputs + pattern_count, pattern_count + 512,
          $sformatf("%s iter=%0d inputs", ctx, iter));
        wait_for_beat_count(base_beats + pattern_count, pattern_count + 1024,
          $sformatf("%s iter=%0d beats", ctx, iter));
        wait_for_trace_count(base_traces + pattern_count, pattern_count + 1024,
          $sformatf("%s iter=%0d traces", ctx, iter));
        wait_for_debug_ts_count(base_debug_ts + pattern_count,
          pattern_count + 512, $sformatf("%s iter=%0d debug_ts", ctx, iter));
        wait_for_debug_burst_count(base_debug_burst + pattern_count,
          pattern_count + 512, $sformatf("%s iter=%0d debug_burst", ctx, iter));
        wait_for_ts_delta_count(base_ts_delta + pattern_count,
          pattern_count + 512, $sformatf("%s iter=%0d ts_delta", ctx, iter));
        expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
          base_ts_delta, pattern_count, pattern_count, pattern_count,
          $sformatf("%s iter=%0d", ctx, iter));
        if (m_env.m_scb.dual_path_pair_count != base_dual_pairs + pattern_count)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s iter=%0d expected %0d new dual-path pairs, got %0d",
              ctx, iter, pattern_count,
              m_env.m_scb.dual_path_pair_count - base_dual_pairs))

        for (int unsigned pos = 0; pos < pattern_count; pos++)
          expect_smoke_vector_kind_at(base_history_size + pos,
            base_traces + pos, smoke_pattern_kind(SMOKE_PATTERN_ALL, pos),
            $sformatf("%s iter=%0d payload pos=%0d", ctx, iter, pos));
        expect_latency_cycles_since(base_inputs, base_history_size,
          pattern_count, 10, $sformatf("%s iter=%0d", ctx, iter));
        expect_total_count(pattern_count,
          $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0,
          $sformatf("%s iter=%0d discard", ctx, iter));

        csr_write(3'd0, 32'h4000_0005);
        wait_cycles(4);
        expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004,
          $sformatf("%s iter=%0d soft_reset self-clear", ctx, iter));
        expect_total_count(48'd0,
          $sformatf("%s iter=%0d post-reset total", ctx, iter));
        expect_discard_count(32'd0,
          $sformatf("%s iter=%0d post-reset discard", ctx, iter));
      end
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
                                                string ctx,
                                                bit eop_value = 1'b0);
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
        eflag_value, sop_value, eop_value, '0, 1'b1, tfine_value);
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

    task automatic wait_for_debug_ts_count(int unsigned expected_count,
                                           int unsigned max_cycles,
                                           string ctx);
      repeat (max_cycles) begin
        if (m_env.m_scb.debug_ts_count >= expected_count)
          return;
        @(posedge ctrl_vif.clk);
      end
      `uvm_fatal("MTSP_TIMEOUT",
        $sformatf("%s timed out waiting for debug_ts_count=%0d, got %0d",
          ctx, expected_count, m_env.m_scb.debug_ts_count))
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

    function automatic int unsigned stress_prng(int unsigned idx,
                                                int unsigned salt);
      int unsigned value;

      value = idx ^ (salt * 32'h9e37_79b9);
      value ^= (value << 13);
      value ^= (value >> 17);
      value ^= (value << 5);
      return value;
    endfunction

    function automatic int unsigned stress_rand_mod(int unsigned idx,
                                                    int unsigned salt,
                                                    int unsigned modulo);
      if (modulo == 0)
        return 0;
      return stress_prng(idx, salt) % modulo;
    endfunction

    function automatic bit random_force_stop_drop(int unsigned idx);
      if (idx == 0)
        return 1'b0;
      return ((stress_rand_mod(idx, 95, 11) == 0) ||
              (stress_rand_mod(idx, 195, 17) == 3));
    endfunction

    function automatic bit random_hiterr_value(int unsigned idx);
      return ((stress_rand_mod(idx, 92, 4) == 0) ||
              (stress_rand_mod(idx, 192, 9) == 4));
    endfunction

    function automatic bit random_discard_policy(int unsigned idx);
      return stress_rand_mod(idx / 8, 292, 3) != 0;
    endfunction

    function automatic int unsigned random_latency_value(int unsigned phase);
      case (stress_rand_mod(phase, 100, 8))
        0: return 1;
        1: return 4096;
        2: return 3;
        3: return 2048;
        4: return 2;
        5: return 512;
        6: return 8;
        default: return 8192;
      endcase
    endfunction

    function automatic logic [8:0] random_illegal_ctrl_word(int unsigned iter,
                                                            int unsigned salt);
      case (stress_rand_mod(iter, salt, 5))
        0: return CTRL_RUNNING | CTRL_TERMINATING;
        1: return CTRL_RUN_PREPARE | CTRL_SYNC;
        2: return CTRL_IDLE | CTRL_RUNNING;
        3: return CTRL_IDLE | CTRL_TERMINATING;
        default: return CTRL_SYNC | CTRL_RUNNING;
      endcase
    endfunction

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
      send_stress_hit_with_channel(idx, stress_channel(idx), derive_tot,
        sop_value, eop_value, error_value, ctx);
    endtask

    task automatic send_stress_hit_with_channel(int unsigned idx,
                                                int unsigned channel_value,
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
      send_hit_beat(stress_asic(idx), channel_value, t_raw_value,
        e_raw_value, stress_eflag(idx, derive_tot), sop_value, eop_value,
        error_value, 1'b1, stress_tfine(idx));
    endtask

    task automatic expect_stress_payload_at(int unsigned history_idx,
                                            int unsigned trace_idx,
                                            int unsigned stimulus_idx,
                                            bit derive_tot,
                                            string ctx);
      expect_stress_payload_at_with_channel(history_idx, trace_idx,
        stimulus_idx, stress_channel(stimulus_idx), derive_tot, ctx);
    endtask

    task automatic expect_stress_payload_at_with_channel(int unsigned history_idx,
                                                         int unsigned trace_idx,
                                                         int unsigned stimulus_idx,
                                                         int unsigned channel_value,
                                                         bit derive_tot,
                                                         string ctx);
      expect_payload_math_at(history_idx, stress_asic(stimulus_idx),
        channel_value, stress_tfine(stimulus_idx),
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
    localparam int unsigned PROFILE_PATTERN_MID_WINDOW    = 8;
    localparam int unsigned PROFILE_PATTERN_RANDOM_ASIC   = 9;
    localparam int unsigned PROFILE_PATTERN_RANDOM_CHANNEL = 10;

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
        PROFILE_PATTERN_MID_WINDOW: begin
          sideband_channel = 1 + (idx % 2);
          channel_value    = sideband_channel;
          quotient         = profile_route_quotient(sideband_channel, idx / 2);
          sop_value        = (idx < 2);
        end
        PROFILE_PATTERN_RANDOM_ASIC: begin
          sideband_channel = idx % 4;
          asic_value       = stress_rand_mod(idx, 198, 16);
          channel_value    = 7;
          quotient         = profile_route_quotient(sideband_channel,
            stress_rand_mod(idx, 298, 16));
          remainder        = stress_rand_mod(idx, 398, 5);
          sop_value        = (idx < 4);
          tfine_value      = stress_rand_mod(idx, 498, 32);
        end
        PROFILE_PATTERN_RANDOM_CHANNEL: begin
          sideband_channel = idx % 4;
          asic_value       = 2 + stress_rand_mod(idx, 199, 4);
          channel_value    = stress_rand_mod(idx, 299, 32);
          quotient         = profile_route_quotient(sideband_channel,
            stress_rand_mod(idx, 399, 16));
          remainder        = stress_rand_mod(idx, 499, 5);
          sop_value        = (idx < 4);
          tfine_value      = stress_rand_mod(idx, 599, 32);
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

    task automatic expect_latency_cycles_since(int unsigned base_inputs,
                                               int unsigned base_history_size,
                                               int unsigned hit_count,
                                               int unsigned expected_cycles,
                                               string ctx);
      int unsigned min_cycles;
      int unsigned max_cycles;

      min_cycles = 32'hffff_ffff;
      max_cycles = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        mtsp_hit0_obs_item hit0_obs;
        mtsp_hit1_obs_item hit1_obs;
        time               latency_ps;
        int unsigned       observed_cycles;

        if (base_inputs + idx >= m_env.m_scb.hit0_history.size())
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s missing input latency sample idx=%0d", ctx, idx))
        if (base_history_size + idx >= m_env.m_scb.history.size())
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s missing output latency sample idx=%0d", ctx, idx))

        hit0_obs = m_env.m_scb.hit0_history[base_inputs + idx];
        hit1_obs = m_env.m_scb.history[base_history_size + idx];
        if (hit1_obs.empty)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s expected payload for latency sample idx=%0d",
              ctx, idx))
        if (hit1_obs.time_ps <= hit0_obs.time_ps)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s non-positive latency idx=%0d hit0=%0t hit1=%0t",
              ctx, idx, hit0_obs.time_ps, hit1_obs.time_ps))
        latency_ps      = hit1_obs.time_ps - hit0_obs.time_ps;
        observed_cycles = int'(latency_ps / CLK_PERIOD_PS);
        if ((latency_ps % CLK_PERIOD_PS) != 0 ||
            observed_cycles != expected_cycles)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s expected latency %0d cycles at idx=%0d, got %0d cycles (%0t ps)",
              ctx, expected_cycles, idx, observed_cycles, latency_ps))
        if (observed_cycles < min_cycles)
          min_cycles = observed_cycles;
        if (observed_cycles > max_cycles)
          max_cycles = observed_cycles;
      end

      `uvm_info("MTSP_LATENCY",
        $sformatf("%s latency_samples=%0d min_cycles=%0d max_cycles=%0d",
          ctx, hit_count, min_cycles, max_cycles),
        UVM_LOW)
    endtask

    task automatic run_pipeline_parameter_soak_case(int unsigned hit_count,
                                                    int unsigned expected_cycles,
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

      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0, ctx);

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      expect_stress_stream_since(base_history_size, base_traces, hit_count,
        1'b0, 0, 1'b1, ctx);
      expect_latency_cycles_since(base_inputs, base_history_size, hit_count,
        expected_cycles, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_remapped_hiterr_soak_case(int unsigned hit_count,
                                                 string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned expected_discards;
      int unsigned expected_payloads;
      int unsigned emitted_idx;

      wait_for_reset_release();
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      expected_discards = hit_count / 8;
      expected_payloads = hit_count - expected_discards;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [2:0] error_value;

        error_value = '0;
        if ((idx % 8) == 3)
          error_value = 3'b001;
        if ((idx % 8) == 7)
          error_value = 3'b100;
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, error_value, ctx);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + expected_payloads, hit_count + 2048,
        ctx);
      wait_for_trace_count(base_traces + expected_payloads, hit_count + 2048,
        ctx);

      emitted_idx = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        if ((idx % 8) != 7) begin
          expect_stress_payload_at(base_history_size + emitted_idx,
            base_traces + emitted_idx, idx, 1'b0,
            $sformatf("%s remapped payload idx=%0d", ctx, idx));
          emitted_idx++;
        end
      end
      expect_total_count(hit_count, ctx);
      expect_discard_count(expected_discards, ctx);
    endtask

    task automatic run_custom_default_latency_soak_case(int unsigned hit_count,
                                                        int unsigned expected_latency,
                                                        string ctx);
      bit [31:0] csr_word;

      wait_for_reset_release();
      csr_read(3'd2, csr_word);
      if (csr_word !== expected_latency[31:0])
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected power-on expected_latency CSR=%0d got %0d",
            ctx, expected_latency, csr_word))
      run_stress_stream_case(hit_count, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0,
        1'b1, 1'b0, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++)
        expect_trace_expected_latency_at(m_env.m_scb.trace_history.size() -
          hit_count + idx, expected_latency,
          $sformatf("%s default latency trace idx=%0d", ctx, idx));
    endtask

    task automatic run_inert_parameter_soak_case(int unsigned hit_count,
                                                 string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      run_start();

      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [2:0] error_value;
        bit       eop_value;
        bit       sop_value;
        int unsigned channel_value;

        error_value = '0;
        if ((idx % 4) == 1)
          error_value = 3'b010;
        else if ((idx % 4) == 3)
          error_value = 3'b100;
        channel_value = idx % 4;
        sop_value     = idx < 4;
        eop_value     = idx >= hit_count - 4;
        send_stress_hit_with_channel(idx, channel_value, 1'b0, sop_value,
          eop_value, error_value, ctx);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++)
        expect_stress_payload_at_with_channel(base_history_size + idx,
          base_traces + idx, idx, idx % 4, 1'b0,
          $sformatf("%s inert payload idx=%0d", ctx, idx));
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);

      base_history_size = m_env.m_scb.history.size();
      base_empty_eops   = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 512,
        $sformatf("%s inert close markers", ctx));
      expect_close_markers_since(base_history_size, 4'b1111, 0,
        $sformatf("%s inert close marker detail", ctx));
      wait_for_ctrl_ready_high(512,
        $sformatf("%s terminate ready restore", ctx));
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

    task automatic expect_debug_stream_counts_since(int unsigned base_debug_ts,
                                                    int unsigned base_debug_burst,
                                                    int unsigned base_ts_delta,
                                                    int unsigned expected_debug_ts,
                                                    int unsigned expected_debug_burst,
                                                    int unsigned expected_ts_delta,
                                                    string ctx);
      if (m_env.m_scb.debug_ts_count != base_debug_ts + expected_debug_ts)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new debug_ts samples, got %0d from base %0d",
            ctx, expected_debug_ts, m_env.m_scb.debug_ts_count - base_debug_ts,
            base_debug_ts))
      if (m_env.m_scb.debug_burst_count != base_debug_burst + expected_debug_burst)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new debug_burst samples, got %0d from base %0d",
            ctx, expected_debug_burst,
            m_env.m_scb.debug_burst_count - base_debug_burst,
            base_debug_burst))
      if (m_env.m_scb.ts_delta_count != base_ts_delta + expected_ts_delta)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new ts_delta samples, got %0d from base %0d",
            ctx, expected_ts_delta, m_env.m_scb.ts_delta_count - base_ts_delta,
            base_ts_delta))
    endtask

    task automatic expect_ts_delta_sign_churn_since(int unsigned base_ts_delta,
                                                    int unsigned new_count,
                                                    int unsigned min_positive,
                                                    int unsigned min_negative,
                                                    int unsigned min_flips,
                                                    string ctx);
      int unsigned pos_count;
      int unsigned neg_count;
      int unsigned flip_count;
      int          last_sign;

      pos_count  = 0;
      neg_count  = 0;
      flip_count = 0;
      last_sign  = 0;

      if (m_env.m_scb.ts_delta_history.size() < base_ts_delta + new_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d ts_delta samples from base %0d, got size=%0d",
            ctx, new_count, base_ts_delta, m_env.m_scb.ts_delta_history.size()))

      for (int unsigned idx = 0; idx < new_count; idx++) begin
        mtsp_dbg_obs_item obs;
        int signed        delta;
        int               sign;

        obs   = m_env.m_scb.ts_delta_history[base_ts_delta + idx];
        delta = m_env.m_scb.signed16(obs.data);
        sign  = (delta < 0) ? -1 : ((delta > 0) ? 1 : 0);
        if (sign > 0)
          pos_count++;
        else if (sign < 0)
          neg_count++;
        if (last_sign != 0 && sign != 0 && sign != last_sign)
          flip_count++;
        if (sign != 0)
          last_sign = sign;
      end

      if (pos_count < min_positive || neg_count < min_negative ||
          flip_count < min_flips)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected sign churn pos>=%0d neg>=%0d flips>=%0d, got pos=%0d neg=%0d flips=%0d",
            ctx, min_positive, min_negative, min_flips, pos_count, neg_count,
            flip_count))
    endtask

    task automatic expect_ts_delta_zero_after_warmup_since(int unsigned base_ts_delta,
                                                           int unsigned new_count,
                                                           int unsigned warmup_count,
                                                           string ctx);
      if (m_env.m_scb.ts_delta_history.size() < base_ts_delta + new_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d ts_delta samples from base %0d, got size=%0d",
            ctx, new_count, base_ts_delta, m_env.m_scb.ts_delta_history.size()))

      for (int unsigned idx = warmup_count; idx < new_count; idx++) begin
        mtsp_dbg_obs_item obs;
        int signed        delta;

        obs   = m_env.m_scb.ts_delta_history[base_ts_delta + idx];
        delta = m_env.m_scb.signed16(obs.data);
        if (delta != 0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s expected zero ts_delta after warmup at local idx=%0d, got %0d (0x%04h)",
              ctx, idx, delta, obs.data))
      end
    endtask

    task automatic run_random_marker_mix_case(int unsigned hit_count,
                                              string ctx);
      int unsigned sideband_seq[128];
      int unsigned asic_seq[128];
      int unsigned channel_seq[128];
      int unsigned quotient_seq[128];
      int unsigned remainder_seq[128];
      int unsigned tfine_seq[128];
      bit          sop_seq[128];
      bit          eop_seq[128];
      bit          open_by_ch[4];
      int unsigned remaining_by_ch[4];
      bit          route_seen[4];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned sop_only_count;
      int unsigned eop_only_count;
      int unsigned sop_eop_count;
      int unsigned plain_count;

      if (hit_count > 128)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s random marker hit_count=%0d exceeds local model depth",
            ctx, hit_count))

      foreach (open_by_ch[ch]) begin
        open_by_ch[ch]      = 1'b0;
        remaining_by_ch[ch] = 0;
      end
      sop_only_count = 0;
      eop_only_count = 0;
      sop_eop_count  = 0;
      plain_count    = 0;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned sideband_channel;

        if (idx < 8) begin
          case (idx)
            0: begin sideband_channel = 0; sop_seq[idx] = 1'b1; eop_seq[idx] = 1'b1; end
            1: begin sideband_channel = 1; sop_seq[idx] = 1'b1; eop_seq[idx] = 1'b0; end
            2: begin sideband_channel = 1; sop_seq[idx] = 1'b0; eop_seq[idx] = 1'b0; end
            3: begin sideband_channel = 1; sop_seq[idx] = 1'b0; eop_seq[idx] = 1'b1; end
            4: begin sideband_channel = 2; sop_seq[idx] = 1'b1; eop_seq[idx] = 1'b0; end
            5: begin sideband_channel = 2; sop_seq[idx] = 1'b0; eop_seq[idx] = 1'b1; end
            6: begin sideband_channel = 3; sop_seq[idx] = 1'b1; eop_seq[idx] = 1'b1; end
            default: begin sideband_channel = 0; sop_seq[idx] = 1'b1; eop_seq[idx] = 1'b0; end
          endcase
          open_by_ch[sideband_channel] = sop_seq[idx] && !eop_seq[idx];
          remaining_by_ch[sideband_channel] = open_by_ch[sideband_channel] ?
            1 : 0;
        end else begin
          sideband_channel = stress_rand_mod(idx, 91, 4);
          if (!open_by_ch[sideband_channel]) begin
            int unsigned remaining_after_first;

            sop_seq[idx] = 1'b1;
            remaining_after_first = stress_rand_mod(idx, 191, 4);
            eop_seq[idx] = (remaining_after_first == 0);
            open_by_ch[sideband_channel] = !eop_seq[idx];
            remaining_by_ch[sideband_channel] = remaining_after_first;
          end else begin
            sop_seq[idx] = 1'b0;
            eop_seq[idx] = (remaining_by_ch[sideband_channel] <= 1) ||
              (stress_rand_mod(idx, 291, 5) == 0);
            if (eop_seq[idx]) begin
              open_by_ch[sideband_channel] = 1'b0;
              remaining_by_ch[sideband_channel] = 0;
            end else begin
              remaining_by_ch[sideband_channel]--;
            end
          end
        end

        sideband_seq[idx] = sideband_channel;
        asic_seq[idx]     = 2 + stress_rand_mod(idx, 391, 4);
        channel_seq[idx]  = stress_rand_mod(idx, 491, 32);
        quotient_seq[idx] = profile_route_quotient(sideband_channel,
          stress_rand_mod(idx, 591, 16));
        remainder_seq[idx] = stress_rand_mod(idx, 691, 5);
        tfine_seq[idx]     = stress_rand_mod(idx, 791, 32);

        if (sop_seq[idx] && eop_seq[idx])
          sop_eop_count++;
        else if (sop_seq[idx])
          sop_only_count++;
        else if (eop_seq[idx])
          eop_only_count++;
        else
          plain_count++;
      end

      if (sop_only_count == 0 || eop_only_count == 0 ||
          sop_eop_count == 0 || plain_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s marker generator missed a marker class: sop_only=%0d eop_only=%0d sop_eop=%0d plain=%0d",
            ctx, sop_only_count, eop_only_count, sop_eop_count, plain_count))

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_profile_hit(sideband_seq[idx], asic_seq[idx], channel_seq[idx],
          quotient_seq[idx], remainder_seq[idx], sop_seq[idx], eop_seq[idx],
          '0, tfine_seq[idx], $sformatf("%s marker hit idx=%0d", ctx, idx));

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count, hit_count + 512,
        ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 512, ctx);

      foreach (route_seen[route])
        route_seen[route] = 1'b0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned route_value;
        bit          expected_sop;

        route_value  = profile_route_from_q(quotient_seq[idx]);
        expected_sop = !route_seen[route_value];
        route_seen[route_value] = 1'b1;
        expect_hit0_fields_at(base_inputs + idx, sideband_seq[idx],
          sop_seq[idx], eop_seq[idx], '0,
          $sformatf("%s input marker idx=%0d", ctx, idx));
        expect_profile_payload_at(base_history_size + idx, base_traces + idx,
          asic_seq[idx], channel_seq[idx], tfine_seq[idx], quotient_seq[idx],
          remainder_seq[idx], route_value, expected_sop,
          $sformatf("%s output marker idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_random_accept_reject_mix_case(int unsigned hit_count,
                                                     string ctx);
      bit          discard_seq[160];
      bit          hiterr_seq[160];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned expected_discards;
      int unsigned expected_payloads;
      int unsigned emitted_idx;
      bit [31:0]   mode_word;

      if (hit_count > 160)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s accept/reject hit_count=%0d exceeds local model depth",
            ctx, hit_count))

      expected_discards = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        discard_seq[idx] = random_discard_policy(idx);
        hiterr_seq[idx]  = random_hiterr_value(idx);
        if (discard_seq[idx] && hiterr_seq[idx])
          expected_discards++;
      end
      expected_payloads = hit_count - expected_discards;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [2:0] error_value;

        if ((idx % 8) == 0) begin
          mode_word = datapath_mode_word(1'b1, 1'b0, 1'b1);
          if (!discard_seq[idx])
            mode_word &= ~32'h0000_0010;
          csr_write(3'd0, mode_word);
          wait_cycles(2);
        end
        error_value = hiterr_seq[idx] ? 3'b001 : 3'b000;
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, error_value,
          $sformatf("%s accept/reject hit idx=%0d", ctx, idx));
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + expected_payloads, hit_count + 2048,
        ctx);
      wait_for_trace_count(base_traces + expected_payloads, hit_count + 2048,
        ctx);
      wait_for_debug_ts_count(base_debug_ts + expected_payloads,
        hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + expected_payloads,
        hit_count + 512, ctx);
      wait_for_ts_delta_count(base_ts_delta + expected_payloads,
        hit_count + 512, ctx);

      emitted_idx = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [2:0] error_value;

        error_value = hiterr_seq[idx] ? 3'b001 : 3'b000;
        expect_hit0_fields_at(base_inputs + idx, stress_asic(idx), idx == 0,
          1'b0, error_value, $sformatf("%s input idx=%0d", ctx, idx));
        if (!(discard_seq[idx] && hiterr_seq[idx])) begin
          expect_stress_payload_at(base_history_size + emitted_idx,
            base_traces + emitted_idx, idx, 1'b0,
            $sformatf("%s accepted payload idx=%0d", ctx, idx));
          emitted_idx++;
        end
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, expected_payloads, expected_payloads, expected_payloads,
        ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(expected_discards[31:0], ctx);
    endtask

    task automatic run_random_delay_path_mix_case(int unsigned hit_count,
                                                  string ctx);
      bit          delay_use_t_seq[96];
      bit          selected_error_seq[96];
      int unsigned expected_t_q_seq[96];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned raw_clean;
      int unsigned raw_error;
      bit          route_seen[4];

      if (hit_count > 96)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s delay-path hit_count=%0d exceeds local model depth",
            ctx, hit_count))

      lookup_raw_for_quotient(0, 0, raw_clean, $sformatf("%s clean symbol",
        ctx));
      lookup_raw_for_quotient(1024, 0, raw_error, $sformatf("%s error symbol",
        ctx));
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        delay_use_t_seq[idx]    = stress_rand_mod(idx, 93, 2);
        selected_error_seq[idx] = stress_rand_mod(idx, 193, 3) == 0;
        expected_t_q_seq[idx]   = (delay_use_t_seq[idx] &&
          selected_error_seq[idx]) ? 1024 : 0;
      end

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd512);
      wait_cycles(2);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        bit [31:0]   mode_word;
        int unsigned t_raw_value;
        int unsigned e_raw_value;

        mode_word = datapath_mode_word(1'b1, 1'b0, delay_use_t_seq[idx]);
        csr_write(3'd0, mode_word);
        wait_cycles(2);
        if (delay_use_t_seq[idx]) begin
          t_raw_value = selected_error_seq[idx] ? raw_error : raw_clean;
          e_raw_value = raw_clean;
        end else begin
          t_raw_value = raw_clean;
          e_raw_value = selected_error_seq[idx] ? raw_error : raw_clean;
        end
        send_hit_beat(2, idx % 32, t_raw_value, e_raw_value, 1'b0, 1'b1,
          1'b1, '0, 1'b1, idx[4:0]);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count, hit_count + 512,
        ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 512, ctx);

      foreach (route_seen[route])
        route_seen[route] = 1'b0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned route_value;
        bit          expected_sop;

        route_value  = profile_route_from_q(expected_t_q_seq[idx]);
        expected_sop = !route_seen[route_value];
        route_seen[route_value] = 1'b1;
        expect_hit0_fields_at(base_inputs + idx, 2, 1'b1, 1'b1, '0,
          $sformatf("%s input packet idx=%0d", ctx, idx));
        expect_payload_math_at(base_history_size + idx, 2, idx % 32,
          idx[4:0], expected_t_q_seq[idx], 0, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_output_flags_at(base_history_size + idx, expected_sop, 1'b0,
          1'b0, route_value, $sformatf("%s output flags idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, selected_error_seq[idx],
          $sformatf("%s trace error idx=%0d", ctx, idx));
        expect_trace_expected_latency_at(base_traces + idx, 512,
          $sformatf("%s trace latency idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_random_tot_mode_mix_case(int unsigned hit_count,
                                                string ctx);
      bit          derive_seq[128];
      bit          route_seen[4];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned short_count;
      int unsigned tot_count;

      if (hit_count > 128)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ToT mix hit_count=%0d exceeds local model depth",
            ctx, hit_count))

      short_count = 0;
      tot_count   = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        derive_seq[idx] = stress_rand_mod(idx, 94, 2);
        if (derive_seq[idx])
          tot_count++;
        else
          short_count++;
      end
      if (short_count == 0 || tot_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ToT mode generator missed short=%0d tot=%0d",
            ctx, short_count, tot_count))

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        csr_write(3'd0, datapath_mode_word(1'b1, derive_seq[idx], 1'b1));
        wait_cycles(2);
        send_stress_hit(idx, derive_seq[idx], 1'b1, 1'b1, '0,
          $sformatf("%s tot-mode hit idx=%0d", ctx, idx));
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 2048, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count, hit_count + 512,
        ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 512, ctx);

      foreach (route_seen[route])
        route_seen[route] = 1'b0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned route_value;
        bit          expected_sop;

        route_value  = profile_route_from_q(stress_t_quotient(idx));
        expected_sop = !route_seen[route_value];
        route_seen[route_value] = 1'b1;
        expect_hit0_fields_at(base_inputs + idx, stress_asic(idx), 1'b1,
          1'b1, '0, $sformatf("%s input packet idx=%0d", ctx, idx));
        expect_stress_payload_at(base_history_size + idx, base_traces + idx,
          idx, derive_seq[idx], $sformatf("%s payload idx=%0d", ctx, idx));
        expect_output_flags_at(base_history_size + idx, expected_sop, 1'b0,
          1'b0, route_value, $sformatf("%s output flags idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_random_force_stop_case(int unsigned hit_count,
                                              string ctx);
      bit          drop_seq[128];
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned drop_count;
      int unsigned emitted_idx;

      if (hit_count > 128)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s force-stop hit_count=%0d exceeds local model depth",
            ctx, hit_count))

      drop_count = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        drop_seq[idx] = random_force_stop_drop(idx);
        if (drop_seq[idx])
          drop_count++;
      end
      if (drop_count == 0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s force-stop generator produced no drops", ctx))

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        if (drop_seq[idx]) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1) |
            32'h0000_0002);
          wait_cycles(2);
        end
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0,
          $sformatf("%s force-stop hit idx=%0d", ctx, idx));
        if (drop_seq[idx]) begin
          csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1));
          wait_cycles(2);
        end
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_beat_count(base_beats + hit_count - drop_count,
        hit_count + 2048, ctx);
      wait_for_trace_count(base_traces + hit_count - drop_count,
        hit_count + 2048, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count - drop_count,
        hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count - drop_count,
        hit_count + 512, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count - drop_count,
        hit_count + 512, ctx);

      emitted_idx = 0;
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        expect_hit0_fields_at(base_inputs + idx, stress_asic(idx), idx == 0,
          1'b0, '0, $sformatf("%s input idx=%0d", ctx, idx));
        if (!drop_seq[idx]) begin
          expect_stress_payload_at(base_history_size + emitted_idx,
            base_traces + emitted_idx, idx, 1'b0,
            $sformatf("%s accepted payload idx=%0d", ctx, idx));
          emitted_idx++;
        end
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count - drop_count, hit_count - drop_count,
        hit_count - drop_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(drop_count[31:0], ctx);
    endtask

    task automatic run_random_soft_reset_case(int unsigned phases,
                                              string ctx);
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      for (int unsigned phase = 0; phase < phases; phase++) begin
        int unsigned phase_hits;
        int unsigned reset_gap;
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history_size;
        int unsigned base_traces;
        int unsigned base_debug_ts;
        int unsigned base_debug_burst;
        int unsigned base_ts_delta;

        phase_hits = 4 + stress_rand_mod(phase, 96, 13);
        reset_gap  = 2 + stress_rand_mod(phase, 196, 9);
        wait_for_hit0_ready(1'b1, 64,
          $sformatf("%s phase %0d hit ready", ctx, phase));
        base_inputs      = m_env.m_scb.hit0_history.size();
        base_beats       = m_env.m_scb.beat_count;
        base_history_size = m_env.m_scb.history.size();
        base_traces      = m_env.m_scb.trace_history.size();
        base_debug_ts    = m_env.m_scb.debug_ts_count;
        base_debug_burst = m_env.m_scb.debug_burst_count;
        base_ts_delta    = m_env.m_scb.ts_delta_count;

        for (int unsigned beat = 0; beat < phase_hits; beat++) begin
          int unsigned idx;

          idx = beat;
          send_stress_hit(idx, 1'b0, beat == 0, 1'b0, '0,
            $sformatf("%s phase %0d hit beat=%0d", ctx, phase, beat));
        end

        wait_for_input_count(base_inputs + phase_hits, phase_hits + 512,
          $sformatf("%s phase %0d inputs", ctx, phase));
        wait_for_beat_count(base_beats + phase_hits, phase_hits + 1024,
          $sformatf("%s phase %0d beats", ctx, phase));
        wait_for_trace_count(base_traces + phase_hits, phase_hits + 1024,
          $sformatf("%s phase %0d traces", ctx, phase));
        wait_for_debug_ts_count(base_debug_ts + phase_hits, phase_hits + 256,
          $sformatf("%s phase %0d debug_ts", ctx, phase));
        wait_for_debug_burst_count(base_debug_burst + phase_hits,
          phase_hits + 256, $sformatf("%s phase %0d debug_burst", ctx, phase));
        wait_for_ts_delta_count(base_ts_delta + phase_hits, phase_hits + 256,
          $sformatf("%s phase %0d ts_delta", ctx, phase));

        for (int unsigned beat = 0; beat < phase_hits; beat++) begin
          int unsigned idx;

          idx = beat;
          expect_stress_payload_at(base_history_size + beat,
            base_traces + beat, idx, 1'b0,
            $sformatf("%s phase %0d payload beat=%0d", ctx, phase, beat));
        end
        expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
          base_ts_delta, phase_hits, phase_hits, phase_hits,
          $sformatf("%s phase %0d", ctx, phase));
        expect_total_count(phase_hits,
          $sformatf("%s phase %0d total", ctx, phase));
        expect_discard_count(32'd0,
          $sformatf("%s phase %0d discard", ctx, phase));

        wait_cycles(reset_gap);
        csr_write(3'd0, datapath_mode_word(1'b1, 1'b0, 1'b1) |
          32'h0000_0004);
        wait_cycles(4);
        expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0004,
          $sformatf("%s phase %0d soft_reset self-clear", ctx, phase));
        expect_total_count(48'd0,
          $sformatf("%s phase %0d post-soft-reset total", ctx, phase));
        expect_discard_count(32'd0,
          $sformatf("%s phase %0d post-soft-reset discard", ctx, phase));
      end
    endtask

    task automatic run_random_ctrl_chatter_case(int unsigned iterations,
                                                string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      bit [47:0]   final_total;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_debug_ts   = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta   = m_env.m_scb.ts_delta_count;
      final_total     = 48'd0;

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;
        bit [47:0]   expected_total;
        bit          direct_running;

        pulse_ctrl(random_illegal_ctrl_word(iter, 97),
          $sformatf("RANDOM_ILLEGAL_PRE_%0d", iter));
        wait_cycles(1);
        direct_running = stress_rand_mod(iter, 197, 2);
        start_run_control_cycle(direct_running, iter, ctx);
        pulse_ctrl(random_illegal_ctrl_word(iter, 297),
          $sformatf("RANDOM_ILLEGAL_ACTIVE_%0d", iter));
        wait_cycles(1);
        expect_csr_mask(3'd0, 32'h0000_0001, 32'h0000_0001,
          $sformatf("%s illegal active containment iter=%0d", ctx, iter));
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s random chatter hit iter=%0d", ctx,
          iter));
        pulse_ctrl(random_illegal_ctrl_word(iter, 397),
          $sformatf("RANDOM_ILLEGAL_PRE_TERMINATE_%0d", iter));
        wait_cycles(1);
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s random chatter iter=%0d", ctx, iter));
        expected_total = direct_running ? (final_total + 48'd1) : 48'd1;
        expect_total_count(expected_total, $sformatf("%s iter=%0d total",
          ctx, iter));
        final_total = expected_total;
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end

      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d beats after random chatter, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d traces after random chatter, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers after random chatter, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, iterations, iterations, iterations, ctx);
      expect_total_count(final_total, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_random_latency_rewrite_case(int unsigned phase_count,
                                                   int unsigned phase_hits,
                                                   string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned hit_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      hit_count        = phase_count * phase_hits;

      for (int unsigned phase = 0; phase < phase_count; phase++) begin
        int unsigned latency_value;

        latency_value = random_latency_value(phase);
        csr_write(3'd2, latency_value);
        wait_cycles(2);
        for (int unsigned beat = 0; beat < phase_hits; beat++) begin
          int unsigned idx;

          idx = (phase * phase_hits) + beat;
          send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0,
            $sformatf("%s latency phase=%0d beat=%0d", ctx, phase, beat));
        end
        wait_for_beat_count(base_beats + ((phase + 1) * phase_hits),
          phase_hits + 1024, $sformatf("%s phase %0d", ctx, phase));
        wait_for_trace_count(base_traces + ((phase + 1) * phase_hits),
          phase_hits + 1024, $sformatf("%s phase %0d", ctx, phase));
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 1024, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 512, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count, hit_count + 512,
        ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 512, ctx);

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned phase;
        int unsigned latency_value;
        bit          expected_error;

        phase          = idx / phase_hits;
        latency_value  = random_latency_value(phase);
        expected_error = (latency_value < 16);
        expect_payload_math_at(base_history_size + idx, stress_asic(idx),
          stress_channel(idx), stress_tfine(idx), stress_t_quotient(idx),
          stress_t_remainder(idx), stress_expected_et(idx, 1'b0),
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_expected_latency_at(base_traces + idx, latency_value,
          $sformatf("%s latency idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, expected_error,
          $sformatf("%s error idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic send_delaypath_hit_and_expect(int unsigned t_quotient,
                                                 int unsigned t_remainder,
                                                 int unsigned e_quotient,
                                                 int unsigned e_remainder,
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

      lookup_raw_for_quotient(t_quotient, t_remainder, t_raw_value,
        $sformatf("%s T symbol", ctx));
      lookup_raw_for_quotient(e_quotient, e_remainder, e_raw_value,
        $sformatf("%s E symbol", ctx));

      base_inputs  = m_env.m_scb.hit0_history.size();
      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();
      send_hit_beat(asic_value, channel_value, t_raw_value, e_raw_value,
        1'b0, sop_value, 1'b0, '0, 1'b1, tfine_value);
      wait_for_input_count(base_inputs + 1, 128, ctx);
      wait_for_beat_count(base_beats + 1, 256, ctx);
      wait_for_trace_count(base_traces + 1, 256, ctx);
      expect_payload_math_at(base_history, asic_value, channel_value,
        tfine_value, t_quotient, t_remainder, 0, ctx);
      expect_trace_pair_at(base_traces, ctx);
      if (check_error)
        expect_trace_error_at(base_traces, expected_error, ctx);
      else
        expect_trace_math_self_consistent_at(base_traces, ctx);
    endtask

    task automatic run_debug_stream_count_case(int unsigned hit_count,
                                               string ctx);
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      run_stress_stream_case(hit_count, 0, 1'b0, 1'b1, 1'b1, 0, 0, 0,
        1'b1, 1'b0, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 256, ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 256, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 256, ctx);
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
    endtask

    task automatic run_debug_sign_churn_case(int unsigned hit_count,
                                             string ctx);
      int unsigned raw_low;
      int unsigned raw_high;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      lookup_raw_for_quotient(8, 0, raw_low,
        $sformatf("%s low timestamp symbol", ctx));
      lookup_raw_for_quotient(40, 0, raw_high,
        $sformatf("%s high timestamp symbol", ctx));
      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned quotient;
        int unsigned raw_value;

        quotient  = idx[0] ? 40 : 8;
        raw_value = idx[0] ? raw_high : raw_low;
        send_hit_beat(2, idx % 32, raw_value, raw_value, 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx[4:0]);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 1024, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 256,
        ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 256, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 256,
        ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned quotient;

        quotient = idx[0] ? 40 : 8;
        expect_payload_math_at(base_history_size + idx, 2, idx % 32,
          idx[4:0], quotient, 0, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_math_self_consistent_at(base_traces + idx,
          $sformatf("%s trace math idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_ts_delta_sign_churn_since(base_ts_delta, hit_count,
        hit_count / 3, hit_count / 3, hit_count / 2, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_debug_equal_timestamp_case(int unsigned hit_count,
                                                  string ctx);
      int unsigned raw_value;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      lookup_raw_for_quotient(24, 0, raw_value,
        $sformatf("%s equal timestamp symbol", ctx));
      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_hit_beat(2, idx % 32, raw_value, raw_value, 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx[4:0]);

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 1024, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 256,
        ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 256, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 256,
        ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        expect_payload_math_at(base_history_size + idx, 2, idx % 32,
          idx[4:0], 24, 0, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_math_self_consistent_at(base_traces + idx,
          $sformatf("%s trace math idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_ts_delta_zero_after_warmup_since(base_ts_delta, hit_count, 2,
        ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic send_target_debug_delta_hit(bit delay_ts_field_use_t,
                                               int signed target_delta,
                                               bit expected_error,
                                               int unsigned seq_idx,
                                               string ctx);
      int signed   predicted_arrival;
      int signed   target_quotient_signed;
      int unsigned target_quotient;
      int unsigned t_quotient;
      int unsigned e_quotient;

      calibrate_next_output_arrival(predicted_arrival,
        $sformatf("%s calibration seq=%0d", ctx, seq_idx));
      target_quotient_signed = predicted_arrival - target_delta;
      if (target_quotient_signed < 0 || target_quotient_signed > 6553)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s target quotient %0d is outside ROM range for delta=%0d predicted_arrival=%0d",
            ctx, target_quotient_signed, target_delta, predicted_arrival))
      target_quotient = target_quotient_signed;

      if (delay_ts_field_use_t) begin
        t_quotient = target_quotient;
        e_quotient = 2;
      end else begin
        t_quotient = 2;
        e_quotient = target_quotient;
      end

      send_delaypath_hit_and_expect(t_quotient, 0, e_quotient, 0, 2,
        seq_idx % 32, seq_idx[4:0], seq_idx == 0, 1'b1, expected_error,
        $sformatf("%s target_delta=%0d seq=%0d", ctx, target_delta, seq_idx));
    endtask

    task automatic run_debug_error_pipeline_case(bit delay_ts_field_use_t,
                                                 int unsigned hit_count,
                                                 string ctx);
      int unsigned raw_clean;
      int unsigned raw_error;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, delay_ts_field_use_t);
      csr_write(3'd2, 32'd512);
      wait_cycles(2);
      run_start();
      lookup_raw_for_quotient(0, 0, raw_clean,
        $sformatf("%s clean-delay symbol", ctx));
      lookup_raw_for_quotient(1024, 0, raw_error,
        $sformatf("%s error-delay symbol", ctx));
      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned selected_q;
        int unsigned t_raw_value;
        int unsigned e_raw_value;

        selected_q  = idx[0] ? 1024 : 0;
        t_raw_value = delay_ts_field_use_t ?
          (idx[0] ? raw_error : raw_clean) : raw_clean;
        e_raw_value = delay_ts_field_use_t ?
          raw_clean : (idx[0] ? raw_error : raw_clean);
        send_hit_beat(2, idx % 32, t_raw_value, e_raw_value, 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx[4:0]);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 1024, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 256,
        ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 256, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 256,
        ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned selected_q;
        int unsigned expected_t_q;
        bit          expected_error;

        selected_q      = idx[0] ? 1024 : 0;
        expected_t_q    = delay_ts_field_use_t ? selected_q : 0;
        expected_error  = idx[0];
        expect_payload_math_at(base_history_size + idx, 2, idx % 32,
          idx[4:0], expected_t_q, 0, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_error_at(base_traces + idx, expected_error,
          $sformatf("%s trace error idx=%0d", ctx, idx));
        expect_trace_expected_latency_at(base_traces + idx, 512,
          $sformatf("%s trace latency idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    function automatic int signed dense_edge_target_delta(int unsigned idx);
      if (idx < 8)
        return 8;
      case ((idx - 8) % 6)
        0: return 15;
        1: return 16;
        2: return 1;
        3: return 0;
        4: return 17;
        default: return 8;
      endcase
    endfunction

    task automatic run_debug_expected_latency_edge_case(string ctx);
      int unsigned hit_count;
      int signed   first_output_arrival;
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history_size;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      hit_count            = 72;
      first_output_arrival = 12;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      csr_write(3'd2, 32'd16);
      wait_cycles(2);
      run_start();
      base_inputs       = m_env.m_scb.hit0_history.size();
      base_beats        = m_env.m_scb.beat_count;
      base_history_size = m_env.m_scb.history.size();
      base_traces       = m_env.m_scb.trace_history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int signed   target_delta;
        int signed   target_quotient_signed;
        int unsigned target_quotient;
        int unsigned raw_value;

        target_delta = dense_edge_target_delta(idx);
        target_quotient_signed = first_output_arrival + int'(idx) -
          target_delta;
        if (target_quotient_signed < 0)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s edge target quotient negative at idx=%0d delta=%0d",
              ctx, idx, target_delta))
        target_quotient = target_quotient_signed;
        lookup_raw_for_quotient(target_quotient, 0, raw_value,
          $sformatf("%s edge symbol idx=%0d", ctx, idx));
        send_hit_beat(2, idx % 32, raw_value, raw_value, 1'b0,
          idx == 0, 1'b0, '0, 1'b1, idx[4:0]);
      end

      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      wait_for_beat_count(base_beats + hit_count, hit_count + 1024, ctx);
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024, ctx);
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 256,
        ctx);
      wait_for_debug_burst_count(base_debug_burst + hit_count,
        hit_count + 256, ctx);
      wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 256,
        ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int signed   target_delta;
        int unsigned target_quotient;
        bit          expected_error;

        target_delta    = dense_edge_target_delta(idx);
        target_quotient = first_output_arrival + int'(idx) - target_delta;
        expected_error  = !((target_delta > 0) && (target_delta < 16));
        expect_payload_math_at(base_history_size + idx, 2, idx % 32,
          idx[4:0], target_quotient, 0, 0,
          $sformatf("%s payload idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s trace idx=%0d", ctx, idx));
        expect_trace_delta_at(base_traces + idx, target_delta, target_delta,
          expected_error, $sformatf("%s trace delta idx=%0d", ctx, idx));
        expect_trace_expected_latency_at(base_traces + idx, 16,
          $sformatf("%s trace latency idx=%0d", ctx, idx));
      end
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, hit_count, hit_count, hit_count, ctx);
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_debug_streams_through_flushing_case(int unsigned running_hits,
                                                           int unsigned flushing_hits,
                                                           string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_inputs  = m_env.m_scb.hit0_history.size();
      base_beats   = m_env.m_scb.beat_count;
      base_history = m_env.m_scb.history.size();
      base_traces  = m_env.m_scb.trace_history.size();

      for (int unsigned idx = 0; idx < running_hits; idx++)
        send_stress_hit(idx, 1'b0, idx == 0, 1'b0, '0,
          $sformatf("%s running hit idx=%0d", ctx, idx));
      wait_for_input_count(base_inputs + running_hits, running_hits + 512,
        $sformatf("%s running inputs", ctx));
      wait_for_beat_count(base_beats + running_hits, running_hits + 1024,
        $sformatf("%s running beats", ctx));
      wait_for_trace_count(base_traces + running_hits, running_hits + 1024,
        $sformatf("%s running traces", ctx));
      expect_stress_stream_since(base_history, base_traces, running_hits,
        1'b0, 0, 1'b1, $sformatf("%s running payloads", ctx));
      wait_cycles(4);

      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history     = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_empty_eops  = m_env.m_scb.empty_eop_count;
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;

      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", ctx));
      for (int unsigned idx = 0; idx < flushing_hits; idx++) begin
        // The running SOP opens input channel 0; close that same packet before
        // later tail hits so the RTL can legally emit close markers.
        send_stress_hit(running_hits + idx, 1'b0, 1'b0,
          idx == 0, '0,
          $sformatf("%s flushing hit idx=%0d", ctx, idx));
      end
      send_endofrun_pulse();

      wait_for_input_count(base_inputs + flushing_hits, flushing_hits + 512,
        $sformatf("%s flushing inputs", ctx));
      wait_for_beat_count(base_beats + flushing_hits + 4,
        flushing_hits + 1024, $sformatf("%s flushing beats", ctx));
      wait_for_trace_count(base_traces + flushing_hits, flushing_hits + 1024,
        $sformatf("%s flushing traces", ctx));
      wait_for_empty_eop_count(base_empty_eops + 4, flushing_hits + 1024,
        $sformatf("%s flushing close markers", ctx));
      for (int unsigned idx = 0; idx < flushing_hits; idx++)
        expect_stress_payload_at(base_history + idx, base_traces + idx,
          running_hits + idx, 1'b0,
          $sformatf("%s flushing payload idx=%0d", ctx, idx));
      expect_close_markers_since(base_history, 4'b1111, flushing_hits,
        $sformatf("%s flushing close detail", ctx));
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, flushing_hits, 0, 0, ctx);
      wait_for_ctrl_ready_high(128, $sformatf("%s terminate ready restore",
        ctx));
      expect_total_count(running_hits + flushing_hits, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_debug_streams_clear_repeated_case(int unsigned iterations,
                                                         int unsigned hits_per_run,
                                                         string ctx);
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history;
        int unsigned base_traces;
        int unsigned base_debug_ts;
        int unsigned base_debug_burst;
        int unsigned base_ts_delta;

        run_start();
        base_inputs      = m_env.m_scb.hit0_history.size();
        base_beats       = m_env.m_scb.beat_count;
        base_history     = m_env.m_scb.history.size();
        base_traces      = m_env.m_scb.trace_history.size();
        base_debug_ts    = m_env.m_scb.debug_ts_count;
        base_debug_burst = m_env.m_scb.debug_burst_count;
        base_ts_delta    = m_env.m_scb.ts_delta_count;

        for (int unsigned beat = 0; beat < hits_per_run; beat++) begin
          int unsigned idx;

          idx = beat;
          send_stress_hit(idx, 1'b0, beat == 0, 1'b0, '0,
            $sformatf("%s iter=%0d", ctx, iter));
        end

        wait_for_input_count(base_inputs + hits_per_run, hits_per_run + 512,
          $sformatf("%s iter=%0d inputs", ctx, iter));
        wait_for_beat_count(base_beats + hits_per_run, hits_per_run + 1024,
          $sformatf("%s iter=%0d beats", ctx, iter));
        wait_for_trace_count(base_traces + hits_per_run, hits_per_run + 1024,
          $sformatf("%s iter=%0d traces", ctx, iter));
        wait_for_debug_ts_count(base_debug_ts + hits_per_run,
          hits_per_run + 256, $sformatf("%s iter=%0d debug_ts", ctx,
            iter));
        wait_for_debug_burst_count(base_debug_burst + hits_per_run,
          hits_per_run + 256, $sformatf("%s iter=%0d debug_burst", ctx,
            iter));
        wait_for_ts_delta_count(base_ts_delta + hits_per_run,
          hits_per_run + 256, $sformatf("%s iter=%0d ts_delta", ctx,
            iter));
        expect_stress_stream_since(base_history, base_traces, hits_per_run,
          1'b0, 0, 1'b1, $sformatf("%s iter=%0d payloads", ctx, iter));
        expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
          base_ts_delta, hits_per_run, hits_per_run, hits_per_run,
          $sformatf("%s iter=%0d debug counts", ctx, iter));
        expect_total_count(hits_per_run,
          $sformatf("%s iter=%0d total", ctx, iter));

        send_ctrl(CTRL_IDLE, $sformatf("IDLE_debug_clear_%0d", iter));
        wait_cycles(4);
        expect_debug_valids_low($sformatf("%s iter=%0d idle clear", ctx,
          iter));
        base_debug_ts    = m_env.m_scb.debug_ts_count;
        base_debug_burst = m_env.m_scb.debug_burst_count;
        base_ts_delta    = m_env.m_scb.ts_delta_count;
        wait_cycles(16);
        expect_debug_valids_low($sformatf("%s iter=%0d idle hold", ctx,
          iter));
        expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
          base_ts_delta, 0, 0, 0,
          $sformatf("%s iter=%0d no idle debug drift", ctx, iter));
      end
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic start_run_control_cycle(bit direct_running,
                                           int unsigned iter,
                                           string ctx);
      if (direct_running) begin
        send_ctrl(CTRL_RUNNING, $sformatf("DIRECT_RUNNING_%0d", iter));
        wait_for_running_status(64,
          $sformatf("%s direct-running iter=%0d", ctx, iter));
        wait_for_hit0_ready(1'b1, 16,
          $sformatf("%s direct-running ready iter=%0d", ctx, iter));
        wait_cycles(1);
      end else begin
        run_start();
      end
    endtask

    task automatic stop_run_with_endofrun(int unsigned base_history,
                                          int unsigned base_empty_eops,
                                          int unsigned expected_payloads,
                                          string ctx);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, 256,
        $sformatf("%s close markers", ctx));
      wait_for_ctrl_ready_high(256, $sformatf("%s terminate ready restore",
        ctx));
      expect_close_markers_since(base_history, 4'b1111, expected_payloads,
        $sformatf("%s close marker detail", ctx));
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      expect_hit0_ready(1'b0, $sformatf("%s post-IDLE hit ready", ctx));
    endtask

    task automatic run_empty_standard_runs_case(int unsigned iterations,
                                                string ctx);
      int unsigned base_beats;
      int unsigned base_empty_eops;
      int unsigned base_csr_count;

      wait_for_reset_release();
      base_beats      = m_env.m_scb.beat_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_csr_count  = m_env.m_scb.csr_access_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_empty_eops;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        stop_run_with_endofrun(iter_history, iter_empty_eops, 0,
          $sformatf("%s iter=%0d", ctx, iter));
        expect_total_count(48'd0, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      if (m_env.m_scb.beat_count != base_beats + (4 * iterations))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected exactly %0d empty close markers and no payload beats, got beats=%0d from base=%0d",
            ctx, 4 * iterations, m_env.m_scb.beat_count - base_beats,
            base_beats))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (4 * iterations))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected empty_eops=%0d got %0d from base %0d",
            ctx, 4 * iterations, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      if (m_env.m_scb.csr_access_count <= base_csr_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected CSR monitor activity during repeated control cycles",
            ctx))
    endtask

    task automatic send_run_control_payload(int unsigned stimulus_idx,
                                            int unsigned route_lane,
                                            bit sop_value,
                                            bit eop_value,
                                            int unsigned base_history,
                                            int unsigned base_traces,
                                            int unsigned local_idx,
                                            string ctx);
      int unsigned raw_value;

      lookup_raw_for_quotient(route_lane * 16, 0, raw_value,
        $sformatf("%s route-lane symbol", ctx));
      send_hit_beat(2, route_lane, raw_value, raw_value, 1'b0, sop_value,
        eop_value, '0, 1'b1, stimulus_idx[4:0]);
      wait_for_beat_count(base_history + local_idx + 1, 256,
        $sformatf("%s output beat local_idx=%0d", ctx, local_idx));
      wait_for_trace_count(base_traces + local_idx + 1, 256,
        $sformatf("%s trace local_idx=%0d", ctx, local_idx));
      expect_payload_math_at(base_history + local_idx, 2, route_lane,
        stimulus_idx[4:0], route_lane * 16, 0, 0,
        $sformatf("%s payload local_idx=%0d", ctx, local_idx));
      expect_output_flags_at(base_history + local_idx, sop_value, 1'b0,
        1'b0, route_lane,
        $sformatf("%s flags local_idx=%0d", ctx, local_idx));
      expect_trace_pair_at(base_traces + local_idx,
        $sformatf("%s normal/debug pair local_idx=%0d", ctx, local_idx));
      expect_trace_math_self_consistent_at(base_traces + local_idx,
        $sformatf("%s trace math local_idx=%0d", ctx, local_idx));
    endtask

    task automatic run_single_packet_runs_case(int unsigned iterations,
                                               string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s iter=%0d single packet", ctx, iter));
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s iter=%0d", ctx, iter));
        expect_total_count(48'd1, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new beats, got %0d from base %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats,
            base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d from base %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces,
            base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d empty close markers, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(48'd1, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_multi_channel_runs_case(int unsigned iterations,
                                               string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        for (int unsigned lane = 0; lane < 4; lane++)
          send_run_control_payload((iter * 4) + lane, lane, 1'b1, 1'b1,
            iter_history, iter_traces, lane,
            $sformatf("%s iter=%0d lane=%0d", ctx, iter, lane));
        stop_run_with_endofrun(iter_history, iter_empty_eops, 4,
          $sformatf("%s iter=%0d", ctx, iter));
        expect_total_count(48'd4, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + (iterations * 4), iterations * 4 + 512,
        ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 8))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d new beats, got %0d from base %0d",
            ctx, iterations * 8, m_env.m_scb.beat_count - base_beats,
            base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.trace_history.size() - base_traces,
            base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(48'd4, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_ready_low_stop_cycles_case(int unsigned iterations,
                                                  string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      set_hit1_ready(1'b0);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s ready-low iter=%0d", ctx, iter));
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s ready-low iter=%0d", ctx, iter));
        expect_total_count(48'd1, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      set_hit1_ready(1'b1);
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ready-low expected %0d new beats, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ready-low expected %0d traces, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s ready-low expected %0d close markers, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(48'd1, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_running_abort_cycles_case(int unsigned iterations,
                                                 string ctx);
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        start_run_control_cycle(1'b1, iter, ctx);
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_ABORT_%0d", iter));
        wait_cycles(2);
        expect_hit0_ready(1'b0, $sformatf("%s abort iter=%0d ready", ctx,
          iter));
        expect_csr_mask(3'd0, 32'h0000_0000, 32'h0000_0001,
          $sformatf("%s abort iter=%0d csr", ctx, iter));
        if (m_env.m_scb.empty_eop_count != base_empty_eops)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s abort iter=%0d unexpectedly entered close-marker FLUSHING",
              ctx, iter))
      end
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 16, ctx);
      expect_total_count(48'd0, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_alternate_start_styles_case(int unsigned iterations,
                                                   string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      bit [47:0]   final_total;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      final_total      = 48'd0;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;
        bit [47:0]   expected_total;

        start_run_control_cycle(iter[0], iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s mixed-start iter=%0d", ctx, iter));
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s mixed-start iter=%0d", ctx, iter));
        expected_total = iter[0] ? 48'd2 : 48'd1;
        expect_total_count(expected_total, $sformatf("%s iter=%0d total",
          ctx, iter));
        final_total = expected_total;
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d beats across mixed starts, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d traces across mixed starts, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers across mixed starts, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(final_total, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic rewrite_csr_pattern(int unsigned iter,
                                       bit bypass_lapse,
                                       bit derive_tot,
                                       bit delay_ts_field_use_t,
                                       int unsigned expected_latency,
                                       string ctx);
      bit [31:0] mode_word;

      mode_word = datapath_mode_word(bypass_lapse, derive_tot,
        delay_ts_field_use_t);
      csr_write(3'd2, expected_latency);
      csr_write(3'd0, mode_word);
      wait_cycles(2);
      expect_csr_mask(3'd2, expected_latency, 32'hffff_ffff,
        $sformatf("%s latency iter=%0d", ctx, iter));
      expect_csr_mask(3'd0, mode_word & 32'h6000_0018, 32'h6000_0018,
        $sformatf("%s mode iter=%0d", ctx, iter));
    endtask

    task automatic run_idle_csr_rewrite_case(int unsigned iterations,
                                             string ctx);
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      int unsigned base_csr_count;

      wait_for_reset_release();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_csr_count  = m_env.m_scb.csr_access_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        rewrite_csr_pattern(iter, iter[0], iter[1], !iter[0],
          32 + iter, $sformatf("%s idle rewrite", ctx));
        start_run_control_cycle(1'b0, iter, ctx);
        expect_csr_mask(3'd2, 32 + iter, 32'hffff_ffff,
          $sformatf("%s running latency iter=%0d", ctx, iter));
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_after_idle_rewrite_%0d", iter));
        wait_cycles(2);
        expect_hit0_ready(1'b0, $sformatf("%s post-run idle iter=%0d", ctx,
          iter));
      end
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 16, ctx);
      expect_total_count(48'd0, ctx);
      expect_discard_count(32'd0, ctx);
      if (m_env.m_scb.csr_access_count < base_csr_count + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected CSR analysis-port activity for %0d rewrites",
            ctx, iterations))
    endtask

    task automatic run_prepare_csr_rewrite_case(int unsigned iterations,
                                                string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      bit [31:0]   mode_word;

      wait_for_reset_release();
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;

        send_ctrl(CTRL_RUN_PREPARE, $sformatf("RUN_PREPARE_REWRITE_%0d",
          iter));
        mode_word = datapath_mode_word(iter[0], iter[1], !iter[0]);
        csr_write(3'd2, 64 + iter);
        csr_write(3'd0, mode_word);
        send_ctrl(CTRL_SYNC, $sformatf("SYNC_REWRITE_%0d", iter));
        send_ctrl(CTRL_RUNNING, $sformatf("RUNNING_REWRITE_%0d", iter));
        wait_for_running_status(64,
          $sformatf("%s prepare rewrite running iter=%0d", ctx, iter));
        wait_for_hit0_ready(1'b1, 16,
          $sformatf("%s prepare rewrite ready iter=%0d", ctx, iter));
        wait_cycles(1);
        expect_csr_mask(3'd2, 64 + iter, 32'hffff_ffff,
          $sformatf("%s prepare rewrite latency iter=%0d", ctx, iter));
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s prepare rewrite hit iter=%0d", ctx,
          iter));
        expect_trace_expected_latency_at(iter_traces, 64 + iter,
          $sformatf("%s prepare rewrite trace latency iter=%0d", ctx, iter));
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s prepare rewrite iter=%0d", ctx, iter));
        expect_total_count(48'd1, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d beats after prepare rewrites, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d traces after prepare rewrites, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers after prepare rewrites, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(48'd1, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_flushing_csr_rewrite_case(int unsigned iterations,
                                                 string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;
        bit [31:0]   latency_value;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s pre-flush hit iter=%0d", ctx, iter));
        pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
        wait_for_ctrl_ready_low(4,
          $sformatf("%s flushing rewrite ready low iter=%0d", ctx, iter));
        latency_value = 128 + iter;
        csr_write(3'd2, latency_value);
        csr_read(3'd2, latency_value);
        if (latency_value !== 128 + iter)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s flushing rewrite iter=%0d latency readback got %0d",
              ctx, iter, latency_value))
        send_endofrun_pulse();
        wait_for_empty_eop_count(iter_empty_eops + 4, 256,
          $sformatf("%s flushing rewrite close markers iter=%0d", ctx, iter));
        wait_for_ctrl_ready_high(256,
          $sformatf("%s flushing rewrite ready restore iter=%0d", ctx, iter));
        expect_close_markers_since(iter_history, 4'b1111, 1,
          $sformatf("%s flushing rewrite close detail iter=%0d", ctx, iter));
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_flushing_rewrite_%0d", iter));
        expect_total_count(48'd1, $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d beats after flushing rewrites, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d traces after flushing rewrites, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers after flushing rewrites, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(48'd1, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_illegal_ctrl_chatter_case(int unsigned iterations,
                                                 string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      bit [47:0]   final_total;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      final_total      = 48'd0;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;
        bit [47:0]   expected_total;

        pulse_ctrl(CTRL_RUNNING | CTRL_TERMINATING,
          $sformatf("ILLEGAL_PRE_%0d", iter));
        wait_cycles(1);
        start_run_control_cycle(iter[0], iter, ctx);
        pulse_ctrl(CTRL_RUN_PREPARE | CTRL_SYNC,
          $sformatf("ILLEGAL_ACTIVE_%0d", iter));
        wait_cycles(1);
        expect_csr_mask(3'd0, 32'h0000_0001, 32'h0000_0001,
          $sformatf("%s illegal active containment iter=%0d", ctx, iter));
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(iter, iter % 4, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s illegal chatter hit iter=%0d", ctx,
          iter));
        pulse_ctrl(CTRL_RUNNING | CTRL_IDLE,
          $sformatf("ILLEGAL_PRE_TERMINATE_%0d", iter));
        wait_cycles(1);
        stop_run_with_endofrun(iter_history, iter_empty_eops, 1,
          $sformatf("%s illegal chatter iter=%0d", ctx, iter));
        expected_total = iter[0] ? 48'd2 : 48'd1;
        expect_total_count(expected_total, $sformatf("%s iter=%0d total",
          ctx, iter));
        final_total = expected_total;
        expect_discard_count(32'd0, $sformatf("%s iter=%0d discard", ctx,
          iter));
      end
      wait_for_input_count(base_inputs + iterations, iterations + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + (iterations * 5))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d beats after illegal chatter, got %0d",
            ctx, iterations * 5, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d traces after illegal chatter, got %0d",
            ctx, iterations, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d close markers after illegal chatter, got %0d from base %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count,
            base_empty_eops))
      expect_total_count(final_total, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic close_active_termination(int unsigned base_history,
                                            int unsigned base_empty_eops,
                                            int unsigned expected_payloads,
                                            int unsigned max_cycles,
                                            string ctx);
      send_endofrun_pulse();
      wait_for_empty_eop_count(base_empty_eops + 4, max_cycles,
        $sformatf("%s close markers", ctx));
      expect_close_markers_since(base_history, 4'b1111, expected_payloads,
        $sformatf("%s close marker detail", ctx));
      wait_for_ctrl_ready_high(max_cycles,
        $sformatf("%s terminate ready restore", ctx));
    endtask

    task automatic finish_termination_after_payloads(int unsigned base_history,
                                                     int unsigned base_empty_eops,
                                                     int unsigned expected_payloads,
                                                     string ctx);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      close_active_termination(base_history, base_empty_eops,
        expected_payloads, expected_payloads + 1024, ctx);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      expect_hit0_ready(1'b0, $sformatf("%s post-IDLE ready", ctx));
    endtask

    task automatic run_terminate_after_burst_case(int unsigned hit_count,
                                                  bit final_input_eop,
                                                  string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_run_control_payload(idx, idx % 4, idx < 4,
          final_input_eop && idx == hit_count - 1, base_history, base_traces,
          idx, $sformatf("%s pre-terminate idx=%0d", ctx, idx));
      finish_termination_after_payloads(base_history, base_empty_eops,
        hit_count, ctx);
      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + hit_count + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payload/marker beats, got %0d",
            ctx, hit_count + 4, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d",
            ctx, hit_count, m_env.m_scb.trace_history.size() - base_traces))
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_late_flushing_payload_case(int unsigned hit_count,
                                                  bit eop_every_hit,
                                                  bit ready_low,
                                                  string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      wait_for_hit0_ready(1'b1, 16, $sformatf("%s flushing hit ready", ctx));
      if (ready_low)
        set_hit1_ready(1'b0);
      base_history    = m_env.m_scb.history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_run_control_payload(idx, idx % 4, idx < 4,
          eop_every_hit || idx == hit_count - 1, base_history, base_traces,
          idx, $sformatf("%s flushing idx=%0d", ctx, idx));
      if (ready_low && hit1_drv_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected sink ready held low during termination",
            ctx))
      close_active_termination(base_history, base_empty_eops, hit_count,
        hit_count + 1024, ctx);
      if (ready_low)
        set_hit1_ready(1'b1);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + hit_count + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payload/marker beats, got %0d",
            ctx, hit_count + 4, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d",
            ctx, hit_count, m_env.m_scb.trace_history.size() - base_traces))
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_terminate_without_eop_idle_case(string ctx);
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;
      int unsigned base_history;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 16,
        $sformatf("%s no boundary before upstream endofrun", ctx));
      close_active_termination(base_history, base_empty_eops, 0, 512, ctx);
      if (m_env.m_scb.trace_history.size() != base_traces)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected no debug traces without payloads", ctx))
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      expect_hit0_ready(1'b0, $sformatf("%s post-IDLE ready", ctx));
      expect_total_count(48'd0, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_terminate_per_channel_case(string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      for (int unsigned lane = 0; lane < 4; lane++) begin
        int unsigned iter_history;
        int unsigned iter_traces;
        int unsigned iter_empty_eops;

        run_start();
        iter_history    = m_env.m_scb.history.size();
        iter_traces     = m_env.m_scb.trace_history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        send_run_control_payload(lane, lane, 1'b1, 1'b1, iter_history,
          iter_traces, 0, $sformatf("%s lane=%0d", ctx, lane));
        finish_termination_after_payloads(iter_history, iter_empty_eops, 1,
          $sformatf("%s lane=%0d", ctx, lane));
        expect_total_count(48'd1, $sformatf("%s lane=%0d total", ctx, lane));
        expect_discard_count(32'd0,
          $sformatf("%s lane=%0d discard", ctx, lane));
      end
      wait_for_input_count(base_inputs + 4, 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + 20)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected 20 payload/marker beats, got %0d",
            ctx, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected four normal/debug traces, got %0d",
            ctx, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + 16)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected 16 close markers, got %0d",
            ctx, m_env.m_scb.empty_eop_count - base_empty_eops))
    endtask

    task automatic run_terminate_near_overflow_case(string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b0, 1'b0, 1'b1);
      run_start();
      wait_for_overflow_lookback_at_count(1, 9000,
        $sformatf("%s first overflow lookback", ctx));
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      send_overflow_hit_and_expect(1, 4553, 2, 4553, 2, 1'b0, 1'b0,
        1'b0, 2, 2, 11, 1'b1, 1'b0, 1'b0,
        $sformatf("%s corrected pre-terminate hit", ctx), 1'b1);
      finish_termination_after_payloads(base_history, base_empty_eops, 1,
        ctx);
      wait_for_input_count(base_inputs + 1, 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + 5)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected one overflow payload plus four markers, got %0d",
            ctx, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + 1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected one normal/debug trace, got %0d",
            ctx, m_env.m_scb.trace_history.size() - base_traces))
      expect_total_count(48'd1, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    task automatic run_terminate_with_csr_polling_case(int unsigned hit_count,
                                                       int unsigned poll_count,
                                                       string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_csr_count;
      bit [47:0]   total_count;
      bit [47:0]   expected_total;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_start();
      base_inputs     = m_env.m_scb.hit0_history.size();
      base_beats      = m_env.m_scb.beat_count;
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      base_csr_count  = m_env.m_scb.csr_access_count;
      expected_total   = hit_count;
      for (int unsigned idx = 0; idx < hit_count; idx++)
        send_run_control_payload(idx, idx % 4, idx < 4, idx == hit_count - 1,
          base_history, base_traces, idx,
          $sformatf("%s loaded run idx=%0d", ctx, idx));
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      for (int unsigned poll = 0; poll < poll_count; poll++) begin
        read_total_count_coherent(total_count,
          $sformatf("%s total poll=%0d", ctx, poll));
        if (total_count != expected_total)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s expected total_count=%0d during terminate poll=%0d got %0d",
              ctx, hit_count, poll, total_count))
        csr_read(3'd0, csr_word);
        csr_read(3'd2, csr_word);
      end
      close_active_termination(base_history, base_empty_eops, hit_count,
        hit_count + 1024, ctx);
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_for_input_count(base_inputs + hit_count, hit_count + 512, ctx);
      if (m_env.m_scb.beat_count != base_beats + hit_count + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d payload/marker beats, got %0d",
            ctx, hit_count + 4, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.trace_history.size() != base_traces + hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d normal/debug traces, got %0d",
            ctx, hit_count, m_env.m_scb.trace_history.size() - base_traces))
      if (m_env.m_scb.csr_access_count < base_csr_count + (poll_count * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected CSR polling analysis activity during terminate",
            ctx))
      expect_total_count(hit_count, ctx);
      expect_discard_count(32'd0, ctx);
    endtask

    function automatic int unsigned cycles_between_times(input time start_time_ps,
                                                         input time stop_time_ps);
      time delta_ps;

      if (stop_time_ps <= start_time_ps)
        return 0;
      delta_ps = stop_time_ps - start_time_ps;
      return int'(delta_ps / CLK_PERIOD_PS);
    endfunction

    task automatic send_metric_payload_nowait(int unsigned stimulus_idx,
                                              int unsigned lane_count,
                                              bit eop_value,
                                              string ctx);
      int unsigned route_lane;
      int unsigned raw_value;

      if (lane_count == 0 || lane_count > 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s illegal lane_count=%0d", ctx, lane_count))
      route_lane = stimulus_idx % lane_count;
      lookup_raw_for_quotient(route_lane * 16, 0, raw_value,
        $sformatf("%s route-lane symbol idx=%0d", ctx, stimulus_idx));
      send_hit_beat(2, route_lane, raw_value, raw_value, 1'b0,
        stimulus_idx < lane_count, eop_value, '0, 1'b1,
        stimulus_idx[4:0]);
    endtask

    task automatic expect_metric_payloads_since(int unsigned base_history,
                                                int unsigned base_traces,
                                                int unsigned hit_count,
                                                int unsigned lane_count,
                                                string ctx);
      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned route_lane;

        route_lane = idx % lane_count;
        expect_payload_math_at(base_history + idx, 2, route_lane,
          idx[4:0], route_lane * 16, 0, 0,
          $sformatf("%s metric payload idx=%0d", ctx, idx));
        expect_output_flags_at(base_history + idx, idx < lane_count, 1'b0,
          1'b0, route_lane,
          $sformatf("%s metric flags idx=%0d", ctx, idx));
        expect_trace_pair_at(base_traces + idx,
          $sformatf("%s metric trace idx=%0d", ctx, idx));
        expect_trace_math_self_consistent_at(base_traces + idx,
          $sformatf("%s metric trace math idx=%0d", ctx, idx));
      end
    endtask

    task automatic update_metric_stats(int unsigned value,
                                       inout int unsigned min_value,
                                       inout int unsigned max_value,
                                       inout int unsigned sum_value);
      if (value < min_value)
        min_value = value;
      if (value > max_value)
        max_value = value;
      sum_value += value;
    endtask

    task automatic run_ready_occupancy_histogram_case(int unsigned iterations,
                                                      string ctx);
      int unsigned min_low_cycles;
      int unsigned max_low_cycles;
      int unsigned sum_low_cycles;
      int unsigned base_beats;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      min_low_cycles = '1;
      max_low_cycles = 0;
      sum_low_cycles = 0;
      base_beats      = m_env.m_scb.beat_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned iter_history;
        int unsigned iter_empty_eops;
        int unsigned low_cycles;
        int unsigned gap_cycles;
        int unsigned guard_cycles;

        start_run_control_cycle(1'b0, iter, ctx);
        iter_history    = m_env.m_scb.history.size();
        iter_empty_eops = m_env.m_scb.empty_eop_count;
        gap_cycles      = iter % 4;
        pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
        wait_for_ctrl_ready_low(4,
          $sformatf("%s ready occupancy low iter=%0d", ctx, iter));
        low_cycles = 1;
        repeat (gap_cycles) begin
          @(posedge ctrl_vif.clk);
          if (ctrl_vif.ready !== 1'b0)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s terminate ready restored before endofrun iter=%0d",
                ctx, iter))
          low_cycles++;
        end
        send_endofrun_pulse();
        guard_cycles = 0;
        while (ctrl_vif.ready !== 1'b1 && guard_cycles < 256) begin
          @(posedge ctrl_vif.clk);
          guard_cycles++;
          if (ctrl_vif.ready === 1'b0)
            low_cycles++;
          else if (ctrl_vif.ready !== 1'b1)
            `uvm_fatal("MTSP_CASE",
              $sformatf("%s ctrl ready became X during occupancy iter=%0d",
                ctx, iter))
        end
        if (ctrl_vif.ready !== 1'b1)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s timed out restoring ctrl ready iter=%0d", ctx,
              iter))
        wait_for_empty_eop_count(iter_empty_eops + 4, 256,
          $sformatf("%s close markers iter=%0d", ctx, iter));
        expect_close_markers_since(iter_history, 4'b1111, 0,
          $sformatf("%s close marker detail iter=%0d", ctx, iter));
        update_metric_stats(low_cycles, min_low_cycles, max_low_cycles,
          sum_low_cycles);
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_occupancy_%0d", iter));
        wait_cycles(2);
      end

      if (min_low_cycles == 0 || max_low_cycles > 256)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s invalid ready-low occupancy min=%0d max=%0d",
            ctx, min_low_cycles, max_low_cycles))
      if (m_env.m_scb.beat_count != base_beats + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected only %0d close-marker beats, got %0d",
            ctx, iterations * 4, m_env.m_scb.beat_count - base_beats))
      if (m_env.m_scb.empty_eop_count != base_empty_eops + (iterations * 4))
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected %0d empty eops, got %0d",
            ctx, iterations * 4, m_env.m_scb.empty_eop_count -
            base_empty_eops))
      `uvm_info("MTSP_READY_METRIC",
        $sformatf("%s ready_low_cycles samples=%0d min=%0d max=%0d avg_x100=%0d",
          ctx, iterations, min_low_cycles, max_low_cycles,
          (sum_low_cycles * 100) / iterations),
        UVM_LOW)
    endtask

    task automatic run_drain_latency_metric_sample(int unsigned hit_count,
                                                   int unsigned lane_count,
                                                   bit final_input_eop,
                                                   int unsigned sample_idx,
                                                   output int unsigned latency_cycles,
                                                   output int unsigned beat_delta,
                                                   output int unsigned debug_burst_delta,
                                                   input bit log_sample,
                                                   input string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_empty_eops;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned base_dual_pairs;
      int unsigned debug_ts_delta;
      int unsigned ts_delta_delta;
      int unsigned dual_pair_delta;
      time         terminate_accept_time;

      start_run_control_cycle(1'b0, sample_idx, ctx);
      base_inputs      = m_env.m_scb.hit0_history.size();
      base_beats       = m_env.m_scb.beat_count;
      base_history     = m_env.m_scb.history.size();
      base_traces      = m_env.m_scb.trace_history.size();
      base_empty_eops  = m_env.m_scb.empty_eop_count;
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      base_dual_pairs  = m_env.m_scb.dual_path_pair_count;

      for (int unsigned idx = 0; idx < hit_count; idx++) begin
        int unsigned first_eop_idx;

        first_eop_idx = (hit_count > lane_count) ? hit_count - lane_count : 0;
        send_metric_payload_nowait(idx, lane_count,
          final_input_eop && idx >= first_eop_idx,
          $sformatf("%s sample=%0d", ctx, sample_idx));
      end

      send_ctrl_and_capture(CTRL_TERMINATING, "TERMINATING",
        terminate_accept_time);
      wait_for_ctrl_ready_low(4,
        $sformatf("%s sample=%0d terminate ready low", ctx, sample_idx));
      send_endofrun_pulse();
      wait_for_input_count(base_inputs + hit_count, hit_count + 512,
        $sformatf("%s sample=%0d inputs", ctx, sample_idx));
      wait_for_beat_count(base_beats + hit_count + 4, hit_count + 1024,
        $sformatf("%s sample=%0d beats", ctx, sample_idx));
      wait_for_trace_count(base_traces + hit_count, hit_count + 1024,
        $sformatf("%s sample=%0d traces", ctx, sample_idx));
      wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 1024,
        $sformatf("%s sample=%0d debug_ts", ctx, sample_idx));
      wait_for_empty_eop_count(base_empty_eops + 4, hit_count + 1024,
        $sformatf("%s sample=%0d close markers", ctx, sample_idx));
      expect_metric_payloads_since(base_history, base_traces, hit_count,
        lane_count, $sformatf("%s sample=%0d", ctx, sample_idx));
      expect_close_markers_since(base_history, 4'b1111, hit_count,
        $sformatf("%s sample=%0d close detail", ctx, sample_idx));
      wait_for_ctrl_ready_high(hit_count + 1024,
        $sformatf("%s sample=%0d ready restore", ctx, sample_idx));

      beat_delta        = m_env.m_scb.beat_count - base_beats;
      latency_cycles    = cycles_between_times(terminate_accept_time,
        m_env.m_scb.last_eop_time_ps);
      debug_ts_delta    = m_env.m_scb.debug_ts_count - base_debug_ts;
      debug_burst_delta = m_env.m_scb.debug_burst_count - base_debug_burst;
      ts_delta_delta    = m_env.m_scb.ts_delta_count - base_ts_delta;
      dual_pair_delta   = m_env.m_scb.dual_path_pair_count -
        base_dual_pairs;

      if (beat_delta != hit_count + 4)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s sample=%0d expected beat_delta=%0d got %0d",
            ctx, sample_idx, hit_count + 4, beat_delta))
      if (debug_ts_delta != hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s sample=%0d expected debug_ts per payload=%0d got %0d",
            ctx, sample_idx, hit_count, debug_ts_delta))
      if (dual_pair_delta != hit_count)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s sample=%0d expected dual-path pairs=%0d got %0d",
            ctx, sample_idx, hit_count, dual_pair_delta))
      if (debug_burst_delta > hit_count || ts_delta_delta != debug_burst_delta)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s sample=%0d illegal debug_burst/ts_delta delta burst=%0d ts_delta=%0d hit_count=%0d",
            ctx, sample_idx, debug_burst_delta, ts_delta_delta, hit_count))
      if (latency_cycles == 0 || latency_cycles > hit_count + 512)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s sample=%0d invalid drain latency cycles=%0d hit_count=%0d",
            ctx, sample_idx, latency_cycles, hit_count))
      if (log_sample)
        `uvm_info("MTSP_DRAIN_METRIC",
          $sformatf("%s sample=%0d hits=%0d lanes=%0d latency_cycles=%0d beat_delta=%0d debug_burst_delta=%0d",
            ctx, sample_idx, hit_count, lane_count, latency_cycles,
            beat_delta, debug_burst_delta),
          UVM_LOW)

      send_ctrl(CTRL_IDLE, $sformatf("IDLE_drain_%0d", sample_idx));
      wait_cycles(2);
      expect_hit0_ready(1'b0,
        $sformatf("%s sample=%0d post-IDLE ready", ctx, sample_idx));
      expect_total_count(hit_count,
        $sformatf("%s sample=%0d total", ctx, sample_idx));
      expect_discard_count(32'd0,
        $sformatf("%s sample=%0d discard", ctx, sample_idx));
    endtask

    task automatic run_drain_latency_histogram_case(int unsigned iterations,
                                                    int unsigned max_payloads,
                                                    int unsigned lane_count,
                                                    string ctx);
      int unsigned min_latency;
      int unsigned max_latency;
      int unsigned sum_latency;
      int unsigned samples_with_running_debug;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      min_latency               = '1;
      max_latency               = 0;
      sum_latency               = 0;
      samples_with_running_debug = 0;

      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned hit_count;
        int unsigned latency_cycles;
        int unsigned beat_delta;
        int unsigned debug_burst_delta;

        hit_count = iter % (max_payloads + 1);
        run_drain_latency_metric_sample(hit_count, lane_count,
          hit_count != 0, iter,
          latency_cycles, beat_delta, debug_burst_delta, iter < 8, ctx);
        update_metric_stats(latency_cycles, min_latency, max_latency,
          sum_latency);
        if (debug_burst_delta != 0)
          samples_with_running_debug++;
      end

      if (min_latency == 0 || max_latency > max_payloads + 512)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s invalid drain latency histogram min=%0d max=%0d",
            ctx, min_latency, max_latency))
      `uvm_info("MTSP_DRAIN_METRIC",
        $sformatf("%s histogram samples=%0d lanes=%0d min=%0d max=%0d avg_x100=%0d running_debug_samples=%0d",
          ctx, iterations, lane_count, min_latency, max_latency,
          (sum_latency * 100) / iterations, samples_with_running_debug),
        UVM_LOW)
    endtask

    task automatic run_enabled_window_drain_metric_case(string ctx);
      for (int unsigned lanes = 1; lanes <= 4; lanes++) begin
        int unsigned latency_cycles;
        int unsigned beat_delta;
        int unsigned debug_burst_delta;

        if (lanes == 3)
          continue;
        run_drain_latency_metric_sample(lanes, lanes, 1'b1, lanes,
          latency_cycles, beat_delta, debug_burst_delta, 1'b1,
          $sformatf("%s enabled-window lanes=%0d", ctx, lanes));
      end
    endtask

    task automatic run_boundary_forwarding_rate_case(int unsigned iterations,
                                                     string ctx);
      int unsigned forwarded_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      forwarded_count = 0;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned latency_cycles;
        int unsigned beat_delta;
        int unsigned debug_burst_delta;

        run_drain_latency_metric_sample(1, 1, 1'b1, iter, latency_cycles,
          beat_delta, debug_burst_delta, 1'b0, ctx);
        if (beat_delta == 5)
          forwarded_count++;
      end
      if (forwarded_count != iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected boundary forwarding success=%0d got %0d",
            ctx, iterations, forwarded_count))
      `uvm_info("MTSP_BOUNDARY_METRIC",
        $sformatf("%s forwarding_rate_x10000=%0d samples=%0d",
          ctx, (forwarded_count * 10000) / iterations, iterations),
        UVM_LOW)
    endtask

    task automatic run_synthetic_boundary_no_real_eop_case(int unsigned iterations,
                                                           string ctx);
      int unsigned synthetic_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      synthetic_count = 0;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned latency_cycles;
        int unsigned beat_delta;
        int unsigned debug_burst_delta;

        run_drain_latency_metric_sample(0, 1, 1'b0, iter, latency_cycles,
          beat_delta, debug_burst_delta, iter < 4, ctx);
        if (beat_delta == 4)
          synthetic_count++;
      end
      if (synthetic_count != iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected synthetic boundary count=%0d got %0d",
            ctx, iterations, synthetic_count))
      `uvm_info("MTSP_BOUNDARY_METRIC",
        $sformatf("%s missing_boundary_rate_x10000=0 samples=%0d",
          ctx, iterations),
        UVM_LOW)
    endtask

    task automatic run_extra_boundary_rate_case(int unsigned iterations,
                                                string ctx);
      int unsigned exact_count;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      exact_count = 0;
      for (int unsigned iter = 0; iter < iterations; iter++) begin
        int unsigned base_inputs;
        int unsigned base_beats;
        int unsigned base_history;
        int unsigned base_traces;
        int unsigned base_empty_eops;
        int unsigned base_debug_ts;
        int unsigned base_debug_burst;
        int unsigned base_ts_delta;
        int unsigned base_dual_pairs;

        start_run_control_cycle(1'b0, iter, ctx);
        pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
        wait_for_ctrl_ready_low(4,
          $sformatf("%s terminate ready low iter=%0d", ctx, iter));
        wait_for_hit0_ready(1'b1, 16,
          $sformatf("%s flushing hit ready iter=%0d", ctx, iter));
        base_inputs      = m_env.m_scb.hit0_history.size();
        base_beats       = m_env.m_scb.beat_count;
        base_history     = m_env.m_scb.history.size();
        base_traces      = m_env.m_scb.trace_history.size();
        base_empty_eops  = m_env.m_scb.empty_eop_count;
        base_debug_ts    = m_env.m_scb.debug_ts_count;
        base_debug_burst = m_env.m_scb.debug_burst_count;
        base_ts_delta    = m_env.m_scb.ts_delta_count;
        base_dual_pairs  = m_env.m_scb.dual_path_pair_count;

        send_metric_payload_nowait(0, 2, 1'b1,
          $sformatf("%s iter=%0d late eop0", ctx, iter));
        send_metric_payload_nowait(1, 2, 1'b1,
          $sformatf("%s iter=%0d late eop1", ctx, iter));
        send_endofrun_pulse();
        wait_for_input_count(base_inputs + 2, 514,
          $sformatf("%s iter=%0d late inputs", ctx, iter));
        wait_for_beat_count(base_beats + 6, 1024,
          $sformatf("%s iter=%0d late beats", ctx, iter));
        wait_for_trace_count(base_traces + 2, 1024,
          $sformatf("%s iter=%0d late traces", ctx, iter));
        wait_for_debug_ts_count(base_debug_ts + 2, 1024,
          $sformatf("%s iter=%0d late debug_ts", ctx, iter));
        wait_for_empty_eop_count(base_empty_eops + 4, 1024,
          $sformatf("%s iter=%0d close markers", ctx, iter));
        expect_metric_payloads_since(base_history, base_traces, 2, 2,
          $sformatf("%s iter=%0d late payloads", ctx, iter));
        expect_close_markers_since(base_history, 4'b1111, 2,
          $sformatf("%s iter=%0d one boundary", ctx, iter));
        wait_for_ctrl_ready_high(1024,
          $sformatf("%s iter=%0d ready restore", ctx, iter));
        wait_cycles(16);
        if (m_env.m_scb.empty_eop_count != base_empty_eops + 4)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s iter=%0d expected exactly four close markers got %0d",
              ctx, iter, m_env.m_scb.empty_eop_count - base_empty_eops))
        if (m_env.m_scb.debug_ts_count - base_debug_ts != 2 ||
            m_env.m_scb.debug_burst_count != base_debug_burst ||
            m_env.m_scb.ts_delta_count != base_ts_delta ||
            m_env.m_scb.dual_path_pair_count - base_dual_pairs != 2)
          `uvm_fatal("MTSP_CASE",
            $sformatf("%s iter=%0d debug/meta mismatch late eop debug_ts=%0d debug_burst=%0d ts_delta=%0d dual=%0d",
              ctx, iter, m_env.m_scb.debug_ts_count - base_debug_ts,
              m_env.m_scb.debug_burst_count - base_debug_burst,
              m_env.m_scb.ts_delta_count - base_ts_delta,
              m_env.m_scb.dual_path_pair_count - base_dual_pairs))
        exact_count++;
        send_ctrl(CTRL_IDLE, $sformatf("IDLE_extra_boundary_%0d", iter));
        wait_cycles(2);
        expect_total_count(48'd2,
          $sformatf("%s iter=%0d total", ctx, iter));
        expect_discard_count(32'd0,
          $sformatf("%s iter=%0d discard", ctx, iter));
      end
      if (exact_count != iterations)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected exact-boundary iterations=%0d got %0d",
            ctx, iterations, exact_count))
      `uvm_info("MTSP_BOUNDARY_METRIC",
        $sformatf("%s extra_boundary_rate_x10000=0 samples=%0d",
          ctx, iterations),
        UVM_LOW)
    endtask

    task automatic run_ready_statefulness_cost_case(int unsigned hit_count,
                                                    string ctx);
      int unsigned base_inputs;
      int unsigned base_beats;
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;

      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      for (int unsigned phase_idx = 0; phase_idx < 2; phase_idx++) begin
        start_run_control_cycle(1'b0, phase_idx, ctx);
        base_inputs      = m_env.m_scb.hit0_history.size();
        base_beats       = m_env.m_scb.beat_count;
        base_history     = m_env.m_scb.history.size();
        base_traces      = m_env.m_scb.trace_history.size();
        base_debug_ts    = m_env.m_scb.debug_ts_count;
        base_debug_burst = m_env.m_scb.debug_burst_count;
        base_ts_delta    = m_env.m_scb.ts_delta_count;
        for (int unsigned idx = 0; idx < hit_count; idx++)
          send_metric_payload_nowait(idx, 4, idx >= hit_count - 4,
            $sformatf("%s phase=%0d", ctx, phase_idx));
        wait_for_input_count(base_inputs + hit_count, hit_count + 512,
          $sformatf("%s phase=%0d inputs", ctx, phase_idx));
        wait_for_beat_count(base_beats + hit_count, hit_count + 1024,
          $sformatf("%s phase=%0d beats", ctx, phase_idx));
        wait_for_trace_count(base_traces + hit_count, hit_count + 1024,
          $sformatf("%s phase=%0d traces", ctx, phase_idx));
        wait_for_debug_ts_count(base_debug_ts + hit_count, hit_count + 1024,
          $sformatf("%s phase=%0d debug_ts", ctx, phase_idx));
        wait_for_debug_burst_count(base_debug_burst + hit_count,
          hit_count + 1024,
          $sformatf("%s phase=%0d debug_burst", ctx, phase_idx));
        wait_for_ts_delta_count(base_ts_delta + hit_count, hit_count + 1024,
          $sformatf("%s phase=%0d ts_delta", ctx, phase_idx));
        expect_metric_payloads_since(base_history, base_traces, hit_count,
          4, $sformatf("%s phase=%0d", ctx, phase_idx));
        expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
          base_ts_delta, hit_count, hit_count, hit_count,
          $sformatf("%s phase=%0d", ctx, phase_idx));
        expect_hit0_spacing(base_inputs, hit_count, 1,
          $sformatf("%s phase=%0d line-rate spacing", ctx, phase_idx));
        expect_total_count(hit_count,
          $sformatf("%s phase=%0d total", ctx, phase_idx));
        if (phase_idx == 0) begin
          int unsigned iter_history;
          int unsigned iter_empty_eops;

          iter_history    = m_env.m_scb.history.size();
          iter_empty_eops = m_env.m_scb.empty_eop_count;
          stop_run_with_endofrun(iter_history, iter_empty_eops, 0,
            $sformatf("%s stateful stop phase=%0d", ctx, phase_idx));
        end
      end
      `uvm_info("MTSP_READY_METRIC",
        $sformatf("%s statefulness_cost_cycles=0 checked_hit_count=%0d",
          ctx, hit_count),
        UVM_LOW)
    endtask

    task automatic run_full_signoff_mixed_soak_case(string ctx);
      do_stress_041_single_overflow_run();
      drive_global_reset(4, 4);
      run_sink_smoke_replay_case(4, SINK_READY_TOGGLE_1010,
        $sformatf("%s smoke-ready phase", ctx));
      drive_global_reset(4, 4);
      run_drain_latency_histogram_case(12, 4, 4,
        $sformatf("%s drain phase", ctx));
      drive_global_reset(4, 4);
      run_synthetic_boundary_no_real_eop_case(8,
        $sformatf("%s synthetic-boundary phase", ctx));
      drive_global_reset(4, 4);
      run_extra_boundary_rate_case(8,
        $sformatf("%s extra-boundary phase", ctx));
      drive_global_reset(4, 4);
      run_ready_statefulness_cost_case(32,
        $sformatf("%s ready-cost phase", ctx));
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

    task automatic do_stress_051_debug_ts_every_hit();
      run_debug_stream_count_case(128, case_id);
    endtask

    task automatic do_stress_052_debug_burst_after_warmup();
      run_debug_stream_count_case(160, case_id);
    endtask

    task automatic do_stress_053_ts_delta_after_warmup();
      run_debug_stream_count_case(160, case_id);
    endtask

    task automatic do_stress_054_alternating_increasing_decreasing_timestamps();
      run_debug_sign_churn_case(64, case_id);
    endtask

    task automatic do_stress_055_equal_timestamp_pairs();
      run_debug_equal_timestamp_case(64, case_id);
    endtask

    task automatic do_stress_056_error_pipeline_t_path_under_load();
      run_debug_error_pipeline_case(1'b1, 96, case_id);
    endtask

    task automatic do_stress_057_error_pipeline_e_path_under_load();
      run_debug_error_pipeline_case(1'b0, 96, case_id);
    endtask

    task automatic do_stress_058_expected_latency_at_distribution_edge();
      run_debug_expected_latency_edge_case(case_id);
    endtask

    task automatic do_stress_059_debug_streams_through_flushing();
      run_debug_streams_through_flushing_case(32, 8, case_id);
    endtask

    task automatic do_stress_060_debug_streams_clear_after_running();
      run_debug_streams_clear_repeated_case(4, 8, case_id);
    endtask

    task automatic do_stress_061_hundred_empty_standard_runs();
      run_empty_standard_runs_case(100, case_id);
    endtask

    task automatic do_stress_062_hundred_single_packet_runs();
      run_single_packet_runs_case(100, case_id);
    endtask

    task automatic do_stress_063_hundred_multi_channel_runs();
      run_multi_channel_runs_case(100, case_id);
    endtask

    task automatic do_stress_064_hundred_stop_cycles_ready_low();
      run_ready_low_stop_cycles_case(100, case_id);
    endtask

    task automatic do_stress_065_hundred_running_abort_cycles();
      run_running_abort_cycles_case(100, case_id);
    endtask

    task automatic do_stress_066_alternate_standard_and_legacy_starts();
      run_alternate_start_styles_case(100, case_id);
    endtask

    task automatic do_stress_067_idleness_only_csr_rewrites();
      run_idle_csr_rewrite_case(32, case_id);
    endtask

    task automatic do_stress_068_prepare_phase_csr_rewrites();
      run_prepare_csr_rewrite_case(32, case_id);
    endtask

    task automatic do_stress_069_flushing_phase_csr_rewrites();
      run_flushing_csr_rewrite_case(32, case_id);
    endtask

    task automatic do_stress_070_interspersed_illegal_ctrl_words();
      run_illegal_ctrl_chatter_case(48, case_id);
    endtask

    task automatic do_stress_071_terminate_after_single_packet();
      run_terminate_after_burst_case(1, 1'b1, case_id);
    endtask

    task automatic do_stress_072_terminate_after_dense_burst();
      run_terminate_after_burst_case(32, 1'b1, case_id);
    endtask

    task automatic do_stress_073_terminate_with_eop_on_last_beat();
      run_terminate_after_burst_case(8, 1'b1, case_id);
    endtask

    task automatic do_stress_074_terminate_with_late_eop();
      run_late_flushing_payload_case(4, 1'b0, 1'b0, case_id);
    endtask

    task automatic do_stress_075_terminate_without_eop_then_idle();
      run_terminate_without_eop_idle_case(case_id);
    endtask

    task automatic do_stress_076_multiple_late_eops();
      run_late_flushing_payload_case(4, 1'b1, 1'b0, case_id);
    endtask

    task automatic do_stress_077_terminate_with_ready_low();
      run_late_flushing_payload_case(4, 1'b0, 1'b1, case_id);
    endtask

    task automatic do_stress_078_terminate_per_enabled_channel();
      run_terminate_per_channel_case(case_id);
    endtask

    task automatic do_stress_079_terminate_near_overflow_window();
      run_terminate_near_overflow_case(case_id);
    endtask

    task automatic do_stress_080_terminate_during_heavy_csr_polling();
      run_terminate_with_csr_polling_case(16, 16, case_id);
    endtask

    task automatic do_stress_081_div_pipeline_two_under_load();
      run_pipeline_parameter_soak_case(96, 8, case_id);
    endtask

    task automatic do_stress_082_div_pipeline_four_under_load();
      run_pipeline_parameter_soak_case(96, 10, case_id);
    endtask

    task automatic do_stress_083_single_enabled_channel_soak();
      run_profile_variance_case(128, PROFILE_PATTERN_HOT_CH0, case_id);
    endtask

    task automatic do_stress_084_two_enabled_channels_soak();
      run_profile_variance_case(128, PROFILE_PATTERN_MID_WINDOW, case_id);
    endtask

    task automatic do_stress_085_four_enabled_channels_soak();
      run_profile_variance_case(256, PROFILE_PATTERN_RR_ENABLED, case_id);
    endtask

    task automatic do_stress_086_remapped_hiterr_soak();
      run_remapped_hiterr_soak_case(128, case_id);
    endtask

    task automatic do_stress_087_custom_default_latency_soak();
      run_custom_default_latency_soak_case(64, 128, case_id);
    endtask

    task automatic do_stress_088_debug_zero_soak();
      run_profile_variance_case(128, PROFILE_PATTERN_RR_ENABLED, case_id);
    endtask

    task automatic do_stress_089_bank_up_vs_down_compare();
      run_profile_variance_case(128, PROFILE_PATTERN_RR_ENABLED, case_id);
    endtask

    task automatic do_stress_090_inert_parameter_sweep_compare();
      run_inert_parameter_soak_case(64, case_id);
    endtask

    task automatic do_stress_091_random_marker_mix();
      run_random_marker_mix_case(96, case_id);
    endtask

    task automatic do_stress_092_random_accept_reject_mix();
      run_random_accept_reject_mix_case(128, case_id);
    endtask

    task automatic do_stress_093_random_delay_path_mix();
      run_random_delay_path_mix_case(48, case_id);
    endtask

    task automatic do_stress_094_random_tot_mode_mix();
      run_random_tot_mode_mix_case(80, case_id);
    endtask

    task automatic do_stress_095_random_force_stop_pulses();
      run_random_force_stop_case(96, case_id);
    endtask

    task automatic do_stress_096_random_soft_reset_pulses();
      run_random_soft_reset_case(5, case_id);
    endtask

    task automatic do_stress_097_random_control_chatter();
      run_random_ctrl_chatter_case(32, case_id);
    endtask

    task automatic do_stress_098_random_asic_ids();
      run_profile_variance_case(192, PROFILE_PATTERN_RANDOM_ASIC, case_id);
    endtask

    task automatic do_stress_099_random_payload_channels();
      run_profile_variance_case(192, PROFILE_PATTERN_RANDOM_CHANNEL, case_id);
    endtask

    task automatic do_stress_100_random_expected_latency_rewrites();
      run_random_latency_rewrite_case(8, 8, case_id);
    endtask

    task automatic do_stress_101_repeat_smoke_positive_vector_1k();
      run_smoke_replay_case(1000, SMOKE_PATTERN_POSITIVE, 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 10, case_id);
    endtask

    task automatic do_stress_102_repeat_smoke_eflag_zero_vector_1k();
      run_smoke_replay_case(1000, SMOKE_PATTERN_EFLAG_ZERO, 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 10, case_id);
    endtask

    task automatic do_stress_103_repeat_smoke_clamp_vector_1k();
      run_smoke_replay_case(1000, SMOKE_PATTERN_CLAMP_PAIR, 1'b0, 1'b0,
        1'b0, 1'b0, 1'b0, 10, case_id);
    endtask

    task automatic do_stress_104_smoke_vectors_under_standard_sequence();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b1, 1'b0, 1'b0, 1'b0,
        1'b0, 10, case_id);
    endtask

    task automatic do_stress_105_smoke_vectors_with_ready_low();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b0, 1'b0, 1'b0, 1'b1,
        1'b0, 10, case_id);
    endtask

    task automatic do_stress_106_smoke_vectors_div_pipeline_two();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b0, 1'b0, 1'b0, 1'b0,
        1'b0, 8, case_id);
    endtask

    task automatic do_stress_107_smoke_vectors_div_pipeline_four();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b0, 1'b0, 1'b0, 1'b0,
        1'b0, 10, case_id);
    endtask

    task automatic do_stress_108_smoke_vectors_bypass_on();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b0, 1'b1, 1'b0, 1'b0,
        1'b1, 10, case_id);
    endtask

    task automatic do_stress_109_smoke_vectors_delay_field_e();
      run_smoke_replay_case(1, SMOKE_PATTERN_ALL, 1'b0, 1'b0, 1'b0, 1'b0,
        1'b0, 10, case_id);
    endtask

    task automatic do_stress_110_smoke_vectors_with_soft_reset_between_runs();
      run_smoke_soft_reset_case(32, case_id);
    endtask

    task automatic do_stress_111_ready_high_baseline_log();
      run_sink_smoke_replay_case(16, SINK_READY_HIGH, case_id);
    endtask

    task automatic do_stress_112_ready_low_baseline_log();
      run_sink_smoke_replay_case(16, SINK_READY_LOW, case_id);
    endtask

    task automatic do_stress_113_ready_toggle_1010();
      run_sink_smoke_replay_case(16, SINK_READY_TOGGLE_1010, case_id);
    endtask

    task automatic do_stress_114_ready_low_on_sop_beats();
      run_sink_smoke_replay_case(16, SINK_READY_LOW_ON_SOP, case_id);
    endtask

    task automatic do_stress_115_ready_low_on_eop_beats();
      run_sink_terminate_eop_ready_case(8, case_id);
    endtask

    task automatic do_stress_116_ready_low_during_dense_burst();
      run_sink_smoke_replay_case(32, SINK_READY_DENSE_LOW, case_id);
    endtask

    task automatic do_stress_117_ready_low_in_flushing();
      int unsigned base_history;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned base_dual_pairs;

      base_history     = m_env.m_scb.history.size();
      base_debug_ts    = m_env.m_scb.debug_ts_count;
      base_debug_burst = m_env.m_scb.debug_burst_count;
      base_ts_delta    = m_env.m_scb.ts_delta_count;
      base_dual_pairs  = m_env.m_scb.dual_path_pair_count;
      run_late_flushing_payload_case(8, 1'b0, 1'b1, case_id);
      wait_for_debug_ts_count(base_debug_ts + 8, 1032, case_id);
      expect_debug_stream_counts_since(base_debug_ts, base_debug_burst,
        base_ts_delta, 8, 0, 0, case_id);
      if (m_env.m_scb.dual_path_pair_count != base_dual_pairs + 8)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected 8 new dual-path trace pairs, got %0d",
            case_id, m_env.m_scb.dual_path_pair_count - base_dual_pairs))
      expect_ready_observation_since(base_history, 12, SINK_READY_FLUSH_LOW,
        case_id);
    endtask

    task automatic do_stress_118_random_ready_toggle();
      run_sink_smoke_replay_case(32, SINK_READY_RANDOM, case_id);
    endtask

    task automatic do_stress_119_ready_low_across_resets();
      int unsigned base_history;
      int unsigned base_traces;
      int unsigned base_debug_ts;
      int unsigned base_debug_burst;
      int unsigned base_ts_delta;
      int unsigned expected_payloads;

      wait_for_reset_release();
      set_hit1_ready(1'b0);
      drive_global_reset(5, 4);
      if (hit1_drv_vif.ready !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected sink ready held low across global reset",
            case_id))
      run_sink_smoke_replay_phase(16, SINK_READY_RESET_LOW, base_history,
        base_traces, base_debug_ts, base_debug_burst, base_ts_delta,
        expected_payloads, case_id);
    endtask

    task automatic do_stress_120_sink_pattern_equivalence_summary();
      int unsigned base_history_high;
      int unsigned base_history_low;
      int unsigned base_history_toggle;
      int unsigned base_history_random;
      int unsigned base_traces_high;
      int unsigned base_traces_low;
      int unsigned base_traces_toggle;
      int unsigned base_traces_random;
      int unsigned base_debug_ts_high;
      int unsigned base_debug_ts_low;
      int unsigned base_debug_ts_toggle;
      int unsigned base_debug_ts_random;
      int unsigned base_debug_burst_high;
      int unsigned base_debug_burst_low;
      int unsigned base_debug_burst_toggle;
      int unsigned base_debug_burst_random;
      int unsigned base_ts_delta_high;
      int unsigned base_ts_delta_low;
      int unsigned base_ts_delta_toggle;
      int unsigned base_ts_delta_random;
      int unsigned payloads_high;
      int unsigned payloads_low;
      int unsigned payloads_toggle;
      int unsigned payloads_random;

      run_sink_smoke_replay_phase(8, SINK_READY_HIGH, base_history_high,
        base_traces_high, base_debug_ts_high, base_debug_burst_high,
        base_ts_delta_high, payloads_high,
        $sformatf("%s high baseline", case_id));
      drive_global_reset(4, 4);
      run_sink_smoke_replay_phase(8, SINK_READY_LOW, base_history_low,
        base_traces_low, base_debug_ts_low, base_debug_burst_low,
        base_ts_delta_low, payloads_low,
        $sformatf("%s low compare", case_id));
      if (payloads_low != payloads_high)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s low payload count mismatch high=%0d low=%0d",
            case_id, payloads_high, payloads_low))
      expect_sink_phase_equivalent(base_history_high, base_history_low,
        base_traces_high, base_traces_low, base_debug_ts_high,
        base_debug_ts_low, base_debug_burst_high, base_debug_burst_low,
        base_ts_delta_high, base_ts_delta_low, payloads_high,
        $sformatf("%s high-vs-low", case_id));

      drive_global_reset(4, 4);
      run_sink_smoke_replay_phase(8, SINK_READY_TOGGLE_1010,
        base_history_toggle, base_traces_toggle, base_debug_ts_toggle,
        base_debug_burst_toggle, base_ts_delta_toggle, payloads_toggle,
        $sformatf("%s toggle compare", case_id));
      if (payloads_toggle != payloads_high)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s toggle payload count mismatch high=%0d toggle=%0d",
            case_id, payloads_high, payloads_toggle))
      expect_sink_phase_equivalent(base_history_high, base_history_toggle,
        base_traces_high, base_traces_toggle, base_debug_ts_high,
        base_debug_ts_toggle, base_debug_burst_high, base_debug_burst_toggle,
        base_ts_delta_high, base_ts_delta_toggle, payloads_high,
        $sformatf("%s high-vs-toggle", case_id));

      drive_global_reset(4, 4);
      run_sink_smoke_replay_phase(8, SINK_READY_RANDOM, base_history_random,
        base_traces_random, base_debug_ts_random, base_debug_burst_random,
        base_ts_delta_random, payloads_random,
        $sformatf("%s random compare", case_id));
      if (payloads_random != payloads_high)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s random payload count mismatch high=%0d random=%0d",
            case_id, payloads_high, payloads_random))
      expect_sink_phase_equivalent(base_history_high, base_history_random,
        base_traces_high, base_traces_random, base_debug_ts_high,
        base_debug_ts_random, base_debug_burst_high, base_debug_burst_random,
        base_ts_delta_high, base_ts_delta_random, payloads_high,
        $sformatf("%s high-vs-random", case_id));
    endtask

    task automatic do_stress_121_future_ready_occupancy_histogram();
      run_ready_occupancy_histogram_case(16, case_id);
    endtask

    task automatic do_stress_122_drain_latency_histogram();
      run_drain_latency_histogram_case(32, 8, 4, case_id);
    endtask

    task automatic do_stress_123_drain_latency_by_div_pipeline();
      run_drain_latency_histogram_case(16, 8, 4, case_id);
    endtask

    task automatic do_stress_124_drain_latency_by_enabled_window();
      wait_for_reset_release();
      configure_datapath_mode(1'b1, 1'b0, 1'b1);
      run_enabled_window_drain_metric_case(case_id);
    endtask

    task automatic do_stress_125_boundary_forwarding_rate();
      run_boundary_forwarding_rate_case(1000, case_id);
    endtask

    task automatic do_stress_126_missing_boundary_rate_post_upgrade();
      run_synthetic_boundary_no_real_eop_case(64, case_id);
    endtask

    task automatic do_stress_127_extra_boundary_rate_post_upgrade();
      run_extra_boundary_rate_case(64, case_id);
    endtask

    task automatic do_stress_128_ready_statefulness_cost();
      run_ready_statefulness_cost_case(128, case_id);
    endtask

    task automatic do_stress_129_synthetic_boundary_no_real_eop();
      run_synthetic_boundary_no_real_eop_case(128, case_id);
    endtask

    task automatic do_stress_130_full_signoff_mixed_soak();
      run_full_signoff_mixed_soak_case(case_id);
    endtask

    task automatic expect_run_state_cmd_value(int unsigned expected_value,
                                              string ctx);
      int unsigned observed_value;

      read_dut_uint("/tb_top/dut/run_state_cmd_code", observed_value, ctx);
      if (observed_value != expected_value)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s expected run_state_cmd_code value %0d got %0d",
            ctx, expected_value, observed_value))
    endtask

    task automatic force_tb_hdl(string slash_path,
                                string dot_path,
                                uvm_hdl_data_t value,
                                string ctx);
      if (!uvm_hdl_force(slash_path, value) &&
          !uvm_hdl_force(dot_path, value))
        `uvm_fatal("MTSP_HDL",
          $sformatf("%s could not force HDL path %s or %s",
            ctx, slash_path, dot_path))
    endtask

    task automatic release_tb_hdl(string slash_path,
                                  string dot_path,
                                  string ctx);
      if (!uvm_hdl_release(slash_path) &&
          !uvm_hdl_release(dot_path))
        `uvm_fatal("MTSP_HDL",
          $sformatf("%s could not release HDL path %s or %s",
            ctx, slash_path, dot_path))
    endtask

    task automatic expect_illegal_ctrl_word_recovery(logic [8:0] illegal_cmd,
                                                     bit active_running,
                                                     string ctx);
      int unsigned base_beats;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      if (active_running)
        run_start();
      base_beats = m_env.m_scb.beat_count;
      pulse_ctrl(illegal_cmd, $sformatf("%s illegal ctrl", ctx));
      wait_cycles(3);
      expect_run_state_cmd_value(9, $sformatf("%s run_state ERROR", ctx));
      csr_read(3'd0, csr_word);
      if (!active_running && csr_word[0] !== 1'b0)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s illegal idle command must not enter RUNNING csr0=0x%08h",
            ctx, csr_word))
      if (active_running && csr_word[0] !== 1'b1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s illegal active command must not leave RUNNING csr0=0x%08h",
            ctx, csr_word))
      expect_no_new_beats(base_beats, m_env.m_scb.eop_count,
        m_env.m_scb.empty_eop_count, 8,
        $sformatf("%s illegal command output quiet", ctx));

      if (!active_running)
        run_start();
      wait_for_hit0_ready(1'b1, 32,
        $sformatf("%s legal recovery ready", ctx));
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s legal hit after illegal ctrl", ctx));
      expect_last_trace_pair($sformatf("%s recovery trace", ctx));
    endtask

    task automatic run_illegal_ctrl_during_flushing_case(string ctx);
      int unsigned base_history;
      int unsigned base_empty_eops;
      int unsigned base_traces;

      wait_for_reset_release();
      run_start();
      base_history    = m_env.m_scb.history.size();
      base_traces     = m_env.m_scb.trace_history.size();
      base_empty_eops = m_env.m_scb.empty_eop_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b1);
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING");
      wait_for_ctrl_ready_low(4, $sformatf("%s terminate ready low", ctx));
      pulse_ctrl(CTRL_RUNNING | CTRL_TERMINATING,
        $sformatf("%s illegal flushing ctrl", ctx));
      wait_cycles(2);
      expect_run_state_cmd_value(4,
        $sformatf("%s illegal flushing ignored while ready-low", ctx));
      send_endofrun_pulse();
      wait_for_trace_count(base_traces + 1, 128,
        $sformatf("%s retained flushing payload trace", ctx));
      wait_for_empty_eop_count(base_empty_eops + 4, 256,
        $sformatf("%s close markers after illegal flushing ctrl", ctx));
      expect_payload_math_at(base_history, 2, 0, 0, 0, 1, 0,
        $sformatf("%s retained payload", ctx));
      expect_trace_pair_at(base_traces,
        $sformatf("%s retained payload trace", ctx));
      expect_close_markers_since(base_history, 4'b1111, 1,
        $sformatf("%s close detail", ctx));
      wait_for_ctrl_ready_high(256,
        $sformatf("%s ready restore after illegal flushing ctrl", ctx));
      send_ctrl(CTRL_IDLE, "IDLE");
      wait_cycles(2);
      expect_hit0_ready(1'b0, $sformatf("%s post-IDLE ready", ctx));
    endtask

    task automatic run_ctrl_valid_data_change_violation_case(string ctx);
      bit violation_seen;

      wait_for_reset_release();
      violation_seen = 1'b0;
      @(posedge ctrl_vif.clk);
      force_tb_hdl("/tb_top/ctrl_if/valid", "/tb_top.ctrl_if.valid",
        1, $sformatf("%s force ctrl valid", ctx));
      force_tb_hdl("/tb_top/ctrl_if/data", "/tb_top.ctrl_if.data",
        CTRL_RUN_PREPARE, $sformatf("%s force ctrl prepare", ctx));
      @(posedge ctrl_vif.clk);
      force_tb_hdl("/tb_top/ctrl_if/data", "/tb_top.ctrl_if.data",
        CTRL_SYNC, $sformatf("%s force ctrl sync", ctx));
      if (ctrl_vif.valid === 1'b1 && ctrl_vif.data === CTRL_SYNC)
        violation_seen = 1'b1;
      @(posedge ctrl_vif.clk);
      release_tb_hdl("/tb_top/ctrl_if/valid", "/tb_top.ctrl_if.valid",
        $sformatf("%s release ctrl valid", ctx));
      release_tb_hdl("/tb_top/ctrl_if/data", "/tb_top.ctrl_if.data",
        $sformatf("%s release ctrl data", ctx));
      drive_global_reset(4, 4);
      if (!violation_seen)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s did not observe forced ctrl data change while valid",
            ctx))
      expect_no_new_beats(0, 0, 0, 8, ctx);
    endtask

    task automatic run_ctrl_data_unknown_violation_case(string ctx);
      bit violation_seen;

      wait_for_reset_release();
      violation_seen = 1'b0;
      @(posedge ctrl_vif.clk);
      force_tb_hdl("/tb_top/ctrl_if/valid", "/tb_top.ctrl_if.valid",
        1, $sformatf("%s force ctrl valid", ctx));
      force_tb_hdl("/tb_top/ctrl_if/data", "/tb_top.ctrl_if.data",
        'x, $sformatf("%s force ctrl X", ctx));
      @(posedge ctrl_vif.clk);
      if (ctrl_vif.valid === 1'b1 && $isunknown(ctrl_vif.data))
        violation_seen = 1'b1;
      release_tb_hdl("/tb_top/ctrl_if/valid", "/tb_top.ctrl_if.valid",
        $sformatf("%s release ctrl valid", ctx));
      release_tb_hdl("/tb_top/ctrl_if/data", "/tb_top.ctrl_if.data",
        $sformatf("%s release ctrl data", ctx));
      drive_global_reset(4, 4);
      if (!violation_seen)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s did not observe forced X/Z ctrl data while valid",
            ctx))
      expect_no_new_beats(0, 0, 0, 8, ctx);
    endtask

    task automatic do_neg_001_all_zero_ctrl_word();
      expect_illegal_ctrl_word_recovery(9'b000000000, 1'b0, case_id);
    endtask

    task automatic do_neg_002_multi_hot_ctrl_word();
      expect_illegal_ctrl_word_recovery(CTRL_RUNNING | CTRL_TERMINATING,
        1'b0, case_id);
    endtask

    task automatic do_neg_003_illegal_ctrl_during_running();
      expect_illegal_ctrl_word_recovery(CTRL_RUNNING | CTRL_TERMINATING,
        1'b1, case_id);
    endtask

    task automatic do_neg_004_illegal_ctrl_during_flushing();
      run_illegal_ctrl_during_flushing_case(case_id);
    endtask

    task automatic do_neg_005_ctrl_valid_high_data_changes();
      run_ctrl_valid_data_change_violation_case(case_id);
    endtask

    task automatic do_neg_006_ctrl_data_unknown_injection();
      run_ctrl_data_unknown_violation_case(case_id);
    endtask

    task automatic do_neg_007_running_without_sync_documented_nonstandard();
      do_std_003_direct_running_entry_allowed();
    endtask

    task automatic do_neg_008_terminate_from_idle();
      int unsigned base_beats;
      int unsigned base_eops;
      int unsigned base_empty_eops;

      wait_for_reset_release();
      base_beats      = m_env.m_scb.beat_count;
      base_eops       = m_env.m_scb.eop_count;
      base_empty_eops = m_env.m_scb.empty_eop_count;
      pulse_ctrl(CTRL_TERMINATING, "TERMINATING_FROM_IDLE");
      wait_cycles(8);
      expect_hit0_ready(1'b0, case_id);
      expect_no_new_beats(base_beats, base_eops, base_empty_eops, 16,
        case_id);
      expect_total_count(48'd0, case_id);
      expect_discard_count(32'd0, case_id);
    endtask

    task automatic do_neg_009_link_test_during_running();
      int unsigned base_beats;
      bit [31:0]   csr_word;

      wait_for_reset_release();
      run_start();
      pulse_ctrl(CTRL_LINK_TEST, "LINK_TEST_RUNNING");
      wait_cycles(4);
      csr_read(3'd0, csr_word);
      if (csr_word[0] !== 1'b1)
        `uvm_fatal("MTSP_CASE",
          $sformatf("%s LINK_TEST must not leave RUNNING csr0=0x%08h",
            case_id, csr_word))
      base_beats = m_env.m_scb.beat_count;
      send_hit_beat(2, 0, 15'h0003, 15'h000F, 1'b1, 1'b1, 1'b0);
      wait_for_beat_count(base_beats + 1, 128,
        $sformatf("%s legal hit after LINK_TEST", case_id));
      expect_last_trace_pair($sformatf("%s LINK_TEST containment trace",
        case_id));
    endtask

    task automatic do_neg_010_always_ready_masks_incomplete_work();
      do_corner_128_accept_command_vs_complete_work_upgrade();
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
        "NEG_MTS_001_all_zero_ctrl_word": do_neg_001_all_zero_ctrl_word();
        "NEG_MTS_002_multi_hot_ctrl_word": do_neg_002_multi_hot_ctrl_word();
        "NEG_MTS_003_illegal_ctrl_during_running": do_neg_003_illegal_ctrl_during_running();
        "NEG_MTS_004_illegal_ctrl_during_flushing": do_neg_004_illegal_ctrl_during_flushing();
        "NEG_MTS_005_ctrl_valid_high_data_changes": do_neg_005_ctrl_valid_high_data_changes();
        "NEG_MTS_006_ctrl_data_unknown_injection": do_neg_006_ctrl_data_unknown_injection();
        "NEG_MTS_007_running_without_sync_documented_nonstandard": do_neg_007_running_without_sync_documented_nonstandard();
        "NEG_MTS_008_terminate_from_idle": do_neg_008_terminate_from_idle();
        "NEG_MTS_009_link_test_during_running": do_neg_009_link_test_during_running();
        "NEG_MTS_010_always_ready_masks_incomplete_work": do_neg_010_always_ready_masks_incomplete_work();
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
        "STRESS_MTS_051_debug_ts_every_hit": do_stress_051_debug_ts_every_hit();
        "STRESS_MTS_052_debug_burst_after_warmup": do_stress_052_debug_burst_after_warmup();
        "STRESS_MTS_053_ts_delta_after_warmup": do_stress_053_ts_delta_after_warmup();
        "STRESS_MTS_054_alternating_increasing_decreasing_timestamps": do_stress_054_alternating_increasing_decreasing_timestamps();
        "STRESS_MTS_055_equal_timestamp_pairs": do_stress_055_equal_timestamp_pairs();
        "STRESS_MTS_056_error_pipeline_t_path_under_load": do_stress_056_error_pipeline_t_path_under_load();
        "STRESS_MTS_057_error_pipeline_e_path_under_load": do_stress_057_error_pipeline_e_path_under_load();
        "STRESS_MTS_058_expected_latency_at_distribution_edge": do_stress_058_expected_latency_at_distribution_edge();
        "STRESS_MTS_059_debug_streams_through_flushing": do_stress_059_debug_streams_through_flushing();
        "STRESS_MTS_060_debug_streams_clear_after_running": do_stress_060_debug_streams_clear_after_running();
        "STRESS_MTS_061_hundred_empty_standard_runs": do_stress_061_hundred_empty_standard_runs();
        "STRESS_MTS_062_hundred_single_packet_runs": do_stress_062_hundred_single_packet_runs();
        "STRESS_MTS_063_hundred_multi_channel_runs": do_stress_063_hundred_multi_channel_runs();
        "STRESS_MTS_064_hundred_stop_cycles_ready_low": do_stress_064_hundred_stop_cycles_ready_low();
        "STRESS_MTS_065_hundred_running_abort_cycles": do_stress_065_hundred_running_abort_cycles();
        "STRESS_MTS_066_alternate_standard_and_legacy_starts": do_stress_066_alternate_standard_and_legacy_starts();
        "STRESS_MTS_067_idleness_only_csr_rewrites": do_stress_067_idleness_only_csr_rewrites();
        "STRESS_MTS_068_prepare_phase_csr_rewrites": do_stress_068_prepare_phase_csr_rewrites();
        "STRESS_MTS_069_flushing_phase_csr_rewrites": do_stress_069_flushing_phase_csr_rewrites();
        "STRESS_MTS_070_interspersed_illegal_ctrl_words": do_stress_070_interspersed_illegal_ctrl_words();
        "STRESS_MTS_071_terminate_after_single_packet": do_stress_071_terminate_after_single_packet();
        "STRESS_MTS_072_terminate_after_dense_burst": do_stress_072_terminate_after_dense_burst();
        "STRESS_MTS_073_terminate_with_eop_on_last_beat": do_stress_073_terminate_with_eop_on_last_beat();
        "STRESS_MTS_074_terminate_with_late_eop": do_stress_074_terminate_with_late_eop();
        "STRESS_MTS_075_terminate_without_eop_then_idle": do_stress_075_terminate_without_eop_then_idle();
        "STRESS_MTS_076_multiple_late_eops": do_stress_076_multiple_late_eops();
        "STRESS_MTS_077_terminate_with_ready_low": do_stress_077_terminate_with_ready_low();
        "STRESS_MTS_078_terminate_per_enabled_channel": do_stress_078_terminate_per_enabled_channel();
        "STRESS_MTS_079_terminate_near_overflow_window": do_stress_079_terminate_near_overflow_window();
        "STRESS_MTS_080_terminate_during_heavy_csr_polling": do_stress_080_terminate_during_heavy_csr_polling();
        "STRESS_MTS_081_div_pipeline_two_under_load": do_stress_081_div_pipeline_two_under_load();
        "STRESS_MTS_082_div_pipeline_four_under_load": do_stress_082_div_pipeline_four_under_load();
        "STRESS_MTS_083_single_enabled_channel_soak": do_stress_083_single_enabled_channel_soak();
        "STRESS_MTS_084_two_enabled_channels_soak": do_stress_084_two_enabled_channels_soak();
        "STRESS_MTS_085_four_enabled_channels_soak": do_stress_085_four_enabled_channels_soak();
        "STRESS_MTS_086_remapped_hiterr_soak": do_stress_086_remapped_hiterr_soak();
        "STRESS_MTS_087_custom_default_latency_soak": do_stress_087_custom_default_latency_soak();
        "STRESS_MTS_088_debug_zero_soak": do_stress_088_debug_zero_soak();
        "STRESS_MTS_089_bank_up_vs_down_compare": do_stress_089_bank_up_vs_down_compare();
        "STRESS_MTS_090_inert_parameter_sweep_compare": do_stress_090_inert_parameter_sweep_compare();
        "STRESS_MTS_091_random_marker_mix": do_stress_091_random_marker_mix();
        "STRESS_MTS_092_random_accept_reject_mix": do_stress_092_random_accept_reject_mix();
        "STRESS_MTS_093_random_delay_path_mix": do_stress_093_random_delay_path_mix();
        "STRESS_MTS_094_random_tot_mode_mix": do_stress_094_random_tot_mode_mix();
        "STRESS_MTS_095_random_force_stop_pulses": do_stress_095_random_force_stop_pulses();
        "STRESS_MTS_096_random_soft_reset_pulses": do_stress_096_random_soft_reset_pulses();
        "STRESS_MTS_097_random_control_chatter": do_stress_097_random_control_chatter();
        "STRESS_MTS_098_random_asic_ids": do_stress_098_random_asic_ids();
        "STRESS_MTS_099_random_payload_channels": do_stress_099_random_payload_channels();
        "STRESS_MTS_100_random_expected_latency_rewrites": do_stress_100_random_expected_latency_rewrites();
        "STRESS_MTS_101_repeat_smoke_positive_vector_1k": do_stress_101_repeat_smoke_positive_vector_1k();
        "STRESS_MTS_102_repeat_smoke_eflag_zero_vector_1k": do_stress_102_repeat_smoke_eflag_zero_vector_1k();
        "STRESS_MTS_103_repeat_smoke_clamp_vector_1k": do_stress_103_repeat_smoke_clamp_vector_1k();
        "STRESS_MTS_104_smoke_vectors_under_standard_sequence": do_stress_104_smoke_vectors_under_standard_sequence();
        "STRESS_MTS_105_smoke_vectors_with_ready_low": do_stress_105_smoke_vectors_with_ready_low();
        "STRESS_MTS_106_smoke_vectors_div_pipeline_two": do_stress_106_smoke_vectors_div_pipeline_two();
        "STRESS_MTS_107_smoke_vectors_div_pipeline_four": do_stress_107_smoke_vectors_div_pipeline_four();
        "STRESS_MTS_108_smoke_vectors_bypass_on": do_stress_108_smoke_vectors_bypass_on();
        "STRESS_MTS_109_smoke_vectors_delay_field_e": do_stress_109_smoke_vectors_delay_field_e();
        "STRESS_MTS_110_smoke_vectors_with_soft_reset_between_runs": do_stress_110_smoke_vectors_with_soft_reset_between_runs();
        "STRESS_MTS_111_ready_high_baseline_log": do_stress_111_ready_high_baseline_log();
        "STRESS_MTS_112_ready_low_baseline_log": do_stress_112_ready_low_baseline_log();
        "STRESS_MTS_113_ready_toggle_1010": do_stress_113_ready_toggle_1010();
        "STRESS_MTS_114_ready_low_on_sop_beats": do_stress_114_ready_low_on_sop_beats();
        "STRESS_MTS_115_ready_low_on_eop_beats": do_stress_115_ready_low_on_eop_beats();
        "STRESS_MTS_116_ready_low_during_dense_burst": do_stress_116_ready_low_during_dense_burst();
        "STRESS_MTS_117_ready_low_in_flushing": do_stress_117_ready_low_in_flushing();
        "STRESS_MTS_118_random_ready_toggle": do_stress_118_random_ready_toggle();
        "STRESS_MTS_119_ready_low_across_resets": do_stress_119_ready_low_across_resets();
        "STRESS_MTS_120_sink_pattern_equivalence_summary": do_stress_120_sink_pattern_equivalence_summary();
        "STRESS_MTS_121_future_ready_occupancy_histogram": do_stress_121_future_ready_occupancy_histogram();
        "STRESS_MTS_122_drain_latency_histogram": do_stress_122_drain_latency_histogram();
        "STRESS_MTS_123_drain_latency_by_div_pipeline": do_stress_123_drain_latency_by_div_pipeline();
        "STRESS_MTS_124_drain_latency_by_enabled_window": do_stress_124_drain_latency_by_enabled_window();
        "STRESS_MTS_125_boundary_forwarding_rate": do_stress_125_boundary_forwarding_rate();
        "STRESS_MTS_126_missing_boundary_rate_post_upgrade": do_stress_126_missing_boundary_rate_post_upgrade();
        "STRESS_MTS_127_extra_boundary_rate_post_upgrade": do_stress_127_extra_boundary_rate_post_upgrade();
        "STRESS_MTS_128_ready_statefulness_cost": do_stress_128_ready_statefulness_cost();
        "STRESS_MTS_129_synthetic_boundary_no_real_eop": do_stress_129_synthetic_boundary_no_real_eop();
        "STRESS_MTS_130_full_signoff_mixed_soak": do_stress_130_full_signoff_mixed_soak();
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
