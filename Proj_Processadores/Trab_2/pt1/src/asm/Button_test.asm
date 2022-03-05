
.text 

	addiu $t2, $zero, 0x80000000  # t2 <= PortEnable address
	addiu $t3, $zero, 0x80000001  # t3 <= PortConfig address
	addiu $t4, $zero, 0x80000002  # t4 <= PortData address
	la $t5, number
	
	addiu $t1, $zero, 0x0000ffff  # All wires are enable
	sw $t1, 0($t2)                # PortEnable <= t1
	
	addiu $t1, $zero, 0x00000003  # Pin_IO(0) <= Button. Pin_IO(1) <= Reg_Periph_Button
	sw $t1, 0($t3)
	
	addiu $t7, $zero, 2
	
read_button:
	#lw $zero, 0($t4)
	lw $zero, 0x80000010          # Bidirectional_Port <= Reg_Periph_Button
	sw $zero, 0($t4)              # PortDta <= Bidirectional_Port
	lw $t1, 0($t4)                # t1 <= PortData
	andi $t1, $t1, 2              # t1 <= $t1 AND 10
	
	beq $t1, $t7, sum
	j read_button

sum:
	lw $t6, 0($t5)
	addiu $t6, $t6, 1
	sw $t6, 0($t5)
	j read_button
	
	
.data
	number: .word 0
