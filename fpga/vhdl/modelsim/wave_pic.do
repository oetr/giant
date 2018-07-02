onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Standard
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/clk
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/reset
add wave -noupdate -group Standard -format Literal /pic_programmer_tb/data_in
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/has_data
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/send
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/prog_startstop
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/get_response
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/programming
add wave -noupdate -group Standard -format Literal /pic_programmer_tb/data_out
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/v_dd_en
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/v_pp_en
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/pgm
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/ispclk
add wave -noupdate -group Standard -format Logic /pic_programmer_tb/ispdat
add wave -noupdate -expand -group Internals
add wave -noupdate -group Internals -format Logic /pic_programmer_tb/dut/isp_clk_gen
add wave -noupdate -group Internals -format Literal -radix unsigned /pic_programmer_tb/dut/isp_clk_counter
add wave -noupdate -group Internals -format Literal /pic_programmer_tb/dut/isp_in
add wave -noupdate -group Internals -format Literal -radix unsigned /pic_programmer_tb/dut/delay_count
add wave -noupdate -group Internals -format Logic /pic_programmer_tb/dut/ispclk_int
add wave -noupdate -group Internals -format Literal /pic_programmer_tb/dut/state
add wave -noupdate -expand -group {I/O counters}
add wave -noupdate -group {I/O counters} -format Literal -radix unsigned /pic_programmer_tb/dut/isp_out_count
add wave -noupdate -group {I/O counters} -format Literal -radix unsigned /pic_programmer_tb/dut/isp_in_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7212121 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {210 us}
