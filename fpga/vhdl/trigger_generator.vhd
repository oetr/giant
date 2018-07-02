----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:09 05/02/2011 
-- Design Name: 
-- Module Name:    trigger_generator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity trigger_generator is
	
	port (
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic; 
			
		-- command ports and pins
		arm : in std_logic;
		
		-- armed status
		armed : out std_logic;
		
		-- coarse trigger for sync
		coarse_trigger_en : in std_logic;
		coarse_trigger : in std_logic;
		
		-- force trigger (skips coarse and detector trigger)
		force_trigger : in std_logic;
		
		-- input data from pattern detector
		detector_in : in unsigned(15 downto 0);
		
		-- input FIFO for threshold (16 bit, 16 bit valid)
		threshold : in byte;
		threshold_w : in std_logic;
		
		-- trigger output
		trigger : out std_logic
	);
end trigger_generator;

architecture behavioral of trigger_generator is
	
	-- constants

	-- components
	component u8_to_parallel is
		generic(
			WIDTH : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			d_in : in byte;
			w_en : in std_logic;
			clear : in std_logic;
			count : out unsigned(log2_ceil(WIDTH)-1 downto 0);
			d_out : out std_logic_vector(WIDTH*8-1 downto 0)
		);
	end component;
	
	-- Trigger state machine
	type state_type is (
		S_IDLE,
		S_ARMED,
		S_COARSE_TRIGGERED,
		S_TRIGGERED
	);
	
	signal trigger_next : std_logic;
	signal state, state_next : state_type;
	signal arm_prev : std_logic;
	signal force_trigger_prev : std_logic;
	signal armed_next : std_logic;
	signal coarse_trigger_prev : std_logic;
	signal coarse_trigger_buf : std_logic;
	signal force_trigger_buf : std_logic;
	signal arm_buf : std_logic;
	signal threshold_buf : std_logic_vector(15 downto 0);
	signal threshold_unsigned : unsigned(15 downto 0);
	signal detector_in_buf : unsigned(15 downto 0);
begin

	SINGLE_WRITE_FIFO : u8_to_parallel
	generic map(
		WIDTH => 2
	)
	port map(
		clk => clk,
		reset => reset,
		d_in => threshold,
		w_en => threshold_w,
		clear => '0', 
		count => open, 
		d_out => threshold_buf
	);
	
	threshold_unsigned <= unsigned(threshold_buf);
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, arm_buf, arm_prev,
		coarse_trigger_buf, coarse_trigger_prev, coarse_trigger_en,
		detector_in_buf, threshold_unsigned, force_trigger_buf, force_trigger_prev)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		trigger_next <= '0';
		armed_next <= '0';
		
		case state is
			when S_IDLE =>
				if arm_buf = '1' and arm_prev = '0' then
				
					if coarse_trigger_en = '1' then
						state_next <= S_ARMED;
						armed_next <= '1';
					else
						state_next <= S_COARSE_TRIGGERED;
						armed_next <= '1';
					end if;
					
				end if;
			
			when S_ARMED =>
				armed_next <= '1';
				
				if force_trigger_buf = '1' and force_trigger_prev = '0' then
					armed_next <= '0';
					state_next <= S_TRIGGERED;
				elsif coarse_trigger_buf = '1' and coarse_trigger_prev = '0' then
					state_next <= S_COARSE_TRIGGERED;
				end if;

			when S_COARSE_TRIGGERED =>
				armed_next <= '1';
				
				if force_trigger_buf = '1' and force_trigger_prev = '0' then
					armed_next <= '0';
					state_next <= S_TRIGGERED;
				
				end if;
				
				if detector_in_buf < threshold_unsigned then
					armed_next <= '0';
					state_next <= S_TRIGGERED;
				end if;
				
			when S_TRIGGERED =>
				trigger_next <= '1';
				armed_next <= '0';
				state_next <= S_IDLE;
			
		end case;
	end process;
	
	-- state register update
	STATE_REG: process (clk, reset)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_IDLE;
				trigger <= '0';
				armed <= '0';
			else
				state <= state_next;
				trigger <= trigger_next;
				armed <= armed_next;
			end if;
		end if;
	end process;

	-- input buffering 
	BUFFERING: process (clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				arm_prev <= '0';
				coarse_trigger_prev <= '0';
				force_trigger_prev <= '0';
				arm_buf <= '0';
				coarse_trigger_buf <= '0';
				force_trigger_buf <= '0';
				detector_in_buf <= (others => '0');
			else
				arm_prev <= arm_buf;
				coarse_trigger_prev <= coarse_trigger_buf;
				force_trigger_prev <= force_trigger_buf;
				
				arm_buf <= arm;
				coarse_trigger_buf <= coarse_trigger;
				force_trigger_buf <= force_trigger;
				detector_in_buf <= detector_in;
			end if;
		end if;
	end process;
end behavioral;
