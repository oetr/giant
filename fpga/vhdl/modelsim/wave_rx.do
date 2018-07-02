onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Basic
add wave -noupdate -group Basic -format Logic /sc_rx_tb/clk
add wave -noupdate -group Basic -format Logic /sc_rx_tb/rxtx_clk
add wave -noupdate -group Basic -format Logic /sc_rx_tb/reset
add wave -noupdate -expand -group Clocking
add wave -noupdate -group Clocking -format Literal /sc_rx_tb/rxtx_counter
add wave -noupdate -group Clocking -format Literal -radix unsigned /sc_rx_tb/etu
add wave -noupdate -group Clocking -format Literal /sc_rx_tb/timeout
add wave -noupdate -expand -group Interface
add wave -noupdate -group Interface -format Logic /sc_rx_tb/serial_in
add wave -noupdate -group Interface -format Literal /sc_rx_tb/byte_out
add wave -noupdate -group Interface -format Logic /sc_rx_tb/byte_complete
add wave -noupdate -group Interface -format Logic /sc_rx_tb/parity_error
add wave -noupdate -group Interface -format Logic /sc_rx_tb/timed_out
add wave -noupdate -expand -group Internal
add wave -noupdate -group Internal -format Literal -radix unsigned /sc_rx_tb/dut/timeout_count
add wave -noupdate -group Internal -format Literal /sc_rx_tb/dut/state
add wave -noupdate -group Internal -format Literal -radix unsigned /sc_rx_tb/dut/etu_count
add wave -noupdate -group Internal -format Logic /sc_rx_tb/dut/etu_reset
add wave -noupdate -group Internal -format Literal -radix unsigned /sc_rx_tb/dut/bit_count
add wave -noupdate -group Internal -format Logic /sc_rx_tb/dut/byte_complete_int
add wave -noupdate -group Internal -format Literal -radix binary /sc_rx_tb/dut/curr_byte
add wave -noupdate -group Internal -format Logic /sc_rx_tb/dut/curr_parity
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1506060606 ps} 0} {{Cursor 2} {199277328 ps} 0}
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
WaveRestoreZoom {0 ps} {2100 us}
