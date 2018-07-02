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
-- Component name: sc_tx_tb
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 11:48 02.02.2011
--
-- Description: Testbench for sc_tx
--
-- Notes:
-- none
--  
-- Dependencies:
-- sc_tx
-----------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

entity sc_tx_tb is
end sc_tx_tb;

architecture behavioral of sc_tx_tb is
	-- constants
	
	-- Clock period definitions
	constant CLK_PERIOD : time := 10 ns;
	
	-- components
	component sc_tx is
		generic(
			BITS_ETU : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			etu : in unsigned(BITS_ETU-1 downto 0);
			transmit : in std_logic;
			byte_in : in byte;
			serial_out : inout std_logic;
			byte_complete : out std_logic
		);
	end component;

	constant etu_d : positive := 371;
	constant BITS_etu_d : positive := log2_ceil(etu_d);
	
	-- signals
	signal clk, reset : std_logic;
	signal etu : unsigned(BITS_ETU_d-1 downto 0);
	signal transmit : std_logic;
	signal byte_in : byte;
	signal serial_out : std_logic;
	signal byte_complete : std_logic;
	
begin
	-- constants
	
	-- components
	
	-- DUT
	DUT : sc_tx generic map(
		BITS_ETU => BITS_ETU_d
	)
	port map(
		clk => clk,
		reset => reset,
		etu => etu,
		transmit => transmit,
		byte_in => byte_in,
		serial_out => serial_out,
		byte_complete => byte_complete
	);
	
	-- processes
	
	-- Generate clock
	CLK_PROCESS :process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;
 
	-- Stimulus process
	STIM_PROC: process
	begin
		reset <= '1';
		etu <= to_unsigned(etu_d, etu'length);
		transmit <= '0';
		byte_in <= "11010111";
		
		-- hold reset state
		wait for CLK_PERIOD*5;
		
		reset <= '0';
		
		wait for CLK_PERIOD*5;
		
		
		-- start programming
		transmit <= '1';
		wait for CLK_PERIOD;
		transmit <= '0';
		wait for CLK_PERIOD;
		
		wait for 8000*CLK_PERIOD;		
		
		byte_in <= "00001111";
		
		-- start programming
		transmit <= '1';
		wait for CLK_PERIOD;
		transmit <= '0';
		wait for CLK_PERIOD;
		
		wait;
	end process;
end;
