-----------------------------------------------------------------
-- This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
--
-- Visit www.sourceforge.net/projects/giant/
--
-- Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License version 3 as
-- published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see http://www.gnu.org/licenses/.
-----------------------------------------------------------------

-----------------------------------------------------------------
-- 
-- Component name: pic_programmer
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 12:02 30.09.2010
--
-- Description: Interface to store PIC programming data
--
-- Notes:
-- none
--  
-- Dependencies:
--
--
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- common stuff
library work;
use work.defaults.all;

-- for Xilinx primitives
library UNISIM;
use UNISIM.vcomponents.all;

entity pic_programmer is
  generic(
    -- clock period in ns
    CLK_PERIOD : positive := 10
  );
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- inputs
		
		-- command to send to PIC, 6 command bits + 16 data bits (optional)
		data_in : in std_logic_vector(21 downto 0);
		
		-- data bits present?
		has_data : in std_logic;

		-- set if current command expects a response
		get_response : in std_logic;
		
		-- send data_in on rising edge
		send : in std_logic;
		
		-- enter/leave pic programming mode on rising edge
		prog_startstop : in std_logic;
		
		-- power up AND send data on rising edge
		start_and_send : in std_logic;

		-- outputs
		
		-- interface to uC
		
		-- currently programming?
		programming: out std_logic;
		
		-- data output (data sent back from PIC)
		data_out : out std_logic_vector(13 downto 0);

		-- interface to PIC
		v_dd_en : out std_logic;
		v_pp_en : out std_logic;
		pgm : out std_logic;
		
		ispclk : out std_logic;
		ispdat : inout std_logic
	);
end pic_programmer;

architecture behavioral of pic_programmer is
  -- constants
	
	-- length of isp_clk cycle in ns
	constant PERIOD_ISPCLK : positive := 4000;
	
	-- length of T_PPDP in ns
	constant T_PPDP : positive := 6000;

	-- length of T_HLD0 in ns
	constant T_HLD0 : positive := 500;
	
	-- length of T_DELAY in ns
	constant T_DELAY : positive := 8000;
		
	-- converted to ticks at CLK_PERIOD
	constant PERIOD_ISPCLK_VAL : positive := PERIOD_ISPCLK/CLK_PERIOD;
	constant BITS_PERIOD_ISPCLK : positive := log2_ceil(PERIOD_ISPCLK_VAL);
	
	constant T_PPDP_VAL : positive := T_PPDP/CLK_PERIOD;
	constant T_HLD0_VAL : positive := T_HLD0/CLK_PERIOD;
	constant T_DELAY_VAL : positive := T_DELAY/CLK_PERIOD;
	constant BITS_T_PPDP : positive := log2_ceil(T_PPDP_VAL);
	constant BITS_T_DELAY : positive := log2_ceil(T_DELAY_VAL);
  
	-- internal state machine states
	type state_type is (S_OFF, S_IDLE, S_POWER_UP, S_WAIT_INITIAL, S_SEND_COMMAND, S_SEND_DELAY, S_SEND_DATA, S_READ_DATA, S_POWER_DOWN);
	
	-- signals
	
	-- ISP clock divider counter
	signal isp_clk_counter : unsigned(BITS_PERIOD_ISPCLK - 1 downto 0);
	signal isp_clk_gen, isp_clk_gen_prev, isp_clk_reset: std_logic;
	signal ispclk_int, ispclk_int_next : std_logic;
	signal ispdat_int, ispdat_int_next : std_logic;
	signal ispdat_oe, ispdat_oe_next : std_logic;
	
	-- output shift register for isp data
	signal isp_out, isp_out_next : std_logic_vector(21 downto 0);
	
	-- counter and end values for input/output bits (max. 16/16)
	signal isp_out_count, isp_out_count_next : unsigned(4 downto 0);
	signal isp_in_count, isp_in_count_next  : unsigned(4 downto 0);
	
	-- input shift register for data from PIC + input enable
	signal isp_in, isp_in_next : std_logic_vector(13 downto 0);
	
	-- Power up/down counter
	signal power_ud_count, power_ud_count_next : unsigned(BITS_T_PPDP-1 downto 0);
	
	-- Counter for command/data delay
	signal delay_count, delay_count_next : unsigned(BITS_T_DELAY-1 downto 0);
	
	-- Force transmission after power up
	signal force_transmit, force_transmit_next : std_logic; 
	
	-- edge detection
	signal prog_startstop_prev : std_logic;
	signal send_prev : std_logic;
	signal start_and_send_prev : std_logic;
	
	-- FSM state
	signal state, state_next : state_type;
	

begin
	
	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_OFF;
				isp_out <= (others => '0');
				isp_in <= (others => '0');
				power_ud_count <= (others => '0');
				delay_count <= (others => '0');
				isp_in_count <= (others => '0');
				isp_out_count <= (others => '0');
				ispclk_int <= '0';
				ispdat_int <= '0';
				ispdat_oe <= '0';
				force_transmit <= '0';
				
				prog_startstop_prev <= '0';
				start_and_send_prev <= '0';
				send_prev <= '0';
				isp_clk_gen_prev <= '0';
			else
				state <= state_next;
				isp_out <= isp_out_next;
				isp_in <= isp_in_next;
				power_ud_count <= power_ud_count_next;
				delay_count <= delay_count_next;
				isp_in_count <= isp_in_count_next;
				isp_out_count <= isp_out_count_next;
				ispclk_int <= ispclk_int_next ;
				ispdat_int <= ispdat_int_next ;
				ispdat_oe <= ispdat_oe_next;
				force_transmit <= force_transmit_next;
				
				-- edge detection
				prog_startstop_prev <= prog_startstop;
				start_and_send_prev <= start_and_send;
				send_prev <= send;
				isp_clk_gen_prev <= isp_clk_gen;
			end if;
		end if;
	end process;
	
	data_out <= isp_in;
	
	ispclk <= ispclk_int;
	ispdat <= ispdat_int when ispdat_oe = '1' else 'Z';
	pgm <= ispdat_oe;
	
	-- ISP clock
	ISP_CLOCKGEN : process(clk)
	begin
		if rising_edge(clk) then
			if isp_clk_reset = '1' then
				isp_clk_counter <= to_unsigned(0, isp_clk_counter'length);
				isp_clk_gen <= '0';
			else
				if isp_clk_counter = to_unsigned(PERIOD_ISPCLK_VAL/2, isp_clk_counter'length) then
					isp_clk_gen <= not isp_clk_gen;
					isp_clk_counter <= to_unsigned(0, isp_clk_counter'length);
				else
					isp_clk_counter <= isp_clk_counter + 1;
				end if;
			end if;
		end if;
	end process;
	
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, data_in, prog_startstop, prog_startstop_prev,
		get_response, isp_in, isp_out, power_ud_count, send, send_prev, isp_in_count, 
		isp_out_count, isp_clk_gen, isp_clk_gen_prev, delay_count, ispclk_int, ispdat_int,
		has_data, ispdat, ispdat_oe, start_and_send, start_and_send_prev, force_transmit)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		isp_out_next <= isp_out;
		isp_in_next <= isp_in;
		programming <= '0';
		v_pp_en <= '0';
		v_dd_en <= '0';
		power_ud_count_next <= power_ud_count;
		delay_count_next <= (others => '0');
		ispdat_int_next  <= ispdat_int;
		ispdat_oe_next  <= ispdat_oe;
		ispclk_int_next  <= ispclk_int;
		isp_in_count_next <= isp_in_count;
		isp_out_count_next <= isp_out_count;
		isp_clk_reset <= '0';
		force_transmit_next <= force_transmit;
		--ispdat_oe <= '1';
		
		-- edge detection
		case state is
			when S_OFF =>
				-- go to S_POWER_UP on rising edge on prog_startstop
				isp_clk_reset <= '1';
				
				if prog_startstop = '1' and prog_startstop_prev = '0' then
					state_next <= S_POWER_UP;
					power_ud_count_next <= to_unsigned(T_HLD0_VAL, power_ud_count_next'length);
					ispdat_int_next <= '0';
					ispclk_int_next <= '0';
					ispdat_oe_next <= '1';
					force_transmit_next <= '0';
				elsif start_and_send = '1' and start_and_send_prev = '0' then
					state_next <= S_POWER_UP;
					power_ud_count_next <= to_unsigned(T_HLD0_VAL, power_ud_count_next'length);
					ispdat_int_next <= '0';
					ispclk_int_next <= '0';
					ispdat_oe_next <= '1';
					force_transmit_next <= '1';
				end if;
			when S_POWER_UP =>
				-- Power up sequence:
				-- V_PP directly, V_DD min. 5 mus T_PPDP, before data 
				-- 0 - 1 mus T_HLD0
				v_pp_en <= '1';
				v_dd_en <= '0';
				programming <= '1';
				
				if power_ud_count = 0 then
					v_dd_en <= '1';
					power_ud_count_next <= to_unsigned(T_PPDP_VAL, power_ud_count_next'length);
					state_next <= S_WAIT_INITIAL;
				else
					v_dd_en <= '0';
					power_ud_count_next <= power_ud_count - 1;
				end if;
			when S_WAIT_INITIAL =>
				-- 0 - 1 mus T_HLD0
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';
				
				if power_ud_count = 0 then
					state_next <= S_IDLE;
				else
					power_ud_count_next <= power_ud_count - 1;
				end if;
			when S_IDLE =>
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';
				ispdat_oe_next <= '1';
				ispclk_int_next <= '0';
				
				-- exit programming mode on rising edge
				if prog_startstop = '1' and prog_startstop_prev = '0' then
					state_next <= S_POWER_DOWN;
					power_ud_count_next <= to_unsigned(T_HLD0, power_ud_count_next'length);
				elsif (send = '1' and send_prev = '0') or force_transmit = '1' then
					state_next <= S_SEND_COMMAND;
					isp_out_count_next <= (others => '0');
					isp_in_count_next <= (others => '0');
					isp_clk_reset <= '1';
					isp_out_next <= data_in;
					ispdat_int_next <= '0';
					force_transmit_next <= '0';
				end if;

			when S_SEND_COMMAND => 
				-- send bits from tx buffer
				-- (update isp_out_next)
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';
				
				ispclk_int_next <= isp_clk_gen;

				if isp_clk_gen = '1' and isp_clk_gen_prev <= '0' then
					if isp_out_count = 6 then
					
						ispclk_int_next <= '0';
						
						if has_data = '1' then
							isp_out_count_next <= (others => '0');
							state_next <= S_SEND_DELAY;
						elsif get_response = '1' then
							state_next <= S_SEND_DELAY;
							ispdat_oe_next <= '0';
						else
							state_next <= S_IDLE;
						end if;
					else	
						isp_out_count_next <= isp_out_count + 1;
					
						-- clock out bit
						isp_out_next <= "0" & isp_out(isp_out'length-1 downto 1);
						ispdat_int_next <= isp_out(0); 
						--ispdat <= isp_out(0); 
					end if;
				end if;
				
			when S_SEND_DELAY => 
				-- wait t_delay
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';
				--ispdat_oe <= '0';
				
				if delay_count = to_unsigned(T_DELAY_VAL-1, delay_count'length) then
					isp_clk_reset <= '1';
					delay_count_next <= (others => '0');
					
					if has_data = '1' then
						state_next <= S_SEND_DATA;
						ispdat_oe_next <= '1';
					elsif get_response = '1' then
						state_next <= S_READ_DATA;
						ispdat_oe_next <= '0';
						--ispdat <= 'Z';
					else
						state_next <= S_IDLE;
					end if;
				else
					delay_count_next <= delay_count + 1;
				end if;	
				
			when S_SEND_DATA => 
				-- send 16 bits from tx buffer
				-- (update isp_out_next)
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';

				ispclk_int_next  <= isp_clk_gen;
				
				if isp_clk_gen = '1' and isp_clk_gen_prev <= '0' then
					if isp_out_count = 16 then
						ispclk_int_next  <= '0';
						state_next <= S_IDLE;
					else	
						isp_out_count_next <= isp_out_count + 1;
					
						-- clock out bit
						isp_out_next <= "0" & isp_out(isp_out'length-1 downto 1);
						ispdat_int_next <= isp_out(0); 
						--ispdat <= isp_out(0); 
					end if;
				end if;
				
			when S_READ_DATA => 
				-- read 16 bits to rx buffer
				-- (into isp_in_next)
				v_pp_en <= '1';
				v_dd_en <= '1';
				programming <= '1';
				--ispdat_oe <= '0';
				--ispdat_int_next <= 'Z';
				
				ispclk_int_next  <= isp_clk_gen;
				if isp_clk_gen = '1' and isp_clk_gen_prev <= '0' then

					if isp_in_count = 16 then
						ispclk_int_next <= '0';
						--ispdat_oe_next <= '1';
						state_next <= S_IDLE;
					else	
						isp_in_count_next <= isp_in_count + 1;
					
						-- clock in bit
						if isp_in_count <= 15 then
							isp_in_next <= ispdat & isp_in(isp_in'length - 1 downto 1);
						end if;
					end if;
				end if;
				
			when S_POWER_DOWN =>
				-- Power down sequence:
				-- V_PP directly, V_DD 0 - 1 mus T_HLD0
				v_pp_en <= '0';
				
				if power_ud_count = 0 then
					v_dd_en <= '0';
					state_next <= S_OFF;
				else
					power_ud_count_next <= power_ud_count - 1;
					v_dd_en <= '1';
				end if;
				
		end case;
	end process;
end behavioral;