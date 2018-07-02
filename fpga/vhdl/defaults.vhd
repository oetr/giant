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
-- Package name: defaults
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 100902
--
-- Description: Default def's and functions
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

package defaults is
	-- constants
	
	-- types
	subtype u8 is unsigned(7 downto 0);
	type u8_vector is array(integer range <>) of u8;
	
	subtype byte is std_logic_vector(7 downto 0);
	type byte_vector is array(integer range <>) of byte;
	
	-- function declarations
	function log2_ceil(N : natural) return positive;
end defaults;

package body defaults is
	-- function definitions
	function log2_ceil(N : natural) return positive is
  begin
    if (N <= 2) then
        return 1;
    else
        if (N mod 2 = 0) then
            return 1 + log2_ceil(N/2);
        else
            return 1 + log2_ceil((N+1)/2);
        end if;
    end if;
  end function log2_ceil;
end defaults;