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
-- Component name: pic_programmer_tb
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 15:42 05.10.2010
--
-- Description: Testbench for programmer
--
-- Notes:
-- none
--  
-- Dependencies:
-- pic_programmer
-----------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

entity pic_programmer_tb is
end pic_programmer_tb;

architecture behavioral of pic_programmer_tb is
	-- constants
	
	-- Clock period definitions
	constant CLK_PERIOD : time := 10 ns;
	
	-- components
	component pic_programmer is
		generic(
			CLK_PERIOD : positive := 10
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			data_in : in std_logic_vector(21 downto 0);
			has_data : in std_logic;
			get_response : in std_logic;
			send : in std_logic;
			prog_startstop : in std_logic;
			programming: out std_logic;
			data_out : out std_logic_vector(13 downto 0);
			v_dd_en : out std_logic;
			v_pp_en : out std_logic;
			pgm : out std_logic;
			ispclk : inout std_logic;
			ispdat : inout std_logic
		);
	end component;
	

	-- signals
	signal clk, reset : std_logic;
	signal data_in : std_logic_vector(21 downto 0);
	signal has_data : std_logic;
	signal send : std_logic;
	signal get_response : std_logic;
	signal prog_startstop : std_logic;
	signal programming: std_logic;
	signal data_out : std_logic_vector(13 downto 0);
	signal v_dd_en : std_logic;
	signal v_pp_en : std_logic;
	signal pgm : std_logic;
	signal ispclk : std_logic;
	signal ispdat : std_logic;
	
begin
	-- constants
	
	-- components
	
	-- DUT
	DUT : pic_programmer
		generic map(
			CLK_PERIOD => 10
		)
		port map(
			clk => clk,
			reset => reset,
			data_in => data_in,
			send => send,
			has_data => has_data,
			get_response => get_response,
			prog_startstop => prog_startstop,
			programming => programming,
			data_out => data_out,
			v_dd_en => v_dd_en,
			v_pp_en => v_pp_en,
			pgm => pgm,
			ispclk => ispclk,
			ispdat => ispdat
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
		data_in <= "0000000000000000110110";
		get_response <= '1';
		prog_startstop <= '0';
		has_data <= '1';
		send <= '0';
		ispdat <= 'Z';
		
		-- hold reset state
		wait for CLK_PERIOD*5;
		
		reset <= '0';
		
		wait for CLK_PERIOD*5;
		
		
		-- start programming
		prog_startstop <= '1';
		wait for CLK_PERIOD;
		prog_startstop <= '0';
		wait for CLK_PERIOD;
		
		wait for 800*CLK_PERIOD;
		
		-- send command
		send <= '1';
		wait for CLK_PERIOD;	
		send <= '0';
		wait for CLK_PERIOD;
		
		
		
		-- wait to finish
		wait for CLK_PERIOD*5000;
		
		data_in <= "0000000000000000111000";
		get_response <= '1';
		has_data <= '0';
		send <= '0';

		
		-- send command
		send <= '1';
		wait for CLK_PERIOD;	
		send <= '0';
		wait for CLK_PERIOD;
		
		wait until rising_edge(ispclk);
		wait until rising_edge(ispclk);
		wait until rising_edge(ispclk);
		wait until rising_edge(ispclk);
		wait until rising_edge(ispclk);
		wait until rising_edge(ispclk);
		
		-- start bit
		wait until rising_edge(ispclk);
		ispdat <= '0';

		
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		wait until falling_edge(ispclk);
		ispdat <= '1';
		wait until falling_edge(ispclk);
		ispdat <= '0';
		
		-- stop bit
		wait until falling_edge(ispclk);
		ispdat <= '0';
		
		
		wait for CLK_PERIOD*30;
		ispdat <= 'Z';
		
		wait;
	end process;
	

end;
