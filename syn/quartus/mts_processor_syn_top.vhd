library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mts_processor_syn_top is
    port(
        clk            : in  std_logic;
        activity_probe : out std_logic_vector(31 downto 0)
    );
end entity mts_processor_syn_top;

architecture rtl of mts_processor_syn_top is
    signal rst_ctr                     : unsigned(7 downto 0) := (others => '0');
    signal rst                         : std_logic;
    signal stim_ctr                    : unsigned(31 downto 0) := (others => '0');
    signal probe_accum                 : std_logic_vector(31 downto 0) := (others => '0');

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
begin
    rst <= '1' when rst_ctr < to_unsigned(32, rst_ctr'length) else '0';
    activity_probe <= probe_accum;

    u_dut : entity work.mts_processor
        generic map(
            LPM_DIV_PIPELINE => 4,
            DEBUG            => 1
        )
        port map(
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
            i_rst                       => rst,
            i_clk                       => clk
        );

    process(clk)
        variable probe_next : std_logic_vector(31 downto 0);
        variable ctrl_state : natural;
    begin
        if rising_edge(clk) then
            if rst_ctr /= to_unsigned(255, rst_ctr'length) then
                rst_ctr <= rst_ctr + 1;
            end if;

            if rst = '1' then
                stim_ctr                    <= (others => '0');
                probe_accum                 <= (others => '0');
                avs_csr_read                <= '0';
                avs_csr_write               <= '0';
                avs_csr_address             <= (others => '0');
                avs_csr_writedata           <= (others => '0');
                asi_hit_type0_channel       <= (others => '0');
                asi_hit_type0_startofpacket <= '0';
                asi_hit_type0_endofpacket   <= '0';
                asi_hit_type0_error         <= (others => '0');
                asi_hit_type0_data          <= (others => '0');
                asi_hit_type0_valid         <= '0';
                asi_ctrl_data               <= (others => '0');
                asi_ctrl_valid              <= '0';
            else
                stim_ctr <= stim_ctr + 1;

                if (asi_hit_type0_valid = '0') or (asi_hit_type0_ready = '1') then
                    if stim_ctr(1 downto 0) /= "00" then
                        asi_hit_type0_valid <= '1';
                    else
                        asi_hit_type0_valid <= '0';
                    end if;

                    if stim_ctr(7 downto 0) = x"00" then
                        asi_hit_type0_startofpacket <= '1';
                    else
                        asi_hit_type0_startofpacket <= '0';
                    end if;

                    if stim_ctr(7 downto 0) = x"1f" then
                        asi_hit_type0_endofpacket <= '1';
                    else
                        asi_hit_type0_endofpacket <= '0';
                    end if;

                    asi_hit_type0_channel       <= std_logic_vector(stim_ctr(5 downto 0));
                    asi_hit_type0_error         <= std_logic_vector(stim_ctr(10 downto 8));
                    asi_hit_type0_data          <= std_logic_vector(stim_ctr(12 downto 0)) & std_logic_vector(stim_ctr);
                end if;

                if (asi_ctrl_valid = '0') or (asi_ctrl_ready = '1') then
                    ctrl_state     := to_integer(stim_ctr(10 downto 7)) mod 9;
                    if stim_ctr(6 downto 0) = to_unsigned(0, 7) then
                        asi_ctrl_valid <= '1';
                    else
                        asi_ctrl_valid <= '0';
                    end if;
                    asi_ctrl_data  <= std_logic_vector(to_unsigned(ctrl_state, asi_ctrl_data'length));
                end if;

                avs_csr_read      <= '0';
                avs_csr_write     <= '0';
                avs_csr_address   <= (others => '0');
                avs_csr_writedata <= std_logic_vector(stim_ctr xor x"13579bdf");
                if stim_ctr(5 downto 0) = to_unsigned(0, 6) then
                    avs_csr_write   <= '1';
                    avs_csr_address <= "000";
                elsif stim_ctr(5 downto 0) = to_unsigned(1, 6) then
                    avs_csr_write   <= '1';
                    avs_csr_address <= "001";
                elsif stim_ctr(5 downto 0) = to_unsigned(2, 6) then
                    avs_csr_read    <= '1';
                    avs_csr_address <= "000";
                elsif stim_ctr(5 downto 0) = to_unsigned(3, 6) then
                    avs_csr_read    <= '1';
                    avs_csr_address <= "010";
                end if;

                probe_next := probe_accum xor avs_csr_readdata xor std_logic_vector(stim_ctr);
                if aso_hit_type1_valid = '1' then
                    probe_next := probe_next xor aso_hit_type1_data(31 downto 0);
                    probe_next(3 downto 0) := probe_next(3 downto 0) xor aso_hit_type1_channel;
                    probe_next(4)          := probe_next(4) xor aso_hit_type1_startofpacket;
                    probe_next(5)          := probe_next(5) xor aso_hit_type1_endofpacket;
                    probe_next(6)          := probe_next(6) xor aso_hit_type1_empty;
                    probe_next(7)          := probe_next(7) xor aso_hit_type1_error;
                end if;
                if aso_debug_ts_valid = '1' then
                    probe_next(15 downto 0) := probe_next(15 downto 0) xor aso_debug_ts_data;
                end if;
                if aso_debug_burst_valid = '1' then
                    probe_next(31 downto 16) := probe_next(31 downto 16) xor aso_debug_burst_data;
                end if;
                if aso_ts_delta_valid = '1' then
                    probe_next(23 downto 8) := probe_next(23 downto 8) xor aso_ts_delta_data;
                end if;
                probe_next(24) := probe_next(24) xor avs_csr_waitrequest;
                probe_next(25) := probe_next(25) xor asi_hit_type0_ready;
                probe_next(26) := probe_next(26) xor asi_ctrl_ready;
                probe_accum    <= probe_next;
            end if;
        end if;
    end process;
end architecture rtl;
