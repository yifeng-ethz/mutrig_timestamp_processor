library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

-- File name: mts_processor_external_epoch_tb.vhd
-- Author   : Yifeng Wang (yifenwan@phys.ethz.ch)
-- Version : 26.6.0
-- Date    : 20260716
-- Change  : Directed comparison of legacy and external timestamp epoch reset.

entity mts_processor_external_epoch_tb is
end entity mts_processor_external_epoch_tb;

architecture sim of mts_processor_external_epoch_tb is

    constant CLK_PERIOD_CONST           : time                             := 8 ns;
    constant CTRL_PREPARE_CONST         : std_logic_vector(8 downto 0)     := "000000010";
    constant CTRL_SYNC_CONST            : std_logic_vector(8 downto 0)     := "000000100";
    constant CTRL_RUNNING_CONST         : std_logic_vector(8 downto 0)     := "000001000";
    constant CSR_CONTROL_ADDR_CONST     : natural                          := 0;
    constant CSR_GO_DERIVE_TOT_CONST    : std_logic_vector(31 downto 0)    := x"40000001";
    constant CSR_SOFT_RESET_CONST       : std_logic_vector(31 downto 0)    := x"40000005";
    constant OUTPUT_WAIT_CONST          : natural                          := 80;

    signal avs_csr_read                    : std_logic                        := '0';
    signal avs_csr_address                 : std_logic_vector(2 downto 0)     := (others    => '0');
    signal avs_csr_write                   : std_logic                        := '0';
    signal avs_csr_writedata               : std_logic_vector(31 downto 0)    := (others    => '0');
    signal asi_hit_type0_channel           : std_logic_vector(5 downto 0)     := (others    => '0');
    signal asi_hit_type0_startofpacket     : std_logic                        := '0';
    signal asi_hit_type0_endofpacket       : std_logic                        := '0';
    signal asi_hit_type0_endofrun          : std_logic                        := '0';
    signal asi_hit_type0_error             : std_logic_vector(2 downto 0)     := (others    => '0');
    signal asi_hit_type0_data              : std_logic_vector(44 downto 0)    := (others    => '0');
    signal asi_hit_type0_valid             : std_logic                        := '0';
    signal asi_hit_type0_ready_legacy      : std_logic;
    signal asi_hit_type0_ready_external    : std_logic;
    signal asi_ctrl_data                   : std_logic_vector(8 downto 0)    := (others    => '0');
    signal asi_ctrl_valid                  : std_logic                       := '0';
    signal hit_type1_valid_legacy          : std_logic;
    signal hit_type1_valid_external        : std_logic;
    signal arrival_gts_legacy              : std_logic_vector(47 downto 0);
    signal arrival_gts_external            : std_logic_vector(47 downto 0);
    signal coe_epoch_reset                 : std_logic    := '1';
    signal i_rst                           : std_logic    := '1';
    signal i_clk                           : std_logic    := '0';

    procedure csr_write(
        signal clk             : in  std_logic;
        signal address         : out std_logic_vector(2 downto 0);
        signal write           : out std_logic;
        signal writedata       : out std_logic_vector(31 downto 0);
        constant addr_value    : in  natural;
        constant data_value    : in  std_logic_vector(31 downto 0)
    ) is
    begin
        address      <= std_logic_vector(to_unsigned(addr_value, address'length));
        writedata    <= data_value;
        write        <= '1';
        wait until rising_edge(clk);
        write        <= '0';
        address      <= (others    => '0');
        writedata    <= (others    => '0');
    end procedure csr_write;

    procedure send_ctrl(
        signal clk            : in  std_logic;
        signal ctrl_data      : out std_logic_vector(8 downto 0);
        signal ctrl_valid     : out std_logic;
        constant ctrl_word    : in  std_logic_vector(8 downto 0)
    ) is
    begin
        ctrl_data     <= ctrl_word;
        ctrl_valid    <= '1';
        wait until rising_edge(clk);
        ctrl_valid    <= '0';
        ctrl_data     <= (others    => '0');
    end procedure send_ctrl;

    procedure send_hit(
        signal clk               : in  std_logic;
        signal ready_legacy      : in  std_logic;
        signal ready_external    : in  std_logic;
        signal hit_channel       : out std_logic_vector(5 downto 0);
        signal hit_data          : out std_logic_vector(44 downto 0);
        signal hit_error         : out std_logic_vector(2 downto 0);
        signal hit_valid         : out std_logic
    ) is
        variable hit_word_v    : std_logic_vector(44 downto 0);
        variable ready_v       : boolean;
    begin
        ready_v := false;
        for wait_cycle in 0 to 32 loop
            if ready_legacy = '1' and ready_external = '1' then
                ready_v := true;
                exit;
            end if;
            wait until rising_edge(clk);
        end loop;
        assert ready_v
            report "Timed out waiting for both MTS instances to accept hits"
            severity failure;

        hit_word_v                  := (others    => '0');
        hit_word_v(44 downto 41)    := std_logic_vector(to_unsigned(0, 4));
        hit_word_v(40 downto 36)    := std_logic_vector(to_unsigned(1, 5));
        hit_word_v(35 downto 21)    := std_logic_vector(to_unsigned(3, 15));
        hit_word_v(15 downto 1)     := std_logic_vector(to_unsigned(15, 15));
        hit_word_v(0)               := '1';

        hit_channel    <= (others    => '0');
        hit_data       <= hit_word_v;
        hit_error      <= (others    => '0');
        hit_valid      <= '1';
        wait until rising_edge(clk);
        hit_valid    <= '0';
        hit_data     <= (others    => '0');
    end procedure send_hit;

    procedure expect_arrival_pair(
        signal clk                    : in  std_logic;
        signal valid_legacy           : in  std_logic;
        signal valid_external         : in  std_logic;
        signal arrival_legacy         : in  std_logic_vector(47 downto 0);
        signal arrival_external       : in  std_logic_vector(47 downto 0);
        variable observed_legacy      : out std_logic_vector(47 downto 0);
        variable observed_external    : out std_logic_vector(47 downto 0)
    ) is
    begin
        for wait_cycle in 0 to OUTPUT_WAIT_CONST loop
            wait until rising_edge(clk);
            wait for 1 ns;
            assert valid_legacy = valid_external
                report "Legacy and external-reset instances lost cycle alignment"
                severity failure;
            if valid_legacy = '1' then
                observed_legacy      := arrival_legacy;
                observed_external    := arrival_external;
                return;
            end if;
        end loop;

        assert false report "Timed out waiting for paired Type1 outputs" severity failure;
    end procedure expect_arrival_pair;

begin

    i_clk <= not i_clk after CLK_PERIOD_CONST / 2;

    legacy_dut : entity work.mts_processor
        generic map (
            DEBUG                       => 0,
            USE_EXTERNAL_EPOCH_RESET    => false
        )
        port map (
            avs_csr_readdata                  => open,
            avs_csr_read                      => avs_csr_read,
            avs_csr_address                   => avs_csr_address,
            avs_csr_waitrequest               => open,
            avs_csr_write                     => avs_csr_write,
            avs_csr_writedata                 => avs_csr_writedata,
            asi_hit_type0_channel             => asi_hit_type0_channel,
            asi_hit_type0_startofpacket       => asi_hit_type0_startofpacket,
            asi_hit_type0_endofpacket         => asi_hit_type0_endofpacket,
            asi_hit_type0_endofrun            => asi_hit_type0_endofrun,
            asi_hit_type0_error               => asi_hit_type0_error,
            asi_hit_type0_data                => asi_hit_type0_data,
            asi_hit_type0_valid               => asi_hit_type0_valid,
            asi_hit_type0_ready               => asi_hit_type0_ready_legacy,
            coe_hit_type0_sidecar_data        => (others => '0'),
            coe_hit_type0_sidecar_valid       => '0',
            aso_hit_type1_channel             => open,
            aso_hit_type1_startofpacket       => open,
            aso_hit_type1_endofpacket         => open,
            aso_hit_type1_data                => open,
            aso_hit_type1_valid               => hit_type1_valid_legacy,
            aso_hit_type1_ready               => '1',
            aso_hit_type1_empty               => open,
            aso_hit_type1_error               => open,
            aso_hit_type1_extended_0_data     => open,
            aso_hit_type1_extended_0_valid    => open,
            aso_hit_type1_extended_1_data     => open,
            aso_hit_type1_extended_1_valid    => open,
            coe_hit_type1_ts                  => open,
            coe_hit_arrival_gts_8n            => arrival_gts_legacy,
            coe_hit_type1_latency_8n          => open,
            asi_ctrl_data                     => asi_ctrl_data,
            asi_ctrl_valid                    => asi_ctrl_valid,
            aso_debug_ts_valid                => open,
            aso_debug_ts_data                 => open,
            aso_debug_burst_valid             => open,
            aso_debug_burst_data              => open,
            aso_ts_delta_valid                => open,
            aso_ts_delta_data                 => open,
            coe_debug_status_data             => open,
            coe_hit_type1_sidecar_data        => open,
            coe_hit_type1_sidecar_valid       => open,
            i_rst                             => i_rst,
            i_clk                             => i_clk,
            coe_epoch_reset                   => coe_epoch_reset
        );

    external_dut : entity work.mts_processor
        generic map (
            DEBUG                       => 0,
            USE_EXTERNAL_EPOCH_RESET    => true
        )
        port map (
            avs_csr_readdata                  => open,
            avs_csr_read                      => avs_csr_read,
            avs_csr_address                   => avs_csr_address,
            avs_csr_waitrequest               => open,
            avs_csr_write                     => avs_csr_write,
            avs_csr_writedata                 => avs_csr_writedata,
            asi_hit_type0_channel             => asi_hit_type0_channel,
            asi_hit_type0_startofpacket       => asi_hit_type0_startofpacket,
            asi_hit_type0_endofpacket         => asi_hit_type0_endofpacket,
            asi_hit_type0_endofrun            => asi_hit_type0_endofrun,
            asi_hit_type0_error               => asi_hit_type0_error,
            asi_hit_type0_data                => asi_hit_type0_data,
            asi_hit_type0_valid               => asi_hit_type0_valid,
            asi_hit_type0_ready               => asi_hit_type0_ready_external,
            coe_hit_type0_sidecar_data        => (others => '0'),
            coe_hit_type0_sidecar_valid       => '0',
            aso_hit_type1_channel             => open,
            aso_hit_type1_startofpacket       => open,
            aso_hit_type1_endofpacket         => open,
            aso_hit_type1_data                => open,
            aso_hit_type1_valid               => hit_type1_valid_external,
            aso_hit_type1_ready               => '1',
            aso_hit_type1_empty               => open,
            aso_hit_type1_error               => open,
            aso_hit_type1_extended_0_data     => open,
            aso_hit_type1_extended_0_valid    => open,
            aso_hit_type1_extended_1_data     => open,
            aso_hit_type1_extended_1_valid    => open,
            coe_hit_type1_ts                  => open,
            coe_hit_arrival_gts_8n            => arrival_gts_external,
            coe_hit_type1_latency_8n          => open,
            asi_ctrl_data                     => asi_ctrl_data,
            asi_ctrl_valid                    => asi_ctrl_valid,
            aso_debug_ts_valid                => open,
            aso_debug_ts_data                 => open,
            aso_debug_burst_valid             => open,
            aso_debug_burst_data              => open,
            aso_ts_delta_valid                => open,
            aso_ts_delta_data                 => open,
            coe_debug_status_data             => open,
            coe_hit_type1_sidecar_data        => open,
            coe_hit_type1_sidecar_valid       => open,
            i_rst                             => i_rst,
            i_clk                             => i_clk,
            coe_epoch_reset                   => coe_epoch_reset
        );

    tb_stim : process
        variable legacy_arrival_v   : std_logic_vector(47 downto 0);
        variable external_arrival_v : std_logic_vector(47 downto 0);
        variable delta_v            : unsigned(47 downto 0);
    begin
        wait for 5 * CLK_PERIOD_CONST;
        wait until rising_edge(i_clk);
        i_rst <= '0';

        csr_write(i_clk, avs_csr_address, avs_csr_write, avs_csr_writedata,
                  CSR_CONTROL_ADDR_CONST, CSR_GO_DERIVE_TOT_CONST);
        send_ctrl(i_clk, asi_ctrl_data, asi_ctrl_valid, CTRL_PREPARE_CONST);
        for wait_cycle in 1 to 4 loop wait until rising_edge(i_clk); end loop;
        send_ctrl(i_clk, asi_ctrl_data, asi_ctrl_valid, CTRL_SYNC_CONST);
        for wait_cycle in 1 to 4 loop wait until rising_edge(i_clk); end loop;

        -- The external instance starts its epoch immediately at this release;
        -- the default instance must remain held by local RESET/SYNC.
        coe_epoch_reset <= '0';
        for wait_cycle in 1 to 12 loop wait until rising_edge(i_clk); end loop;
        send_ctrl(i_clk, asi_ctrl_data, asi_ctrl_valid, CTRL_RUNNING_CONST);
        for wait_cycle in 1 to 8 loop wait until rising_edge(i_clk); end loop;

        send_hit(i_clk, asi_hit_type0_ready_legacy, asi_hit_type0_ready_external,
                 asi_hit_type0_channel, asi_hit_type0_data,
                 asi_hit_type0_error, asi_hit_type0_valid);
        expect_arrival_pair(i_clk, hit_type1_valid_legacy, hit_type1_valid_external,
                            arrival_gts_legacy, arrival_gts_external,
                            legacy_arrival_v, external_arrival_v);
        assert unsigned(external_arrival_v) > unsigned(legacy_arrival_v)
            report "External epoch release did not advance independently of legacy RESET/SYNC"
            severity failure;
        delta_v := unsigned(external_arrival_v) - unsigned(legacy_arrival_v);
        assert delta_v(47 downto 31) = to_unsigned(0, 17)
            report "External epoch early-release delta exceeded the directed-test report range"
            severity failure;
        report "EXTERNAL_EPOCH: early-release delta=" &
               integer'image(to_integer(delta_v(30 downto 0)))
            severity note;

        -- In RUNNING, the external input must reset only the opted-in instance.
        coe_epoch_reset <= '1';
        for wait_cycle in 1 to 3 loop wait until rising_edge(i_clk); end loop;
        coe_epoch_reset <= '0';
        for wait_cycle in 1 to 4 loop wait until rising_edge(i_clk); end loop;
        send_hit(i_clk, asi_hit_type0_ready_legacy, asi_hit_type0_ready_external,
                 asi_hit_type0_channel, asi_hit_type0_data,
                 asi_hit_type0_error, asi_hit_type0_valid);
        expect_arrival_pair(i_clk, hit_type1_valid_legacy, hit_type1_valid_external,
                            arrival_gts_legacy, arrival_gts_external,
                            legacy_arrival_v, external_arrival_v);
        assert unsigned(external_arrival_v) < unsigned(legacy_arrival_v)
            report "External epoch reset was not honored while RUNNING, or leaked into legacy mode"
            severity failure;

        -- CSR soft reset remains common to both elaborated modes and must bring
        -- their epoch counters back into exact cycle alignment.
        csr_write(i_clk, avs_csr_address, avs_csr_write, avs_csr_writedata,
                  CSR_CONTROL_ADDR_CONST, CSR_SOFT_RESET_CONST);
        for wait_cycle in 1 to 5 loop wait until rising_edge(i_clk); end loop;
        send_hit(i_clk, asi_hit_type0_ready_legacy, asi_hit_type0_ready_external,
                 asi_hit_type0_channel, asi_hit_type0_data,
                 asi_hit_type0_error, asi_hit_type0_valid);
        expect_arrival_pair(i_clk, hit_type1_valid_legacy, hit_type1_valid_external,
                            arrival_gts_legacy, arrival_gts_external,
                            legacy_arrival_v, external_arrival_v);
        assert external_arrival_v = legacy_arrival_v
            report "CSR soft reset did not align legacy and external epoch modes"
            severity failure;

        report "mts_processor_external_epoch_tb PASSED" severity note;
        finish;
    end process tb_stim;

end architecture sim;
