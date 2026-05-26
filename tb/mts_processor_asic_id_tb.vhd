library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

-- BUG-022-R directed check:
-- The readyless mux puts its selected input slot in hit_type0_channel[5:4].
-- MTS must use that slot, plus BANK, as the global ASIC ID in Type1[38:35].
-- The continuous-stream case rotates mux slots and payload-channel low nibbles
-- independently so record-field leakage cannot satisfy the checker.
entity mts_processor_asic_id_tb is
    generic (
        DUT_BANK    : string  := "UP";
        ASIC_OFFSET : natural := 0
    );
end entity mts_processor_asic_id_tb;

architecture sim of mts_processor_asic_id_tb is

    constant CLK_PERIOD_CONST       : time := 8 ns;
    constant CTRL_RUNNING_CONST     : std_logic_vector(8 downto 0) := "000001000";
    constant CSR_CONTROL_ADDR_CONST : natural := 0;
    constant CSR_GO_DERIVE_TOT_CONST: std_logic_vector(31 downto 0) := x"40000001";
    constant ASIC_FIELD_HI_CONST    : natural := 38;
    constant ASIC_FIELD_LO_CONST    : natural := 35;
    constant PIPELINE_WAIT_CONST    : natural := 40;
    constant DOWN_BANK_CONST        : boolean := (DUT_BANK = "DW" or DUT_BANK = "DOWN");

    signal avs_csr_readdata            : std_logic_vector(31 downto 0);
    signal avs_csr_read                : std_logic := '0';
    signal avs_csr_address             : std_logic_vector(2 downto 0) := (others => '0');
    signal avs_csr_waitrequest         : std_logic;
    signal avs_csr_write               : std_logic := '0';
    signal avs_csr_writedata           : std_logic_vector(31 downto 0) := (others => '0');
    signal asi_hit_type0_channel       : std_logic_vector(5 downto 0) := (others => '0');
    signal asi_hit_type0_startofpacket : std_logic := '0';
    signal asi_hit_type0_endofpacket   : std_logic := '0';
    signal asi_hit_type0_endofrun      : std_logic := '0';
    signal asi_hit_type0_error         : std_logic_vector(2 downto 0) := (others => '0');
    signal asi_hit_type0_data          : std_logic_vector(44 downto 0) := (others => '0');
    signal asi_hit_type0_valid         : std_logic := '0';
    signal asi_hit_type0_ready         : std_logic;
    signal coe_hit_type0_sidecar_data  : std_logic_vector(63 downto 0) := (others => '0');
    signal coe_hit_type0_sidecar_valid : std_logic := '0';
    signal aso_hit_type1_channel       : std_logic_vector(3 downto 0);
    signal aso_hit_type1_startofpacket : std_logic;
    signal aso_hit_type1_endofpacket   : std_logic;
    signal aso_hit_type1_data          : std_logic_vector(38 downto 0);
    signal aso_hit_type1_valid         : std_logic;
    signal aso_hit_type1_ready         : std_logic := '1';
    signal aso_hit_type1_empty         : std_logic;
    signal aso_hit_type1_error         : std_logic;
    signal aso_hit_type1_extended_0_data  : std_logic_vector(86 downto 0);
    signal aso_hit_type1_extended_0_valid : std_logic;
    signal aso_hit_type1_extended_1_data  : std_logic_vector(86 downto 0);
    signal aso_hit_type1_extended_1_valid : std_logic;
    signal coe_hit_type1_ts              : std_logic_vector(47 downto 0);
    signal asi_ctrl_data               : std_logic_vector(8 downto 0) := (others => '0');
    signal asi_ctrl_valid              : std_logic := '0';
    signal aso_debug_ts_valid          : std_logic;
    signal aso_debug_ts_data           : std_logic_vector(15 downto 0);
    signal aso_debug_burst_valid       : std_logic;
    signal aso_debug_burst_data        : std_logic_vector(15 downto 0);
    signal aso_ts_delta_valid          : std_logic;
    signal aso_ts_delta_data           : std_logic_vector(15 downto 0);
    signal coe_debug_status_data       : std_logic_vector(31 downto 0);
    signal coe_hit_type1_sidecar_data  : std_logic_vector(63 downto 0);
    signal coe_hit_type1_sidecar_valid : std_logic;
    signal i_rst                       : std_logic := '1';
    signal i_clk                       : std_logic := '0';

    procedure wait_cycles(
        signal clk      : in std_logic;
        constant cycles : in natural
    ) is
    begin
        for idx in 1 to cycles loop
            wait until rising_edge(clk);
        end loop;
    end procedure wait_cycles;

    procedure csr_write(
        signal clk       : in  std_logic;
        signal addr      : out std_logic_vector(2 downto 0);
        signal write     : out std_logic;
        signal writedata : out std_logic_vector(31 downto 0);
        constant addr_value : in natural;
        constant data_value : in std_logic_vector(31 downto 0)
    ) is
    begin
        addr      <= std_logic_vector(to_unsigned(addr_value, addr'length));
        writedata <= data_value;
        write     <= '1';
        wait until rising_edge(clk);
        write     <= '0';
        addr      <= (others => '0');
        writedata <= (others => '0');
    end procedure csr_write;

    procedure send_ctrl(
        signal clk        : in  std_logic;
        signal ctrl_data  : out std_logic_vector(8 downto 0);
        signal ctrl_valid : out std_logic;
        constant ctrl_word : in std_logic_vector(8 downto 0)
    ) is
    begin
        ctrl_data  <= ctrl_word;
        ctrl_valid <= '1';
        wait until rising_edge(clk);
        ctrl_valid <= '0';
        ctrl_data  <= (others => '0');
    end procedure send_ctrl;

    procedure send_hit_beat(
        signal clk          : in  std_logic;
        signal ready        : in  std_logic;
        signal hit_channel  : out std_logic_vector(5 downto 0);
        signal hit_sop      : out std_logic;
        signal hit_eop      : out std_logic;
        signal hit_data     : out std_logic_vector(44 downto 0);
        signal hit_valid    : out std_logic;
        signal hit_error    : out std_logic_vector(2 downto 0);
        constant mux_slot_value     : in natural;
        constant payload_asic_value : in natural;
        constant payload_channel_value : in natural;
        constant tcc_raw_value      : in natural;
        constant ecc_raw_value      : in natural;
        constant sop_value          : in std_logic;
        constant eop_value          : in std_logic
    ) is
        variable hit_word_v : std_logic_vector(44 downto 0);
    begin
        while ready /= '1' loop
            wait until rising_edge(clk);
        end loop;

        hit_word_v               := (others => '0');
        hit_word_v(44 downto 41) := std_logic_vector(to_unsigned(payload_asic_value, 4));
        hit_word_v(40 downto 36) := std_logic_vector(to_unsigned(payload_channel_value, 5));
        hit_word_v(35 downto 21) := std_logic_vector(to_unsigned(tcc_raw_value, 15));
        hit_word_v(20 downto 16) := (others => '0');
        hit_word_v(15 downto 1)  := std_logic_vector(to_unsigned(ecc_raw_value, 15));
        hit_word_v(0)            := '1';

        hit_channel <= std_logic_vector(to_unsigned(mux_slot_value, 2))
                     & std_logic_vector(to_unsigned(payload_channel_value, 4));
        hit_sop     <= sop_value;
        hit_eop     <= eop_value;
        hit_data    <= hit_word_v;
        hit_error   <= (others => '0');
        hit_valid   <= '1';
        wait until rising_edge(clk);
        hit_channel <= (others => '0');
        hit_sop     <= '0';
        hit_eop     <= '0';
        hit_data    <= (others => '0');
        hit_error   <= (others => '0');
        hit_valid   <= '0';
    end procedure send_hit_beat;

    procedure expect_asic(
        signal clk        : in std_logic;
        signal hit_valid  : in std_logic;
        signal hit_data   : in std_logic_vector(38 downto 0);
        signal ext0_valid : in std_logic;
        signal ext0_data  : in std_logic_vector(86 downto 0);
        signal ext1_valid : in std_logic;
        signal ext1_data  : in std_logic_vector(86 downto 0);
        constant expected_asic : in natural;
        constant expect_down_bank : in boolean
    ) is
        variable expected_v : std_logic_vector(3 downto 0);
    begin
        expected_v := std_logic_vector(to_unsigned(expected_asic, 4));
        for wait_cycle in 0 to PIPELINE_WAIT_CONST loop
            wait until rising_edge(clk);
            if hit_valid = '1' then
                assert hit_data(ASIC_FIELD_HI_CONST downto ASIC_FIELD_LO_CONST) = expected_v
                    report "Unexpected Type1 ASIC field exp=0x"
                        & to_hstring(expected_v)
                        & " got=0x"
                        & to_hstring(hit_data(ASIC_FIELD_HI_CONST downto ASIC_FIELD_LO_CONST))
                    severity failure;
                if expect_down_bank then
                    assert ext1_valid = '1'
                        report "Expected DW/DOWN-bank extended_1 valid with Type1 payload"
                        severity failure;
                    assert ext1_data(38 downto 0) = hit_data
                        report "extended_1 payload does not match Type1 payload"
                        severity failure;
                    assert ext0_valid = '0'
                        report "DW/DOWN-bank test unexpectedly drove extended_0"
                        severity failure;
                else
                    assert ext0_valid = '1'
                        report "Expected UP-bank extended_0 valid with Type1 payload"
                        severity failure;
                    assert ext0_data(38 downto 0) = hit_data
                        report "extended_0 payload does not match Type1 payload"
                        severity failure;
                    assert ext1_valid = '0'
                        report "UP-bank test unexpectedly drove extended_1"
                        severity failure;
                end if;
                return;
            end if;
        end loop;

        assert false report "Timed out waiting for Type1 ASIC-ID payload" severity failure;
    end procedure expect_asic;

    procedure expect_no_type1(
        signal clk       : in std_logic;
        signal hit_valid : in std_logic;
        constant context_msg : in string
    ) is
    begin
        for wait_cycle in 0 to PIPELINE_WAIT_CONST loop
            wait until rising_edge(clk);
            assert hit_valid = '0'
                report "Unexpected Type1 payload for rejected hit: " & context_msg
                severity failure;
        end loop;
    end procedure expect_no_type1;

begin

    i_clk <= not i_clk after CLK_PERIOD_CONST / 2;

    dut : entity work.mts_processor
        generic map (
            BANK  => DUT_BANK,
            DEBUG => 1
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
            coe_hit_type1_ts            => coe_hit_type1_ts,
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
    begin
        wait_cycles(i_clk, 5);
        i_rst <= '0';
        wait_cycles(i_clk, 2);

        csr_write(i_clk, avs_csr_address, avs_csr_write, avs_csr_writedata,
                  CSR_CONTROL_ADDR_CONST, CSR_GO_DERIVE_TOT_CONST);
        send_ctrl(i_clk, asi_ctrl_data, asi_ctrl_valid, CTRL_RUNNING_CONST);
        wait_cycles(i_clk, 2);

        for slot in 0 to 3 loop
            send_hit_beat(
                clk                   => i_clk,
                ready                 => asi_hit_type0_ready,
                hit_channel           => asi_hit_type0_channel,
                hit_sop               => asi_hit_type0_startofpacket,
                hit_eop               => asi_hit_type0_endofpacket,
                hit_data              => asi_hit_type0_data,
                hit_valid             => asi_hit_type0_valid,
                hit_error             => asi_hit_type0_error,
                mux_slot_value        => slot,
                payload_asic_value    => 15 - slot,
                payload_channel_value => (slot + 1) mod 4,
                tcc_raw_value         => 16#0003# + slot,
                ecc_raw_value         => 16#000F# + slot,
                sop_value             => '1',
                eop_value             => '1'
            );
            expect_asic(
                clk              => i_clk,
                hit_valid        => aso_hit_type1_valid,
                hit_data         => aso_hit_type1_data,
                ext0_valid       => aso_hit_type1_extended_0_valid,
                ext0_data        => aso_hit_type1_extended_0_data,
                ext1_valid       => aso_hit_type1_extended_1_valid,
                ext1_data        => aso_hit_type1_extended_1_data,
                expected_asic    => ASIC_OFFSET + slot,
                expect_down_bank => DOWN_BANK_CONST
            );
        end loop;

        for idx in 0 to 7 loop
            send_hit_beat(
                clk                   => i_clk,
                ready                 => asi_hit_type0_ready,
                hit_channel           => asi_hit_type0_channel,
                hit_sop               => asi_hit_type0_startofpacket,
                hit_eop               => asi_hit_type0_endofpacket,
                hit_data              => asi_hit_type0_data,
                hit_valid             => asi_hit_type0_valid,
                hit_error             => asi_hit_type0_error,
                mux_slot_value        => idx mod 4,
                payload_asic_value    => 15 - (idx mod 4),
                payload_channel_value => (idx + 1) mod 4,
                tcc_raw_value         => 16#0020# + idx,
                ecc_raw_value         => 16#0040# + idx,
                sop_value             => '1',
                eop_value             => '1'
            );
        end loop;

        for idx in 0 to 7 loop
            expect_asic(
                clk              => i_clk,
                hit_valid        => aso_hit_type1_valid,
                hit_data         => aso_hit_type1_data,
                ext0_valid       => aso_hit_type1_extended_0_valid,
                ext0_data        => aso_hit_type1_extended_0_data,
                ext1_valid       => aso_hit_type1_extended_1_valid,
                ext1_data        => aso_hit_type1_extended_1_data,
                expected_asic    => ASIC_OFFSET + (idx mod 4),
                expect_down_bank => DOWN_BANK_CONST
            );
        end loop;

        for slot in 1 to 3 loop
            send_hit_beat(
                clk                   => i_clk,
                ready                 => asi_hit_type0_ready,
                hit_channel           => asi_hit_type0_channel,
                hit_sop               => asi_hit_type0_startofpacket,
                hit_eop               => asi_hit_type0_endofpacket,
                hit_data              => asi_hit_type0_data,
                hit_valid             => asi_hit_type0_valid,
                hit_error             => asi_hit_type0_error,
                mux_slot_value        => slot,
                payload_asic_value    => 0,
                payload_channel_value => slot,
                tcc_raw_value         => 16#0060# + slot,
                ecc_raw_value         => 16#0070# + slot,
                sop_value             => '1',
                eop_value             => '1'
            );
            expect_asic(i_clk, aso_hit_type1_valid, aso_hit_type1_data,
                        aso_hit_type1_extended_0_valid, aso_hit_type1_extended_0_data,
                        aso_hit_type1_extended_1_valid, aso_hit_type1_extended_1_data,
                        ASIC_OFFSET + slot, DOWN_BANK_CONST);
        end loop;

        send_hit_beat(
            clk                   => i_clk,
            ready                 => asi_hit_type0_ready,
            hit_channel           => asi_hit_type0_channel,
            hit_sop               => asi_hit_type0_startofpacket,
            hit_eop               => asi_hit_type0_endofpacket,
            hit_data              => asi_hit_type0_data,
            hit_valid             => asi_hit_type0_valid,
            hit_error             => asi_hit_type0_error,
            mux_slot_value        => 1,
            payload_asic_value    => 0,
            payload_channel_value => 4,
            tcc_raw_value         => 16#0080#,
            ecc_raw_value         => 16#0090#,
            sop_value             => '1',
            eop_value             => '1'
        );
        expect_no_type1(i_clk, aso_hit_type1_valid, "slot=1 low_ch=4 outside ENABLED_CHANNEL 0..3");

        send_hit_beat(
            clk                   => i_clk,
            ready                 => asi_hit_type0_ready,
            hit_channel           => asi_hit_type0_channel,
            hit_sop               => asi_hit_type0_startofpacket,
            hit_eop               => asi_hit_type0_endofpacket,
            hit_data              => asi_hit_type0_data,
            hit_valid             => asi_hit_type0_valid,
            hit_error             => asi_hit_type0_error,
            mux_slot_value        => 2,
            payload_asic_value    => 0,
            payload_channel_value => 2,
            tcc_raw_value         => 16#0010#,
            ecc_raw_value         => 16#0011#,
            sop_value             => '1',
            eop_value             => '0'
        );
        expect_asic(i_clk, aso_hit_type1_valid, aso_hit_type1_data,
                    aso_hit_type1_extended_0_valid, aso_hit_type1_extended_0_data,
                    aso_hit_type1_extended_1_valid, aso_hit_type1_extended_1_data,
                    ASIC_OFFSET + 2, DOWN_BANK_CONST);
        wait_cycles(i_clk, PIPELINE_WAIT_CONST);
        assert coe_debug_status_data(5) = '1'
            report "Open-packet tracking did not hold input_pipeline_busy for mux slot 2"
            severity failure;

        send_hit_beat(
            clk                   => i_clk,
            ready                 => asi_hit_type0_ready,
            hit_channel           => asi_hit_type0_channel,
            hit_sop               => asi_hit_type0_startofpacket,
            hit_eop               => asi_hit_type0_endofpacket,
            hit_data              => asi_hit_type0_data,
            hit_valid             => asi_hit_type0_valid,
            hit_error             => asi_hit_type0_error,
            mux_slot_value        => 2,
            payload_asic_value    => 0,
            payload_channel_value => 2,
            tcc_raw_value         => 16#0012#,
            ecc_raw_value         => 16#0013#,
            sop_value             => '0',
            eop_value             => '1'
        );
        expect_asic(i_clk, aso_hit_type1_valid, aso_hit_type1_data,
                    aso_hit_type1_extended_0_valid, aso_hit_type1_extended_0_data,
                    aso_hit_type1_extended_1_valid, aso_hit_type1_extended_1_data,
                    ASIC_OFFSET + 2, DOWN_BANK_CONST);
        wait_cycles(i_clk, PIPELINE_WAIT_CONST);
        assert coe_debug_status_data(5) = '0'
            report "Packet close on mux slot 2 did not release input_pipeline_busy"
            severity failure;

        report "mts_processor_asic_id_tb PASSED bank=" & DUT_BANK severity note;
        finish;
    end process tb_stim;

end architecture sim;
