library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

-- Re-arm regression for the RESET-state RUN_PREPARE deadlock.
-- Standard run sequence: IDLE -> RUN_PREPARE -> SYNC -> RUNNING.
-- Silicon trigger: the host retries the start sequence, so a 2nd RUN_PREPARE
-- lands while processor_state is already RESET (reset_flow=SYNC). Without the
-- RESET-state RUN_PREPARE branch the FSM wedges in RESET (ctrl_ready_comb=0
-- rejects every later SYNC/RUNNING word) and type1-extended never emits.
entity mts_processor_rearm_tb is
end entity mts_processor_rearm_tb;

architecture sim of mts_processor_rearm_tb is

    constant CLK_PERIOD_CONST       : time := 8 ns;
    constant CTRL_IDLE_CONST        : std_logic_vector(8 downto 0) := "000000001";
    constant CTRL_PREPARE_CONST     : std_logic_vector(8 downto 0) := "000000010";
    constant CTRL_SYNC_CONST        : std_logic_vector(8 downto 0) := "000000100";
    constant CTRL_RUNNING_CONST     : std_logic_vector(8 downto 0) := "000001000";
    constant CSR_CONTROL_ADDR_CONST : natural := 0;
    constant CSR_STATUS_ADDR_CONST  : natural := 2;
    constant CSR_GO_DERIVE_TOT_CONST: std_logic_vector(31 downto 0) := x"40000001";
    -- processor_state_t enum order: RUNNING=0, RESET=1, IDLE=2, FLUSHING=3, ERROR=4
    constant PSTATE_RUNNING_CONST   : std_logic_vector(3 downto 0) := x"0";
    constant PSTATE_RESET_CONST     : std_logic_vector(3 downto 0) := x"1";
    constant EXT_WAIT_CONST         : natural := 64;

    signal avs_csr_readdata         : std_logic_vector(31 downto 0);
    signal avs_csr_read             : std_logic := '0';
    signal avs_csr_address          : std_logic_vector(2 downto 0) := (others => '0');
    signal avs_csr_waitrequest      : std_logic;
    signal avs_csr_write            : std_logic := '0';
    signal avs_csr_writedata        : std_logic_vector(31 downto 0) := (others => '0');
    signal asi_hit_type0_channel    : std_logic_vector(5 downto 0) := (others => '0');
    signal asi_hit_type0_startofpacket : std_logic := '0';
    signal asi_hit_type0_endofpacket   : std_logic := '0';
    signal asi_hit_type0_endofrun      : std_logic := '0';
    signal asi_hit_type0_error      : std_logic_vector(2 downto 0) := (others => '0');
    signal asi_hit_type0_data       : std_logic_vector(44 downto 0) := (others => '0');
    signal asi_hit_type0_valid      : std_logic := '0';
    signal asi_hit_type0_ready      : std_logic;
    signal coe_hit_type0_sidecar_data : std_logic_vector(63 downto 0) := (others => '0');
    signal coe_hit_type0_sidecar_valid : std_logic := '0';
    signal aso_hit_type1_channel    : std_logic_vector(3 downto 0);
    signal aso_hit_type1_startofpacket : std_logic;
    signal aso_hit_type1_endofpacket   : std_logic;
    signal aso_hit_type1_data       : std_logic_vector(38 downto 0);
    signal aso_hit_type1_valid      : std_logic;
    signal aso_hit_type1_ready      : std_logic := '1';
    signal aso_hit_type1_empty      : std_logic;
    signal aso_hit_type1_error      : std_logic;
    signal aso_hit_type1_extended_0_data : std_logic_vector(86 downto 0);
    signal aso_hit_type1_extended_0_valid: std_logic;
    signal aso_hit_type1_extended_1_data : std_logic_vector(86 downto 0);
    signal aso_hit_type1_extended_1_valid: std_logic;
    signal coe_hit_type1_ts              : std_logic_vector(47 downto 0);
    signal asi_ctrl_data            : std_logic_vector(8 downto 0) := (others => '0');
    signal asi_ctrl_valid           : std_logic := '0';
    signal aso_debug_ts_valid       : std_logic;
    signal aso_debug_ts_data        : std_logic_vector(15 downto 0);
    signal aso_debug_burst_valid    : std_logic;
    signal aso_debug_burst_data     : std_logic_vector(15 downto 0);
    signal aso_ts_delta_valid       : std_logic;
    signal aso_ts_delta_data        : std_logic_vector(15 downto 0);
    signal coe_debug_status_data    : std_logic_vector(31 downto 0);
    signal coe_hit_type1_sidecar_data : std_logic_vector(63 downto 0);
    signal coe_hit_type1_sidecar_valid : std_logic;
    signal i_rst                    : std_logic := '1';
    signal i_clk                    : std_logic := '0';

    procedure csr_write(
        signal clk                  : in  std_logic;
        signal addr                 : out std_logic_vector(2 downto 0);
        signal write                : out std_logic;
        signal writedata            : out std_logic_vector(31 downto 0);
        constant addr_value         : in  natural;
        constant data_value         : in  std_logic_vector(31 downto 0)
    ) is
    begin
        addr                        <= std_logic_vector(to_unsigned(addr_value, addr'length));
        writedata                   <= data_value;
        write                       <= '1';
        wait until rising_edge(clk);
        write                       <= '0';
        addr                        <= (others => '0');
        writedata                   <= (others => '0');
    end procedure csr_write;

    procedure csr_read(
        signal clk                  : in  std_logic;
        signal addr                 : out std_logic_vector(2 downto 0);
        signal read                 : out std_logic;
        signal readdata             : in  std_logic_vector(31 downto 0);
        constant addr_value         : in  natural;
        variable data_value         : out std_logic_vector(31 downto 0)
    ) is
    begin
        addr                        <= std_logic_vector(to_unsigned(addr_value, addr'length));
        read                        <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        data_value                  := readdata;
        read                        <= '0';
        addr                        <= (others => '0');
        wait until rising_edge(clk);
    end procedure csr_read;

    procedure send_ctrl(
        signal clk                  : in  std_logic;
        signal ctrl_data            : out std_logic_vector(8 downto 0);
        signal ctrl_valid           : out std_logic;
        constant ctrl_word          : in  std_logic_vector(8 downto 0)
    ) is
    begin
        ctrl_data                   <= ctrl_word;
        ctrl_valid                  <= '1';
        wait until rising_edge(clk);
        ctrl_valid                  <= '0';
        ctrl_data                   <= (others => '0');
    end procedure send_ctrl;

    -- Reusable run-control arm sequence: RUN_PREPARE -> SYNC, each settling 4
    -- cycles. Leaves the processor in RESET (reset_flow=SYNC). Call once for the
    -- standard start; call a SECOND time to model the host retrying the start
    -- sequence (the silicon pattern that exposed BUG-021-R: a fresh RUN_PREPARE
    -- arriving while processor_state is already RESET). Reuse this in any MTS
    -- run-control regression rather than open-coding the word ordering.
    procedure run_arm(
        signal clk                  : in  std_logic;
        signal ctrl_data            : out std_logic_vector(8 downto 0);
        signal ctrl_valid           : out std_logic
    ) is
    begin
        send_ctrl(clk, ctrl_data, ctrl_valid, CTRL_PREPARE_CONST);
        for w in 1 to 4 loop wait until rising_edge(clk); end loop;
        send_ctrl(clk, ctrl_data, ctrl_valid, CTRL_SYNC_CONST);
        for w in 1 to 4 loop wait until rising_edge(clk); end loop;
    end procedure run_arm;

    procedure send_hit(
        signal clk                  : in  std_logic;
        signal ready                : in  std_logic;
        signal hit_channel          : out std_logic_vector(5 downto 0);
        signal hit_data             : out std_logic_vector(44 downto 0);
        signal hit_valid            : out std_logic;
        signal hit_error            : out std_logic_vector(2 downto 0);
        constant asic_value         : in  natural;
        constant channel_value      : in  natural;
        constant tcc_raw_value      : in  natural;
        constant ecc_raw_value      : in  natural;
        constant eflag_value        : in  std_logic;
        signal sidecar_data         : out std_logic_vector(63 downto 0);
        signal sidecar_valid        : out std_logic;
        constant sidecar_value      : in  std_logic_vector(63 downto 0)
    ) is
        variable hit_word_v         : std_logic_vector(44 downto 0);
    begin
        while ready /= '1' loop
            wait until rising_edge(clk);
        end loop;

        hit_word_v                  := (others => '0');
        hit_word_v(44 downto 41)    := std_logic_vector(to_unsigned(asic_value, 4));
        hit_word_v(40 downto 36)    := std_logic_vector(to_unsigned(channel_value, 5));
        hit_word_v(35 downto 21)    := std_logic_vector(to_unsigned(tcc_raw_value, 15));
        hit_word_v(20 downto 16)    := (others => '0');
        hit_word_v(15 downto 1)     := std_logic_vector(to_unsigned(ecc_raw_value, 15));
        hit_word_v(0)               := eflag_value;

        hit_channel                 <= "00" & std_logic_vector(to_unsigned(asic_value, 4));
        hit_data                    <= hit_word_v;
        hit_error                   <= (others => '0');
        sidecar_data                <= sidecar_value;
        sidecar_valid               <= '1';
        hit_valid                   <= '1';
        wait until rising_edge(clk);
        hit_valid                   <= '0';
        hit_channel                 <= (others => '0');
        hit_data                    <= (others => '0');
        hit_error                   <= (others => '0');
        sidecar_data                <= (others => '0');
        sidecar_valid               <= '0';
    end procedure send_hit;

begin

    i_clk                           <= not i_clk after CLK_PERIOD_CONST / 2;

    dut : entity work.mts_processor
        generic map (
            DEBUG => 2
        )
        port map (
            avs_csr_readdata            => avs_csr_readdata,
            avs_csr_read                => avs_csr_read,
            avs_csr_address             => avs_csr_address,
            avs_csr_waitrequest         => avs_csr_waitrequest,
            avs_csr_write               => avs_csr_write,
            avs_csr_writedata           => avs_csr_writedata,
            asi_hit_type0_channel       => asi_hit_type0_channel,
            asi_hit_type0_startofpacket => asi_hit_type0_startofpacket,
            asi_hit_type0_endofpacket   => asi_hit_type0_endofpacket,
            asi_hit_type0_endofrun      => asi_hit_type0_endofrun,
            asi_hit_type0_error         => asi_hit_type0_error,
            asi_hit_type0_data          => asi_hit_type0_data,
            asi_hit_type0_valid         => asi_hit_type0_valid,
            asi_hit_type0_ready         => asi_hit_type0_ready,
            coe_hit_type0_sidecar_data  => coe_hit_type0_sidecar_data,
            coe_hit_type0_sidecar_valid => coe_hit_type0_sidecar_valid,
            aso_hit_type1_channel       => aso_hit_type1_channel,
            aso_hit_type1_startofpacket => aso_hit_type1_startofpacket,
            aso_hit_type1_endofpacket   => aso_hit_type1_endofpacket,
            aso_hit_type1_data          => aso_hit_type1_data,
            aso_hit_type1_valid         => aso_hit_type1_valid,
            aso_hit_type1_ready         => aso_hit_type1_ready,
            aso_hit_type1_empty         => aso_hit_type1_empty,
            aso_hit_type1_error         => aso_hit_type1_error,
            aso_hit_type1_extended_0_data  => aso_hit_type1_extended_0_data,
            aso_hit_type1_extended_0_valid => aso_hit_type1_extended_0_valid,
            aso_hit_type1_extended_1_data  => aso_hit_type1_extended_1_data,
            aso_hit_type1_extended_1_valid => aso_hit_type1_extended_1_valid,
            coe_hit_type1_ts              => coe_hit_type1_ts,
            coe_hit_arrival_gts_8n        => open,
            coe_hit_type1_latency_8n      => open,
            asi_ctrl_data               => asi_ctrl_data,
            asi_ctrl_valid              => asi_ctrl_valid,
            aso_debug_ts_valid          => aso_debug_ts_valid,
            aso_debug_ts_data           => aso_debug_ts_data,
            aso_debug_burst_valid       => aso_debug_burst_valid,
            aso_debug_burst_data        => aso_debug_burst_data,
            aso_ts_delta_valid          => aso_ts_delta_valid,
            aso_ts_delta_data           => aso_ts_delta_data,
            coe_debug_status_data       => coe_debug_status_data,
            coe_hit_type1_sidecar_data  => coe_hit_type1_sidecar_data,
            coe_hit_type1_sidecar_valid => coe_hit_type1_sidecar_valid,
            i_rst                       => i_rst,
            i_clk                       => i_clk
        );

    tb_stim : process
        variable status_v          : std_logic_vector(31 downto 0);
        variable ext_seen_v        : boolean := false;
        variable pstate_v          : std_logic_vector(3 downto 0);
    begin
        wait for 5 * CLK_PERIOD_CONST;
        wait until rising_edge(i_clk);
        i_rst                       <= '0';

        -- csr.go default is '1' here too; also set the derive-tot config.
        csr_write(i_clk, avs_csr_address, avs_csr_write, avs_csr_writedata,
                  CSR_CONTROL_ADDR_CONST, CSR_GO_DERIVE_TOT_CONST);

        report "REARM: run_arm #1 (standard start RUN_PREPARE -> SYNC)" severity note;
        run_arm(i_clk, asi_ctrl_data, asi_ctrl_valid);

        -- Confirm the FSM is parked in RESET (reset_flow=SYNC) before the re-arm.
        -- processor_state/run_state_cmd are exposed on the coe_debug_status_data
        -- conduit (DEBUG>=1), bits [15:12] and [19:16] respectively.
        wait until rising_edge(i_clk);
        status_v := coe_debug_status_data;
        report "REARM: pre-rearm status=0x" & to_hstring(status_v)
            & " processor_state=0x" & to_hstring(status_v(15 downto 12))
            & " run_state_cmd=0x" & to_hstring(status_v(19 downto 16)) severity note;
        assert status_v(15 downto 12) = PSTATE_RESET_CONST
            report "REARM: expected processor_state=RESET before re-arm" severity failure;

        -- *** SILICON TRIGGER: a 2nd run_arm (RUN_PREPARE) lands while already
        -- in RESET -- the host retry pattern that exposed BUG-021-R ***
        report "REARM: run_arm #2 (silicon retry: 2nd RUN_PREPARE while in RESET)" severity note;
        run_arm(i_clk, asi_ctrl_data, asi_ctrl_valid);
        send_ctrl(i_clk, asi_ctrl_data, asi_ctrl_valid, CTRL_RUNNING_CONST);
        for w in 1 to 8 loop wait until rising_edge(i_clk); end loop;

        wait until rising_edge(i_clk);
        status_v := coe_debug_status_data;
        pstate_v := status_v(15 downto 12);
        report "REARM: post-RUNNING status=0x" & to_hstring(status_v)
            & " processor_state=0x" & to_hstring(pstate_v)
            & " run_state_cmd=0x" & to_hstring(status_v(19 downto 16)) severity note;

        if pstate_v = PSTATE_RUNNING_CONST then
            report "REARM: processor_state reached RUNNING after re-arm sequence" severity note;
        else
            report "REARM: WEDGED - processor_state did NOT reach RUNNING (0x"
                & to_hstring(pstate_v) & "); FSM stuck in RESET" severity note;
        end if;
        assert pstate_v = PSTATE_RUNNING_CONST
            report "REARM FAIL: FSM did not reach RUNNING after a 2nd RUN_PREPARE in RESET (deadlock)"
            severity failure;

        -- Now push hits and confirm type1-extended bank 0 actually emits.
        for hit_i in 1 to 4 loop
            send_hit(i_clk, asi_hit_type0_ready, asi_hit_type0_channel, asi_hit_type0_data,
                     asi_hit_type0_valid, asi_hit_type0_error,
                     2, 1, 16#0003#, 16#000F#, '1',
                     coe_hit_type0_sidecar_data, coe_hit_type0_sidecar_valid,
                     x"0123456789ABCDEF");
        end loop;

        ext_seen_v := false;
        for wc in 0 to EXT_WAIT_CONST loop
            wait until rising_edge(i_clk);
            if aso_hit_type1_extended_0_valid = '1' then
                ext_seen_v := true;
                report "REARM: aso_hit_type1_extended_0_valid pulsed; ext_data(38:0)=0x"
                    & to_hstring(aso_hit_type1_extended_0_data(38 downto 0)) severity note;
                exit;
            end if;
        end loop;

        assert ext_seen_v
            report "REARM FAIL: no type1-extended hit emitted after re-arm + RUNNING"
            severity failure;

        report "mts_processor_rearm_tb PASSED" severity note;
        finish;
    end process tb_stim;

end architecture sim;
