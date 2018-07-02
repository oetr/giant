onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Interface
add wave -noupdate -group Interface -format Logic /sc_tx_tb/clk
add wave -noupdate -group Interface -format Logic /sc_tx_tb/reset
add wave -noupdate -group Interface -format Literal /sc_tx_tb/etu
add wave -noupdate -group Interface -format Logic /sc_tx_tb/transmit
add wave -noupdate -group Interface -format Literal /sc_tx_tb/byte_in
add wave -noupdate -group Interface -format Logic /sc_tx_tb/serial_out
add wave -noupdate -group Interface -format Logic /sc_tx_tb/byte_complete
add wave -noupdate -expand -group Internals
add wave -noupdate -group Internals -format Literal -radix unsigned /sc_tx_tb/dut/etu_count
add wave -noupdate -group Internals -format Logic /sc_tx_tb/dut/etu_reset
add wave -noupdate -group Internals -format Literal /sc_tx_tb/dut/curr_byte
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {499999807 ps} 0}
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
WaveRestoreZoom {0 ps} {51570048 ps}
