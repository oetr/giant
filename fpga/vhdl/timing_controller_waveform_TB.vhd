library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------------------------------------
entity timing_controller_waveform_TB is
end timing_controller_waveform_TB;
------------------------------------------------------------
architecture TB of timing_controller_waveform_TB is
  
begin
  DUT : timing_controller_waveform
    generic map(
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
end architecture TB;
