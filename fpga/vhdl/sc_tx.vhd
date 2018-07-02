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
-- Component name: sc_tx
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 09:20 06.01.2011
--
-- Description: ISO 7816 tx path
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

entity sc_tx is
	generic(
		-- max. width of etu counter
		BITS_ETU : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- tx clock (divided) for etu counting
		tx_clk : in std_logic;

		-- "elementary time unit" (etu) of signal in
		-- ticks of tx_clk
		etu : in unsigned(BITS_ETU-1 downto 0);
		
		-- start transmission on rising edge
		transmit : in std_logic;
		
		-- byte input
		byte_in : in byte;
		
		-- serial output
		serial_out : inout std_logic;
		
		-- 1 if byte complete
		byte_complete : out std_logic
		
	);
end sc_tx;

architecture behavioral of sc_tx is

	-- internal state machine states
	type state_type is (S_WAIT, S_TX);
	
	-- components
	
	-- signals
	
	-- edge detection
	signal transmit_prev : std_logic;
	
	-- Counter for etu
	signal etu_count : unsigned(BITS_ETU-1 downto 0);
	signal etu_reset : std_logic;
	signal etu_overflow, etu_overflow_prev : std_logic;
	
	-- Counter for current bit + 12 Guard Time (from 0 to 31)
	signal bit_count, bit_count_next : unsigned(4 downto 0);
	signal byte_complete_int, byte_complete_next : std_logic;
	
	-- shift register for current byte
	signal curr_byte, curr_byte_next : byte;
	signal curr_parity, curr_parity_next : std_logic;
	
	-- output mux
	signal serial_out_oe, serial_out_oe_next : std_logic;
	signal serial_out_int, serial_out_int_next : std_logic;

	-- FSM state
	signal state, state_next : state_type;

begin

	-- components
	
	-- signals
	
	-- processes
	
	-- etu counter
	COUNTER_ETU : process(tx_clk)
	begin
		if rising_edge(tx_clk) then
			if reset = '1' then
				etu_count <= (others => '0');
				etu_overflow <= '0';
			else
				if etu_reset = '1' then
					etu_count <= (others => '0');
					etu_overflow <= '0';
				elsif etu_count = etu - 1 then
					etu_count <= (others => '0');
					etu_overflow <= '1';
				else
					etu_count <= etu_count + 1;
					etu_overflow <= '0';
				end if;
			end if;
		end if;
	end process;

	byte_complete <= byte_complete_int;
	
	
--	MAIN : process(tx_clk)
--	begin
--		if rising_edge(tx_clk) then
--			if reset = '1' then
--				transmit_prev <= '0';
--			else
--				transmit_prev <= transmit;
--			end if;
--		end if;
--	end process;
	
	MAIN_SLOW : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_WAIT;	
				bit_count <= (others => '0');
				curr_byte <= (others => '0');
				curr_parity <= '0';
				byte_complete_int <= '0';
				etu_overflow_prev <= '0';
				transmit_prev <= '0';
				serial_out_oe <= '0';
				serial_out_int <= '0';
			else
				state <= state_next;
				bit_count <= bit_count_next;
				curr_byte <= curr_byte_next;
				curr_parity <= curr_parity_next;
				byte_complete_int <= byte_complete_next;
				etu_overflow_prev <= etu_overflow;
				transmit_prev <= transmit;
				serial_out_oe <= serial_out_oe_next;
				serial_out_int <= serial_out_int_next;
			end if;
		end if;
	end process;
	
	serial_out <= serial_out_int when serial_out_oe = '1' else 'Z';
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, etu_count, bit_count,
		curr_byte, curr_parity, byte_complete_int, transmit,
		transmit_prev, byte_in, serial_out_oe, serial_out_int, etu_overflow, etu_overflow_prev)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		byte_complete_next <= byte_complete_int;
		etu_reset <= '0';
		bit_count_next <= bit_count;
		curr_parity_next <= curr_parity;
		curr_byte_next <= curr_byte;
		serial_out_oe_next <= serial_out_oe;
		serial_out_int_next <= serial_out_int;

		case state is
			when S_WAIT =>
				-- start rx on rising edge on transmit
				etu_reset <= '1';
				
				if transmit = '1' and transmit_prev = '0' then
					curr_byte_next <= byte_in;
					
					curr_parity_next <= (byte_in(0) xor byte_in(1))
						xor (byte_in(2) xor byte_in(3)) 
						xor (byte_in(4) xor byte_in(5))
						xor (byte_in(6) xor byte_in(7));
					
					-- send start bit
					serial_out_int_next <= '0';
					serial_out_oe_next <= '1';
					
					bit_count_next <= (others => '0');

					byte_complete_next <= '0';
					
					state_next <= S_TX;
				end if;
			when S_TX =>
				etu_reset <= '0';
				
				-- send next bit here
				if etu_overflow = '1' and etu_overflow_prev = '0' then
					if bit_count < to_unsigned(8, bit_count'length) then
						-- shift out, MSB first
						curr_byte_next <= "0" & curr_byte(7 downto 1);
						serial_out_int_next <= curr_byte(0);
						
						bit_count_next <= bit_count + 1;
					elsif bit_count < to_unsigned(9, bit_count'length) then
						-- parity
						serial_out_int_next <= curr_parity;
						
						bit_count_next <= bit_count + 1;
					elsif bit_count < to_unsigned(9 + 5, bit_count'length) then
						-- guard time
						serial_out_oe_next <= '0';
						
						bit_count_next <= bit_count + 1;
					else
						state_next <= S_WAIT;
						byte_complete_next <= '1';
					end if;
				end if;
		end case;
	end process;
end behavioral;