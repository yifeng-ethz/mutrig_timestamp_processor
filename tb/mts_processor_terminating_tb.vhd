library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity mts_processor_terminating_tb is
end entity mts_processor_terminating_tb;

architecture sim of mts_processor_terminating_tb is

    constant CLK_PERIOD_CONST      : time := 8 ns;
    constant CTRL_IDLE_CONST       : std_logic_vector(8 downto 0) := "000000001";
    constant CTRL_RUN_PREP_CONST   : std_logic_vector(8 downto 0) := "000000010";
    constant CTRL_SYNC_CONST       : std_logic_vector(8 downto 0) := "000000100";
    constant CTRL_RUNNING_CONST    : std_logic_vector(8 downto 0) := "000001000";
    constant CTRL_TERMINATE_CONST  : std_logic_vector(8 downto 0) := "000010000";

    signal avs_csr_readdata            : std_logic_vector(31 downto 0);
    signal avs_csr_read                : std_logic := '0';
    signal avs_csr_address             : std_logic_vector(2 downto 0) := (others => '0');
    signal avs_csr_waitrequest         : std_logic;
    signal avs_csr_write               : std_logic := '0';
    signal avs_csr_writedata           : std_logic_vector(31 downto 0) := (others => '0');
    signal asi_hit_type0_channel       : std_logic_vector(5 downto 0) := (others => '0');
    signal asi_hit_type0_startofpacket : std_logic := '0';
    signal asi_hit_type0_endofpacket   : std_logic := '0';
    signal asi_hit_type0_error         : std_logic_vector(2 downto 0) := (others => '0');
    signal asi_hit_type0_data          : std_logic_vector(44 downto 0) := (others => '0');
    signal asi_hit_type0_valid         : std_logic := '0';
    signal asi_hit_type0_ready         : std_logic;
    signal aso_hit_type1_channel       : std_logic_vector(3 downto 0);
    signal aso_hit_type1_startofpacket : std_logic;
    signal aso_hit_type1_endofpacket   : std_logic;
    signal aso_hit_type1_data          : std_logic_vector(38 downto 0);
    signal aso_hit_type1_valid         : std_logic;
    signal aso_hit_type1_ready         : std_logic := '1';
    signal aso_hit_type1_empty         : std_logic;
    signal aso_hit_type1_error         : std_logic;
    signal asi_ctrl_data               : std_logic_vector(8 downto 0) := (others => '0');
    signal asi_ctrl_valid              : std_logic := '0';
    signal asi_ctrl_ready              : std_logic;
    signal aso_debug_ts_valid          : std_logic;
    signal aso_debug_ts_data           : std_logic_vector(15 downto 0);
    signal aso_debug_burst_valid       : std_logic;
    signal aso_debug_burst_data        : std_logic_vector(15 downto 0);
    signal aso_ts_delta_valid          : std_logic;
    signal aso_ts_delta_data           : std_logic_vector(15 downto 0);
    signal i_rst                       : std_logic := '1';
    signal i_clk                       : std_logic := '0';

    procedure wait_cycles(
        signal clk                     : in std_logic;
        constant cycles                : in natural
    ) is
    begin
        for idx in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    procedure send_ctrl_until_ready(
        signal clk                     : in  std_logic;
        signal ctrl_data               : out std_logic_vector(8 downto 0);
        signal ctrl_valid              : out std_logic;
        signal ctrl_ready              : in  std_logic;
        constant ctrl_word             : in  std_logic_vector(8 downto 0)
    ) is
    begin
        ctrl_data                      <= ctrl_word;
        ctrl_valid                     <= '1';
        loop
            wait until rising_edge(clk);
            exit when ctrl_ready = '1';
        end loop;
        ctrl_valid                     <= '0';
        ctrl_data                      <= (others => '0');
    end procedure send_ctrl_until_ready;

    procedure send_hit_beat(
        signal clk                     : in  std_logic;
        signal ready                   : in  std_logic;
        signal hit_channel             : out std_logic_vector(5 downto 0);
        signal hit_sop                 : out std_logic;
        signal hit_eop                 : out std_logic;
        signal hit_data                : out std_logic_vector(44 downto 0);
        signal hit_valid               : out std_logic;
        signal hit_error               : out std_logic_vector(2 downto 0);
        constant asic_value            : in  natural;
        constant channel_value         : in  natural;
        constant tcc_raw_value         : in  natural;
        constant ecc_raw_value         : in  natural;
        constant eflag_value           : in  std_logic;
        constant sop_value             : in  std_logic;
        constant eop_value             : in  std_logic
    ) is
        variable hit_word_v            : std_logic_vector(44 downto 0);
    begin
        while ready /= '1' loop
            wait until rising_edge(clk);
        end loop;

        hit_word_v                     := (others => '0');
        hit_word_v(44 downto 41)       := std_logic_vector(to_unsigned(asic_value, 4));
        hit_word_v(40 downto 36)       := std_logic_vector(to_unsigned(channel_value, 5));
        hit_word_v(35 downto 21)       := std_logic_vector(to_unsigned(tcc_raw_value, 15));
        hit_word_v(20 downto 16)       := (others => '0');
        hit_word_v(15 downto 1)        := std_logic_vector(to_unsigned(ecc_raw_value, 15));
        hit_word_v(0)                  := eflag_value;

        hit_channel                    <= "00" & std_logic_vector(to_unsigned(asic_value, 4));
        hit_sop                        <= sop_value;
        hit_eop                        <= eop_value;
        hit_data                       <= hit_word_v;
        hit_error                      <= (others => '0');
        hit_valid                      <= '1';
        wait until rising_edge(clk);
        hit_channel                    <= (others => '0');
        hit_sop                        <= '0';
        hit_eop                        <= '0';
        hit_data                       <= (others => '0');
        hit_error                      <= (others => '0');
        hit_valid                      <= '0';
    end procedure send_hit_beat;

    procedure send_synthetic_eop(
        signal clk                     : in  std_logic;
        signal ready                   : in  std_logic;
        signal hit_sop                 : out std_logic;
        signal hit_eop                 : out std_logic;
        signal hit_valid               : out std_logic
    ) is
    begin
        while ready /= '1' loop
            wait until rising_edge(clk);
        end loop;
        hit_sop                        <= '0';
        hit_eop                        <= '1';
        hit_valid                      <= '0';
        wait until rising_edge(clk);
        hit_sop                        <= '0';
        hit_eop                        <= '0';
        hit_valid                      <= '0';
    end procedure send_synthetic_eop;

begin

    i_clk <= not i_clk after CLK_PERIOD_CONST / 2;

    dut : entity work.mts_processor
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
            asi_hit_type0_error         => asi_hit_type0_error,
            asi_hit_type0_data          => asi_hit_type0_data,
            asi_hit_type0_valid         => asi_hit_type0_valid,
            asi_hit_type0_ready         => asi_hit_type0_ready,
            aso_hit_type1_channel       => aso_hit_type1_channel,
            aso_hit_type1_startofpacket => aso_hit_type1_startofpacket,
            aso_hit_type1_endofpacket   => aso_hit_type1_endofpacket,
            aso_hit_type1_data          => aso_hit_type1_data,
            aso_hit_type1_valid         => aso_hit_type1_valid,
            aso_hit_type1_ready         => aso_hit_type1_ready,
            aso_hit_type1_empty         => aso_hit_type1_empty,
            aso_hit_type1_error         => aso_hit_type1_error,
            asi_ctrl_data               => asi_ctrl_data,
            asi_ctrl_valid              => asi_ctrl_valid,
            asi_ctrl_ready              => asi_ctrl_ready,
            aso_debug_ts_valid          => aso_debug_ts_valid,
            aso_debug_ts_data           => aso_debug_ts_data,
            aso_debug_burst_valid       => aso_debug_burst_valid,
            aso_debug_burst_data        => aso_debug_burst_data,
            aso_ts_delta_valid          => aso_ts_delta_valid,
            aso_ts_delta_data           => aso_ts_delta_data,
            i_rst                       => i_rst,
            i_clk                       => i_clk
        );

    stim : process
        variable payload_seen_v           : boolean;
        variable payload_lane_v           : integer;
        variable close_mask_v             : std_logic_vector(3 downto 0);
        variable close_count_v            : natural;
        variable ready_seen_v             : boolean;
    begin
        wait_cycles(i_clk, 5);
        i_rst <= '0';
        wait_cycles(i_clk, 2);

        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_RUN_PREP_CONST);
        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_SYNC_CONST);
        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_RUNNING_CONST);

        asi_ctrl_data  <= CTRL_TERMINATE_CONST;
        asi_ctrl_valid <= '1';
        wait until rising_edge(i_clk);

        send_hit_beat(
            clk           => i_clk,
            ready         => asi_hit_type0_ready,
            hit_channel   => asi_hit_type0_channel,
            hit_sop       => asi_hit_type0_startofpacket,
            hit_eop       => asi_hit_type0_endofpacket,
            hit_data      => asi_hit_type0_data,
            hit_valid     => asi_hit_type0_valid,
            hit_error     => asi_hit_type0_error,
            asic_value    => 2,
            channel_value => 1,
            tcc_raw_value => 16#0003#,
            ecc_raw_value => 16#000F#,
            eflag_value   => '1',
            sop_value     => '1',
            eop_value     => '1'
        );

        payload_seen_v := false;
        payload_lane_v := -1;
        close_mask_v   := (others => '0');
        close_count_v  := 0;
        ready_seen_v   := false;
        for wait_idx in 0 to 128 loop
            wait until rising_edge(i_clk);
            if aso_hit_type1_valid = '1' then
                if aso_hit_type1_empty = '0' then
                    payload_seen_v := true;
                    payload_lane_v := to_integer(unsigned(aso_hit_type1_channel(1 downto 0)));
                    assert aso_hit_type1_endofpacket = '0'
                        report "Active terminate must close via dedicated empty markers, not on the payload beat"
                        severity failure;
                elsif aso_hit_type1_endofpacket = '1' then
                    close_mask_v(to_integer(unsigned(aso_hit_type1_channel(1 downto 0)))) := '1';
                    close_count_v := close_count_v + 1;
                    if (payload_lane_v = to_integer(unsigned(aso_hit_type1_channel(1 downto 0)))) then
                        assert aso_hit_type1_startofpacket = '0'
                            report "The payload lane close marker must not reassert SOP"
                            severity failure;
                    else
                        assert aso_hit_type1_startofpacket = '1'
                            report "Idle lanes must close with SOP+EOP on the empty marker"
                            severity failure;
                    end if;
                end if;
            end if;
            if asi_ctrl_ready = '1' and close_count_v = 4 then
                ready_seen_v := true;
            end if;
            exit when payload_seen_v and close_count_v = 4 and ready_seen_v;
        end loop;
        assert payload_seen_v
            report "Expected one payload beat before the terminate close-marker train"
            severity failure;
        assert close_mask_v = "1111"
            report "Expected one lane-targeted empty close marker for each downstream lane"
            severity failure;
        assert ready_seen_v
            report "Expected TERMINATING acknowledge only after all lane close markers were emitted"
            severity failure;
        asi_ctrl_valid <= '0';
        asi_ctrl_data  <= (others => '0');

        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_IDLE_CONST);
        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_RUN_PREP_CONST);
        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_SYNC_CONST);
        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_RUNNING_CONST);

        asi_ctrl_data  <= CTRL_TERMINATE_CONST;
        asi_ctrl_valid <= '1';

        close_mask_v   := (others => '0');
        close_count_v  := 0;
        ready_seen_v   := false;
        for wait_idx in 0 to 128 loop
            wait until rising_edge(i_clk);
            if aso_hit_type1_valid = '1' and aso_hit_type1_endofpacket = '1' then
                assert aso_hit_type1_empty = '1'
                    report "Idle-close termination must emit empty close markers"
                    severity failure;
                assert aso_hit_type1_startofpacket = '1'
                    report "An idle lane close marker must carry SOP as well as EOP"
                    severity failure;
                close_mask_v(to_integer(unsigned(aso_hit_type1_channel(1 downto 0)))) := '1';
                close_count_v := close_count_v + 1;
            end if;
            if asi_ctrl_ready = '1' and close_count_v = 4 then
                ready_seen_v := true;
            end if;
            exit when close_count_v = 4 and ready_seen_v;
        end loop;
        assert close_mask_v = "1111"
            report "Expected four empty close markers for an idle terminate"
            severity failure;
        assert ready_seen_v
            report "Expected TERMINATING acknowledge after the idle close-marker train"
            severity failure;
        asi_ctrl_valid <= '0';
        asi_ctrl_data  <= (others => '0');

        send_ctrl_until_ready(i_clk, asi_ctrl_data, asi_ctrl_valid, asi_ctrl_ready, CTRL_IDLE_CONST);
        report "mts_processor_terminating_tb PASSED" severity note;
        finish;
    end process stim;

end architecture sim;
