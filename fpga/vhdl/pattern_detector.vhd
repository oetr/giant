-----------------------------------------------------------------
-- 
-- Component name: pattern_detector
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 100902
--
-- Description: Top-level for absolute difference pattern matching
--
-- Notes:
-- none
--  
-- Dependencies:
-- pipelined_adder_64
-- shift_register_u8
-- abs_diff
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

entity pattern_detector is
	port ( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		ce : in std_logic;
		
		-- pattern register input
		pattern_in : in u8;
		-- edge triggered write enable for pattern
		pattern_we: in std_logic;
		
		-- number of data points to use in the pattern
		pattern_sample_count : in unsigned(7 downto 0);
		
		-- signal (from ADC) input
		adc_in: in u8;
		
		-- ADC write enable (not edge triggered)
		adc_we : in std_logic;
		
		-- (absolute difference sum) output	
		d_out : out unsigned(15 downto 0)
	);
end pattern_detector;

architecture behavioral of pattern_detector is
	-- constants
	constant WIDTH : positive := 64;
	
	-- components
	component shift_register_u8 is
		generic(
			WIDTH : positive
		);
		port( 
			clk : in std_logic;
			ce : in std_logic;
			reset : in std_logic;
			d_in : in u8;
			d_out : out u8_vector(WIDTH-1 downto 0)
		);
	end component;
	
	component pipelined_adder_64 is
	--component pipelined_adder_128 is
		port( 
			clk : in std_logic;
			ce : in std_logic;
			op : in u8_vector(63 downto 0);
			--op : in u8_vector(127 downto 0);
			sum : out unsigned(log2_ceil(64 * 255)-1 downto 0)
			--sum : out unsigned(log2_ceil(128 * 255)-1 downto 0)
		);
	end component;
	
	component abs_diff is
		port( 
			clk : in std_logic;
			ce : in std_logic;
			reset : in std_logic;
			a : in u8;
			b : in u8;
			enable : in std_logic;
			c : out u8
		);
	end component;

	-- signals
	signal pattern_in_ce : std_logic;
	signal pattern_we_prev : std_logic;
	
	signal d_out1, d_out2 : u8_vector(WIDTH-1 downto 0);
	signal pointwise_abs_diff : u8_vector(WIDTH-1 downto 0);
	signal diff_enable : std_logic_vector(WIDTH-1 downto 0);
	--signal sum_abs_diff : unsigned(log2_ceil(64*255)-1 downto 0);
	signal sum_abs_diff : unsigned(log2_ceil(WIDTH*255)-1 downto 0);
begin
	-- constants
	
	-- components
	
	-- data and pattern register
	SR1 : shift_register_u8
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk => clk,
			ce => pattern_in_ce,
			reset => reset,
			d_in => pattern_in,
			d_out => d_out1
		);
		
	SR2 : shift_register_u8
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk => clk,
			ce => adc_we,
			reset => reset,
			d_in => adc_in,
			d_out => d_out2
		);
	
	-- computation of pointwise absolute difference
	ABS_DIFFS: for i in 0 to WIDTH-1 generate
		ABS_DIFF_I : abs_diff 
			port map(
				clk => clk,
				ce => ce,
				reset => reset,
				a => d_out1(i),
				b => d_out2(i),
				enable => diff_enable(i),
				c => pointwise_abs_diff(i)
			);
	end generate;
	
	-- summation over all differences (pipelined)
	ADDER : pipelined_adder_64 
	--ADDER : pipelined_adder_128 
		port map(
			clk => clk,
			ce => ce,
			op => pointwise_abs_diff,
			sum => sum_abs_diff
		);
		
	-- signals
	d_out(log2_ceil(64*255)-1 downto 0) <= sum_abs_diff;
	d_out(15 downto log2_ceil(64*255)) <= (others => '0');
	
	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				diff_enable <= (others => '0');
				pattern_we_prev <= '0';
				pattern_in_ce <= '0';
			else
				if to_integer(pattern_sample_count) < diff_enable'length then
					diff_enable(to_integer(pattern_sample_count)-1 downto 0) <= (others => '1');
					diff_enable(diff_enable'length-1 downto to_integer(pattern_sample_count)) <= (others => '0');
				else
					diff_enable <= (others => '1');
				end if;
				
				pattern_we_prev <= pattern_we;

				if pattern_we_prev = '0' and  pattern_we = '1' then
					pattern_in_ce <= '1';
				else
					pattern_in_ce <= '0';
				end if;
			end if;
		end if;
	end process;
	

end;
