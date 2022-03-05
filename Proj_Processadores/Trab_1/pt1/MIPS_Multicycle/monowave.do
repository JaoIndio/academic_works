onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Inst}
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/clock
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/decodedInstruction
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/pc
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/inPC
add wave -noupdate -divider ALU
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/ALUoperand1
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/ALUoperand2
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/readData2
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/result
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/branchOffset
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/zero
add wave -noupdate -divider {Register File}
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/registerFile
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/RegWrite
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/writeRegister
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/writeData
add wave -noupdate -divider Memory
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/instructionAddress
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/dataAddress
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/data_i
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/data_o
add wave -noupdate -divider {Other sigs}
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/branchTarget
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/signExtend
add wave -noupdate /mips_monocycle_tb/MIPS_MONOCYCLE/zeroExtended
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {65 ns}
