.macro bcd_begin(%reg_add, %reg_value)
	li %reg_value, 63
	sw %reg_value, 0(%reg_add) # bcd <- 0111111
.end_macro

.macro begin_number(%reg_add, %reg_value)
	li %reg_value, 0
	sw %reg_value, 0(%reg_add) # display_var <- 0
.end_macro

.macro reestart_time_value(%reg_ref, %reg_add)
	addiu %reg_ref, $zero, 0
	sw %reg_ref, 0(%reg_add) # variable <- 0
.end_macro

.macro update_time_value(%reg_ref, %reg_add)
	addiu %reg_ref, %reg_ref, 1
	sw %reg_ref, 0(%reg_add) # variable++
.end_macro

.macro select_display(%value_shifted, %PortData_add, %location)
	sll %value_shifted, %value_shifted, 6               # V_f <- V_f << 6, 2 shifts for buttons and 4 for enable
	ori %value_shifted, %value_shifted, %location       # enable[V_f] <- 1, enable just one display. OBS: enable = t3(5 downto 2)= location
	sw %value_shifted, 0(%PortData_add)	            # Stores bcd code and enable in PortData
.end_macro

.text

startApp:

	addiu $t0, $zero, 0x0004cc61 #t0 = treshold time = 314 465 verifications
	#addiu $t0, $zero, 0x00000061
	
	la $t1, bcd_1
	bcd_begin(T1, T2)
	
	la $t1, bcd_2
	bcd_begin(T1, T2)
	
	la $t1, bcd_3
	bcd_begin(T1, T2)
	
	la $t1, bcd_4
	bcd_begin(T1, T2)
	
	la $t1, display1_num1
	begin_number(T1, T2)
	
	la $t1, display1_num2
	begin_number(T1, T2)
	
	la $t1, display2_num1
	begin_number(T1, T2)
	
	la $t1, display2_num2
	begin_number(T1, T2)

time_management:
	la $t1, time
	load_variable_value(T1, T1)
	bne $t0, $t1, add_time_value
	jal change_display1
	
	la $t2, time
	reestart_time_value(T1, T2)
	j multiplex_bcds
	
add_time_value:
	
	la $t2, time
	update_time_value(T1, T2)

multiplex_bcds:
	
	addiu $t2, $zero, 0x80000002  # t2 <= PortData   address

	show_num_1:
		la $t3, bcd_1
		load_variable_value(T3, T3)
		
		select_display(T3, T2, 56)
	
	show_num_2:
		la $t3, bcd_2
		load_variable_value(T3, T3)
		
		select_display(T3, T2, 52)
	
	show_num_3:
		la $t3, bcd_3  
		load_variable_value(T3, T3)
		
		select_display(T3, T2, 44)
	
	show_num_4:
		la $t3, bcd_4          
		load_variable_value(T3, T3)
		
		select_display(T3, T2, 28)

	j time_management

change_display1:

        subu $sp, $sp, 32
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp) 
	sw $ra, 28($sp)
	
	#Handler

	la $s0, display1_num1    # s0 <- &display1_num1
	load_variable_value(S0, S1)
	
	check_limit(S2, S1, up_dec)
	
	add_one(S1, S0)
	j end_up

	up_dec:
	
		sw $zero, 0($s0)          # display1_num1 <- 0
		la $s0, display1_num2     # s0 <- &display1_num2
		load_variable_value(S0, S1)
		
		check_limit(S2, S1, max_reached)
		
		add_one(S1, S0)
		j end_up
		
	max_reached:
	
		sw $zero, 0($s0)          # display2_num2 <- 0
		
	end_up:
		jal code_bcd
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $s2, 24($sp)
		lw $ra, 28($sp)
		addiu $sp, $sp, 32
		
		jr $ra
		
code_bcd:

	subu $sp, $sp, 40
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	sw $ra, 36($sp)

	li $s0, 2            # s0 controls the loop. If s0 = 2, make the bcd for display1_num1
			     #                       if s0 = 1, make the bcd for display1_num2
	coding:

	select_number_to_decode(S1, S0, num_2_code)
	
	num_1_code:
	
	la $s1, display1_num1 # s1 <- &display1_num1
	load_variable_value(S1, S2)
	la $s3, bcd_1
	j code_0

	num_2_code:

	la $s1, display1_num2   # s1 <- &display1_num2
	load_variable_value(S1, S2)
	la $s3, bcd_2
	
	# bcd selection area:
	
	code_0:
		save_if_equal_if_not_branch(0, 63, code_1)
		j iterate
	code_1:
		save_if_equal_if_not_branch(1, 6, code_2)
		j iterate
	code_2:
		save_if_equal_if_not_branch(2, 91, code_3)
		j iterate
	code_3:
		save_if_equal_if_not_branch(3, 79, code_4)
		j iterate
	code_4:
		save_if_equal_if_not_branch(4, 102, code_5)
		j iterate
	code_5:
		save_if_equal_if_not_branch(5, 109, code_6)
		j iterate
	code_6:
		save_if_equal_if_not_branch(6, 125, code_7)
		j iterate
	code_7:
		save_if_equal_if_not_branch(7, 7, code_8)
		j iterate
	code_8:
		save_if_equal_if_not_branch(8, 127, code_9)
		j iterate
	code_9:
		save_if_equal_if_not_branch(9, 111, code_10)
		j iterate
	code_10:
		save_if_equal_if_not_branch(10, 119, code_11)
		j iterate
	code_11:
		save_if_equal_if_not_branch(11, 94, code_12)
		j iterate
	code_12:
		save_if_equal_if_not_branch(12, 57, code_13)
		j iterate
	code_13:
		save_if_equal_if_not_branch(13, 124, code_14)
		j iterate
	code_14:
		save_if_equal_if_not_branch(14, 121, code_15)
		j iterate
	code_15:
		li $s4, 113  
		sw $s4, 0($s3) # bcd <- 1110001
		
	iterate:
	
	subu $s0, $s0, 1
	bne $s0, $zero, coding # when s0 reaches 0 both bcd codes have been done
	
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	lw $ra, 36($sp)
	addiu $sp, $sp, 40
	
	jr $ra
	
.data
	display1_num1:     .word 0 # MEM [29]
	display1_num2:     .word 0 # MEM [30]
	display2_num1:     .word 0 # MEM [31]
	display2_num2:     .word 0 # MEM [32]
	
	bcd_1:          .word 0    # MEM [33]
	bcd_2:		.word 0    # MEM [34]
	bcd_3:          .word 0    # MEM [35]
	bcd_4:		.word 0    # MEM [36]
	
	time:         .word 0      # MEM [37]
