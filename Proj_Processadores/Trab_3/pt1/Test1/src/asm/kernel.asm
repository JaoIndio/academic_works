.eqv AT $at
.eqv V0 $v0
.eqv V1 $v1
.eqv A0 $a0
.eqv A1 $a1

.eqv A2 $a2
.eqv A3 $a3
.eqv T0 $t0
.eqv T1 $t1
.eqv T2 $t2

.eqv T3 $t3
.eqv T4 $t4
.eqv T5 $t5
.eqv T6 $t6
.eqv T7 $t7

.eqv T8 $t8
.eqv T9 $t9
.eqv S0 $s0
.eqv S1 $s1
.eqv S2 $s2

.eqv S3 $s3
.eqv S4 $s4
.eqv S5 $s5
.eqv S6 $s6
.eqv S7 $s7

.eqv GP $gp
.eqv SP $sp
.eqv FP $fp
.eqv RA $ra

.macro save_register(%register_to_save, %byte_distance)
	addiu $k0, %register_to_save, 0
	sw $k0, %byte_distance($k1)
.end_macro

.macro return_register(%register_to_save, %byte_distance)
	lw $k0, %byte_distance($k1)
	addiu %register_to_save, $k0, 0
.end_macro

.macro read_Birectional_Port()
	#sw $t0, 0x80000002
	lw $t0, 0x80000002 # t0 <- PortData
.end_macro

.macro check_peripheral(%Handler_position, %handler_Name)
	andi $t1, $t0, %Handler_position
	bne $t1, $zero, %handler_Name
.end_macro

.macro temporary_boot()
	addiu $t0, $zero, 0x80000000  # t0 <= PortEnable address
	addiu $t1, $zero, 0x80000001  # t1 <= PortConfig address
	
	addiu $t3, $zero, 0x0000ffff  # All wires are enabled
	sw $t3, 0($t0)                # PortEnable <= t3
	
	addiu $t3, $zero, 0x00000003  # Only the 2 button bits are to be read, the is to write
	sw $t3, 0($t1)                # PortConfig <= t3
.end_macro

.macro change_register(%register_to_save, %byte_distance)
	addiu %register_to_save, $zero, %byte_distance
.end_macro

.text
        la $t0, PCB
        sw $zero, 0($t0)
        
        la $t0, peripheral_variable
        addiu $t1, $zero, 4
        sw $t1, 0($t0)
	
	change_register(AT, 0)
	change_register(V0, 4)
	change_register(V1, 8)
	change_register(A0, 12)
	change_register(A1, 16)
	
	change_register(A2, 20)
	change_register(A3, 24)
	change_register(T0, 28)
	change_register(T1, 32)
	change_register(T2, 36)
	
	change_register(T3, 40)
	change_register(T4, 44)
	change_register(T5, 48)
	change_register(T6, 52)
	change_register(T7, 56)
	
	change_register(S0, 60)
	change_register(S1, 64)
	change_register(S2, 68)
	change_register(S3, 72)
	change_register(S4, 76)
	
	change_register(S5, 80)
	change_register(S6, 84)
	change_register(S7, 88)
	change_register(T8, 92)
	change_register(T9, 96)
	
	#change_register(GP, 100)
	#change_register(SP, 102)
	change_register(FP, 104)
	change_register(RA, 108)
	
	
	# Save context
	la $k1, PCB
	save_register(AT, 0)
	save_register(V0, 4)
	save_register(V1, 8)
	save_register(A0, 12)
	save_register(A1, 16)
	
	save_register(A2, 20)
	save_register(A3, 24)
	save_register(T0, 28)
	save_register(T1, 32)
	save_register(T2, 36)
	
	save_register(T3, 40)
	save_register(T4, 44)
	save_register(T5, 48)
	save_register(T6, 52)
	save_register(T7, 56)
	
	save_register(S0, 60)
	save_register(S1, 64)
	save_register(S2, 68)
	save_register(S3, 72)
	save_register(S4, 76)
	
	save_register(S5, 80)
	save_register(S6, 84)
	save_register(S7, 88)
	save_register(T8, 92)
	save_register(T9, 96)
	
	save_register(GP, 100)
	save_register(SP, 102)
	save_register(FP, 104)
	save_register(RA, 108)
	
	# Set sp to kernel stack
	addiu $sp, $zero, 0x10010080 # definir melhor onde vai começar a pilha do kernel
	
	# Find peripheral who have caused interruption
	temporary_boot()
	read_Birectional_Port()
	
	check_peripheral(1, peripheral_1_label)
	#check_peripheral(2, peripheral_2_label) 
	#check_peripheral(4, peripheral_3_label) 
	#check_peripheral(8, peripheral_4_label) 
	#check_peripheral(16, peripheral_5_label)  
	
	j ISR_end
	
	# peripheral_1()
peripheral_1_label:
	jal peripheral_1
	j ISR_end
	
	# peripheral_2()
#peripheral_2_label:
#	jal peripheral_2
#	j ISR_end

	# peripheral_2()
#peripheral_3_label:
#	jal peripheral_3
#	j ISR_end
	
	 
ISR_end:
	j return_to_user
	
	
	# execute peripheral Handler
peripheral_1:
	subu $sp, $sp, 28
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $ra, 24($sp)
	
	# Handler
	la $s0, peripheral_variable
	lw $s1, 0($s0)
	addiu $s1, $s1, 23
	sw $s1, 0($s0) 
	
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $ra, 24($sp)
	addiu $sp, $sp, 28
	
	jr $ra
	
	# recover context
return_to_user:

	return_register(AT, 0)
	return_register(V0, 4)
	return_register(V1, 8)
	return_register(A0, 12)
	return_register(A1, 16)
	
	return_register(A2, 20)
	return_register(A3, 24)
	return_register(T0, 28)
	return_register(T1, 32)
	return_register(T2, 36)
	
	return_register(T3, 40)
	return_register(T4, 44)
	return_register(T5, 48)
	return_register(T6, 52)
	return_register(T7, 56)
	
	return_register(S0, 60)
	return_register(S1, 64)
	return_register(S2, 68)
	return_register(S3, 72)
	return_register(S4, 76)
	
	return_register(S5, 80)
	return_register(S6, 84)
	return_register(S7, 88)
	return_register(T8, 92)
	return_register(T9, 96)
	
	return_register(GP, 100)
	return_register(SP, 102)
	return_register(FP, 104)
	return_register(RA, 108)
	
	eret
	
.data


	peripheral_variable: .word 4
	PCB:                .space 112
