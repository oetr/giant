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
-- Component name: sc_rx
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 09:20 06.01.2011
--
-- Description: ISO 7816 rx path
--
-- Notes:
-- none
--  
-- Dependencies:
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

entity sc_rx is
	generic(
		-- max. width of etu counter
		BITS_ETU : positive;
		-- max. width of timeout counter
		BITS_TIMEOUT : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- rx clock
		rx_clk : in std_logic;
		
		-- enable rx
		en : in std_logic;

		-- "elementary time unit" (etu) of signal in
		-- ticks of rx_clk
		etu : in unsigned(BITS_ETU-1 downto 0);
		
		-- Number of etu ticks before timing out when waiting for first byte
		timeout : in unsigned(BITS_TIMEOUT-1 downto 0);
		
		-- Number of etu ticks before timing out when waiting for next byte
		timeout_next_byte : in unsigned(BITS_TIMEOUT-1 downto 0);
		
		-- serial input
		serial_in : in std_logic;
		
		-- byte output
		byte_out : out byte;
		
		-- 1 if byte complete
		byte_complete : out std_logic;
		
		-- 1 on parity error
		parity_error : out std_logic;
		
		-- 1 on timeout
		timed_out : out std_logic;
		
		-- 1 to signal that a bit is sampled
		sampled_bit : out std_logic
		
	);
end sc_rx;

architecture behavioral of sc_rx is

	-- internal state machine states
	type state_type is (S_WAIT, S_RX);
	
	-- components
	
	-- signals
	
	-- edge detection
	signal serial_in_prev : std_logic;

	-- Counter for timeout
	signal timeout_count, timeout_count_next, timeout_reg, timeout_byte_reg : unsigned(BITS_TIMEOUT-1 downto 0);
	
	-- Counter for etu
	signal etu_count, etu_reg : unsigned(BITS_ETU-1 downto 0);
	signal etu_reset : std_logic;
	
	-- Counter for current bit (from 0 to 9)
	signal bit_count, bit_count_next : unsigned(3 downto 0);
	signal byte_complete_int, byte_complete_next : std_logic;
	
	-- shift register for current byte
	signal curr_byte, curr_byte_next : byte;
	signal curr_parity, curr_parity_next : std_logic;
	
	-- signal that at least one byte was read before timeout
	signal got_byte, got_byte_next : std_logic;

	-- FSM state
	signal state, state_next : state_type;

begin

	-- components
	
	-- signals
	
	-- processes
	
	-- etu counter
	COUNTER_ETU : process(rx_clk)
	begin
		if rising_edge(rx_clk) then
			if reset = '1' then
				etu_count <= (others => '0');
			else
				if etu_reset = '1' then
					etu_count <= etu - 1;
				elsif etu_count = to_unsigned(0, etu_count'length) then
					etu_count <= etu - 1;
				else
					etu_count <= etu_count - 1;
				end if;
			end if;
		end if;
	end process;
	
	parity_error <= curr_parity;
	byte_out <= curr_byte;
	byte_complete <= byte_complete_int;
	
	
	MAIN : process(rx_clk)
	begin
		if rising_edge(rx_clk) then
			if reset = '1' then
				state <= S_WAIT;
				serial_in_prev <= '0';	
				bit_count <= (others => '0');
				timeout_count <= (others => '0');
				curr_byte <= (others => '0');
				curr_parity <= '0';
				byte_complete_int <= '0';
				timeout_reg <= (others => '0');
				timeout_byte_reg <= (others => '0');
				etu_reg <= (others => '0');
				got_byte <= '0';
			elsif en = '1' then
				state <= state_next;
				serial_in_prev <= serial_in;
				bit_count <= bit_count_next;
				timeout_count <= timeout_count_next;
				curr_byte <= curr_byte_next;
				curr_parity <= curr_parity_next;
				byte_complete_int <= byte_complete_next;
				timeout_reg <=  timeout;
				timeout_byte_reg <= timeout_next_byte;
				etu_reg <= etu;
				got_byte <= got_byte_next;
			end if;
		end if;
	end process;
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, serial_in, serial_in_prev, etu_count, bit_count, timeout_count,
		curr_byte, curr_parity, byte_complete_int, timeout_reg, etu_reg, en, got_byte, 
		timeout_byte_reg)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		byte_complete_next <= byte_complete_int;
		timed_out <= '0';
		etu_reset <= '0';
		bit_count_next <= bit_count;
		curr_parity_next <= curr_parity;
		curr_byte_next <= curr_byte;
		timeout_count_next <= timeout_count;
		sampled_bit <= '0';
		got_byte_next <= got_byte;

		case state is
			when S_WAIT =>
				if en = '1' then
					-- start rx on falling edge of serial_in
					if serial_in = '0' and serial_in_prev = '1' then
						etu_reset <= '1';
						state_next <= S_RX;
						curr_byte_next <= (others => '0');
						bit_count_next <= (others => '0');
						curr_parity_next <= '0';
						byte_complete_next <= '0';
						timeout_count_next <= (others => '0');
						got_byte_next <= '1';
					elsif got_byte = '1' then
						-- timeout within byte frame
						if etu_count = to_unsigned(0, etu_count'length) then
							-- timeout
							if timeout_count = timeout_byte_reg then
								timed_out <= '1';
								got_byte_next <= '0';
							else	
								timeout_count_next <= timeout_count + 1;
							end if;
						end if;
					else
						-- longer timeout (having received nothing at all
						if etu_count = to_unsigned(0, etu_count'length) then
							-- timeout
							if timeout_count = timeout_reg then
								timed_out <= '1';
							else	
								timeout_count_next <= timeout_count + 1;
							end if;
						end if;
					end if;
				end if;
			when S_RX =>
				-- expect next bit here
				if etu_count = "0" & etu_reg(etu_reg'length-1 downto 1) then
					sampled_bit <= '1';
					
					if bit_count = to_unsigned(9, bit_count'length) then
						-- end of byte, back to wait
						
						-- check parity
						--if not (serial_in = curr_parity) then
						--	parity_error <= '1';
						--end if;
						curr_parity_next <= curr_parity xor serial_in;
						
						timeout_count_next <= (others => '0');
						byte_complete_next <= '1';
						state_next <= S_WAIT;
					else
						bit_count_next <= bit_count + 1;
						
						-- clock in bit & update parity
						curr_byte_next <= curr_byte(6 downto 0) & serial_in;
						curr_parity_next <= curr_parity xor serial_in;
					end if;
				end if;
		end case;
	end process;
end behavioral;