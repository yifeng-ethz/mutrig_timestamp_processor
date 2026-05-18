library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity mts_processor_tb is
end entity mts_processor_tb;

architecture sim of mts_processor_tb is

    constant CLK_PERIOD_CONST       : time := 8 ns;
    constant CTRL_IDLE_CONST        : std_logic_vector(8 downto 0) := "000000001";
    constant CTRL_RUNNING_CONST     : std_logic_vector(8 downto 0) := "000001000";
    constant CSR_CONTROL_ADDR_CONST : natural := 0;
    constant CSR_DISCARD_ADDR_CONST : natural := 1;
    constant CSR_TOTAL_HI_ADDR_CONST: natural := 3;
    constant CSR_TOTAL_LO_ADDR_CONST: natural := 4;
    constant CSR_GO_DERIVE_TOT_CONST: std_logic_vector(31 downto 0) := x"40000001";
    constant ET_FIELD_HI_CONST      : natural := 8;
    constant ET_FIELD_LO_CONST      : natural := 0;
    constant PIPELINE_WAIT_CONST    : natural := 24;

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

    procedure expect_et(
        signal clk                  : in  std_logic;
        signal hit_valid            : in  std_logic;
        signal hit_data             : in  std_logic_vector(38 downto 0);
        signal ext_valid            : in  std_logic;
        signal ext_data             : in  std_logic_vector(86 downto 0);
        signal sidecar_valid        : in  std_logic;
        signal sidecar_data         : in  std_logic_vector(63 downto 0);
        constant expected_et        : in  natural;
        constant expected_sidecar   : in  std_logic_vector(63 downto 0)
    ) is
    begin
        for wait_cycle in 0 to PIPELINE_WAIT_CONST loop
            wait until rising_edge(clk);
            if hit_valid = '1' then
                assert unsigned(hit_data(ET_FIELD_HI_CONST downto ET_FIELD_LO_CONST)) = to_unsigned(expected_et, ET_FIELD_HI_CONST - ET_FIELD_LO_CONST + 1)
                    report "Unexpected ET_1n6 value exp=0x"
                        & to_hstring(std_logic_vector(to_unsigned(expected_et, ET_FIELD_HI_CONST - ET_FIELD_LO_CONST + 1)))
                        & " got=0x"
                        & to_hstring(hit_data(ET_FIELD_HI_CONST downto ET_FIELD_LO_CONST))
                        severity failure;
                assert ext_valid = '1'
                    report "Expected extended debug-plane valid with the hit_type1 payload"
                    severity failure;
                assert ext_data(38 downto 0) = hit_data
                    report "Extended debug-plane payload does not match hit_type1 data exp=0x"
                        & to_hstring(hit_data)
                        & " got=0x"
                        & to_hstring(ext_data(38 downto 0))
                        severity failure;
                assert aso_hit_type1_extended_1_valid = '0'
                    report "Default UP-bank testbench unexpectedly drove extended bank 1"
                    severity failure;
                assert sidecar_valid = '1'
                    report "Expected DEBUG sidecar valid with the hit_type1 payload"
                    severity failure;
                assert sidecar_data = expected_sidecar
                    report "Unexpected DEBUG sidecar metadata exp=0x"
                        & to_hstring(expected_sidecar)
                        & " got=0x"
                        & to_hstring(sidecar_data)
                        severity failure;
                return;
            end if;
        end loop;

        assert false report "Timed out waiting for processed hit" severity failure;
    end procedure expect_et;

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
        variable discard_before_v   : std_logic_vector(31 downto 0);
        variable discard_after_v    : std_logic_vector(31 downto 0);
        variable total_hi_before_v  : std_logic_vector(31 downto 0);
        variable total_hi_after_v   : std_logic_vector(31 downto 0);
        variable total_lo_before_v  : std_logic_vector(31 downto 0);
        variable total_lo_after_v   : std_logic_vector(31 downto 0);
    begin
        wait for 5 * CLK_PERIOD_CONST;
        wait until rising_edge(i_clk);
        i_rst                       <= '0';

        csr_write(
            clk                     => i_clk,
            addr                    => avs_csr_address,
            write                   => avs_csr_write,
            writedata               => avs_csr_writedata,
            addr_value              => CSR_CONTROL_ADDR_CONST,
            data_value              => CSR_GO_DERIVE_TOT_CONST
        );

        send_ctrl(
            clk                     => i_clk,
            ctrl_data               => asi_ctrl_data,
            ctrl_valid              => asi_ctrl_valid,
            ctrl_word               => CTRL_RUNNING_CONST
        );

        send_hit(
            clk                     => i_clk,
            ready                   => asi_hit_type0_ready,
            hit_channel             => asi_hit_type0_channel,
            hit_data                => asi_hit_type0_data,
            hit_valid               => asi_hit_type0_valid,
            hit_error               => asi_hit_type0_error,
            asic_value              => 2,
            channel_value           => 1,
            tcc_raw_value           => 16#0003#,
            ecc_raw_value           => 16#000F#,
            eflag_value             => '1',
            sidecar_data            => coe_hit_type0_sidecar_data,
            sidecar_valid           => coe_hit_type0_sidecar_valid,
            sidecar_value           => x"0123456789ABCDEF"
        );
        expect_et(
            clk                     => i_clk,
            hit_valid               => aso_hit_type1_valid,
            hit_data                => aso_hit_type1_data,
            ext_valid               => aso_hit_type1_extended_0_valid,
            ext_data                => aso_hit_type1_extended_0_data,
            sidecar_valid           => coe_hit_type1_sidecar_valid,
            sidecar_data            => coe_hit_type1_sidecar_data,
            expected_et             => 2,
            expected_sidecar        => x"0123456789ABCDEF"
        );

        send_hit(
            clk                     => i_clk,
            ready                   => asi_hit_type0_ready,
            hit_channel             => asi_hit_type0_channel,
            hit_data                => asi_hit_type0_data,
            hit_valid               => asi_hit_type0_valid,
            hit_error               => asi_hit_type0_error,
            asic_value              => 2,
            channel_value           => 1,
            tcc_raw_value           => 16#0003#,
            ecc_raw_value           => 16#000F#,
            eflag_value             => '0',
            sidecar_data            => coe_hit_type0_sidecar_data,
            sidecar_valid           => coe_hit_type0_sidecar_valid,
            sidecar_value           => x"1020304050607080"
        );
        expect_et(
            clk                     => i_clk,
            hit_valid               => aso_hit_type1_valid,
            hit_data                => aso_hit_type1_data,
            ext_valid               => aso_hit_type1_extended_0_valid,
            ext_data                => aso_hit_type1_extended_0_data,
            sidecar_valid           => coe_hit_type1_sidecar_valid,
            sidecar_data            => coe_hit_type1_sidecar_data,
            expected_et             => 0,
            expected_sidecar        => x"1020304050607080"
        );

        send_hit(
            clk                     => i_clk,
            ready                   => asi_hit_type0_ready,
            hit_channel             => asi_hit_type0_channel,
            hit_data                => asi_hit_type0_data,
            hit_valid               => asi_hit_type0_valid,
            hit_error               => asi_hit_type0_error,
            asic_value              => 2,
            channel_value           => 1,
            tcc_raw_value           => 16#000F#,
            ecc_raw_value           => 16#0003#,
            eflag_value             => '1',
            sidecar_data            => coe_hit_type0_sidecar_data,
            sidecar_valid           => coe_hit_type0_sidecar_valid,
            sidecar_value           => x"DEADBEEFCAFEBABE"
        );
        expect_et(
            clk                     => i_clk,
            hit_valid               => aso_hit_type1_valid,
            hit_data                => aso_hit_type1_data,
            ext_valid               => aso_hit_type1_extended_0_valid,
            ext_data                => aso_hit_type1_extended_0_data,
            sidecar_valid           => coe_hit_type1_sidecar_valid,
            sidecar_data            => coe_hit_type1_sidecar_data,
            expected_et             => 0,
            expected_sidecar        => x"DEADBEEFCAFEBABE"
        );

        send_hit(
            clk                     => i_clk,
            ready                   => asi_hit_type0_ready,
            hit_channel             => asi_hit_type0_channel,
            hit_data                => asi_hit_type0_data,
            hit_valid               => asi_hit_type0_valid,
            hit_error               => asi_hit_type0_error,
            asic_value              => 2,
            channel_value           => 1,
            tcc_raw_value           => 16#0001#,
            ecc_raw_value           => 16#0000#,
            eflag_value             => '1',
            sidecar_data            => coe_hit_type0_sidecar_data,
            sidecar_valid           => coe_hit_type0_sidecar_valid,
            sidecar_value           => x"0F0E0D0C0B0A0908"
        );
        expect_et(
            clk                     => i_clk,
            hit_valid               => aso_hit_type1_valid,
            hit_data                => aso_hit_type1_data,
            ext_valid               => aso_hit_type1_extended_0_valid,
            ext_data                => aso_hit_type1_extended_0_data,
            sidecar_valid           => coe_hit_type1_sidecar_valid,
            sidecar_data            => coe_hit_type1_sidecar_data,
            expected_et             => 511,
            expected_sidecar        => x"0F0E0D0C0B0A0908"
        );

        send_ctrl(
            clk                     => i_clk,
            ctrl_data               => asi_ctrl_data,
            ctrl_valid              => asi_ctrl_valid,
            ctrl_word               => CTRL_IDLE_CONST
        );
        for wait_cycle in 1 to 8 loop
            wait until rising_edge(i_clk);
        end loop;
        assert asi_hit_type0_ready = '0'
            report "hit_type0 ready should be low while MTS is idle"
            severity failure;

        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_DISCARD_ADDR_CONST, discard_before_v);
        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_TOTAL_HI_ADDR_CONST, total_hi_before_v);
        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_TOTAL_LO_ADDR_CONST, total_lo_before_v);

        asi_hit_type0_channel       <= "000010";
        asi_hit_type0_startofpacket <= '1';
        asi_hit_type0_endofpacket   <= '1';
        asi_hit_type0_error         <= "001";
        asi_hit_type0_data          <= (others => '0');
        asi_hit_type0_valid         <= '1';
        for wait_cycle in 1 to 32 loop
            wait until rising_edge(i_clk);
            assert asi_hit_type0_ready = '0'
                report "MTS accepted a held idle hit_type0 beat"
                severity failure;
        end loop;

        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_DISCARD_ADDR_CONST, discard_after_v);
        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_TOTAL_HI_ADDR_CONST, total_hi_after_v);
        csr_read(i_clk, avs_csr_address, avs_csr_read, avs_csr_readdata, CSR_TOTAL_LO_ADDR_CONST, total_lo_after_v);
        assert discard_after_v = discard_before_v
            report "Discard counter advanced while hit_type0_valid was held with ready low in IDLE"
            severity failure;
        assert total_hi_after_v = total_hi_before_v and total_lo_after_v = total_lo_before_v
            report "Total counter advanced while hit_type0_valid was held with ready low in IDLE"
            severity failure;
        asi_hit_type0_valid         <= '0';
        asi_hit_type0_startofpacket <= '0';
        asi_hit_type0_endofpacket   <= '0';
        asi_hit_type0_error         <= (others => '0');
        asi_hit_type0_channel       <= (others => '0');

        report "mts_processor_tb PASSED" severity note;
        finish;
    end process tb_stim;

end architecture sim;
