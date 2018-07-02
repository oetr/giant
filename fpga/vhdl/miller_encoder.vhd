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
-- Component name: miller_encoder
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 14:40 08.02.2011
--
-- Description: Encoder to generate modulating signal
--              with miller encoding
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

library work;
use work.defaults.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity miller_encoder is
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- inputs
		
		-- write byte to buffer
		w_en : in std_logic;
		
		-- byte to write to output buffer
		data : in byte;
		
		-- send current contents of data buffer on rising edge
		transmit : in std_logic;
		
		-- number of data buffer bits to omit (0 ... 255)
		omit_count : in byte;
		
		-- outputs
		
		-- modulating signal (to be multiplied with carrier)
		encoded : out std_logic;
		
		-- currently transmitting?
		transmitting: out std_logic
	);
end miller_encoder;

architecture behavioral of miller_encoder is
   -- constants
	
	-- pulse timing
	constant PERIOD_END : unsigned(9 downto 0) := to_unsigned(944, 10);
	constant PAUSE_LENGTH : unsigned(9 downto 0) := to_unsigned(250, 10);
	constant PAUSE_MIDDLE_BEGIN : unsigned(9 downto 0) := to_unsigned(472, 10);
	constant PAUSE_MIDDLE_END : unsigned(9 downto 0) := to_unsigned((472 + 250 - 1), 10);

	-- internal state machine states
	type state_type is (S_IDLE, S_NOPAUSE, S_PAUSE_BEGIN, S_PAUSE_MIDDLE, S_NEXTBIT);
   
	
   -- components
	component data_buffer
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(7 downto 0);
			dina: in std_logic_vector(7 downto 0);
			clkb: in std_logic;
			addrb: in std_logic_vector(10 downto 0);
			doutb: out std_logic_vector(0 downto 0)
		);
	end component;
   
   -- signals
	
	-- FSM state
	signal state, state_next : state_type;
	
	-- number of bits in tx buffer
	signal tx_count, tx_count_next, tx_read_addr : unsigned(10 downto 0);
	
	-- transmission buffer (256 byte)
	signal tx_buffer_out : std_logic;
	
	-- helper signals for transmission state
   signal transmit_prev, w_en_prev : std_logic;
	signal transmitting_next : std_logic;
	signal encoded_next: std_logic;
	
	-- bit period counter (0...944)
	signal period_cnt, period_cnt_next : unsigned(9 downto 0);
	signal prev_bit, prev_bit_next : std_logic;
	signal eoc, eoc_next : std_logic;
begin
	BUF : data_buffer
		port map (
			clka => clk,
			wea(0) => w_en,
			addra => std_logic_vector(tx_count(10 downto 3)),
			dina => data,
			clkb => clk,
			addrb => std_logic_vector(tx_read_addr),
			doutb(0) => tx_buffer_out
		);
	
	tx_read_addr <= tx_count - 1;
	
	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_IDLE;
				transmitting <= '0';
				encoded <= '0';
				tx_count <= to_unsigned(0, tx_count'length);
				period_cnt <= to_unsigned(0, period_cnt'length);
				prev_bit <= '0';
				eoc <= '0';
				transmit_prev <= '0';
				w_en_prev <= '0';
			else
				transmit_prev <= transmit;
				state <= state_next;
				transmitting <= transmitting_next;
				encoded <= encoded_next;
				tx_count <= tx_count_next;
				period_cnt <= period_cnt_next;
				prev_bit <= prev_bit_next;
				eoc <= eoc_next;
				w_en_prev <= w_en;
			end if;
		end if;
	end process;
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, transmit, data, w_en, tx_count, tx_buffer_out, period_cnt,
		prev_bit, eoc, transmit_prev, omit_count)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		transmitting_next <= '0';
		encoded_next <= '1';
		period_cnt_next <= (others => '0');
		tx_count_next <= tx_count;
		prev_bit_next <= prev_bit;
		eoc_next <= eoc;
		
		-- edge detection
		case state is
			when S_IDLE =>
				if w_en_prev = '0' and w_en = '1' then
					-- insert into memory
					--tx_buffer(to_integer(tx_count+7) downto to_integer(tx_count)) <= data;
					tx_count_next <= tx_count + to_unsigned(8, tx_count'length);
				end if;
				
				-- start with SOC (pause at beginning)
				if transmit_prev = '0' and transmit = '1' then
					state_next <= S_PAUSE_BEGIN;
					tx_count_next <= tx_count - resize(unsigned(omit_count), tx_count'length);
					--tx_count_next <= tx_count - 1;
				end if;
				
			when S_NOPAUSE =>
				transmitting_next <= '1';
				
				if period_cnt = PERIOD_END then
					state_next <= S_NEXTBIT;
				else
					period_cnt_next <= period_cnt + 1;
				end if;
			
			when S_PAUSE_BEGIN => 
				transmitting_next <= '1';
				
				if period_cnt = PERIOD_END then
					state_next <= S_NEXTBIT;
				else
					if period_cnt < PAUSE_LENGTH then
						encoded_next <= '0';
					end if;
					
					period_cnt_next <= period_cnt + 1;
				end if;
			
			when S_PAUSE_MIDDLE =>
				transmitting_next <= '1';
				
				if period_cnt = PERIOD_END then
					state_next <= S_NEXTBIT;
				else
					if period_cnt > PAUSE_MIDDLE_BEGIN and period_cnt < PAUSE_MIDDLE_END then
						encoded_next <= '0';
					end if;
					
					period_cnt_next <= period_cnt + 1;
				end if;
				
			when S_NEXTBIT => 
					if eoc = '1' then
						eoc_next <= '0';
						state_next <= S_IDLE;
						tx_count_next <= (others => '0');
					elsif tx_count = to_unsigned(0, tx_count'length) then
					  transmitting_next <= '1';
					  
						if prev_bit = '0' then
							state_next <= S_PAUSE_BEGIN;
							prev_bit_next <= '0';
						else 
							state_next <= S_NOPAUSE;
							prev_bit_next <= '0';
						end if;	

						eoc_next <= '1';
					else
						transmitting_next <= '1';
						tx_count_next <= tx_count - 1;
						prev_bit_next <= tx_buffer_out;
						
						if tx_buffer_out = '1' then
							state_next <= S_PAUSE_MIDDLE;
						elsif prev_bit = '0' then
							state_next <= S_PAUSE_BEGIN;
						else 
							state_next <= S_NOPAUSE;
						end if;										
					end if;
		end case;
	end process;
end behavioral;