onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock, PC, INST and STATE}
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/clock
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/currentState
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/decodedInstruction
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/pc
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/inPC
add wave -noupdate -divider ALU
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/ALUoperand1
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/ALUoperand2
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/result
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/ALUOut
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/readData1
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/readData2
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/A
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/B
add wave -noupdate -divider Registers
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/registerFile
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/RegWrite
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/writeData
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/writeRegister
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/rd
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/rt
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/rs
add wave -noupdate -divider {Other Sigs}
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/zero
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/signExtend
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/branchOffset
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/instruction_reg
add wave -noupdate -divider Memory
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/instructionAddress
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/dataAddress
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/data_i
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/data_o
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/MDR
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/ce
add wave -noupdate /mips_multicycle_tb/MIPS_MULTICYCLE/MemWrite
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1038 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 328
configure wave -valuecolwidth 94
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
WaveRestoreZoom {1006 ns} {1056 ns}
