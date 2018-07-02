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
-- Component name: u8_to_parallel
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 090415
--
-- Description: Bytewise serial to parallel converter
--
-- Notes:
-- none
--  
-- Dependencies:
-- none
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

entity u8_to_parallel is
	generic(
		-- input width in byte 
		WIDTH : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- inputs
		d_in : in byte;
		-- rising-edge triggered write enable
		w_en : in std_logic;
		
		
		-- rising-edge triggered clear count
		clear : in std_logic;
		
		-- outputs	
		count : out unsigned(log2_ceil(WIDTH)-1 downto 0);
		d_out : out std_logic_vector(WIDTH*8-1 downto 0)
	);
end u8_to_parallel;

architecture behavioral of u8_to_parallel is
   -- constants
   constant BITS_WIDTH : positive := log2_ceil(WIDTH);
   
   -- components
   
   -- signals
   signal reg : std_logic_vector(WIDTH*8 - 1 downto 0);
   signal count_i : unsigned(BITS_WIDTH-1 downto 0);
   --signal d_out_buf : byte;
	signal clear_prev, w_en_prev : std_logic;
begin
	-- constants
	
	-- components
	
	-- signals
	d_out <= reg;

	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => '0');
				count_i <= (others => '0');
				--d_out_buf <= (others => '0');
				clear_prev <= '0';
				w_en_prev <= '0';
			-- clear counter (higher priority than write)
			elsif clear = '1' and clear_prev = '0' then
				count_i <= (others => '0');
				clear_prev <= clear;
				w_en_prev <= w_en;
			-- write (lower priority than read)
			elsif w_en = '1' and w_en_prev = '0' then
				-- overwrite LSB with new byte, i.e., shift to left
				reg(7 downto 0) <= d_in;
				
				for i in 0 to WIDTH-2 loop
					reg(8*(i + 2)-1 downto 8*(i+1)) <= reg(8*(i+1)-1 downto 8*i);
				end loop;

				if count_i < WIDTH then
					count_i <= count_i+1;
				end if;
				
				--d_out_buf <= d_in;
				
				clear_prev <= clear;
				w_en_prev <= w_en;
			else
				clear_prev <= clear;
				w_en_prev <= w_en;
			end if;
		end if;
	end process;
	
	-- output counter
	count <= count_i;
end;
