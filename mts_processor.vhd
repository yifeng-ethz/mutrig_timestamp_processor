-- File name: mts_processor.vhd 
-- Author: Yifeng Wang (yifenwan@phys.ethz.ch)
-- =======================================
-- Revision: 1.0 (file created)
--		Date: Mar 25, 2024
-- Revision: 2.0 (seperate long/short data paths into individual entities; avoid input contention with skid-buffer;
--		collects hit loss in data path switching and input flow congestion)
--		Date: Mar 28, 2024 
-- Revision: 3.0 (clean up)
--		Date: Jun 26, 2024
-- Revision: 4.0 (Re-write)
--		Date: Jul 2, 2024
-- Revision: 5.0 (Support new hit type0b with same throughput as type0a)
--      Date: Sep 24, 2025 
-- =========
-- Description:	[MuTRiG Timestamp Processor] 
	-- Processes the Timestamp TCC (15 bit)(1.6 ns) into TCC_8n (13 bit) and TCC_1n6 (3 bit).:
	-- 		1) decode the TCC_s from FLSR state symbol into unsigned binary of incresing TCC_b
	--		2) devide by 5 to calculate remainder and divison
	--		3) (optional) do this also for ECC
	--		4) (optional) calculate: ECC_1n6 - TCC_1n6 = ET_1n6 (9 bit)
	-- Integrity validation (optional):
	-- 		1) Filter hits with hiterr from assembly. 
	--		2) Ignore frame with crcerr from assembly. (this needs pre-buffer of a whole packet in the input FIFO, undetermistic delay)
	--		3) Ignore links with frame_corrupt from assembly. (this masks the links in error state)
	-- 
	-- Data type:
	--	Input [hit type 0]:
	--		asic	4
	--		ch		5
	--		TCC		15
	--		TFine	5
	--		ECC		15
	--		EFlag	1
	-- =================
	--		Total	45
	--
	-- Output [hit type 1a/b] (a=short/scifi mode; b=long/tile mode) :
	--		asic	4
	--		ch		5
	--		TCC_8n	13
	--		TCC_1n6	3
	--		TFine	5
	--		ET_1n6	9	(for type 1b, E-T; for type 1a, =all "0"s while EFlag=0 / =all "1"s while EFlag=1)
	-- ==================
	--		Total	39
	-- (a and b are automatically switch over, depending on the current hit flag from the upstream mutrig_frame_assembly. 
	
	-- Latency: 
	-- 		
	--
	-- Throughput: (f_clk=125 MHz)
	--		Hit type 0a (short) (4 links in / 1 ROM port)			 1 * f_clk   		< 4 * f_clk / 3.5 	(expected)
	--		Hit type 0b (long)  (4 links in / 2 ROM port)		     1 * f_clk   		> 4 * f_clk / 6 	(expected)
	-- 
	-- Comments: 
	--		1) Use Simple-DP ROM, with pre-calculated LUT, rather than True-DP RAM, with on-the-fly LUT calculation,
	--		reduces the RAM usage by half.
	--		2) For scifi (short hit), it connects 4 frame_assembly, from the same bank. This will not induce time-stamp re-order.
	--		This will not induce backpressure.
	--		3) For tile (long hit), it connects 4 frame_assembly, from four different banks. This will not induce time-stamp re-order.
	--		This will not induce backpressure.
	--		4) Always in-order processing per link, i.e. no pre-fetch of a link. First decode link 0-1, then decode link 2-3, in total 2 cycles.
	--		If there is no hit in that link, go idle, do not pre-fetch other links. The hits are expect to appear in the next 3.5-6 cycles, so
	--		the buffer depth is 2, 
	--		5) Arbitration is required to combinationally, decide which hits gets looked up and sequently in the pipeline 
	-- Resource usage:
	--		1) 1 DP-RAM for symbol decode. 
	
-- ================ synthsizer configuration =================== 		
-- altera vhdl_input_version vhdl_2008
-- ============================================================= 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.log2;
use IEEE.math_real.ceil;

LIBRARY lpm; 
USE lpm.lpm_components.all;

entity mts_processor is 
generic (
	FRAME_CORRPT_BIT_LOC	: natural := 2; -- error channel descriptor bit locations of sink streaming interface
	CRCERR_BIT_LOC			: natural := 1;
	HITERR_BIT_LOC			: natural := 0;
	BANK					: string := "UP"; -- not used, output asic id is set by input asic id
	ENABLED_CHANNEL_HI		: natural := 3; -- must be within 0-15, used for generate eop for enabled channels
	ENABLED_CHANNEL_LO		: natural := 0;
	PADDING_EOP_WAIT_CYCLE	: natural := 512; -- set the wait grace period to generating eop of each link at end of run. note: backpressure fifo depth (128) x enabled_channel (4)
	LPM_DIV_PIPELINE		: natural := 4;
	MUTRIG_BUFFER_EXPECTED_LATENCY_8N		: natural := 2000; -- affects the error signal on <hit_type1>
	DEBUG					: natural := 1
);
port (

	-- avmm-slave
	-- CSR 
	avs_csr_readdata				: out std_logic_vector(31 downto 0);
	avs_csr_read					: in  std_logic;
	avs_csr_address					: in  std_logic_vector(2 downto 0);
	avs_csr_waitrequest				: out std_logic; 
	avs_csr_write					: in  std_logic;
	avs_csr_writedata				: in  std_logic_vector(31 downto 0);
	
	-- ============ INPUT ==============
	-- input stream of raw hits
	asi_hit_type0_channel			: in  std_logic_vector(5 downto 0); -- for asic 0-15 (4 bit) + 2 msb for mux sel channel (binary, redundant)
	asi_hit_type0_startofpacket		: in  std_logic; -- mutrig frame
	asi_hit_type0_endofpacket		: in  std_logic;
	asi_hit_type0_error				: in  std_logic_vector(2 downto 0); 
	-- frame_corrupt & crcerr & hiterr
		-- crcerr available at "eop"
		-- hiterr available at "valid"
	asi_hit_type0_data				: in  std_logic_vector(44 downto 0); -- valid is a seperate signal below
	asi_hit_type0_valid 			: in  std_logic;
	asi_hit_type0_ready				: out std_logic;
	
	-- ============ OUTPUT ==============
	-- output stream of processed hits (TODO: add back-pressure)
	aso_hit_type1_channel			: out  std_logic_vector(3 downto 0); -- for asic 0-15 (4 bit)
	aso_hit_type1_startofpacket		: out  std_logic; -- marks the start and end of run
	aso_hit_type1_endofpacket		: out  std_logic;
	aso_hit_type1_data				: out  std_logic_vector(38 downto 0);
	aso_hit_type1_valid				: out  std_logic; 
	aso_hit_type1_ready				: in   std_logic; 
	aso_hit_type1_empty				: out  std_logic_vector(0 downto 0); -- TODO: marks the eor of this mutrig link (avst-channel), if theeor cycle does not contain hit.
	-- add an individual fifo for each channel, give an option to release last packet when next sop is seen
	-- the cache stack will not deassert ready, since it has input fifo (with 1 pop head, write is always possible, only when really full, overwrite takes 2 cycle and pop takes 1 cycle, ov can happen), 
	-- in case of overflow, such information should be collected by upstream, such as this mts processor
    aso_hit_type1_error             : out std_logic_vector(0 downto 0); -- { tserr : possible wrong timestamp }
                                                                        -- tserr is asserted to indicate this hit timestamp is not within the range of (0-2000 cycles delay)
                                                                        -- the upstream (ring-buffer cam) should ignore this hit as it is not meaningful. 
	

	-- input stream of control signal (enable)
	-- this signal is time critical and must be synchronzed for all datapath modules
	asi_ctrl_data			: in  std_logic_vector(8 downto 0); 
	-- ====================================
	-- Command				Code	Payload 
	-- ====================================
	-- Run Prepare			0x10	32 bit run number
	-- Sync					0x11	-
	-- Start Run			0x12	-
	-- End Run				0x13	-
	-- Abort Run			0x14	-
	-- ____________________________________
	-- Start Link Test		0x20
	-- Stop Link Test		0x21	-
	-- Start Sync Test 		0x24
	-- Stop Sync Test		0x25	-
	-- Test Sync			0x26
	-- ____________________________________
	-- Reset				0x30	16 bit mask
	-- Stop Reset			0x31	16 bit mask
	-- Enable 				0x32	
	-- Disable				0x33
	-- ____________________________________
	-- Address				0x40	16 bit address
	
	-- ===============================
	-- #: State  (9 states)
	-- ===============================
	-- 0: IDLE						
	-- 1: RUN_PREPARE				
	-- 2: SYNC (reset active)		
	-- 3: RUNNING					
	-- 4: TERMINATING
	-- 5: LINK_TEST
	-- 6: SYNC_TEST
	-- 7: RESET
	-- 8: OUT_OF_DAQ
	asi_ctrl_valid			: in  std_logic;
	asi_ctrl_ready			: out std_logic;
	
	-- AVST <debug_ts> 
    -- debug port (showing the time difference of gts - mts)
	aso_debug_ts_valid		: out std_logic;
	aso_debug_ts_data		: out std_logic_vector(15 downto 0);
    
    -- AVST <debug_burst> 
    aso_debug_burst_valid		: out std_logic;
	aso_debug_burst_data		: out std_logic_vector(15 downto 0);

	-- clock and reset interface
    i_rst                   : in std_logic; -- async reset assertion, sync reset release
    i_clk                   : in std_logic -- clock should match the lvds parallel clock (125MHz)
);
end entity mts_processor;

architecture rtl of mts_processor is
	
	-- constants
	constant HIT_MODE_HI			: natural := 30;
	constant HIT_MODE_LO			: natural := 28;
	constant I_ASIC_HI				: natural := 44;
	constant I_ASIC_LO				: natural := 41;
	constant I_CHANNEL_HI			: natural := 40;
	constant I_CHANNEL_LO			: natural := 36;
	constant I_TCC_HI				: natural := 35;
	constant I_TCC_LO				: natural := 21;
	constant I_TFINE_HI				: natural := 20;
	constant I_TFINE_LO				: natural := 16;
	constant I_ECC_HI				: natural := 15;
	constant I_ECC_LO				: natural := 1;
	constant I_EFLAG_BIT_LOC		: natural := 0;
	constant O_ASIC_HI				: natural := 38;
	constant O_ASIC_LO				: natural := 35;
	constant O_CHANNEL_HI			: natural := 34;
	constant O_CHANNEL_LO			: natural := 30;
	constant O_TCC8N_HI				: natural := 29;
	constant O_TCC8N_LO				: natural := 17;
	constant O_TCC1n6_HI			: natural := 16;
	constant O_TCC1n6_LO			: natural := 14;
	constant O_TFINE_HI				: natural := 13;
	constant O_TFINE_LO				: natural := 9;
	constant O_ET1n6_HI				: natural := 8;
	constant O_ET1n6_LO				: natural := 0;
	

	-- global control signals 
	type mutrig_hit_mode_t is (SHORT, LONG, PRBS);
	signal mutrig_hit_mode			: mutrig_hit_mode_t := SHORT;
	
	-- hit record types
	type hit_type0_t is record -- total 45 bits + etc
        asic            : std_logic_vector(3 downto 0);  --ASIC ID
        channel         : std_logic_vector(4 downto 0);  --Channel number
        t_cc            : std_logic_vector(14 downto 0); --T-Trigger coarse time value (1.6ns)
        t_fine          : std_logic_vector(4 downto 0);  --T-Trigger fine time value
        e_cc            : std_logic_vector(14 downto 0); --Energy coarse time value (in units of 1.6ns)
        e_flag          : std_logic;                     --E-Flag valid flag
		valid           : std_logic;                     --data word valid flag
		hiterr			: std_logic;
    end record;
	signal hit_in		: hit_type0_t;
	
	type hit_padding_t is record -- total 45 bits + etc
        asic            : std_logic_vector(3 downto 0);  --ASIC ID
        channel         : std_logic_vector(4 downto 0);  --Channel number
        cc_out          : std_logic_vector(14 downto 0); --###Decoded from LUT RAM###
		ecc_out			: std_logic_vector(14 downto 0); --###Decoded from LUT RAM###
        t_fine          : std_logic_vector(4 downto 0);  --T-Trigger fine time value
        e_cc            : std_logic_vector(14 downto 0); --Energy coarse time value (in units of 1.6ns)
        e_flag          : std_logic;                     --E-Flag valid flag
		valid           : std_logic;                     --data word valid flag
		hiterr			: std_logic;
    end record;
	signal hit_padding	: hit_padding_t;
	
	type div_pipeline_stage_t is record -- total 45 bits + etc
        asic            : std_logic_vector(3 downto 0);  --ASIC ID
        channel         : std_logic_vector(4 downto 0);  --Channel number
        --t_cc            : std_logic_vector(14 downto 0); --T-Trigger coarse time value (1.6ns) -- this part is seperated pipelined by lpm_div
        t_fine          : std_logic_vector(4 downto 0);  --T-Trigger fine time value
        e_cc            : std_logic_vector(14 downto 0); --Energy coarse time value (in units of 1.6ns)
		et_1n6			: std_logic_vector(8 downto 0); -- E-T part (calculated with 50 bits)
        e_flag          : std_logic;                     --E-Flag valid flag
		valid           : std_logic;                     --data word valid flag
		hiterr			: std_logic;
    end record;
	type div_pipeline_t is array (0 to LPM_DIV_PIPELINE) of div_pipeline_stage_t;
	signal hit_div		: div_pipeline_t;
	
	type hit_type1_t is record -- total 39 bits + xx.int
		asic            : std_logic_vector(3 downto 0);  	-- ASIC ID
        channel         : std_logic_vector(4 downto 0);  	-- Channel number
        tcc_8n          : std_logic_vector(12 downto 0); 	-- 8n
        tcc_1n6         : std_logic_vector(2 downto 0);  	-- 1.6ns	
		tfine			: std_logic_vector(4 downto 0);		-- 50ps
		et_1n6			: std_logic_vector(8 downto 0); 	-- E-T (for type 1b, E-T; for type 1a, =all "0"s while EFlag=0 / =all "1"s while EFlag=1)
		valid			: std_logic;
		hiterr			: std_logic;
	end record;
	signal hit_out		: hit_type1_t;

	-- run state signals
	type running_hit_mode_t is (SHORT,LONG,PRBS,UNKNOWN);
	signal running_hit_mode			: running_hit_mode_t;
	
	type processor_state_t is (RUNNING, RESET, IDLE, FLUSHING, ERROR);
	signal processor_state		: processor_state_t;
	
	type reset_flow_t is (SCLR,SYNC,DONE);
	signal reset_flow 			: reset_flow_t;
	
	type run_state_t is (IDLE, RUN_PREPARE, SYNC, RUNNING, TERMINATING, LINK_TEST, SYNC_TEST, RESET, OUT_OF_DAQ, ERROR);
	signal run_state_cmd	: run_state_t;
	
	-- processor
	signal startofrun_sent					: std_logic_vector(15 downto 0);
	signal hit_in_ok						: std_logic;
	signal processor_allow_input			: std_logic;
	
	-- data and control path signals 
	type csr_t is record 
		go					: std_logic;
		force_stop			: std_logic;
		soft_reset			: std_logic;
		set_hit_mode		: running_hit_mode_t;
		bypass_lapse		: std_logic;
		discard_hiterr		: std_logic;
		expected_latency	: std_logic_vector(31 downto 0);
	end record;
	signal csr				: csr_t;
	
	type debug_msg_t is record
		discard_hit_cnt		: unsigned(31 downto 0);
		total_hit_cnt		: unsigned(47 downto 0);
	end record;
	signal debug_msg		: debug_msg_t;
	
	-- dual port rom (2^15 depth - 15 bit wide)
	component dual_port_rom
	generic (
		DATA_WIDTH	: natural := 15;
		ADDR_WIDTH	: natural := 15
	);	
	port (
		addr_a		: in  std_logic_vector(14 downto 0);
		q_a			: out std_logic_vector(14 downto 0);
		addr_b		: in  std_logic_vector(14 downto 0);
		q_b			: out std_logic_vector(14 downto 0);
		clk			: in  std_logic
	);
	end component dual_port_rom;
	signal cc_in,cc_out			: std_logic_vector(14 downto 0);
	signal ecc_in,ecc_out		: std_logic_vector(14 downto 0);
	
	
	
	-- counter (gts)
	component LPM_COUNTER
	generic ( 
		LPM_WIDTH 		: natural; 
		LPM_MODULUS 	: natural := 0;
		LPM_DIRECTION 	: string := "UNUSED";
		LPM_AVALUE 		: string := "UNUSED";
		LPM_SVALUE 		: string := "UNUSED";
		LPM_PORT_UPDOWN : string := "PORT_CONNECTIVITY";
		LPM_PVALUE 		: string := "UNUSED";
		LPM_TYPE 		: string := L_COUNTER;
		LPM_HINT 		: string := "UNUSED");
	port (
		DATA 	: in std_logic_vector(LPM_WIDTH-1 downto 0):= (OTHERS => '0');
		CLOCK 	: in std_logic ;
		CLK_EN 	: in std_logic := '1';
		CNT_EN 	: in std_logic := '1';
		UPDOWN 	: in std_logic := '1';
		SLOAD 	: in std_logic := '0';
		SSET 	: in std_logic := '0';
		SCLR 	: in std_logic := '0';
		ALOAD 	: in std_logic := '0';
		ASET 	: in std_logic := '0';
		ACLR 	: in std_logic := '0';
		CIN 	: in std_logic := '1';
		COUT 	: out std_logic := '0';
		Q 		: out std_logic_vector(LPM_WIDTH-1 downto 0);
		EQ 		: out std_logic_vector(15 downto 0));
	end component;
	
	-- multiplier
	component LPM_MULT
	generic ( 	
		LPM_WIDTHA 		: natural; 
		LPM_WIDTHB 		: natural;
		LPM_WIDTHS 		: natural := 1;
		LPM_WIDTHP 		: natural;
		LPM_REPRESENTATION 	: string := "UNSIGNED";
		LPM_PIPELINE 	: natural := 0;
		LPM_TYPE		: string := L_MULT;
		LPM_HINT 		: string := "UNUSED"
	);
	port (
		DATAA 	: in std_logic_vector(LPM_WIDTHA-1 downto 0);
		DATAB 	: in std_logic_vector(LPM_WIDTHB-1 downto 0);
		ACLR 	: in std_logic := '0';
		CLOCK 	: in std_logic := '0';
		CLKEN 	: in std_logic := '1';
		SUM 	: in std_logic_vector(LPM_WIDTHS-1 downto 0) := (OTHERS => '0');
		RESULT 	: out std_logic_vector(LPM_WIDTHP-1 downto 0)
	);
	end component;
	
	-- multiplier	
	constant LPM_MULT_PIPELINE			: natural := 10;
	-- padding_logic_comb (tcc (15bit) -> cc_gts_1n6_slv50 (50bit))
	constant OVERFLOW_1N6				: integer := 32766;
	constant OVERFLOW_TIME_1N6			: integer := OVERFLOW_1N6 + 1; 
	-- NOTE: mutrig overflow at 2^15-2=32766 (counting from 0), but takes 2^15-1=32767 * 1.6ns. So we plus 1 here.
	--		 when calculating the time, we use OVERFLOW_TIME_1N6.
	--		 when count up, we use OVERFLOW_1N6.
	constant UPPER						: integer := OVERFLOW_1N6 - MUTRIG_BUFFER_EXPECTED_LATENCY_8N*5; -- 2000
	signal padding_logic_gray_ts		: unsigned(14 downto 0);
	signal padding_logic_gray_ts_e		: unsigned(14 downto 0);
	signal padding_logic_white_ts		: unsigned(49 downto 0);
	signal padding_logic_white_ts_e		: unsigned(49 downto 0);
	signal cc_gts_1n6_slv50				: std_logic_vector(49 downto 0);
	signal ecc_gts_1n6_slv50			: std_logic_vector(49 downto 0);
	signal padding_logic_gts_product	: std_logic_vector(49 downto 0);
	
	-- divider 
	component LPM_DIVIDE
	generic (
		LPM_WIDTHN 			: natural;
        LPM_WIDTHD 			: natural;
		LPM_NREPRESENTATION : string := "UNSIGNED";
		LPM_DREPRESENTATION : string := "UNSIGNED";
		LPM_PIPELINE 		: natural := 0;
		MAXIMIZE_SPEED		: integer := 9;
		LPM_TYPE 			: string := L_DIVIDE;
		INTENDED_DEVICE_FAMILY	: string;
		LPM_HINT 			: string := "UNUSED"
	);
	port (
		NUMER 			: in  std_logic_vector(LPM_WIDTHN-1 downto 0);
		DENOM 			: in  std_logic_vector(LPM_WIDTHD-1 downto 0);
		ACLR 			: in  std_logic := '0';
		CLOCK 			: in  std_logic := '0';
		CLKEN 			: in  std_logic := '1';
		QUOTIENT 		: out std_logic_vector(LPM_WIDTHN-1 downto 0);
		REMAIN 			: out std_logic_vector(LPM_WIDTHD-1 downto 0)
	);
	end component LPM_DIVIDE; 
	constant LPM_DIV_WIDTHN	: natural := 50;
	signal lpm_div_num_in	: std_logic_vector(LPM_DIV_WIDTHN-1 downto 0);
	signal lpm_div_quo_out	: std_logic_vector(LPM_DIV_WIDTHN-1 downto 0);
	signal lpm_div_rem_out	: std_logic_vector(2 downto 0);

	

	
	-- counter mts
	signal counter_mts_1n6			: unsigned(14 downto 0);
	signal counter_ov_cnt			: unsigned(31 downto 0); -- can be tuned
	signal counter_ov_cnt_reg		: unsigned(31 downto 0);
	signal fpga_overflow_happened			: std_logic;
	signal fpga_overflow_lookback_cnt		: unsigned(31 downto 0);
    signal lpm_multi_valid_cnt              : unsigned(15 downto 0);
	-- counter gts 
	signal counter_gts_8n					: unsigned(47 downto 0); -- can be tuned
	
	-- eop
	constant EOP_DELAY_CYCLE		: natural := 3;
	constant N_ENABLED_CHANNEL		: natural := ENABLED_CHANNEL_HI - ENABLED_CHANNEL_LO + 1;
	signal packet_in_transaction	: std_logic_vector(N_ENABLED_CHANNEL-1 downto 0);
    
    
    -- debug_ts 
    signal int_aso_debug_ts_data    : std_logic_vector(aso_debug_ts_data'high downto 0); -- for read internally. note: you could also use "buffer" instead of "out" of this port, but its support is poor across platform.
    
    -- ///////////////////////////////////////////////////////////////////////////////
    -- debug_burst
    -- ///////////////////////////////////////////////////////////////////////////////
    signal egress_valid             : std_logic;
    signal delta_valid              : std_logic;
    
    type egress_regs_t is array(0 to 1) of std_logic_vector(47 downto 0);
    signal egress_timestamp         : egress_regs_t;
    signal egress_arrival           : egress_regs_t;
    
    constant DELTA_TIMESTAMP_WIDTH            : natural := 12; -- ex: 10 bit, range is -512 to 511, triming 2 bits yields -> -128 to 127
    constant DELTA_ARRIVAL_WIDTH              : natural := 12; -- ex: 10 bit, range is 0 to 1023, triming 2 bits yields -> 0 to 255
    signal delta_timestamp          : std_logic_vector(DELTA_TIMESTAMP_WIDTH-1 downto 0);
    signal delta_arrival            : std_logic_vector(DELTA_ARRIVAL_WIDTH-1 downto 0);
    
    
    
	-- ----------------------------
	-- data flow chart
    -- ----------------------------
	-- Legend:
	--		Dark TS: non yet decoded, the lfsr output raw symbol of MuTRiG
	--		Gray TS: decoded, the lfsr cycle of MuTRiG, so called MuTRiG timestamp (mts)
	--		White TS: padded to 50 bit according to global timestamp counter (overflow round)
	--		TS 8n: mu3e global timestamp (gts) with 8ns step, to be output to the hit cache. 
	
	-- mts -> gts mapping: 
	--		1) Padding 2) Divide by 5
    
    

begin

	-- debug
	--asi_hit_type0_ready		<= i_issp_ready;
	
	cc_lut : dual_port_rom
	-- input: dark ts (asi_hit_type0_data(I_TCC_HI downto I_TCC_LO)
	-- output: gray ts (cc_out from lut_ram)	
	port map(
		addr_a		=> cc_in,
		q_a			=> cc_out,
		addr_b		=> ecc_in,
		q_b			=> ecc_out,
		clk			=> i_clk
	);
	
	cc_div : LPM_DIVIDE
	-- input: white ts 
	-- output: white ts 8n
	generic map (
		LPM_WIDTHN				=> LPM_DIV_WIDTHN,
		LPM_WIDTHD				=> 3,
		LPM_NREPRESENTATION		=> "UNSIGNED",
		LPM_DREPRESENTATION		=> "UNSIGNED",
		MAXIMIZE_SPEED			=> 9,
		LPM_PIPELINE			=> LPM_DIV_PIPELINE,
		INTENDED_DEVICE_FAMILY	=> "Arria V",
		LPM_TYPE				=> "L_DIVIDE"
	)
	port map (
		CLOCK 				=> i_clk,
		NUMER				=> lpm_div_num_in,
		DENOM				=> std_logic_vector(to_unsigned(5,3)),
		QUOTIENT			=> lpm_div_quo_out,
		REMAIN				=> lpm_div_rem_out
	);
	
	of2gts_mult : LPM_MULT
	generic map ( 	
		LPM_WIDTHA 		=> 32, -- counter_ov_cnt
		LPM_WIDTHB 		=> 15, -- OVERFLOW_TIME_1N6
		LPM_WIDTHS 		=> 15, -- hit_padding.cc_out
		LPM_WIDTHP 		=> 50, -- cc_gts_1n6_slv50
		LPM_REPRESENTATION 	=> "UNSIGNED",
		LPM_PIPELINE 	=> LPM_MULT_PIPELINE
	)
	port map (
		DATAA 		=> std_logic_vector(counter_ov_cnt),
		DATAB 		=> std_logic_vector(to_unsigned(OVERFLOW_TIME_1N6,15)), 
		ACLR 		=> i_rst,
		CLOCK 		=> i_clk,
		CLKEN 		=> '1',
		SUM 		=> (14 downto 0 => '0'),
		RESULT 		=> padding_logic_gts_product
	);
	
	proc_run_control_mgmt_agent : process (i_rst, i_clk)
	begin
		if (i_rst = '1') then 
			run_state_cmd		<= IDLE;
		elsif (rising_edge(i_clk)) then
			-- valid
			if (asi_ctrl_valid = '1') then 
				-- payload of run control to run cmd
				case asi_ctrl_data is 
					when "000000001" =>
						run_state_cmd		<= IDLE;
					when "000000010" => 
						run_state_cmd		<= RUN_PREPARE;
					when "000000100" =>
						run_state_cmd		<= SYNC;
					when "000001000" =>
						run_state_cmd		<= RUNNING;
					when "000010000" =>
						run_state_cmd		<= TERMINATING;
					when "000100000" => 
						run_state_cmd		<= LINK_TEST;
					when "001000000" =>
						run_state_cmd		<= SYNC_TEST;
					when "010000000" =>
						run_state_cmd		<= RESET;
					when "100000000" =>
						run_state_cmd		<= OUT_OF_DAQ;
					when others =>
						run_state_cmd		<= ERROR;
				end case;
			else 
				run_state_cmd		<= run_state_cmd;
			end if;
			-- ready
			-- TODO: hook up with main state machine
			asi_ctrl_ready		<= '1';
			
		end if;
	end process;
		
	
	
	proc_avmm_csr : process (i_rst,i_clk)
	-- avalon memory-mapped interface for accessing the control and status registers
	-- address map:
	-- 		0: control and status 
	--		1: discard hits count
	--		2: expected mutrig buffering latency in 8ns 
	--		3: total hits count (H) (incl. errors)
	--		4: total hits count (L)
	begin
		if (i_rst = '1') then 
			csr.go			            <= '1'; -- NOTE: default is go. If go is low, cmd from run_state_controller cannot send processor to run state.
			csr.force_stop	            <= '0';
			csr.soft_reset	            <= '0'; -- only reset counters for now
			csr.set_hit_mode    	    <= SHORT;
			csr.expected_latency		<= std_logic_vector(to_unsigned(MUTRIG_BUFFER_EXPECTED_LATENCY_8N, csr.expected_latency'length));
			csr.discard_hiterr		    <= '1'; -- NOTE: default is discard hiterr
		elsif (rising_edge(i_clk)) then
			-- default
			avs_csr_waitrequest		<= '1'; 
			avs_csr_readdata		<= (others => '0');
			-- write logic
			if (avs_csr_write = '1') then 
				avs_csr_waitrequest		<= '0'; -- ack 
				case to_integer(unsigned(avs_csr_address)) is -- addr map
					when 0 =>
						csr.go				<= 	avs_csr_writedata(0);
						csr.force_stop		<=  avs_csr_writedata(1);
						csr.soft_reset		<=	avs_csr_writedata(2);
						csr.bypass_lapse	<=  avs_csr_writedata(3);
						csr.discard_hiterr	<= 	avs_csr_writedata(4);
						case avs_csr_writedata(HIT_MODE_HI downto HIT_MODE_LO) is -- MSB
							when "100" =>
								csr.set_hit_mode 	<= SHORT;
							when "000" =>
								csr.set_hit_mode	<= LONG;
							when "010" =>
								csr.set_hit_mode	<= PRBS; -- full-frame
							when "001" =>
								csr.set_hit_mode	<= PRBS; -- single
							when others =>
								csr.set_hit_mode	<= UNKNOWN;
						end case;
					when 1 => 
						
					when 2 =>
						csr.expected_latency		<= avs_csr_writedata;
					when others =>
						null;
				end case;
			-- read logic
			elsif (avs_csr_read = '1') then 
				avs_csr_waitrequest		<= '0'; -- ack
				case to_integer(unsigned(avs_csr_address)) is -- addr map
					when 0 =>
						if (processor_state = RUNNING) then -- show current state 
							avs_csr_readdata(0)		<= '1' ; 
						else
							avs_csr_readdata(0)		<= '0';
						end if;
						avs_csr_readdata(1) 	<= csr.force_stop;
						avs_csr_readdata(2)		<= csr.soft_reset;
						avs_csr_readdata(3)		<= csr.bypass_lapse;
						avs_csr_readdata(4)		<= csr.discard_hiterr;
						case running_hit_mode is 
							when SHORT =>
								avs_csr_readdata(HIT_MODE_HI downto HIT_MODE_LO) <= "100";
							when LONG =>
								avs_csr_readdata(HIT_MODE_HI downto HIT_MODE_LO) <= "000";
							when PRBS =>
								avs_csr_readdata(HIT_MODE_HI downto HIT_MODE_LO) <= "001";
							when others =>
								avs_csr_readdata(HIT_MODE_HI downto HIT_MODE_LO) <= "110";
						end case;
					when 1 => 
						avs_csr_readdata		<= std_logic_vector(debug_msg.discard_hit_cnt);
					when 2 =>
						avs_csr_readdata		<= csr.expected_latency;
					when 3 =>
						avs_csr_readdata(15 downto 0)		<= std_logic_vector(debug_msg.total_hit_cnt(47 downto 32));
					when 4 =>
						avs_csr_readdata				<= std_logic_vector(debug_msg.total_hit_cnt(31 downto 0));
					when others => 
						null;
				end case;
			-- contention with other state machines
			else 
                -- release reset by csr
                if (csr.soft_reset = '1') then 
                    csr.soft_reset          <= '0';
                end if;
			
			end if;
		end if;
	end process;
	
	
	proc_processor_fsm : process (i_rst, i_clk)
	-- IDLE: write ok, read no. FIFO can overflow. 
	-- RUN_PREP: write no, read ok. FIFO is flushed until empty.
	-- SYNC: write no, read no. FIFO should already be emptied
	-- RUNNING: write ok, read ok. FIFO is in normal op.
	-- TERMINATING: write ok (do not gen new frame), read ok. FIFO is flushed empty. 
	-- OTHERS: same as IDLE. 
	begin
		if (i_rst = '1') then 
			processor_state		<= IDLE;
			reset_flow			<= DONE;
		
		elsif (rising_edge(i_clk)) then
			processor_allow_input		<= '0';
            
			case processor_state is 
				when IDLE => -- do not read fifo
					if (csr.go = '1' and run_state_cmd = RUNNING) then -- !not standard run sequence, but allowed
						processor_state		<= RUNNING; 
						reset_flow			<= DONE;
					elsif (run_state_cmd = RUN_PREPARE) then -- standard sequence
						processor_state		<= RESET; 
						reset_flow			<= SCLR;
					elsif (run_state_cmd = SYNC) then -- !not standard sequence, skipped sclr counters
						processor_state		<= RESET;
						reset_flow			<= SYNC;
					end if;
					
				when RESET =>	-- in this state, the mts->gts is reset, the fifo of assembly is flushed until empty (assembly should no generate until RUNNING)
					case reset_flow is
						when SCLR => 
							-- sclr all counters and fifos 
							processor_allow_input		<= '1';
						when SYNC =>
							-- hold mts->gts 
						when DONE =>
							-- normal op
						when others => 
					end case;
					if (csr.go = '1' and run_state_cmd = RUNNING) then -- standard sequence 2 
						processor_state		<= RUNNING;
						reset_flow			<= DONE;
					elsif (run_state_cmd = SYNC) then -- standard sequence 1 
						reset_flow			<= SYNC;
					elsif (run_state_cmd = IDLE) then -- abort
						processor_state		<= IDLE;
						reset_flow			<= DONE;
					end if;
				
				when RUNNING =>
					processor_allow_input		<= '1';
					if (run_state_cmd = TERMINATING) then -- standard sequence
						processor_state		<= FLUSHING;
					elsif (run_state_cmd = IDLE) then -- abort
						processor_state		<= IDLE; 
					end if;
					
				when FLUSHING => -- read fifo eop for all channels are seen
					processor_allow_input		<= '1';
					if (run_state_cmd = IDLE) then -- standard sequence
						processor_state		<= IDLE;
					end if;
				when others => 
			end case;
            
            -- manual force stop by csr control 
            if (csr.force_stop = '1') then 
                processor_allow_input       <= '0';
            end if;
		
		end if;
	end process;
	
	proc_in_ready : process (i_rst, i_clk)
	begin
		if (i_rst = '1') then 
		
		elsif (rising_edge(i_clk)) then 
			-- default 
			asi_hit_type0_ready			<= '0';	
			case processor_state is 
				when IDLE => 
					asi_hit_type0_ready			<= '0';
				when RESET =>
					case reset_flow is 
						when SCLR => 
							asi_hit_type0_ready			<= '1'; -- flushing fifo
						when SYNC =>
							asi_hit_type0_ready			<= '0';
						when DONE =>
							asi_hit_type0_ready			<= '0';
						when others =>
					end case;
				when RUNNING =>
					asi_hit_type0_ready			<= '1'; -- accepting input hits
				when FLUSHING =>
					asi_hit_type0_ready			<= '1'; -- flushing
				when others =>
			end case;
		end if;
	
	end process;
	
	proc_mts_counter : process (i_clk)
	-- counter of the mutrig timestamp on the FPGA
	begin
		if rising_edge(i_clk) then
			if (processor_state = RESET and reset_flow = SYNC) then 
				 -- reset counter
				counter_mts_1n6		<= (others => '0');
				counter_ov_cnt		<= (others => '0');
				fpga_overflow_lookback_cnt		<= (others => '0');
                lpm_multi_valid_cnt     <= (others => '0');
			else
				-- begin counter
				case counter_mts_1n6 is -- overflow at (32766 - 0 - 1 - 2 - 3 - 4)
					when to_unsigned(32766,15) =>
						counter_mts_1n6		<= to_unsigned(4,15);
						counter_ov_cnt		<= counter_ov_cnt + to_unsigned(1,counter_ov_cnt'length);
					when to_unsigned(32765,15) =>
						counter_mts_1n6		<= to_unsigned(3,15);
						counter_ov_cnt		<= counter_ov_cnt + to_unsigned(1,counter_ov_cnt'length);
					when to_unsigned(32764,15) =>
						counter_mts_1n6		<= to_unsigned(2,15);
						counter_ov_cnt		<= counter_ov_cnt + to_unsigned(1,counter_ov_cnt'length);
					when to_unsigned(32763,15) =>
						counter_mts_1n6		<= to_unsigned(1,15);
						counter_ov_cnt		<= counter_ov_cnt + to_unsigned(1,counter_ov_cnt'length);
					when to_unsigned(32762,15) =>
						counter_mts_1n6		<= to_unsigned(0,15);
						counter_ov_cnt		<= counter_ov_cnt + to_unsigned(1,counter_ov_cnt'length);
					when others => -- bullshit
						counter_mts_1n6		<= counter_mts_1n6 + to_unsigned(5,15);
						counter_ov_cnt		<= counter_ov_cnt;
				end case;
				
				counter_ov_cnt_reg	<= counter_ov_cnt;
				if (fpga_overflow_happened = '1') then -- set counter
					fpga_overflow_lookback_cnt		<= to_unsigned(to_integer(unsigned(csr.expected_latency))*5 , fpga_overflow_lookback_cnt'length);
                    
				elsif (to_integer(fpga_overflow_lookback_cnt) <= to_integer(unsigned(csr.expected_latency))*5 and to_integer(fpga_overflow_lookback_cnt) /= 0) then
					fpga_overflow_lookback_cnt		<= fpga_overflow_lookback_cnt - 5; -- with underflow protection
				else
					fpga_overflow_lookback_cnt		<= (others => '0');
				end if;
				
				if (fpga_overflow_happened = '1') then 
                    lpm_multi_valid_cnt             <= to_unsigned(LPM_MULT_PIPELINE-1,lpm_multi_valid_cnt'length);
                elsif (lpm_multi_valid_cnt /= to_unsigned(0,lpm_multi_valid_cnt'length)) then 
                    lpm_multi_valid_cnt             <= lpm_multi_valid_cnt - 1;
                end if;
				
			end if;
		end if;
	end process;
	
	proc_gts_counter : process (i_clk)
	-- counter of the global timestamp on the FPGA
		-- needs to be 48 bit at 125 MHz
	begin
		if rising_edge(i_clk) then
			if (processor_state = RESET and reset_flow = SYNC) then 
				 -- reset counter
				counter_gts_8n		<= (others => '0');
			else
				-- begin counter
				counter_gts_8n		<= counter_gts_8n + to_unsigned(1,counter_gts_8n'length);
			end if;
		end if;
	end process;
	
	
	
	proc_padding_logic_comb : process (all)
	-- input: gray ts (cc_out from lut_ram)
	-- output: white ts (cc_gts_1n6_slv50), latch at the input stage of lpm div pipeline
		--variable cc_mts_1n6			: unsigned(14 downto 0); -- input 15 bit 
		--variable cc_gts_1n6			: unsigned(49 downto 0); -- padded to 50 bit
		
	begin
		if (counter_ov_cnt_reg /= counter_ov_cnt) then -- generate a pulse when overflow happened on fpga
			fpga_overflow_happened 	<= '1'; -- after reset it should be ok 
		else
			fpga_overflow_happened 	<= '0';
		end if;
		
		-- input
		padding_logic_gray_ts				<= unsigned(hit_padding.cc_out); -- padding the gray (decoded) ts to white ts
		padding_logic_gray_ts_e				<= unsigned(hit_padding.ecc_out); -- padding the gray (decoded) ts_e to white ts_e
	
		-- mts_1n6 (FPGA) will be faster/larger than receiving cc_mts_1n6 (MuTRiG), because of buffering, which is maximum two frame length (short=910 cycle, long = 1550 cycle; cycle=8ns)
		-- plus, a bit of cycles inside FPGA. 
		-- As a result, for small incoming hits, it is correct.
		-- For large incoming hits, the fpga counter might already overflowed, so we subtract 1 in overflow counter during this calculation.
		-- We set a fpga local time window. Only within this window, the subtraction is needed.
		
        -- fpga overflow, but mutrig hits didn't, and multiplier is updated 
		if (to_integer(padding_logic_gray_ts) > UPPER and to_integer(fpga_overflow_lookback_cnt) /= 0 and to_integer(lpm_multi_valid_cnt) = 0) then 
			--cc_gts_1n6		:= to_unsigned(cc_mts_1n6 + (to_integer(counter_ov_cnt)-1) * OVERFLOW_1N6, cc_gts_1n6'length);
			padding_logic_white_ts		<= padding_logic_gray_ts	+ unsigned(padding_logic_gts_product) - to_unsigned(OVERFLOW_1N6, 15);
		else 
			--cc_gts_1n6		:= to_unsigned(cc_mts_1n6 + to_integer(counter_ov_cnt) * OVERFLOW_1N6, cc_gts_1n6'length);
			padding_logic_white_ts		<= padding_logic_gray_ts	+ unsigned(padding_logic_gts_product);
		end if;

		if (to_integer(padding_logic_gray_ts_e) > UPPER and to_integer(fpga_overflow_lookback_cnt) /= 0 and to_integer(lpm_multi_valid_cnt) = 0) then 
			padding_logic_white_ts_e	<= padding_logic_gray_ts_e	+ unsigned(padding_logic_gts_product) - to_unsigned(OVERFLOW_1N6, 15);
		else 
			padding_logic_white_ts_e	<= padding_logic_gray_ts_e	+ unsigned(padding_logic_gts_product);
		end if;

	
		-- connect i/o
		
		-- output
		cc_gts_1n6_slv50		<= std_logic_vector(padding_logic_white_ts);
		ecc_gts_1n6_slv50		<= std_logic_vector(padding_logic_white_ts_e);
	
	end process;
	
	proc_avst2payload_comb : process (all)
	-- input validation from avst to the datapath
	begin
		-- default
		hit_in_ok		<= '0';
		if (processor_allow_input = '1') then -- allow input at run prep, running and terminating
			if (asi_hit_type0_error(HITERR_BIT_LOC) = '0' or csr.discard_hiterr = '0') then -- disable check or no error 
				hit_in_ok		<= '1'; -- in comb with avst valid
			end if;
		end if;
	
	end process;
	
	proc_discard_hit_cnt : process (i_rst, i_clk)
	-- count the hits discard by 1) hit error (if csr.discard_hiterr setting is enabled) 2) in wrong run state (e.g. idle (continue up), sync (something is wrong)
	-- , other state (TODO: add after term)) 
	begin
		if (i_rst = '1') then 
			debug_msg.discard_hit_cnt		<= (others => '0');
            debug_msg.total_hit_cnt			<= (others => '0');
		elsif (rising_edge(i_clk)) then 
            
			if (asi_hit_type0_valid = '1' and hit_in_ok = '0') then -- capture invalid error
				debug_msg.discard_hit_cnt		<= debug_msg.discard_hit_cnt + 1;
			elsif (reset_flow = SYNC or csr.soft_reset = '1') then -- soft reset by csr
				debug_msg.discard_hit_cnt		<= (others => '0'); -- sclr the counter
			end if;
			
			if (asi_hit_type0_valid = '1') then -- including errors
				debug_msg.total_hit_cnt			<= debug_msg.total_hit_cnt + 1;
			elsif (reset_flow = SYNC or csr.soft_reset = '1') then -- soft reset by csr
				debug_msg.total_hit_cnt			<= (others => '0');
			end if;
            

		end if;
	end process;
	
	proc_datapath_comb : process (all)
	begin
		cc_in			<= asi_hit_type0_data(I_TCC_HI downto I_TCC_LO); -- decode tcc
		ecc_in			<= asi_hit_type0_data(I_ECC_HI downto I_ECC_LO); -- decode ecc
	end process;
	
	proc_datapath : process (i_rst, i_clk) 
	--	
	begin
		if (i_rst = '1') then 
		
		
		elsif (rising_edge(i_clk)) then
			-- default 
			hit_in.asic		<= (others => '0');
			hit_in.channel	<= (others => '0');
			hit_in.t_cc		<= (others => '0');
			hit_in.t_fine	<= (others => '0');
			hit_in.e_cc		<= (others => '0');
			hit_in.e_flag	<= '0';
			hit_in.valid	<= '0';
			hit_in.hiterr	<= '0';
			--cc_in			<= (others => '0');
			
			
			hit_padding.asic	<= (others => '0');
			hit_padding.channel	<= (others => '0');
			hit_padding.cc_out	<= (others => '0');
			hit_padding.t_fine	<= (others => '0');
			hit_padding.e_cc	<= (others => '0');
			hit_padding.e_flag	<= '0';
			hit_padding.valid	<= '0';
			hit_padding.hiterr	<= '0';
			
			lpm_div_num_in		<= (others => '0');
			-- clr the input stage for debug purpose
			for i in 0 to 0 loop
				hit_div(i).asic			<= (others => '0');
				hit_div(i).channel		<= (others => '0');
				hit_div(i).t_fine		<= (others => '0');
				hit_div(i).e_cc			<= (others => '0');
				hit_div(i).e_flag		<= '0';
				hit_div(i).valid		<= '0';
				hit_div(i).hiterr		<= '0';
			end loop;
			
			hit_out.asic		<= (others => '0');
			hit_out.channel		<= (others => '0');
			hit_out.tcc_8n		<= (others => '0');
			hit_out.tcc_1n6		<= (others => '0');
			hit_out.tfine		<= (others => '0');
			hit_out.et_1n6		<= (others => '0');
			hit_out.valid		<= '0';
			hit_out.hiterr		<= '0';
				
				
				
			case running_hit_mode is 
				when SHORT =>
					-- input stage
					if (asi_hit_type0_valid = '1' and hit_in_ok = '1') then 
						hit_in.asic		<= asi_hit_type0_data(I_ASIC_HI downto I_ASIC_LO);
						hit_in.channel	<= asi_hit_type0_data(I_CHANNEL_HI downto I_CHANNEL_LO);
						hit_in.t_cc		<= asi_hit_type0_data(I_TCC_HI downto I_TCC_LO);
						--cc_in			<= asi_hit_type0_data(I_TCC_HI downto I_TCC_LO); -- decode tcc
						hit_in.t_fine	<= asi_hit_type0_data(I_TFINE_HI downto I_TFINE_LO);
						hit_in.e_flag   <= asi_hit_type0_data(I_EFLAG_BIT_LOC);
						hit_in.valid	<= '1';
						hit_in.hiterr	<= asi_hit_type0_error(HITERR_BIT_LOC);
					end if;
					
					-- pipeline for lut ram
					if (hit_in.valid = '1') then 
						hit_padding.asic		<= hit_in.asic;
						hit_padding.channel		<= hit_in.channel;
						hit_padding.cc_out		<= cc_out; -- decode
						hit_padding.ecc_out		<= ecc_out; -- decode
						hit_padding.e_flag		<= hit_in.e_flag;
						hit_padding.t_fine		<= hit_in.t_fine;
						hit_padding.valid		<= '1';
						hit_padding.hiterr		<= hit_in.hiterr;
					end if;
					
					-- lpm div pipeline input reg
					if (hit_padding.valid = '1') then 
						hit_div(0).asic			<= hit_padding.asic;
						hit_div(0).channel		<= hit_padding.channel;
						if (csr.bypass_lapse = '0') then  -- mts -> gts transformation enable 
							lpm_div_num_in											<= cc_gts_1n6_slv50;
						else -- mts -> gts transformation disable (this would result in random dist., which is simply for sanity check.) 
							lpm_div_num_in(hit_padding.cc_out'high downto 0)		<= hit_padding.cc_out;
						end if;

						-- e-flag : as a signed number, if negative, means wrong
						-- ecc not valid. note : seems flag=1 is bad, which is inverted?
						hit_div(0).et_1n6 		<= std_logic_vector(resize(unsigned(ecc_gts_1n6_slv50) - unsigned(cc_gts_1n6_slv50), hit_div(0).et_1n6'length)); -- msb for flag
						hit_div(0).et_1n6(hit_div(0).et_1n6'high)		<= not hit_padding.e_flag; -- flag_n overwrite the msb, '1' means no E-Flag, which means ECC is not valid
																								   -- note: this is used as et_1n6 are limited to lower bits, range from [23,128].
																								   -- range [129,511] is generally free of events, so [256,511] is used for invalid hits.
																								   -- note2: we could also use 5 bits of et_50p to extend the resolution of this TOT dist.
																								   -- this will require sacrifising a lot of the range, which will need add adjustable offset
																								   -- for E-T. 
						hit_div(0).t_fine		<= hit_padding.t_fine;
						hit_div(0).valid		<= '1';
						hit_div(0).hiterr		<= hit_padding.hiterr;
					end if;
					
					-- lpm div pipeline output reg
					if (hit_div(LPM_DIV_PIPELINE).valid = '1') then -- assemble the hit_out 
						hit_out.asic		<= hit_div(LPM_DIV_PIPELINE).asic;
						hit_out.channel		<= hit_div(LPM_DIV_PIPELINE).channel;
						hit_out.tcc_8n		<= lpm_div_quo_out(hit_out.tcc_8n'high downto 0); -- latch div result (quotient)
						hit_out.tcc_1n6		<= lpm_div_rem_out(hit_out.tcc_1n6'high downto 0); -- latch div result (remainder)
						hit_out.tfine		<= hit_div(LPM_DIV_PIPELINE).t_fine;
						hit_out.et_1n6		<= hit_div(LPM_DIV_PIPELINE).et_1n6;
						hit_out.valid		<= '1';
						hit_out.hiterr		<= hit_div(LPM_DIV_PIPELINE).hiterr;
					end if;
				when others =>
			end case;
		
		end if;
	
	end process;
	
	proc_div_pipeline : process (i_clk)
	begin
		if (rising_edge(i_clk)) then
			for i in 0 to LPM_DIV_PIPELINE-1 loop 
				hit_div(i+1)	<= hit_div(i);
			end loop;
		end if;
	end process;
	

	
	proc_payload2avst : process (i_rst, i_clk)
	-- assembly of avst ( hit type 1 )
	begin
		if (i_rst = '1') then 
			startofrun_sent		<= (others => '0');
		
		elsif (rising_edge(i_clk)) then
			-- TODO: add run states behaviors
			-- reg out stage
			if (processor_state = RUNNING) then 
				if (hit_out.valid = '1') then
					aso_hit_type1_data(O_ASIC_HI downto O_ASIC_LO)				<= hit_out.asic;
					aso_hit_type1_data(O_CHANNEL_HI downto O_CHANNEL_LO)		<= hit_out.channel;
					aso_hit_type1_data(O_TCC8N_HI downto O_TCC8N_LO)			<= hit_out.tcc_8n;
					aso_hit_type1_data(O_TCC1N6_HI downto O_TCC1N6_LO)			<= hit_out.tcc_1n6;
					aso_hit_type1_data(O_TFINE_HI downto O_TFINE_LO)			<= hit_out.tfine;
					aso_hit_type1_data(O_ET1N6_HI downto O_ET1N6_LO)			<= hit_out.et_1n6;
					aso_hit_type1_valid											<= '1';
					aso_hit_type1_channel										<= hit_out.asic;
				else 
					aso_hit_type1_data		<= (others => '0');
					aso_hit_type1_valid		<= '0';
					aso_hit_type1_channel	<= (others => '0');
				end if;
			elsif (processor_state = FLUSHING) then -- generate eop for all channels, do a round-robin arbitration if all channel wants to generate eop at the same cycle
				aso_hit_type1_valid											<= '0'; -- fixed 
				aso_hit_type1_data											<= (others => '0');
				aso_hit_type1_empty(0)										<= '1'; -- debug: downstream must ignore this beat
			else 
				aso_hit_type1_data		<= (others => '0');
				aso_hit_type1_valid		<= '0';
				aso_hit_type1_channel	<= (others => '0');
			end if;
			
			-- derive sop
			gen_sop : for i in ENABLED_CHANNEL_LO to ENABLED_CHANNEL_HI loop
				if (processor_state = RUNNING and startofrun_sent(i) = '0') then
					if (hit_out.valid = '1' and to_integer(unsigned(hit_out.channel)) = i) then
						aso_hit_type1_startofpacket		<= '1';
						startofrun_sent(i)				<= '1';
					else
						aso_hit_type1_startofpacket		<= '0';
					end if;
				elsif (processor_state = RESET) then
					startofrun_sent(i)					<= '0';
					aso_hit_type1_startofpacket			<= '0';
				else 
					aso_hit_type1_startofpacket		<= '0';
				end if;
			end loop gen_sop;
			
			-- derive eop_seen for all channels
			gen_packet_awareness : for i in ENABLED_CHANNEL_LO to ENABLED_CHANNEL_HI loop
				if (processor_state = RUNNING) then
					if (asi_hit_type0_endofpacket = '1' and asi_hit_type0_valid = '1') then -- eop is here
						if (to_integer(unsigned(asi_hit_type0_channel)) = i) then -- for this channel
							packet_in_transaction(i)		<= '0'; -- eop, output transaction,
							-- No new frame generated by assembly, but a frame could already in fifo.
							-- This is a speical case, we must check the fifo empty flag. 
							-- If empty, we are safe. Simply generate an empty beat with eop to mark the end of run for this channel. 
							-- If not empty, ... TODO: think about this corner case. connect headerinfo to it? Or, add a grace period for allowing new frame.
						end if;
					elsif (asi_hit_type0_startofpacket = '1' and asi_hit_type0_valid = '1') then -- sop is here
						if (to_integer(unsigned(asi_hit_type0_channel)) = i) then -- for this channel
							packet_in_transaction(i)		<= '1'; -- sop, indicating mutrig packet is continuing 
						end if;
					end if;
				elsif (processor_state = RESET) then -- reset this
					packet_in_transaction(i)		<= '0'; 
				end if;
			end loop gen_packet_awareness;
			
--			-- eop
--			gen_eop : for i in ENABLED_CHANNEL_LO to ENABLED_CHANNEL_HI loop
--				-- derive the internal eop signal 
--				if (processor_state = FLUSHING)
--					if (packet_in_transaction(i) = '1') then -- packet is in transaction, generate eop once eop of this channel is detected
--						if (asi_hit_type0_endofpacket = '1' and asi_hit_type0_valid = '1') then -- detect eop for mutrig frame
--							if (to_integer(unsigned(asi_hit_type0_channel)) = i) then -- for this channel
--								in_trans_eop(i)(0)			<= '1'; -- input to the delay pipeline
--							else
--								in_trans_eop(i)(0)			<= '0';
--							end if;
--						else
--							in_trans_eop(i)(0)			<= '0';
--						end if;
--					else -- not in trasaction, send an empty, valid, eop. 
--						missing_eop(i)			<= '1';
--						
--				
--				
--				
--				end if;
--				-- delay the internal eop signal
--				gen_eop_pipeline : for j in 0 to EOP_DELAY_CYCLE-2 loop
--					in_trans_eop(i)(j+1)	<= in_trans_eop(i)(j);
--			
--				end loop gen_eop_pipeline;
--				-- connect internal eop to streaming output
--				if ( in_trans_eop(i)(EOP_DELAY_CYCLE-2+1) 
--					aso_hit_type1_endofpacket			<= in_trans_eop(i)(EOP_DELAY_CYCLE-2+1); -- for each channel 
--			
--			end loop gen_eop;
			
			
			
		end if;
	end process;
    
    proc_debug_ts_comb : process (all)
    begin
        aso_debug_ts_data           <= int_aso_debug_ts_data;
	end process;
    
	proc_debug_ts : process (i_clk)
	begin
		if (rising_edge(i_clk)) then
			if (hit_div(LPM_DIV_PIPELINE).valid = '1') then -- 48 bit - 48 bit (no of/df)
				int_aso_debug_ts_data	<= std_logic_vector(to_signed( to_integer(counter_gts_8n) - to_integer(unsigned(lpm_div_quo_out)),aso_debug_ts_data'length));
				aso_debug_ts_valid		<= '1';
			else 
				aso_debug_ts_valid		<= '0';
			end if;
            
            -- --------------------------------------------
            -- derive the error signals of the datapath
            -- --------------------------------------------
            -- default 
            aso_hit_type1_error(0)           <= '0'; -- timing aligned with <hit_type1> valid
            if (aso_debug_ts_valid = '1') then 
                -- ok: ts within range of (0,2000)
                if (to_integer(signed(int_aso_debug_ts_data)) > 0 and to_integer(signed(int_aso_debug_ts_data)) < MUTRIG_BUFFER_EXPECTED_LATENCY_8N) then 
                    aso_hit_type1_error(0)      <= '0';
                -- error: ts out of range of (0,2000). possible pll unlocked or cml logic recv side is too low (generate a bit of side noise)
                else 
                    aso_hit_type1_error(0)      <= '1';
                end if;
            end if;
		end if;
	end process;
    
    
    -- ///////////////////////////////////////////////////////////////////////////////
    -- @name            debug_burst
    -- @brief           calculate the delta of timestamp and inter-arrival time
    --                  of adjacent hits. 
    --
    -- ///////////////////////////////////////////////////////////////////////////////
    proc_debug_burst : process (i_clk)
    -- 3 pipeline stages
    begin
        if (rising_edge(i_clk)) then 
            if (processor_state = RUNNING and i_rst = '0') then 
                -- default
                egress_valid                <= '0';
                delta_valid                 <= '0';
                aso_debug_burst_valid       <= '0';
                -- --------------
                -- latch new 
                -- --------------
                if (hit_div(LPM_DIV_PIPELINE).valid = '1') then -- 48 bit - 48 bit
                    -- timestamp
                    egress_timestamp(0)         <= lpm_div_quo_out(egress_timestamp(0)'high downto 0);
                    egress_timestamp(1)         <= egress_timestamp(0);
                    -- arrival
                    egress_arrival(0)           <= std_logic_vector(counter_gts_8n);
                    egress_arrival(1)           <= egress_arrival(0);
                    --
                    egress_valid                <= '1';
                end if;
             
                -- -------------------
                -- calculate deltas
                -- -------------------
                if (egress_valid = '1') then 
                    -- signed magnitude substraction (take care of underflow)
                    if (egress_timestamp(0) >= egress_timestamp(1)) then 
                        -- sorted
                        delta_timestamp(delta_timestamp'high)               <= '0';
                        delta_timestamp(delta_timestamp'high-1 downto 0)    <= std_logic_vector(unsigned(egress_timestamp(0)) - unsigned(egress_timestamp(1)))(delta_timestamp'high-1 downto 0); -- delta_timestamp = Hit_{t+1} - Hit_{t}
                    else 
                        -- unsorted
                        delta_timestamp(delta_timestamp'high)               <= '1';
                        delta_timestamp(delta_timestamp'high-1 downto 0)    <= std_logic_vector(unsigned(egress_timestamp(1)) - unsigned(egress_timestamp(0)))(delta_timestamp'high-1 downto 0);
                    end if;
                    -- unsigned sub.
                    delta_arrival               <= std_logic_vector(unsigned(egress_arrival(0)) - unsigned(egress_arrival(1)))(delta_arrival'high downto 0); -- delta_arrival = Hit_{t+1} - Hit_{t}
                    --
                    delta_valid                 <= '1';
                end if;
                
                -- -------
                -- trim
                -- -------
                if (delta_valid = '1') then 
                    -- [XX] [YY]
                    -- XX := timestamp (higher 8 bit). ex: 10 bit, range is -512 to 511, triming 2 bits yields -> -128 to 127
                    -- YY := interarrival time (higher 8 bit). ex 10 bit, range is 0 to 1023, triming 2 bits yields -> 0 to 255
                    aso_debug_burst_data(15 downto 8)           <= delta_timestamp(delta_timestamp'high downto delta_timestamp'high-7);
                    aso_debug_burst_data(7 downto 0)            <= delta_arrival(delta_arrival'high downto delta_arrival'high-7);
                    --
                    aso_debug_burst_valid                       <= '1';
                end if;
            else -- reset
                -- default
                egress_valid                <= '0';
                delta_valid                 <= '0';
                aso_debug_burst_valid       <= '0';
                egress_timestamp            <= (others => (others => '0'));
                egress_arrival              <= (others => (others => '0'));
                delta_timestamp             <= (others => '0');
                delta_arrival               <= (others => '0');
            end if;
        end if;
    
    
    end process;
	
	


	
	
	
end architecture rtl;










