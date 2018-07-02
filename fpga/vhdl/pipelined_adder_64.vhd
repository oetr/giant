-----------------------------------------------------------------
-- 
-- Component name: pipelined_adder_64
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 100902
--
-- Description: Pipelined adder for 64 8-bit values
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

library work;
use work.defaults.all;

entity pipelined_adder_64 is
	port( 
		-- standard inputs
		clk : in std_logic;
		ce : in std_logic;
		
		-- inputs
		op : in u8_vector(63 downto 0);
		
		-- output
		sum : out unsigned(log2_ceil(64 * 255)-1 downto 0)
	);
end pipelined_adder_64;

architecture behavioral of pipelined_adder_64 is
	-- types
	subtype stage1_word is unsigned(log2_ceil(2*255)-1 downto 0);
	subtype stage2_word is unsigned(log2_ceil(4*255)-1 downto 0);
	subtype stage3_word is unsigned(log2_ceil(8*255)-1 downto 0);
	subtype stage4_word is unsigned(log2_ceil(16*255)-1 downto 0);
	subtype stage5_word is unsigned(log2_ceil(32*255)-1 downto 0);
	subtype stage6_word is unsigned(log2_ceil(64*255)-1 downto 0);

	type stage1_register is array(2**(6-1) - 1 downto 0) of stage1_word;
	type stage2_register is array(2**(6-2) - 1 downto 0) of stage2_word;
	type stage3_register is array(2**(6-3) - 1 downto 0) of stage3_word;
	type stage4_register is array(2**(6-4) - 1 downto 0) of stage4_word;
	type stage5_register is array(2**(6-5) - 1 downto 0) of stage5_word;
	type stage6_register is array(2**(6-6) - 1 downto 0) of stage6_word;

	-- constants

	-- components

	-- signals

	-- addition stage registers
	signal stage1 : stage1_register;
	signal stage2 : stage2_register;
	signal stage3 : stage3_register;
	signal stage4 : stage4_register;
	signal stage5 : stage5_register;
	signal stage6 : stage6_register;
begin
	-- constants
	
	-- components
	
	-- signals

	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				-- stage 1
				for i in 0 to 32-1 loop
				  stage1(i) <= resize(op(2*i), stage1(i)'length) + resize(op(2*i + 1), stage1(i)'length);
				end loop;

				-- stage 2
				for i in 0 to 16-1 loop
				  stage2(i) <= resize(stage1(2*i), stage2(i)'length) + resize(stage1(2*i + 1), stage2(i)'length);
				end loop;

				-- stage 3
				for i in 0 to 8-1 loop
				  stage3(i) <= resize(stage2(2*i), stage3(i)'length) + resize(stage2(2*i + 1), stage3(i)'length);
				end loop;
					  
					  -- stage 4
				for i in 0 to 4-1 loop
				  stage4(i) <= resize(stage3(2*i), stage4(i)'length) + resize(stage3(2*i + 1), stage4(i)'length);
				end loop;

				-- stage 5
				for i in 0 to 2-1 loop
				  stage5(i) <= resize(stage4(2*i), stage5(i)'length) + resize(stage4(2*i + 1), stage5(i)'length);
				end loop;

				-- stage 6
				for i in 0 to 1-1 loop
				  stage6(i) <= resize(stage5(2*i), stage6(i)'length) + resize(stage5(2*i + 1), stage6(i)'length);
				end loop;

				sum <= stage6(0);
		  end if;
		end if;
	end process;
end;
