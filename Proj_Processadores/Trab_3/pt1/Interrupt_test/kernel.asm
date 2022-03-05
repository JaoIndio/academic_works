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

.eqv KSS 0x100100b8 # Kernel Stack Start

.macro save_register(%register_to_save, %byte_distance)
	addiu $k0, %register_to_save, 0
	sw $k0, %byte_distance($k1)
.end_macro

.macro return_register(%register_to_save, %byte_distance)
	lw $k0, %byte_distance($k1)
	addiu %register_to_save, $k0, 0
.end_macro

.macro read_Birectional_Port()
	lw $t0, 0x80000002 # t0 <- PortData
.end_macro

.macro check_peripheral(%Handler_position, %handler_Name)
	andi $t1, $t0, %Handler_position
	bne $t1, $zero, %handler_Name
.end_macro

.text	
	# Save context
	lui $k1,0x00001001      # KERNEL's CODE START
	ori $k1,$k1,0x00000000  # k1 = &PCB
	
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
	save_register(SP, 104)
	save_register(FP, 108)
	save_register(RA, 112)
	
	# Set sp to kernel stack
	addiu $sp, $zero, KSS
	
	# Find peripheral who has caused interruption
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
	return_register(SP, 104)
	return_register(FP, 108)
	return_register(RA, 112)
	
	eret                     # KERNEL's CODE END
	
#startApp:
#	j BubbleSort
	
.data
	PCB:                 .space 116
	peripheral_variable: .word 4
	
#.include "BubbleSort.asm"
