.eqv ZERO $zero
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

.eqv KSS 0x100101b8 # Kernel Stack Start

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

.macro load_variable_value(%address, %register_to_save)
	lw %register_to_save, 0(%address)           # register_to_save <- variable_name
.end_macro

.macro check_limit(%reg_aux, %reg_ref, %label_to_branch)
	li %reg_aux, 15
	beq %reg_ref, %reg_aux, %label_to_branch       # if(reg_ref == 15) goto label_to_branch
.end_macro

.macro add_one(%variable_value, %variable_address)
	addiu %variable_value, %variable_value, 1      # variable_value <- variable_value++
	sw %variable_value, 0(%variable_address)       # variable_address <= variable_value
.end_macro

.macro sub_one(%variable_value, %variable_address)
	subu %variable_value, %variable_value, 1       # variable_value <- variable_value++
	sw %variable_value, 0(%variable_address)       # variable_address <= variable_value
.end_macro

.macro select_number_to_decode(%reg_aux, %reg_ref, %label)
	li %reg_aux, 1
	beq %reg_ref, %reg_aux, %label
.end_macro

.macro save_if_equal_if_not_branch(%num_ref, %decode,  %next_verification)
        li $s1, %num_ref
	bne $s2, $s1, %next_verification
	li $s4, %decode
	sw $s4, 0($s3) # bcd <- decode
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
	
	check_peripheral(1, peripheral_1_label) #Button Up
	check_peripheral(2, peripheral_2_label) #Button Down
	
	j ISR_end
	
	# peripheral_1()
peripheral_1_label:
	jal peripheral_1
	j ISR_end
	
# peripheral_2()
peripheral_2_label:
	jal peripheral_2
	j ISR_end
	 
ISR_end:
	j return_to_user
	
	
# execute peripheral_1 Handler
peripheral_1:                  #Buttun Up Handler

	subu $sp, $sp, 32
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $ra, 28($sp)
	
	#Handler

	la $s0, display2_num1    # s0 <- &display2_num1
	load_variable_value(S0, S1)
	
	check_limit(S2, S1,Kup_dec)
	
	add_one(S1, S0)
	j Kend_up

	Kup_dec:
	
		sw $zero, 0($s0)          # display2_num1 <- 0
		la $s0, display2_num2     # s0 <- &display2_num2
		load_variable_value(S0, S1)
		
		check_limit(S2, S1, Kmax_reached)
		
		add_one(S1, S0)
		j Kend_up
		
	Kmax_reached:
	
		sw $zero, 0($s0)          # display2_num2 <- 0
		
	Kend_up:
		jal Kcode_bcd
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $s2, 24($sp)
		lw $ra, 28($sp)
		addiu $sp, $sp, 32
		
		jr $ra


peripheral_2: #Button Down Handler
	
	subu $sp, $sp, 32
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $ra, 28($sp)
	
	#Handler

	la $s0, display2_num1    # s0 <- &display2_num1
	load_variable_value(S0, S1)
	
	check_limit(S2, S1, Kdown_dec)
	
	sub_one(S1, S0)
	j Kend_down

	Kdown_dec:
	
		sw $zero, 0($s0)          # display2_num1 <- 0
		la $s0, display2_num2     # s0 <- &display2_num2
		load_variable_value(S0, S1)
		
		check_limit(S2, S1, Kmin_reached)
		
		sub_one(S1, S0)
		j Kend_down
		
	Kmin_reached:
	
		li $s1, 0xf
		sw $s1, 0($s0)               # display2_num2 <- 15
		
	Kend_down:
		jal Kcode_bcd
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $s2, 24($sp)
		lw $ra, 28($sp)
		addiu $sp, $sp, 32
		
		jr $ra
		
Kcode_bcd:

	subu $sp, $sp, 40
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	sw $ra, 36($sp)

	li $s0, 2            # s0 controls the loop. If s0 = 2, make the bcd for display2_num1
			     #                       if s0 = 1, make the bcd for display2_num2
	Kcoding:

	select_number_to_decode(S1, S0, Knum_2_code)
	
	Knum_1_code:
	
	la $s1, display2_num1  # s1 <- &display2_num1
	load_variable_value(S1 ,S2)
	la $s3, bcd_3
	j Kcode_0

	Knum_2_code:

	la $s1, display2_num2   # s1 <- &display2_num2
	load_variable_value(S1, S2)
	la $s3, bcd_4
	
	# bcd selection area:
	
	Kcode_0:
		save_if_equal_if_not_branch(0, 63, Kcode_1)
		j Kiterate
	Kcode_1:
		save_if_equal_if_not_branch(1, 6, Kcode_2)
		j Kiterate
	Kcode_2:
		save_if_equal_if_not_branch(2, 91, Kcode_3)
		j Kiterate
	Kcode_3:
		save_if_equal_if_not_branch(3, 79,  Kcode_4)
		j Kiterate
	Kcode_4:
		save_if_equal_if_not_branch(4, 102, Kcode_5)
		j Kiterate
	Kcode_5:
		save_if_equal_if_not_branch(5, 109, Kcode_6)
		j Kiterate
	Kcode_6:
		save_if_equal_if_not_branch(6, 125, Kcode_7)
		j Kiterate
	Kcode_7:
		save_if_equal_if_not_branch(7, 7, Kcode_8)
		j Kiterate
	Kcode_8:
		save_if_equal_if_not_branch(8, 127, Kcode_9)
		j Kiterate
	Kcode_9:
		save_if_equal_if_not_branch(9, 111, Kcode_10)
		j Kiterate
	Kcode_10:
		save_if_equal_if_not_branch(10, 119, Kcode_11)
		j Kiterate
	Kcode_11:
		save_if_equal_if_not_branch(11, 94, Kcode_12)
		j Kiterate
	Kcode_12:
		save_if_equal_if_not_branch(12, 57, Kcode_13)
		j Kiterate
	Kcode_13:
		save_if_equal_if_not_branch(13, 124, Kcode_14)
		j Kiterate
	Kcode_14:
		save_if_equal_if_not_branch(14, 121, Kcode_15)
		j Kiterate
	Kcode_15:
		li $s4, 113  
		sw $s4, 0($s3) # bcd <- 1110001
		
	Kiterate:
	
	subu $s0, $s0, 1
	bne $s0, $zero, Kcoding # when s0 reaches 0 both bcd codes have been done
	
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	lw $ra, 36($sp)
	addiu $sp, $sp, 40
	
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
	
.data
	PCB:                   .space 116
	
