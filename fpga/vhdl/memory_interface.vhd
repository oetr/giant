----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:09 05/02/2011 
-- Design Name: 
-- Module Name:    memory_interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity memory_interface is
	generic
	(
		C3_P0_MASK_SIZE           : integer := 4;
		C3_P0_DATA_PORT_SIZE      : integer := 32;
		C3_P1_MASK_SIZE           : integer := 4;
		C3_P1_DATA_PORT_SIZE      : integer := 32;
		C3_NUM_DQ_PINS          : integer := 16; 
		C3_MEM_ADDR_WIDTH       : integer := 13; 
		C3_MEM_BANKADDR_WIDTH   : integer := 2 
	);
	port (
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic; 
			
		-- command ports and pins
		
		-- input FIFO and write trigger for single memory word (32 bit)
		single_write	 : in byte;
		single_write_w	 : in std_logic;
		single_write_commit : in std_logic;
		
		-- output FIFO and read trigger for single memory word (32 bit)
		single_read	 	 : out byte;
		single_read_r	 : in std_logic;
		single_read_commit : in std_logic;
		
		-- input FIFO for memory address (32 bit, 28 bit valid)
		address : in byte;
		address_w : in std_logic;
		
		-- input FIFO for burst length (24 bit, 20 bit valid)
		block_count      : in byte;
		block_count_w    : in std_logic;
		
		-- edge-triggered signal to start slave FIFO read
		slave_fifo_start : in std_logic;
		
		-- status register output
		status : out byte;
		
		-- DDR I/O connections
		mcb3_dram_dq    : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
		mcb3_dram_a     : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
		mcb3_dram_ba    : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
		mcb3_dram_cke   : out std_logic;
		mcb3_dram_ras_n : out std_logic;
		mcb3_dram_cas_n : out std_logic;
		mcb3_dram_we_n  : out std_logic;
		mcb3_dram_dm    : out std_logic;
		mcb3_dram_udqs  : inout  std_logic;
		mcb3_rzq        : inout  std_logic;
		mcb3_dram_udm   : out std_logic;
		mcb3_dram_dqs   : inout  std_logic;
		mcb3_dram_ck    : out std_logic;
		mcb3_dram_ck_n  : out std_logic;

		-- Write DMA (ADC, pattern detection etc.)
		
		-- rising edge on this pin triggers a block DMA write
		dma_start     : in std_logic;
		-- DMA data input port
		dma_input       : in std_logic_vector(15 downto 0);

		-- USB FIFO interface
		IFCLK         : in std_logic;
		FD            : out std_logic_vector(15 downto 0); 
		SLOE          : out std_logic;
		SLRD          : out std_logic;
		SLWR          : out std_logic;
		FIFOADR0      : out std_logic;
		FIFOADR1      : out std_logic;
		PKTEND        : out std_logic;
		EMPTYFLAGC	  : in std_logic;
		FULLFLAGB	  : in std_logic;
		FLAGA	      : in std_logic
	);
end memory_interface;

architecture behavioral of memory_interface is
	
	-- constants
	constant C3_P0_DATA_PORT_SIZE_BYTE  : integer := C3_P0_DATA_PORT_SIZE/8;
	constant C3_P1_DATA_PORT_SIZE_BYTE  : integer := C3_P1_DATA_PORT_SIZE/8;
	
	-- components
	component memory_controller is
		generic
		(
			C3_P0_MASK_SIZE           : integer := 4;
			C3_P0_DATA_PORT_SIZE      : integer := 32;
			C3_P1_MASK_SIZE           : integer := 4;
			C3_P1_DATA_PORT_SIZE      : integer := 32;
			C3_MEMCLK_PERIOD        : integer := 5000;  -- Memory data transfer clock period.
			C3_RST_ACT_LOW          : integer := 0;   -- # = 1 for active low reset, 0 for active high reset.
			C3_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; 
			C3_CALIB_SOFT_IP        : string := "FALSE"; 
			C3_SIMULATION           : string := "FALSE"; 
			DEBUG_EN                : integer := 0; 
			C3_MEM_ADDR_ORDER       : string := "ROW_BANK_COLUMN"; 
			C3_NUM_DQ_PINS          : integer := 16; 
			C3_MEM_ADDR_WIDTH       : integer := 13; 
			C3_MEM_BANKADDR_WIDTH   : integer := 2 
		);
		port
		(
			mcb3_dram_dq        : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
			mcb3_dram_a         : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
			mcb3_dram_ba        : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
			mcb3_dram_cke       : out std_logic;
			mcb3_dram_ras_n     : out std_logic;
			mcb3_dram_cas_n     : out std_logic;
			mcb3_dram_we_n      : out std_logic;
			mcb3_dram_dm        : out std_logic;
			mcb3_dram_udqs      : inout  std_logic;
			mcb3_rzq            : inout  std_logic;
			mcb3_dram_udm       : out std_logic;
			c3_sys_clk          : in  std_logic;
			c3_sys_rst_i        : in  std_logic;
			c3_calib_done       : out std_logic;
			c3_clk0             : out std_logic;
			c3_rst0             : out std_logic;
			mcb3_dram_dqs       : inout  std_logic;
			mcb3_dram_ck        : out std_logic;
			mcb3_dram_ck_n      : out std_logic;
			c3_p0_cmd_clk       : in std_logic;
			c3_p0_cmd_en        : in std_logic;
			c3_p0_cmd_instr     : in std_logic_vector(2 downto 0);
			c3_p0_cmd_bl        : in std_logic_vector(5 downto 0);
			c3_p0_cmd_byte_addr : in std_logic_vector(29 downto 0);
			c3_p0_cmd_empty     : out std_logic;
			c3_p0_cmd_full      : out std_logic;
			c3_p0_wr_clk        : in std_logic;
			c3_p0_wr_en         : in std_logic;
			c3_p0_wr_mask       : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
			c3_p0_wr_data       : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_wr_full       : out std_logic;
			c3_p0_wr_empty      : out std_logic;
			c3_p0_wr_count      : out std_logic_vector(6 downto 0);
			c3_p0_wr_underrun   : out std_logic;
			c3_p0_wr_error      : out std_logic;
			c3_p0_rd_clk        : in std_logic;
			c3_p0_rd_en         : in std_logic;
			c3_p0_rd_data       : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
			c3_p0_rd_full       : out std_logic;
			c3_p0_rd_empty      : out std_logic;
			c3_p0_rd_count      : out std_logic_vector(6 downto 0);
			c3_p0_rd_overflow   : out std_logic;
			c3_p0_rd_error      : out std_logic;
			c3_p1_cmd_clk       : in std_logic;
			c3_p1_cmd_en        : in std_logic;
			c3_p1_cmd_instr     : in std_logic_vector(2 downto 0);
			c3_p1_cmd_bl        : in std_logic_vector(5 downto 0);
			c3_p1_cmd_byte_addr : in std_logic_vector(29 downto 0);
			c3_p1_cmd_empty     : out std_logic;
			c3_p1_cmd_full      : out std_logic;
			c3_p1_wr_clk        : in std_logic;
			c3_p1_wr_en         : in std_logic;
			c3_p1_wr_mask       : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
			c3_p1_wr_data       : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_wr_full       : out std_logic;
			c3_p1_wr_empty      : out std_logic;
			c3_p1_wr_count      : out std_logic_vector(6 downto 0);
			c3_p1_wr_underrun   : out std_logic;
			c3_p1_wr_error      : out std_logic;
			c3_p1_rd_clk        : in std_logic;
			c3_p1_rd_en         : in std_logic;
			c3_p1_rd_data       : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
			c3_p1_rd_full       : out std_logic;
			c3_p1_rd_empty      : out std_logic;
			c3_p1_rd_count      : out std_logic_vector(6 downto 0);
			c3_p1_rd_overflow   : out std_logic;
			c3_p1_rd_error      : out std_logic;
			c3_p2_cmd_clk       : in std_logic;
			c3_p2_cmd_en        : in std_logic;
			c3_p2_cmd_instr     : in std_logic_vector(2 downto 0);
			c3_p2_cmd_bl        : in std_logic_vector(5 downto 0);
			c3_p2_cmd_byte_addr : in std_logic_vector(29 downto 0);
			c3_p2_cmd_empty     : out std_logic;
			c3_p2_cmd_full      : out std_logic;
			c3_p2_rd_clk        : in std_logic;
			c3_p2_rd_en         : in std_logic;
			c3_p2_rd_data       : out std_logic_vector(31 downto 0);
			c3_p2_rd_full       : out std_logic;
			c3_p2_rd_empty      : out std_logic;
			c3_p2_rd_count      : out std_logic_vector(6 downto 0);
			c3_p2_rd_overflow   : out std_logic;
			c3_p2_rd_error      : out std_logic;
			c3_p3_cmd_clk       : in std_logic;
			c3_p3_cmd_en        : in std_logic;
			c3_p3_cmd_instr     : in std_logic_vector(2 downto 0);
			c3_p3_cmd_bl        : in std_logic_vector(5 downto 0);
			c3_p3_cmd_byte_addr : in std_logic_vector(29 downto 0);
			c3_p3_cmd_empty     : out std_logic;
			c3_p3_cmd_full      : out std_logic;
			c3_p3_rd_clk        : in std_logic;
			c3_p3_rd_en         : in std_logic;
			c3_p3_rd_data       : out std_logic_vector(31 downto 0);
			c3_p3_rd_full       : out std_logic;
			c3_p3_rd_empty      : out std_logic;
			c3_p3_rd_count      : out std_logic_vector(6 downto 0);
			c3_p3_rd_overflow   : out std_logic;
			c3_p3_rd_error      : out std_logic
		);
	end component;
	
	component parallel_to_u8 is
		generic(
			WIDTH : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			d_in : in std_logic_vector(WIDTH*8-1 downto 0);
			w_en : in std_logic;
			r_en : in std_logic;
			d_out : out byte;
			count : out unsigned(log2_ceil(WIDTH)-1 downto 0)
		);
	end component;

	component u8_to_parallel is
		generic(
			WIDTH : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			d_in : in byte;
			w_en : in std_logic;
			clear : in std_logic;
			count : out unsigned(log2_ceil(WIDTH)-1 downto 0);
			d_out : out std_logic_vector(WIDTH*8-1 downto 0)
		);
	end component;
	
	-- DDR control (common)
	signal c3_sys_rst_n        : std_logic;
	signal c3_calib_done       : std_logic;
	signal c3_rst0             : std_logic;
	
	-- DDR control signals (port 0)
	signal c3_p0_cmd_en        : std_logic;
	signal c3_p0_cmd_en_next   : std_logic;
	
	signal c3_p0_cmd_instr      : std_logic_vector(2 downto 0);
	signal c3_p0_cmd_instr_next : std_logic_vector(2 downto 0);
	
	signal c3_p0_cmd_bl        : std_logic_vector(5 downto 0);
	signal c3_p0_cmd_bl_next   : std_logic_vector(5 downto 0);
	
	signal c3_p0_cmd_byte_addr      : std_logic_vector(29 downto 0);
	signal c3_p0_cmd_byte_addr_next : std_logic_vector(29 downto 0);
	
	signal c3_p0_cmd_empty     : std_logic;
	signal c3_p0_cmd_full      : std_logic;
	
	signal c3_p0_wr_en         : std_logic;
	signal c3_p0_wr_en_next    : std_logic;
	
	signal c3_p0_wr_mask       : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
	signal c3_p0_wr_mask_next  : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
	
	signal c3_p0_wr_data       : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
	signal c3_p0_wr_data_next  : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
	
	signal c3_p0_wr_full       : std_logic;
	signal c3_p0_wr_empty      : std_logic;
	signal c3_p0_wr_count      : std_logic_vector(6 downto 0);
	signal c3_p0_wr_underrun   : std_logic;
	signal c3_p0_wr_error      : std_logic;
	
	signal c3_p0_rd_en         : std_logic;
	signal c3_p0_rd_en_next    : std_logic;
	
	signal c3_p0_rd_data       : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);

	signal c3_p0_rd_full       : std_logic;
	signal c3_p0_rd_empty      : std_logic;
	signal c3_p0_rd_count      : std_logic_vector(6 downto 0);
	signal c3_p0_rd_overflow   : std_logic;
	signal c3_p0_rd_error      : std_logic;   

	-- DDR control signals (port 1, 2, 3)
	type DDR_DATA_ARRAY is array(2 downto 0) of std_logic_vector(C3_p1_DATA_PORT_SIZE-1 downto 0);
	type DDR_COUNT_ARRAY is array(2 downto 0) of std_logic_vector(6 downto 0);
	
	signal c3_pX_cmd_en        : std_logic_vector(2 downto 0);
	signal c3_pX_cmd_en_next   : std_logic_vector(2 downto 0);
	
	signal c3_pX_cmd_instr      : std_logic_vector(2 downto 0);
	signal c3_pX_cmd_instr_next : std_logic_vector(2 downto 0);
	
	signal c3_pX_cmd_bl        : std_logic_vector(5 downto 0);
	signal c3_pX_cmd_bl_next   : std_logic_vector(5 downto 0);
	
	signal c3_pX_cmd_byte_addr      : std_logic_vector(29 downto 0);	
	signal c3_pX_cmd_byte_addr_next : std_logic_vector(29 downto 0);	
	
	signal c3_pX_cmd_empty     : std_logic_vector(2 downto 0);
	signal c3_pX_cmd_full      : std_logic_vector(2 downto 0);
	signal c3_p1_wr_en         : std_logic;
	signal c3_p1_wr_mask       : std_logic_vector(C3_p1_MASK_SIZE - 1 downto 0);
	signal c3_p1_wr_data       : std_logic_vector(C3_p1_DATA_PORT_SIZE - 1 downto 0);	
	signal c3_p1_wr_full       : std_logic;
	signal c3_p1_wr_empty      : std_logic;
	signal c3_p1_wr_count      : std_logic_vector(6 downto 0);
	signal c3_p1_wr_underrun   : std_logic;
	signal c3_p1_wr_error      : std_logic;	
	signal c3_pX_rd_en         : std_logic_vector(2 downto 0);	
	
	signal c3_pX_rd_data       : DDR_DATA_ARRAY;
	signal c3_pX_rd_data_buf   : DDR_DATA_ARRAY;
	
	signal c3_pX_rd_full       : std_logic_vector(2 downto 0);
	
	signal c3_pX_rd_empty      : std_logic_vector(2 downto 0);
	signal c3_pX_rd_empty_buf  : std_logic_vector(2 downto 0);
	
	signal c3_pX_rd_count      : DDR_COUNT_ARRAY;
	signal c3_pX_rd_overflow   : std_logic_vector(2 downto 0);
	signal c3_pX_rd_error      : std_logic_vector(2 downto 0);  
	
	-- Main DDR state machine
	type state_type is (
		S_IDLE,
		S_READ_COMMAND, S_READ_DATA,
		S_WRITE_COMMAND, S_WRITE_DATA,
		S_SLAVE_FIFO, S_DMA_WRITE
	);
	
	signal state, state_next : state_type;
	
	-- DMA control signals 
	signal ddr_dma_enabled : std_logic;
	signal ddr_dma_enabled_next : std_logic;
	signal ddr_dma_word : std_logic;
	signal ddr_dma_word_next : std_logic;
	signal ddr_dma_word_buffer : std_logic_vector(15 downto 0);
	signal ddr_dma_word_buffer_next : std_logic_vector(15 downto 0);
	signal ddr_dma_word_count : unsigned(26 downto 0);
	signal ddr_dma_word_count_next : unsigned(26 downto 0);
	signal ddr_dma_address : unsigned(29 downto 0);
	signal ddr_dma_address_next : unsigned(29 downto 0);
	
	-- DDR read/write
	signal ddr_data_valid : std_logic;
	signal ddr_data_valid_next : std_logic;
	
	signal ddr_address : std_logic_vector(31 downto 0);
	signal ddr_block_count : std_logic_vector(23 downto 0);
	signal ddr_write_buf : std_logic_vector(C3_P0_DATA_PORT_SIZE-1 downto 0);
	signal ddr_read_buf : std_logic_vector(C3_P0_DATA_PORT_SIZE-1 downto 0);
	
	-- control from main to read FIFO
	signal ddr_fifo_go : std_logic;
	signal ddr_fifo_go_next : std_logic;
	signal ddr_fifo_go_we : std_logic;
	signal ddr_fifo_go_we_next : std_logic;
	signal ddr_fifo_done_buf : std_logic;
	
	-- DCM
	signal locked : std_logic;
	signal clk_in : std_logic;
	
	-- edge detection
	signal single_read_commit_prev : std_logic;
	signal single_write_commit_prev : std_logic;
	signal slave_fifo_start_prev : std_logic;
	signal dma_start_prev : std_logic;
	
	-- Slave FIFO interface state machine
	type fifo_state_type is (
		S_IDLE,
		S_ENABLED,
		S_DONE
	);
	
	signal ddr_fifo_state : fifo_state_type;
	signal ddr_fifo_state_next : fifo_state_type;
	
	signal ddr_fifo_go_buf1 : std_logic;
	signal ddr_fifo_go_buf2 : std_logic;
	signal ddr_fifo_go_buf_prev : std_logic;
	signal ddr_address_buf : std_logic_vector(29 downto 0);
	signal ddr_block_count_buf : std_logic_vector(23 downto 0);
	signal ddr_block_count_ifclk_buf : std_logic_vector(23 downto 0);
	signal ddr_fifo_done : std_logic;
	signal ddr_fifo_done_next : std_logic;
	signal ddr_pktend : std_logic;
	signal ddr_pktend_next : std_logic;
	signal ddr_fifo_read_count : unsigned(6 downto 0);
	signal ddr_fifo_read_count_next : unsigned(6 downto 0);
	signal ddr_read_port : unsigned(1 downto 0);
	signal ddr_read_port_next : unsigned(1 downto 0);
	signal ddr_fifo_block_count : unsigned(19 downto 0);
	signal ddr_fifo_block_count_next : unsigned(19 downto 0);
	signal ddr_fifo_read_address_next : std_logic_vector(29 downto 0);
	signal ddr_fifo_slwr_buf : std_logic;
	signal ddr_fifo_slwr_buf_next : std_logic;
	signal ddr_fifo_word : std_logic;
	signal ddr_fifo_word_next : std_logic;
	signal ddr_fifo_FD_buf1, ddr_fifo_FD_buf2 : std_logic_vector(15 downto 0);
	signal ddr_fifo_FD_buf1_next, ddr_fifo_FD_buf2_next : std_logic_vector(15 downto 0);

begin

	-- default assignments for some signals
	SLOE       <= '0';
	SLRD       <= '0';
	FIFOADR0   <= '0';
	FIFOADR1   <= '1';
	
	c3_p1_wr_en <= '0';

	-- Slave FIFO read
	slwr <= ddr_fifo_slwr_buf;
	FD <= ddr_fifo_FD_buf1; 
	PKTEND <= ddr_pktend;

	MEMC_inst : memory_controller
	generic map (
		C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
		C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
		C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
		C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE
	)
	port map (
		-- to DDR IC
		mcb3_dram_dq     => mcb3_dram_dq,  
		mcb3_dram_a      => mcb3_dram_a,  
		mcb3_dram_ba     => mcb3_dram_ba,
		mcb3_dram_ras_n  => mcb3_dram_ras_n,                        
		mcb3_dram_cas_n  => mcb3_dram_cas_n,                        
		mcb3_dram_we_n   => mcb3_dram_we_n,                          
		mcb3_dram_cke    => mcb3_dram_cke,                          
		mcb3_dram_ck     => mcb3_dram_ck,                          
		mcb3_dram_ck_n   => mcb3_dram_ck_n,       
		mcb3_dram_dqs    => mcb3_dram_dqs,                          
		mcb3_dram_udqs   => mcb3_dram_udqs,    -- for X16 parts           
		mcb3_dram_udm    => mcb3_dram_udm,     -- for X16 parts
		mcb3_dram_dm     => mcb3_dram_dm,
		
		-- control signals
		c3_sys_clk       => clk,                     
		c3_sys_rst_i     => reset,                  
		c3_calib_done    => c3_calib_done,                     
		c3_clk0          => open,                     
		c3_rst0          => c3_rst0,
		
		c3_p0_cmd_clk    => clk,                 
		c3_p0_cmd_en     => c3_p0_cmd_en,                      
		c3_p0_cmd_instr  => c3_p0_cmd_instr,                      
		c3_p0_cmd_bl        => c3_p0_cmd_bl,            
		c3_p0_cmd_byte_addr => c3_p0_cmd_byte_addr,                 
		c3_p0_cmd_empty     => c3_p0_cmd_empty,                 
		c3_p0_cmd_full      => c3_p0_cmd_full,               
		c3_p0_wr_clk        => clk,          
		c3_p0_wr_en         => c3_p0_wr_en,            
		c3_p0_wr_mask       => c3_p0_wr_mask,          
		c3_p0_wr_data       => c3_p0_wr_data,           
		c3_p0_wr_full       => c3_p0_wr_full,           
		c3_p0_wr_empty      => c3_p0_wr_empty,          
		c3_p0_wr_count      => c3_p0_wr_count,         
		c3_p0_wr_underrun   => c3_p0_wr_underrun,       
		c3_p0_wr_error      => c3_p0_wr_error,        
		c3_p0_rd_clk        => clk,      
		c3_p0_rd_en         => c3_p0_rd_en,         
		c3_p0_rd_data       => c3_p0_rd_data,        
		c3_p0_rd_full       => c3_p0_rd_full,        
		c3_p0_rd_empty      => c3_p0_rd_empty,       
		c3_p0_rd_count      => c3_p0_rd_count,      
		c3_p0_rd_overflow   => c3_p0_rd_overflow,      
		c3_p0_rd_error      => c3_p0_rd_error,

		c3_p1_cmd_clk    => IFCLK,                 
		c3_p1_cmd_en     => c3_pX_cmd_en(0),                      
		c3_p1_cmd_instr  => c3_pX_cmd_instr,                      
		c3_p1_cmd_bl        => c3_pX_cmd_bl,            
		c3_p1_cmd_byte_addr => c3_pX_cmd_byte_addr,                 
		c3_p1_cmd_empty     => c3_pX_cmd_empty(0),                 
		c3_p1_cmd_full      => c3_pX_cmd_full(0),               
		c3_p1_wr_clk        => IFCLK,          
		c3_p1_wr_en         => c3_p1_wr_en,            
		c3_p1_wr_mask       => c3_p1_wr_mask,          
		c3_p1_wr_data       => c3_p1_wr_data,           
		c3_p1_wr_full       => c3_p1_wr_full,           
		c3_p1_wr_empty      => c3_p1_wr_empty,          
		c3_p1_wr_count      => c3_p1_wr_count,         
		c3_p1_wr_underrun   => c3_p1_wr_underrun,       
		c3_p1_wr_error      => c3_p1_wr_error,        
		c3_p1_rd_clk        => IFCLK,      
		c3_p1_rd_en         => c3_pX_rd_en(0),         
		c3_p1_rd_data       => c3_pX_rd_data(0),        
		c3_p1_rd_full       => c3_pX_rd_full(0),            
		c3_p1_rd_empty      => c3_pX_rd_empty(0),       
		c3_p1_rd_count      => c3_pX_rd_count(0),      
		c3_p1_rd_overflow   => c3_pX_rd_overflow(0),      
		c3_p1_rd_error      => c3_pX_rd_error(0),  

		c3_p2_cmd_clk    => IFCLK,                 
		c3_p2_cmd_en     => c3_pX_cmd_en(1),                      
		c3_p2_cmd_instr  => c3_pX_cmd_instr,                      
		c3_p2_cmd_bl        => c3_pX_cmd_bl,            
		c3_p2_cmd_byte_addr => c3_pX_cmd_byte_addr,                 
		c3_p2_cmd_empty     => c3_pX_cmd_empty(1),                 
		c3_p2_cmd_full      => c3_pX_cmd_full(1),                     
		c3_p2_rd_clk        => IFCLK,      
		c3_p2_rd_en         => c3_pX_rd_en(1),         
		c3_p2_rd_data       => c3_pX_rd_data(1),        
		c3_p2_rd_full       => c3_pX_rd_full(1),            
		c3_p2_rd_empty      => c3_pX_rd_empty(1),       
		c3_p2_rd_count      => c3_pX_rd_count(1),      
		c3_p2_rd_overflow   => c3_pX_rd_overflow(1),      
		c3_p2_rd_error      => c3_pX_rd_error(1),
		
		c3_p3_cmd_clk    => IFCLK,                 
		c3_p3_cmd_en     => c3_pX_cmd_en(2),                      
		c3_p3_cmd_instr  => c3_pX_cmd_instr,                      
		c3_p3_cmd_bl        => c3_pX_cmd_bl,            
		c3_p3_cmd_byte_addr => c3_pX_cmd_byte_addr,                 
		c3_p3_cmd_empty     => c3_pX_cmd_empty(2),                 
		c3_p3_cmd_full      => c3_pX_cmd_full(2),                     
		c3_p3_rd_clk        => IFCLK,      
		c3_p3_rd_en         => c3_pX_rd_en(2),         
		c3_p3_rd_data       => c3_pX_rd_data(2),        
		c3_p3_rd_full       => c3_pX_rd_full(2),            
		c3_p3_rd_empty      => c3_pX_rd_empty(2),       
		c3_p3_rd_count      => c3_pX_rd_count(2),      
		c3_p3_rd_overflow   => c3_pX_rd_overflow(2),      
		c3_p3_rd_error      => c3_pX_rd_error(2)
	);
	
	-- RAM for clock domain sync
	RAM32X1S_inst : RAM32X1S
	generic map (
		INIT => X"00000000"
	)
	port map (
		O => ddr_fifo_go_buf1,       -- RAM output
		A0 => '0',     -- RAM address[0] input
		A1 => '0',     -- RAM address[1] input
		A2 => '0',     -- RAM address[2] input
		A3 => '0',     -- RAM address[3] input
		A4 => '0',     -- RAM address[4] input
		D => ddr_fifo_go,       -- RAM data input
		WCLK => clk, -- Write clock input
		WE => ddr_fifo_go_we      -- Write enable input
	);
	
	-- Reader on DDR port 1 read FIFO
	SLAVE_FIFO_READ: process (IFCLK, reset)
	begin
		if reset = '1' then
			c3_pX_cmd_instr <= "001";
			c3_pX_cmd_bl <= "111111"; 
			c3_pX_cmd_byte_addr <= (others => '0');         		
			
			ddr_fifo_state <= S_IDLE;
			ddr_fifo_done <= '0';
			ddr_fifo_read_count <= to_unsigned(64, ddr_fifo_read_count'length);
			ddr_fifo_block_count <= (others => '0');
			ddr_fifo_slwr_buf <= '0';
			ddr_fifo_word <= '0';
			ddr_fifo_FD_buf1 <= (others => '0');
			ddr_fifo_FD_buf2 <= (others => '0');
			ddr_read_port <= (others => '0');
			
			ddr_address_buf <= (others => '0');
			ddr_block_count_ifclk_buf <= (others => '0');
			c3_pX_rd_data_buf <= (others => (others => '0'));
			c3_pX_rd_empty_buf <= (others => '0');
			ddr_pktend <= '0';
			ddr_fifo_go_buf2 <= '0';
			ddr_fifo_go_buf_prev <= '0';
		elsif rising_edge(IFCLK) then
			c3_pX_cmd_instr <= c3_pX_cmd_instr_next;
			c3_pX_cmd_bl <= c3_pX_cmd_bl_next;         		
			c3_pX_cmd_byte_addr <= c3_pX_cmd_byte_addr_next;
			
			ddr_fifo_state        <= ddr_fifo_state_next;      
			ddr_fifo_done         <= ddr_fifo_done_next;         
			ddr_fifo_read_count   <= ddr_fifo_read_count_next;   
			ddr_fifo_block_count  <= ddr_fifo_block_count_next;  
			ddr_fifo_slwr_buf     <= ddr_fifo_slwr_buf_next;          
			ddr_fifo_word         <= ddr_fifo_word_next;         
			ddr_fifo_FD_buf1      <= ddr_fifo_FD_buf1_next;      
			ddr_fifo_FD_buf2      <= ddr_fifo_FD_buf2_next;      
			ddr_pktend 	          <= ddr_pktend_next;
			ddr_read_port         <= ddr_read_port_next;
			
			ddr_address_buf <= ddr_address(29 downto 0);
			ddr_block_count_ifclk_buf <= ddr_block_count_buf;
			c3_pX_rd_data_buf <= c3_pX_rd_data;
			c3_pX_rd_empty_buf <= c3_pX_rd_empty;
			ddr_fifo_go_buf2 <= ddr_fifo_go_buf1;
			ddr_fifo_go_buf_prev <= ddr_fifo_go_buf2;
		end if;
	end process;
	
		
	FIFO_STATEMACHINE : process(ddr_fifo_state,
		ddr_fifo_done, ddr_address_buf, ddr_block_count_ifclk_buf,
		ddr_fifo_word, ddr_fifo_slwr_buf,
		ddr_fifo_block_count,
		ddr_fifo_read_count,
		ddr_fifo_FD_buf1, ddr_fifo_FD_buf2, 
		ddr_read_port,
		FULLFLAGB, 
		c3_pX_rd_empty_buf, c3_pX_rd_data_buf,
		c3_pX_cmd_byte_addr,
		ddr_fifo_go_buf2, ddr_fifo_go_buf_prev)
	begin
		-- defaults
		c3_pX_cmd_instr_next <= "001";
		c3_pX_cmd_bl_next <= "111111";         		
		c3_pX_rd_en <= (others => '0');
		c3_pX_cmd_en  <= (others => '0');
		c3_pX_cmd_byte_addr_next <= c3_pX_cmd_byte_addr;

		ddr_fifo_state_next       <= ddr_fifo_state;        
		ddr_fifo_done_next        <= ddr_fifo_done;         
		ddr_fifo_read_count_next  <= ddr_fifo_read_count;   
		ddr_fifo_block_count_next <= ddr_fifo_block_count;  
		ddr_fifo_slwr_buf_next    <= ddr_fifo_slwr_buf;          
		ddr_fifo_word_next        <= ddr_fifo_word;         
		ddr_fifo_FD_buf1_next     <= ddr_fifo_FD_buf1;      
		ddr_fifo_FD_buf2_next     <= ddr_fifo_FD_buf2;      
		ddr_pktend_next           <= '0';
		ddr_read_port_next        <= ddr_read_port;
        
		case ddr_fifo_state is
			when S_IDLE =>
				--ddr_fifo_block_count_next <= to_unsigned(64, ddr_fifo_block_count_next'length); --unsigned(ddr_block_count_ifclk_buf(19 downto 0));
				ddr_fifo_block_count_next <= unsigned(ddr_block_count_ifclk_buf(19 downto 0));
				ddr_fifo_done_next <= '0';
				
				if ddr_fifo_go_buf2 = '1' and ddr_fifo_go_buf_prev = '0' then
					-- sync address
					ddr_fifo_read_count_next <= to_unsigned(64, ddr_fifo_read_count'length);
					ddr_fifo_done_next <= '0';
					
					c3_pX_cmd_byte_addr_next(29 downto 2) <= ddr_address_buf(27 downto 0);
					c3_pX_cmd_byte_addr_next(1 downto 0) <= (others => '0');

					ddr_fifo_state_next <= S_ENABLED;
				end if;
		
			when S_ENABLED =>
				-- Space left in output FIFO
				if FULLFLAGB = '0' then 
					if c3_pX_rd_empty_buf(to_integer(ddr_read_port)) = '1' or ddr_fifo_read_count = 
						to_unsigned(64, ddr_fifo_read_count'length) then
						
						ddr_fifo_slwr_buf_next <= '0';
						
						if c3_pX_rd_empty_buf(to_integer(ddr_read_port)) = '1' and ddr_fifo_read_count = 
							to_unsigned(64, ddr_fifo_read_count'length) then
							
							ddr_fifo_read_count_next <= (others => '0');
							
							-- update address
							c3_pX_cmd_byte_addr_next(29 downto 2) <= std_logic_vector(
								unsigned(c3_pX_cmd_byte_addr(29 downto 2)) + 64
							); 
							c3_pX_cmd_byte_addr_next(1 downto 0) <= (others => '0');
							
							-- stop if done
							if ddr_fifo_block_count = to_unsigned(0, ddr_fifo_block_count'length) then
								ddr_fifo_state_next <= S_DONE;
								
								-- done
								ddr_pktend_next <= '1';
							else
								ddr_fifo_block_count_next <= ddr_fifo_block_count - to_unsigned(1, ddr_fifo_block_count'length);
								
								-- issue read request (on next port)
								if ddr_read_port = to_unsigned(2, ddr_read_port'length) then
									c3_pX_cmd_en(0) <= '1';
									ddr_read_port_next <= (others => '0');
								else
									c3_pX_cmd_en(to_integer(ddr_read_port)+1) <= '1';
									ddr_read_port_next <= ddr_read_port + 1;
								end if;
							end if;
						end if;
					else
						if ddr_fifo_word = '0' then
							ddr_fifo_FD_buf1_next <= c3_pX_rd_data_buf(to_integer(ddr_read_port))(15 downto 0);
							ddr_fifo_FD_buf2_next <= c3_pX_rd_data_buf(to_integer(ddr_read_port))(31 downto 16);
							c3_pX_rd_en(to_integer(ddr_read_port)) <= '1';
						else
							ddr_fifo_FD_buf1_next <= ddr_fifo_FD_buf2;
							ddr_fifo_read_count_next <= ddr_fifo_read_count +1;
						end if;
						
						ddr_fifo_word_next <= not ddr_fifo_word;
						ddr_fifo_slwr_buf_next <= '1';
					end if;				
				end if;
				
				when S_DONE =>
					ddr_fifo_done_next <= '1';
					ddr_fifo_state_next <= S_IDLE;
					
			end case;
	end process;
						
	-- status
	status(0) <= c3_pX_cmd_full(0);
	status(1) <= c3_pX_cmd_empty(0);
	status(2) <= c3_pX_rd_full(0);
	status(3) <= c3_pX_rd_overflow(0);
	status(4) <= c3_pX_rd_error(0);
	status(5) <= ddr_fifo_go;
	status(6) <= ddr_dma_enabled;
	status(7) <= '0';
	
	SINGLE_READ_FIFO : parallel_to_u8
	generic map(
		WIDTH => C3_P0_DATA_PORT_SIZE_BYTE
	)
	port map(
		clk => clk,
		reset => reset,
		d_in => ddr_read_buf, 
		w_en => ddr_data_valid, 
		r_en => single_read_r,	
		d_out => single_read,
		count => open
	);
	
	SINGLE_WRITE_FIFO : u8_to_parallel
	generic map(
		WIDTH => C3_P0_DATA_PORT_SIZE_BYTE
	)
	port map(
		clk => clk,
		reset => reset,
		d_in => single_write,
		w_en => single_write_w,
		clear => '0', -- FIXME
		count => open, -- FIXME	
		d_out => ddr_write_buf
	);
	
	ADDRESS_FIFO : u8_to_parallel
	generic map(
		WIDTH => 4
	)
	port map(
		clk => clk,
		reset => reset,
		d_in => address,
		w_en => address_w,
		clear => '0', -- FIXME
		count => open, -- FIXME	
		d_out => ddr_address
	);
	
	BLOCK_COUNT_FIFO : u8_to_parallel
	generic map(
		WIDTH => 3
	)
	port map(
		clk => clk,
		reset => reset,
		d_in => block_count,
		w_en => block_count_w,
		clear => '0', -- FIXME
		count => open, -- FIXME	
		d_out => ddr_block_count
	);
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, single_read_commit, 
		single_read_commit_prev, single_write_commit, single_write_commit_prev,
		slave_fifo_start, slave_fifo_start_prev,
		ddr_address, ddr_write_buf, ddr_block_count,
		c3_p0_rd_empty, c3_p0_wr_empty, 
		c3_p0_cmd_en, c3_p0_cmd_instr, c3_p0_cmd_bl, c3_p0_cmd_byte_addr, c3_p0_cmd_empty,
		c3_p0_wr_en, c3_p0_wr_mask, c3_p0_wr_data,
		c3_p0_rd_en,
		ddr_fifo_done_buf, ddr_fifo_go,
		ddr_dma_enabled, ddr_dma_word, ddr_dma_word_count, ddr_dma_address,
		ddr_dma_word_buffer, dma_input, dma_start, dma_start_prev)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		c3_p0_cmd_en_next <= '0'; 
		c3_p0_cmd_instr_next <= c3_p0_cmd_instr; 
		c3_p0_cmd_bl_next <= c3_p0_cmd_bl;     
		c3_p0_cmd_byte_addr_next <= c3_p0_cmd_byte_addr;	
		c3_p0_wr_en_next <= '0';
		c3_p0_wr_mask_next <= c3_p0_wr_mask;
		c3_p0_wr_data_next <= c3_p0_wr_data; 
		c3_p0_rd_en_next <= '0'; 
		ddr_data_valid_next <= '0';
		ddr_fifo_go_next <= ddr_fifo_go;
		ddr_fifo_go_we_next <= '0';
		ddr_dma_enabled_next <= ddr_dma_enabled;
		ddr_dma_word_next <= ddr_dma_word;
		ddr_dma_word_count_next <= ddr_dma_word_count;
		ddr_dma_address_next <= ddr_dma_address;
		ddr_dma_word_buffer_next <= ddr_dma_word_buffer;
		
		case state is
			when S_IDLE =>
				-- activate single r/w
				if single_read_commit = '1' and single_read_commit_prev = '0' then
					state_next <= S_READ_COMMAND;
					c3_p0_cmd_byte_addr_next(29 downto 2) <= ddr_address(27 downto 0);
					c3_p0_cmd_byte_addr_next(1 downto 0) <= "00";
					c3_p0_cmd_bl_next <= (others => '0');
					c3_p0_cmd_instr_next <= "001";
					
				elsif single_write_commit = '1' and single_write_commit_prev = '0' then
					state_next <= S_WRITE_DATA;
					c3_p0_wr_data_next <= ddr_write_buf;
					
				elsif slave_fifo_start = '1' and slave_fifo_start_prev = '0' then
					state_next <= S_SLAVE_FIFO;
					
				elsif dma_start = '1' and dma_start_prev = '0' then
					-- load write address
					ddr_dma_address_next(29 downto 2) <= unsigned(ddr_address(27 downto 0));
					ddr_dma_address_next(1 downto 0) <= "00";
					ddr_dma_word_count_next(26 downto 7) <= unsigned(ddr_block_count(19 downto 0));
					ddr_dma_word_count_next(6 downto 0) <= "0000000";
					ddr_dma_word_next <= '0';
					
					c3_p0_cmd_bl_next <= (others => '0');
					c3_p0_cmd_instr_next <= "001";
							
					state_next <= S_DMA_WRITE;
				end if;
				
				ddr_fifo_go_next <= '0';
				ddr_dma_enabled_next <= '0';
				
			when S_READ_COMMAND => 
				-- issue read command
				if c3_p0_cmd_empty = '1' and c3_p0_rd_empty = '1' then			
					c3_p0_cmd_en_next <= '1';
					state_next <= S_READ_DATA;
				end if;
				
			when S_READ_DATA =>
				if c3_p0_rd_empty = '0' then
					-- flush  w/ 1 reading
					c3_p0_rd_en_next <= '1';
					
					-- put data into read buffer register
					ddr_data_valid_next <= '1';
					
					-- back to idle mode
					state_next <= S_IDLE;	
				-- all valid data read
				else
					-- enable reading if data coming in
					c3_p0_rd_en_next <= '1';
					ddr_data_valid_next <= '1';
				end if;
			
			when S_WRITE_DATA =>
				-- write data into (empty) output FIFO
				if c3_p0_wr_empty = '1' then
					c3_p0_wr_en_next <= '1';
					c3_p0_cmd_byte_addr_next(29 downto 2) <= ddr_address(27 downto 0);
					c3_p0_cmd_byte_addr_next(1 downto 0) <= "00";
					c3_p0_cmd_bl_next <= (others => '0');
					c3_p0_cmd_instr_next <= "000";
					state_next <= S_WRITE_COMMAND;
				end if;
				
			when S_WRITE_COMMAND => 
				-- data present
				if c3_p0_wr_empty = '0' and c3_p0_cmd_empty = '1' then
					-- issue write command
					c3_p0_cmd_en_next <= '1';
					state_next <= S_IDLE;
				end if;
				
			when S_SLAVE_FIFO => 
				ddr_fifo_go_next <= '1';
				ddr_fifo_go_we_next <= '1';
				
				-- done?	
				if ddr_fifo_done_buf = '1' then
					ddr_fifo_go_next <= '0';
					ddr_fifo_go_we_next <= '1';
					state_next <= S_IDLE;
				end if;
				
			when S_DMA_WRITE =>
				ddr_dma_enabled_next <= '1';
				
				if ddr_dma_word = '0' then
					ddr_dma_word_next <= '1';
					ddr_dma_word_buffer_next <= dma_input;
					
					-- write data from output FIFO if present
					if c3_p0_wr_empty = '0' then
						c3_p0_cmd_byte_addr_next(29 downto 2) <= std_logic_vector(ddr_dma_address(27 downto 0));
						c3_p0_cmd_byte_addr_next(1 downto 0) <= "00";
						c3_p0_cmd_bl_next <= (others => '0');
						c3_p0_cmd_instr_next <= "000";
						c3_p0_cmd_en_next <= '1';
						
						-- update write address
						ddr_dma_address_next <= ddr_dma_address + 1;
					end if;
				else
					ddr_dma_word_next <= '0';
					
					-- put into output FIFO
					c3_p0_wr_data_next <= ddr_dma_word_buffer & dma_input;
					c3_p0_wr_en_next <= '1';
				end if;
				
				-- back to idle mode when all bytes written
				if ddr_dma_word_count = to_unsigned(0, ddr_dma_word_count'length)  then
					ddr_dma_enabled_next <= '0';
					state_next <= S_IDLE;
				else
					ddr_dma_word_count_next <= ddr_dma_word_count - 1;
				end if;
						
		end case;
	end process;
	
	-- state register update
	STATE_REG: process (clk, reset)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_IDLE;
				
				c3_p0_cmd_en <= '0';
				c3_p0_cmd_instr <= (others => '0'); 
				c3_p0_cmd_bl <= (others => '0');    
				c3_p0_cmd_byte_addr <= (others => '0'); 
				c3_p0_wr_en <= '0';
				c3_p0_wr_mask <= (others => '0'); 
				c3_p0_wr_data <= (others => '0'); 
				c3_p0_rd_en <= '0';
				
				ddr_data_valid <= '0';
				ddr_fifo_go <= '0';
				ddr_fifo_go_we <= '1';
				ddr_read_buf <= (others => '0');
				ddr_block_count_buf <= (others => '0');
				ddr_fifo_done_buf <= '0';
				
				ddr_dma_enabled <= '0';
				ddr_dma_word <= '0';
				ddr_dma_word_count <= (others => '0');
				ddr_dma_address <= (others => '0');
				ddr_dma_word_buffer <= (others => '0');
			else
				state <= state_next;
				
				c3_p0_cmd_en <= c3_p0_cmd_en_next;
				c3_p0_cmd_instr <= c3_p0_cmd_instr_next; 
				c3_p0_cmd_bl <= c3_p0_cmd_bl_next;     
				c3_p0_cmd_byte_addr <= c3_p0_cmd_byte_addr_next;
				c3_p0_wr_en <= c3_p0_wr_en_next;
				c3_p0_wr_mask <= c3_p0_wr_mask_next;
				c3_p0_wr_data <= c3_p0_wr_data_next; 
				c3_p0_rd_en <= c3_p0_rd_en_next;
				
				ddr_data_valid <= ddr_data_valid_next;
				ddr_fifo_go <= ddr_fifo_go_next;
				ddr_fifo_go_we <= ddr_fifo_go_we_next;
				ddr_read_buf <= c3_p0_rd_data;
				ddr_block_count_buf <= ddr_block_count;
				ddr_fifo_done_buf <= ddr_fifo_done;
				
				ddr_dma_enabled <= ddr_dma_enabled_next;
				ddr_dma_word <= ddr_dma_word_next;
				ddr_dma_word_count <= ddr_dma_word_count_next;
				ddr_dma_address <= ddr_dma_address_next;
				ddr_dma_word_buffer <= ddr_dma_word_buffer_next;
			end if;
		end if;
	end process;

	-- input buffering 
	BUFFERING: process (clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				single_write_commit_prev <= '0';
				single_read_commit_prev <= '0';
				slave_fifo_start_prev <= '0';
				dma_start_prev <= '0';
			else
				single_write_commit_prev <= single_write_commit;
				single_read_commit_prev <= single_read_commit;
				slave_fifo_start_prev <= slave_fifo_start;
				dma_start_prev <= dma_start;
			end if;
		end if;
	end process;
end behavioral;
