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
-- Component name: main
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 09:32 26.11.2010
--
-- Description: Top level of UFIP (Universal Fault Injection Peripheral)
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

entity main is
  port(
    -- standard inputs
    clk_in   : in std_logic;
    reset_in : in std_logic;

    -- uC <-> FPGA interface
    w_en    : in  std_logic;
    r_en    : in  std_logic;
    in_pin  : in  std_logic;
    out_pin : out std_logic;

    -- LEDs
    led : out std_logic_vector(3 downto 0);

    -- smartcard
    sc_io   : inout std_logic;
    sc_clk  : out   std_logic;
    sc_rst  : out   std_logic;
    sc_pin4 : in    std_logic;
    sc_pin6 : in    std_logic;
    sc_pin8 : in    std_logic;
    sc_sw1  : out   std_logic;
    sc_sw2  : in    std_logic;

    -- DAC interface
    dac_v_out : out std_logic_vector(7 downto 0);
    dac_clk   : out std_logic;

    -- ADC interface
    adc_v_in   : in  std_logic_vector(7 downto 0);
    adc_encode : out std_logic;

    -- DDR interface
    mcb3_dram_dq    : inout std_logic_vector(15 downto 0);
    mcb3_dram_a     : out   std_logic_vector(12 downto 0);
    mcb3_dram_ba    : out   std_logic_vector(1 downto 0);
    mcb3_dram_cke   : out   std_logic;
    mcb3_dram_ras_n : out   std_logic;
    mcb3_dram_cas_n : out   std_logic;
    mcb3_dram_we_n  : out   std_logic;
    mcb3_dram_dm    : out   std_logic;
    mcb3_dram_udqs  : inout std_logic;
    mcb3_rzq        : inout std_logic;
    mcb3_dram_udm   : out   std_logic;
    mcb3_dram_dqs   : inout std_logic;
    mcb3_dram_ck    : out   std_logic;
    mcb3_dram_ck_n  : out   std_logic;

    -- USB FIFO
    IFCLK      : in  std_logic;
    FD         : out std_logic_vector(15 downto 0);
    SLOE       : out std_logic;
    SLRD       : out std_logic;
    SLWR       : out std_logic;
    FIFOADR0   : out std_logic;
    FIFOADR1   : out std_logic;
    PKTEND     : out std_logic;
    EMPTYFLAGC : in  std_logic;
    FULLFLAGB  : in  std_logic;
    FLAGA      : in  std_logic;

    -- user I/O pins
    gpio : inout std_logic_vector(7 downto 0)
    );
end main;

architecture behavioral of main is
  -- constants

  -- main clk frequency
  constant F_CLK : positive := 50000000;
  -- main clk period (in ns)
  constant T_CLK : positive := 20;

  -- first 32 (0...31) are read-only, others may be written
  constant RD_REG_COUNT    : integer := 32;
  constant WR_REG_COUNT    : integer := 64;
  constant REG_FILE_LENGTH : integer := RD_REG_COUNT+WR_REG_COUNT;

  -- components
  component io_controller is
    generic(
      WR_REG_COUNT : natural := 32;
      RD_REG_COUNT : natural := 32
      );
    port(
      clk_in                 : in  std_logic;
      reset_in               : in  std_logic;
      clk                    : in  std_logic;
      reset                  : in  std_logic;
      uc_in_w_en             : in  std_logic;
      uc_out_r_en            : in  std_logic;
      uc_in_pin              : in  std_logic;
      uc_out_pin             : out std_logic;
      register_file_readonly : in  byte_vector(RD_REG_COUNT-1 downto 0);
      register_file_writable : out byte_vector(WR_REG_COUNT-1 downto 0);
      register_file_r        : out std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0);
      register_file_w        : out std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0)
      );
  end component;

  component clock_domain_sync_1to8
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(0 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(7 downto 0);
      full   : out std_logic;
      wr_ack : out std_logic;
      empty  : out std_logic;
      valid  : out std_logic
      );
  end component;

  component memory_interface is
    generic
      (
        C3_P0_MASK_SIZE       : integer := 4;
        C3_P0_DATA_PORT_SIZE  : integer := 32;
        C3_P1_MASK_SIZE       : integer := 4;
        C3_P1_DATA_PORT_SIZE  : integer := 32;
        C3_NUM_DQ_PINS        : integer := 16;
        C3_MEM_ADDR_WIDTH     : integer := 13;
        C3_MEM_BANKADDR_WIDTH : integer := 2
        );
    port (
      clk                 : in  std_logic;
      reset               : in  std_logic;
      single_write        : in  byte;
      single_write_w      : in  std_logic;
      single_write_commit : in  std_logic;
      single_read         : out byte;
      single_read_r       : in  std_logic;
      single_read_commit  : in  std_logic;
      address             : in  byte;
      address_w           : in  std_logic;
      block_count         : in  byte;
      block_count_w       : in  std_logic;
      slave_fifo_start    : in  std_logic;
      status              : out byte;

      mcb3_dram_dq    : inout std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
      mcb3_dram_a     : out   std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
      mcb3_dram_ba    : out   std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
      mcb3_dram_cke   : out   std_logic;
      mcb3_dram_ras_n : out   std_logic;
      mcb3_dram_cas_n : out   std_logic;
      mcb3_dram_we_n  : out   std_logic;
      mcb3_dram_dm    : out   std_logic;
      mcb3_dram_udqs  : inout std_logic;
      mcb3_rzq        : inout std_logic;
      mcb3_dram_udm   : out   std_logic;
      mcb3_dram_dqs   : inout std_logic;
      mcb3_dram_ck    : out   std_logic;
      mcb3_dram_ck_n  : out   std_logic;
      dma_start       : in    std_logic;
      dma_input       : in    std_logic_vector(15 downto 0);
      IFCLK           : in    std_logic;
      FD              : out   std_logic_vector(15 downto 0);
      SLOE            : out   std_logic;
      SLRD            : out   std_logic;
      SLWR            : out   std_logic;
      FIFOADR0        : out   std_logic;
      FIFOADR1        : out   std_logic;
      PKTEND          : out   std_logic;
      EMPTYFLAGC      : in    std_logic;
      FULLFLAGB       : in    std_logic;
      FLAGA           : in    std_logic
      );
  end component;

  component sc_controller is
    generic(
      CLK_PERIOD : positive
      );
    port(
      clk                  : in    std_logic;
      reset                : in    std_logic;
      switch_power         : in    std_logic;
      transmit             : in    std_logic;
      data_in              : in    byte;
      data_in_we           : in    std_logic;
      data_in_count        : out   byte;
      data_out             : out   byte;
      data_out_count       : out   byte;
      data_out_re          : in    std_logic;
      status               : out   byte;
      data_sent_trigger    : out   std_logic;
      data_sending_trigger : out   std_logic;
      sc_v_cc_en           : out   std_logic;
      sc_io                : inout std_logic;
      sc_rst               : out   std_logic;
      sc_clk               : out   std_logic
      );
  end component;

  component pic_programmer is
    generic(
      CLK_PERIOD : positive
      );
    port(
      clk            : in    std_logic;
      reset          : in    std_logic;
      data_in        : in    std_logic_vector(21 downto 0);
      has_data       : in    std_logic;
      get_response   : in    std_logic;
      send           : in    std_logic;
      prog_startstop : in    std_logic;
      start_and_send : in    std_logic;
      programming    : out   std_logic;
      data_out       : out   std_logic_vector(13 downto 0);
      v_dd_en        : out   std_logic;
      v_pp_en        : out   std_logic;
      pgm            : out   std_logic;
      ispclk         : out   std_logic;
      ispdat         : inout std_logic
      );
  end component;

  component dac_controller is
    port (
      clk            : in  std_logic;
      ce             : in  std_logic;
      reset          : in  std_logic;
      test_mode      : in  std_logic;
      voltage_low    : in  byte;
      voltage_high   : in  byte;
      voltage_off    : in  byte;
      voltage_select : in  std_logic;
      voltage_update : in  std_logic;
      off            : in  std_logic;
      voltage_out    : out byte;
      sleep          : out std_logic;
      clk_dac        : out std_logic
      );
  end component;

  component ask_modulator is
    port(
      clk           : in  std_logic;
      ce            : in  std_logic;
      reset         : in  std_logic;
      out_amplitude : in  byte;
      data          : in  std_logic;
      modulated     : out byte
      );
  end component;

  component miller_encoder is
    port(
      clk          : in  std_logic;
      reset        : in  std_logic;
      w_en         : in  std_logic;
      data         : in  byte;
      transmit     : in  std_logic;
      omit_count   : in  byte;
      encoded      : out std_logic;
      transmitting : out std_logic
      );
  end component;

  component timing_controller_waveform is
    generic(
      TIME_REGISTER_WIDTH : positive
      );
    port(
      clk          : in  std_logic;
      ce           : in  std_logic;
      reset        : in  std_logic;
      arm          : in  std_logic;
      trigger      : in  std_logic;
      armed        : out std_logic;
      ready        : out std_logic;
      inject_fault : out std_logic;
      addr         : in  std_logic_vector(9 downto 0);
      w_en         : in  std_logic;
      d_in         : in  std_logic_vector(7 downto 0);
      d_out        : out std_logic_vector(7 downto 0)
      );
  end component;

  component adc_controller is
    port(
      clk        : in  std_logic;
      ce         : in  std_logic;
      reset      : in  std_logic;
      adc_in     : in  std_logic_vector(7 downto 0);
      adc_encode : out std_logic;
      adc_value  : out byte
      );
  end component;

  component pattern_detector is
    port(
      clk                  : in  std_logic;
      reset                : in  std_logic;
      ce                   : in  std_logic;
      pattern_in           : in  u8;
      pattern_we           : in  std_logic;
      pattern_sample_count : in  unsigned(7 downto 0);
      adc_in               : in  u8;
      adc_we               : in  std_logic;
      d_out                : out unsigned(15 downto 0)
      );
  end component;

  component trigger_generator is
    port (
      clk               : in  std_logic;
      reset             : in  std_logic;
      arm               : in  std_logic;
      armed             : out std_logic;
      coarse_trigger_en : in  std_logic;
      coarse_trigger    : in  std_logic;
      force_trigger     : in  std_logic;
      detector_in       : in  unsigned(15 downto 0);
      threshold         : in  byte;
      threshold_w       : in  std_logic;
      trigger           : out std_logic
      );
  end component;

  -- signals

  -- pattern detector
  signal detector_ce                   : std_logic;
  signal detector_adc_we               : std_logic;
  signal detector_pattern_in           : byte;
  signal detector_adc_in               : byte;
  signal detector_out                  : unsigned(15 downto 0);
  signal detector_pattern_sample_count : unsigned(7 downto 0);

  -- DDR controller
  signal ddr_single_write, ddr_single_read                    : byte;
  signal ddr_control, ddr_address, ddr_status, ddr_fifo_count : byte;
  signal ddr_dma_in                                           : std_logic_vector(15 downto 0);
  signal ddr_dma_start                                        : std_logic;

  -- smartcard
  signal sc_data_in, sc_data_out, sc_control, sc_status : byte;
  signal sc_data_in_count, sc_data_out_count            : byte;
  signal sc_vcc_en, sc_clk_gen                          : std_logic;
  signal sc_data_sent_trigger                           : std_logic;
  signal sc_data_sending_trigger                        : std_logic;

  -- DCM signals
  signal clk, clk_main, clk_main_buf, clk_90, clk_180, clk_270 : std_logic;
  signal clk_2x, clk_2x_180                                    : std_logic;
  signal clk_div                                               : std_logic;
  signal clk_fx, clk_fx_180                                    : std_logic;
  signal clk_fb, clk_locked, clk_psdone                        : std_logic;
  signal clk_psclk, clk_psen, clk_psincdec                     : std_logic;
  signal clk_status                                            : byte;
  signal clk_fast                                              : std_logic;

  -- PIC programmer
  signal pic_data_in                                                                : std_logic_vector(21 downto 0);
  signal pic_control                                                                : byte;
  signal pic_data_out                                                               : std_logic_vector(13 downto 0);
  signal pic_v_dd_en, pic_v_pp_en, pic_pgm, pic_ispclk, pic_ispdat, pic_programming : std_logic;

  -- DAC controller
  signal dac_ce, dac_test_mode, dac_v_select, dac_v_update, dac_off : std_logic;
  signal dac_v_high, dac_v_low, dac_v_off, dac_control              : byte;

  -- Timing controller
  signal fi_control, fi_status                         : byte;
  signal fi_ce, fi_arm, fi_trigger, fi_armed, fi_ready : std_logic;
  signal fi_inject_fault                               : std_logic;
  signal fi_addr                                       : std_logic_vector(9 downto 0);
  signal fi_w_en                                       : std_logic;
  signal fi_d_in, fi_d_out                             : byte;
  signal fi_trigger_control                            : byte;
  signal fi_trigger_ext                                : std_logic;

  -- ADC controller
  signal thresh_control        : byte;
  signal thresh_status         : byte;
  signal adc_value             : byte;
  signal adc_ce                : std_logic;
  signal thresh_value          : byte;
  signal thresh_trigger        : std_logic;
  signal thresh_armed          : std_logic;
  signal thresh_coarse_trigger : std_logic;
  signal thresh_force_trigger  : std_logic;

  -- RFID interface
  signal rfid_trigger                                                     : std_logic;
  signal rfid_to_dac_enabled                                              : std_logic;
  signal rfid_ask_modulated                                               : byte;
  signal rfid_ask_data                                                    : std_logic;
  signal rfid_ask_amplitude                                               : byte;
  signal rfid_miller_data                                                 : byte;
  signal rfid_miller_control                                              : byte;
  signal rfid_miller_status                                               : byte;
  signal rfid_miller_omit_count                                           : byte;
  signal rfid_miller_encoded                                              : std_logic;
  signal rfid_miller_w_en, rfid_miller_transmit, rfid_miller_transmitting : std_logic;

  -- register file of 64 registers
  signal register_file_readonly   : byte_vector(RD_REG_COUNT-1 downto 0);
  signal register_file_writable   : byte_vector(WR_REG_COUNT-1 downto 0);
  alias register_file_writable_5  : byte is register_file_writable(5);
  alias register_file_writable_13 : byte is register_file_writable(13);
  alias register_file_writable_31 : byte is register_file_writable(31);

  -- read/write strobes for register_file
  signal register_file_r : std_logic_vector(REG_FILE_LENGTH-1 downto 0);
  signal register_file_w : std_logic_vector(REG_FILE_LENGTH-1 downto 0);

  -- internal reset
  signal reset : std_logic;
begin
  -- components

  -- IO/register controller
  IO_CONTROLLER_inst : io_controller
    generic map(
      WR_REG_COUNT => WR_REG_COUNT,
      RD_REG_COUNT => RD_REG_COUNT
      )
    port map(
      clk_in                 => clk_in,
      reset_in               => reset_in,
      clk                    => clk,
      reset                  => reset,
      uc_in_w_en             => w_en,
      uc_out_r_en            => r_en,
      uc_in_pin              => in_pin,
      uc_out_pin             => out_pin,
      register_file_readonly => register_file_readonly,
      register_file_writable => register_file_writable,
      register_file_r        => register_file_r,
      register_file_w        => register_file_w
      );

  -- DDR controller
  -- Register mapping:
  -- ddr_in_low         (r): 11
  -- ddr_in_high        (r): 19
  -- ddr_single_read    (r): 17 
  -- ddr_status         (r): 18
  -- ddr_control        (r/w): 56 (32 + 24)
  -- ddr_single_write   (r/w): 57 (32 + 25)
  -- ddr_address        (r/w): 58 (32 + 26)
  -- ddr_fifo_count     (r/w): 59 (32 + 27)

  -- Control register bits
  -- 0: Single write commit
  -- 1: Single read commit
  -- 2: Start slave FIFO read
  -- 3: Reset memory interface
  -- 4: Start DMA write
  -- 5: Select 0 for DMA input source selection
  -- 6: Select 1 for DMA input source selection
  ddr_control                <= register_file_writable(24);
  ddr_single_write           <= register_file_writable(25);
  ddr_address                <= register_file_writable(26);
  ddr_fifo_count             <= register_file_writable(27);
  register_file_readonly(17) <= ddr_single_read;
  register_file_readonly(18) <= ddr_status;
  register_file_readonly(11) <= ddr_dma_in(7 downto 0);
  register_file_readonly(19) <= ddr_dma_in(15 downto 8);

  DDR_inst : memory_interface
    port map(
      clk                 => clk,
      reset               => reset,     -- or ddr_control(3)
      single_write        => ddr_single_write,
      single_write_w      => register_file_w(57),
      single_write_commit => ddr_control(0),
      single_read         => ddr_single_read,
      single_read_r       => register_file_r(17),
      single_read_commit  => ddr_control(1),
      address             => ddr_address,
      address_w           => register_file_w(58),
      block_count         => ddr_fifo_count,
      block_count_w       => register_file_w(59),
      slave_fifo_start    => ddr_control(2),
      status              => ddr_status,
      mcb3_dram_dq        => mcb3_dram_dq,
      mcb3_dram_a         => mcb3_dram_a,
      mcb3_dram_ba        => mcb3_dram_ba,
      mcb3_dram_cke       => mcb3_dram_cke,
      mcb3_dram_ras_n     => mcb3_dram_ras_n,
      mcb3_dram_cas_n     => mcb3_dram_cas_n,
      mcb3_dram_we_n      => mcb3_dram_we_n,
      mcb3_dram_dm        => mcb3_dram_dm,
      mcb3_dram_udqs      => mcb3_dram_udqs,
      mcb3_rzq            => mcb3_rzq,
      mcb3_dram_udm       => mcb3_dram_udm,
      mcb3_dram_dqs       => mcb3_dram_dqs,
      mcb3_dram_ck        => mcb3_dram_ck,
      mcb3_dram_ck_n      => mcb3_dram_ck_n,
      dma_start           => ddr_dma_start,
      dma_input           => ddr_dma_in,
      IFCLK               => IFCLK,
      FD                  => FD,
      SLOE                => SLOE,
      SLRD                => SLRD,
      SLWR                => SLWR,
      FIFOADR0            => FIFOADR0,
      FIFOADR1            => FIFOADR1,
      PKTEND              => PKTEND,
      EMPTYFLAGC          => EMPTYFLAGC,
      FULLFLAGB           => FULLFLAGB,
      FLAGA               => FLAGA
      );

  ddr_dma_in <= "00000000" & std_logic_vector(adc_value) when ddr_control(6 downto 5) = "00" else
                std_logic_vector(detector_out) when ddr_control(6 downto 5) = "01" else
                "00000000" & std_logic_vector(adc_value);

  -- DMA is either started from software (via DDR control) or from the
  -- threshold trigger generator
  ddr_dma_start <= ddr_control(4) or thresh_trigger;

  -- Smartcard controller
  -- Register mapping:
  -- sc_control        (r/w): 34 (32 + 2)
  -- sc_data_in        (r/w): 35 (32 + 3)
  -- sc_status           (r): 3  
  -- sc_data_out         (r): 4
  -- sc_data_out_count   (r): 9
  -- sc_data_in_count    (r): 10
  sc_control                 <= register_file_writable(2);
  sc_data_in                 <= register_file_writable(3);
  register_file_readonly(3)  <= sc_status;
  register_file_readonly(4)  <= sc_data_out;
  register_file_readonly(9)  <= sc_data_out_count;
  register_file_readonly(10) <= sc_data_in_count;

  SC_CTRL_inst : sc_controller
    generic map(
      CLK_PERIOD => T_CLK/2
      )
    port map(
      clk                  => clk_fast,
      reset                => reset,
      switch_power         => sc_control(0),
      transmit             => sc_control(1),
      data_in              => sc_data_in,
      data_in_we           => register_file_w(35),
      data_in_count        => sc_data_in_count,
      data_out             => sc_data_out,
      data_out_count       => sc_data_out_count,
      data_out_re          => register_file_r(4),
      status               => sc_status,
      data_sent_trigger    => sc_data_sent_trigger,
      data_sending_trigger => sc_data_sending_trigger,
      sc_v_cc_en           => sc_vcc_en,
      sc_io                => sc_io,
      sc_rst               => sc_rst,
      sc_clk               => sc_clk_gen
      );

  sc_clk <= sc_clk_gen;
  sc_sw1 <= '1';

  -- PIC programmer
  -- Register mapping:
  -- pic_control    (r/w): 36 (32 + 4)
  -- pic_command    (r/w): 37 (32 + 5)
  -- pic_data_in_l  (r/w): 38 (32 + 6)
  -- pic_data_in_h  (r/w): 39 (32 + 7)
  -- pic_data_out_l (r): 5
  -- pic_data_out_h (r): 6
  pic_control               <= register_file_writable(4);
  pic_data_in(5 downto 0)   <= register_file_writable_5(5 downto 0);  --std_logic_vector(resize(unsigned(register_file_writable(5)), 6));
  pic_data_in(13 downto 6)  <= register_file_writable(6);
  pic_data_in(21 downto 14) <= register_file_writable(7);

  register_file_readonly(5) <= pic_data_out(7 downto 0);
  register_file_readonly(6) <= "00" & pic_data_out(13 downto 8);

  PIC_inst : pic_programmer
    generic map(
      CLK_PERIOD => T_CLK
      )
    port map(
      clk            => clk,
      reset          => reset,
      data_in        => pic_data_in,
      has_data       => pic_control(0),
      get_response   => pic_control(1),
      send           => pic_control(2),
      prog_startstop => pic_control(3),
      start_and_send => pic_control(4),
      programming    => pic_programming,
      data_out       => pic_data_out,
      v_dd_en        => pic_v_dd_en,
      v_pp_en        => pic_v_pp_en,
      pgm            => pic_pgm,
      ispclk         => pic_ispclk,
      ispdat         => pic_ispdat
      );

  -- RFID
  -- Register mapping:
  -- miller_data    (r/w): 53 (32 + 21)
  -- miller_omit_count   (r/w): 54 (32 + 22)
  -- miller_control (r/w): 55 (32 + 23)
  -- miller_status  (r)  : 16 

  rfid_miller_data           <= register_file_writable(21);
  rfid_miller_w_en           <= register_file_w(53);
  rfid_miller_omit_count     <= register_file_writable(22);
  rfid_miller_control        <= register_file_writable(23);
  register_file_readonly(16) <= rfid_miller_status;

  -- control register
  -- 0: transmit
  rfid_miller_transmit <= rfid_miller_control(0);

  -- status register
  -- 0: transmitting
  rfid_miller_status(0)          <= rfid_miller_transmitting;
  rfid_miller_status(7 downto 1) <= (others => '0');

  miller_encoder_inst : miller_encoder
    port map(
      clk          => clk_fast,
      reset        => reset,
      w_en         => rfid_miller_w_en,
      data         => rfid_miller_data,
      transmit     => rfid_miller_transmit,
      omit_count   => rfid_miller_omit_count,
      encoded      => rfid_miller_encoded,
      transmitting => rfid_miller_transmitting
      );

  ask_modulator_inst : ask_modulator
    port map(
      clk           => clk_fast,
      ce            => '1',
      reset         => reset,
      out_amplitude => rfid_ask_amplitude,
      data          => rfid_ask_data,
      modulated     => rfid_ask_modulated
      );

  rfid_ask_amplitude <= register_file_writable(9) when fi_inject_fault = '0' else
                        register_file_writable(8);

  rfid_ask_data <= rfid_miller_encoded;
  rfid_trigger  <= rfid_miller_transmitting;

  -- DAC controller
  -- Register mapping:
  -- dac_v_low      (r/w): 40 (32 + 8)
  -- dac_v_high     (r/w): 41 (32 + 9)
  -- dac_v_off      (r/w): 46 (32 + 14)
  -- dac_control    (r/w): 48 (32 + 16)
  dac_v_low <= register_file_writable(8) when rfid_to_dac_enabled = '0' else
               rfid_ask_modulated;

  dac_v_high <= register_file_writable(9);
  dac_v_off  <= register_file_writable(14);


  -- several control functions
  -- 0: enable DAC if = 1, else disable
  -- 1: in test mode if = 1
  -- 2: using output of RFID fault injector
  dac_control         <= register_file_writable(16);
  rfid_to_dac_enabled <= dac_control(2);

  -- update output on voltage low/high change
  dac_v_update <= register_file_w(40) or register_file_w(41)
                  or register_file_w(46) or register_file_w(48) or rfid_to_dac_enabled;

  DAC_CONTROLLER_inst : dac_controller
    port map(
      clk            => clk_fast,
      ce             => dac_ce,
      reset          => reset,
      test_mode      => dac_test_mode,
      voltage_low    => dac_v_low,
      voltage_high   => dac_v_high,
      voltage_off    => dac_v_off,
      voltage_select => dac_v_select,
      voltage_update => dac_v_update,
      off            => dac_off,
      voltage_out    => dac_v_out,
      sleep          => open,
      clk_dac        => dac_clk
      );

  dac_ce        <= '1';
  dac_off       <= not (pic_v_dd_en or dac_control(0));
  dac_test_mode <= dac_control(1);
  dac_v_select  <= fi_inject_fault when rfid_to_dac_enabled = '0' else
                  '0';


  -- Timing controller
  -- fi_control         (r/w): 42 (32 + 10)
  -- fi_d_in            (r/w): 43 (32 + 11)
  -- fi_addr_l          (r/w): 44 (32 + 12)
  -- fi_addr_h          (r/w): 45 (32 + 13)
  -- fi_trigger_control (r/w): 47 (32 + 15)
  -- fi_status          (r): 7
  -- fi_d_out           (r): 8
  fi_control          <= register_file_writable(10);
  fi_trigger_control  <= register_file_writable(15);
  fi_d_in             <= register_file_writable(11);
  fi_addr(7 downto 0) <= register_file_writable(12);
  fi_addr(9 downto 8) <= register_file_writable_13(1 downto 0);

  register_file_readonly(7) <= fi_status;
  register_file_readonly(8) <= fi_d_out;

  TIMING_CONTROLLER_WAVEFORM_inst : timing_controller_waveform generic map(
    TIME_REGISTER_WIDTH => 32
    )
    port map(
      clk          => clk_fast,
      ce           => fi_ce,
      reset        => reset,
      arm          => fi_arm,
      trigger      => fi_trigger,
      armed        => fi_armed,
      ready        => fi_ready,
      inject_fault => fi_inject_fault,
      addr         => fi_addr,
      w_en         => fi_w_en,
      d_in         => fi_d_in,
      d_out        => fi_d_out
      );

  fi_ce <= '1';

  -- control register
  -- 0: w_en
  -- 1: arm
  -- 2: trigger force
  fi_w_en        <= fi_control(0);
  fi_arm         <= fi_control(1);
  -- trigger if enabled in resp. control register
  -- 0: PIC programmer trigger
  -- 1: RFID trigger
  -- 2: External trigger
  -- 3: ADC trigger
  -- 4: Smartcard data sent trigger 
  -- 5: Smartcard data begin sending trigger
  fi_trigger_ext <= sc_pin4;
  fi_trigger     <= (pic_programming and fi_trigger_control(0)) or
                (rfid_trigger and fi_trigger_control(1)) or
                (fi_trigger_ext and fi_trigger_control(2)) or
                (sc_data_sent_trigger and fi_trigger_control(4)) or
                (sc_data_sending_trigger and fi_trigger_control(5)) or
                fi_control(2);  -- this is the software trigger, always enabled

  -- status register
  -- 0: ready
  -- 1: armed
  fi_status(0)          <= fi_ready;
  fi_status(1)          <= fi_armed;
  fi_status(7 downto 2) <= (others => '0');

  -- ADC controller
  adc_ce <= '1';

  ADC_CONTROLLER_inst : adc_controller
    port map(
      clk        => clk,
      reset      => reset,
      ce         => adc_ce,
      adc_in     => adc_v_in,
      adc_encode => adc_encode,
      adc_value  => adc_value
      );

  -- Threshold trigger generator
  -- thresh_status  (r): 12
  -- thresh_control (r/w): 49 (32 + 17)
  -- thresh_value (r/w): 61 (32 + 29)
  register_file_readonly(12) <= thresh_status;

  -- Status register bits
  -- Bit 0: Armed
  thresh_status(0)          <= thresh_armed;
  thresh_status(7 downto 1) <= (others => '0');

  -- Control register
  -- Bit 0: Arm
  -- Bit 1: Enable coarse trigger
  -- Bit 2: Software trigger
  thresh_control       <= register_file_writable(17);
  thresh_value         <= register_file_writable(29);
  thresh_force_trigger <= thresh_control(2);

  TRIGGER_GENERATOR_inst : trigger_generator
    port map(
      clk               => clk,
      reset             => reset,
      arm               => thresh_control(0),
      armed             => thresh_armed,
      coarse_trigger_en => thresh_control(1),
      coarse_trigger    => thresh_coarse_trigger,
      force_trigger     => thresh_force_trigger,
      detector_in       => detector_out,
      threshold         => thresh_value,
      threshold_w       => register_file_w(61),
      trigger           => thresh_trigger
      );

  thresh_coarse_trigger <= fi_trigger;

  -- Pattern detector
  -- pattern_in      (r/w): 60 (32 + 28)
  -- pattern_debug   (r/w): 62 (32 + 30)
  -- pattern_sample_count   (r/w): 63 (32 + 31)
  detector_pattern_in <= register_file_writable(28);

  -- uncomment the following for debug mode (i.e. input from PC controlled 
  -- register)
  --detector_adc_in <= register_file_writable(30);
  --detector_adc_we <= register_file_w(62);

  -- uncomment the following for normal mode (i.e. input from ADC)
  detector_adc_in <= adc_value;
  detector_adc_we <= '1';

  detector_pattern_sample_count <= unsigned(register_file_writable_31(7 downto 0));

  PATTERN_DETECTOR_inst : pattern_detector
    port map(
      clk                  => clk,
      reset                => reset,
      ce                   => detector_ce,
      pattern_in           => u8(detector_pattern_in),
      pattern_we           => register_file_w(60),
      pattern_sample_count => detector_pattern_sample_count,
      adc_in               => u8(detector_adc_in),
      adc_we               => detector_adc_we,
      d_out                => detector_out
      );

  detector_ce <= '1';


  -- Clock generator
  DCM_CLKGEN_inst : DCM_CLKGEN
    generic map (
      CLKFXDV_DIVIDE  => 2,  -- CLKFXDV divide value (2, 4, 8, 16, 32)
      CLKFX_DIVIDE    => 12,  -- Divide value - D - (1-256)
      CLKFX_MD_MAX    => 0.0,  -- Specify maximum M/D ratio for timing anlysis
      CLKFX_MULTIPLY  => 25,  -- Multiply value - M - (2-256)
      --CLKIN_PERIOD => 1.0/48*1000.0,       -- Input clock period specified in nS
      --CLKIN_PERIOD => 48 MHz,
      SPREAD_SPECTRUM => "NONE",  -- Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD" or "CENTER_HIGH_SPREAD" 
      STARTUP_WAIT    => false  -- Delay config DONE until DCM LOCKED (TRUE/FALSE),
      )
    port map (
      CLKFX     => clk_2x,   -- 1-bit Generated clock output
      CLKFX180  => clk_2x_180,  -- 1-bit Generated clock output 180 degree out of phase from CLKFX.
      CLKFXDV   => clk_main,  -- 1-bit Divided clock output
      LOCKED    => clk_locked,  -- 1-bit Locked output
      PROGDONE  => open,  -- 1-bit Active high output to indicate the successful re-programming
      STATUS    => clk_status(2 downto 1),  -- 2-bit DCM status
      CLKIN     => clk_in,              -- 1-bit Input clock
      FREEZEDCM => '0',  -- 1-bit Prevents frequency adjustments to input clock
      PROGCLK   => '0',  -- 1-bit Clock input for M/D reconfiguration
      PROGDATA  => '0',  -- 1-bit Serial data input for M/D reconfiguration
      PROGEN    => '0',  -- 1-bit Active high program enable
      RST       => reset_in  -- 1-bit Reset input pin
      );

  ODDR2_inst : ODDR2
    generic map(
      DDR_ALIGNMENT => "C0",
      INIT          => '0',
      SRTYPE        => "ASYNC"
      )
    port map (
      Q  => gpio(0),                    -- 1-bit output data
      C0 => clk,                        -- 1-bit clock input
      C1 => not clk,                    -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D0 => '1',  -- 1-bit data input (associated with C0)
      D1 => '0',  -- 1-bit data input (associated with C1)
      R  => reset,                      -- 1-bit reset input
      S  => '0'                         -- 1-bit set input
      );

  -- Global clock buffer
  BUFG_inst : BUFG
    port map (
      O => clk_main_buf,  -- 1-bit Clock buffer output
      I => clk_main       -- 1-bit Clock buffer input
      );


  -- DCM connections
  clk_fb       <= clk_main_buf;
  clk_psen     <= '0';
  clk_psincdec <= '0';
  clk_psclk    <= '0';

  -- clocking & reset
  clk_fast <= clk_2x;
  clk      <= clk_main_buf;
  reset    <= not clk_locked;

  -- LEDs
  led(0) <= clk_locked;
  led(1) <= fi_armed;
  led(2) <= fi_trigger;
  led(3) <= sc_sw2;

  -- GPIO
  --gpio(0) <= pic_v_dd_en;
  gpio(1) <= not pic_v_pp_en;
  gpio(2) <= pic_ispdat;
  gpio(3) <= sc_status(5);
  gpio(4) <= sc_status(6);
  gpio(5) <= thresh_trigger;
  gpio(6) <= fi_trigger;
  gpio(7) <= fi_inject_fault;

  -- processes


end behavioral;


