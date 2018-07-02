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
-- Component name: ask_modulator
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 091004
--
-- Description:
-- Amplitude Shift Keying modulator, with 13.56 MHz output waveform
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

entity ask_modulator is
	port( 
		-- standard inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- max value for output
		out_amplitude : in byte;
		
		-- modulating signal
		data : in std_logic;
		
		-- modulated output
		modulated : out byte
	);
end ask_modulator;

architecture behavioral of ask_modulator is
   -- constants
   
   -- components
	component rfid_freqgen
		port (
			clk: in std_logic;
			cosine: out byte
		);
	end component;
	
	component multiplier
		port (
			clk: in std_logic;
			a: in std_logic_vector(7 downto 0);
			b: in std_logic_vector(7 downto 0);
			ce: in std_logic;
			p: out std_logic_vector(7 downto 0)
		);
	end component;
   
   -- signals
	signal carrier_ac, modulated_ac, mod_ac : std_logic_vector(7 downto 0);
begin
	RFID_FREQGEN_INST : rfid_freqgen
	port map(
		clk => clk,
		cosine => carrier_ac
	);
	
	mod_ac <= std_logic_vector(out_amplitude) when data = '1' else
				 (others => '0');
	
	MODULATOR : multiplier
	port map(
		clk => clk,
		a => carrier_ac,
		b => mod_ac,
		ce => ce,
		p => modulated_ac
	);
			
	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				modulated <= (others => '0');
			else
				modulated <= std_logic_vector(signed(modulated_ac) + to_signed(128, modulated_ac'length));
			end if;
		end if;
	end process;
	
end behavioral;
