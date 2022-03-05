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

#.macro load_variable_value(%address, %register_to_save)
#	lw %register_to_save, 0(%address)           # register_to_save <- variable_name
#.end_macro

#.macro selec_number_to_decode(%reg_aux, %reg_ref, %label)
#	li %reg_aux, 1
#	beq %reg_ref, %reg_aux, %label
#.end_macro

.text

startApp:

	#addiu $t0, $zero, 0x0004cc61 #t0 = treshold time = 314 465 verifications
	addiu $t0, $zero, 0x00000061
	
	la $t1, bcd_1
	#li $t2, 63
	#sw $t2, 0($t1) # bcd <- 0111111
	bcd_begin(T1, T2)
	
	la $t1, bcd_2
	#li $t2, 63
	#sw $t2, 0($t1) # bcd <- 0111111
	bcd_begin(T1, T2)
	
	la $t1, bcd_3
	#li $t2, 63
	#sw $t2, 0($t1) # bcd <- 0111111
	bcd_begin(T1, T2)
	
	la $t1, bcd_4
	#li $t2, 63
	#sw $t2, 0($t1) # bcd <- 0111111
	bcd_begin(T1, T2)
	
	la $t1, display1_num1
	#li $t2, 0
	#sw $t2, 0($t1)
	begin_number(T1, T2)
	
	la $t1, display1_num2
	#li $t2, 0
	#sw $t2, 0($t1)
	begin_number(T1, T2)
	
	la $t1, display2_num1
	#li $t2, 0
	#sw $t2, 0($t1)
	begin_number(T1, T2)
	
	la $t1, display2_num2
	#li $t2, 0
	#sw $t2, 0($t1)
	begin_number(T1, T2)

time_management:
	la $t1, time
	#lw $t1, 0($t1)
	load_variable_value(T1, T1)
	bne $t0, $t1, add_time_value
	jal change_display1
	
	la $t2, time
	#addiu $t1, $zero, 0
	#sw $t1, 0($t2)
	reestart_time_value(T1, T2)
	j multiplex_bcds
	
add_time_value:
	
	# This nops helps to debbug the code at ISE simulator
	#nop 
	#nop
	#nop
	
	la $t2, time
	#addiu $t1, $t1, 1
	#sw $t1, 0($t2)
	update_time_value(T1, T2)

multiplex_bcds:
	
	# This nops helps to debbug the code at ISE simulator
	#nop 
	#nop
	#nop
	#nop
	#nop
	
	#nop
	#nop
	#nop
	#nop
	#nop
	
	addiu $t2, $zero, 0x80000002  # t2 <= PortData   address
	#load_address(T2, PortDataAddres)

	show_num_1:
		la $t3, bcd_1         
		#lw $t3, 0($t3)         # t3 <- bcd_1
		load_variable_value(T3, T3)
		
		#sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		#ori $t3, $t3, 56       # t3[2] <- 1, enabling first display. OBS: enable = t3(5 downto 2)= 1110 00
		#sw $t3, 0($t2)	       # Stores bcd code and enable in PortData
		select_display(T3, T2, 56)
	
	show_num_2:
		la $t3, bcd_2          
		#lw $t3, 0($t3)         # t3 <- bcd_2
		load_variable_value(T3, T3)
		
		#sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		#ori $t3, $t3, 52       # t3[3] <- 1, enabling second display. OBS: enable = t3(5 downto 2) = 1101 00     
		#sw $t3, 0($t2)         # Stores bcd code and enable in PortData
		select_display(T3, T2, 52)
	
	show_num_3:
		la $t3, bcd_3         
		#lw $t3, 0($t3)         # t3 <- bcd_3
		load_variable_value(T3, T3)
		
		#sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		#ori $t3, $t3, 44       # t3[2] <- 1, enabling first display. OBS: enable = t3(5 downto 2)= 1011 00
		#sw $t3, 0($t2)	       # Stores bcd code and enable in PortData
		select_display(T3, T2, 44)
	
	show_num_4:
		la $t3, bcd_4          
		#lw $t3, 0($t3)         # t3 <- bcd_4
		load_variable_value(T3, T3)
		
		#sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		#ori $t3, $t3, 28       # t3[3] <- 1, enabling second display. OBS: enable = t3(5 downto 2) = 0111 00    
		#sw $t3, 0($t2)         # Stores bcd code and enable in PortData
		select_display(T3, T2, 28)
	
	# This nops helps to debbug the code at ISE simulator
	#nop 
	#nop
	#nop
	#nop
	#nop	
	
	#nop
	#nop
	#nop
	#nop
	#nop
	
	j time_management

change_display1:

        subu $sp, $sp, 32
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp) 
	sw $ra, 28($sp)
	
	#Handler

	la $s0, display1_num1    # s0 <- &display1_num1
	#lw $s1, 0($s0)           # s1 <- display1_num1
	load_variable_value(S0, S1)
	
	#li $s2,15
	#beq $s1, $s2, up_dec # if(display2_num1 == 15) goto inc_dec
	check_limit(S2, S1, up_dec)
	
	#addiu $s1,$s1,1      # s1 <- s1++
	#sw $s1, 0($s0)       # display2_num1 <= s1
	add_one(S1, S0)
	j end_up

	up_dec:
	
		sw $zero, 0($s0)          # display1_num1 <- 0
		la $s0, display1_num2     # s0 <- &display1_num2
		#lw $s1, 0($s0)            # s1 <- display1_num2
		load_variable_value(S0, S1)
		
		#li $s2,15
		#beq $s1, $s2, max_reached # if(display1_num2 == 15) goto max_reached
		check_limit(S2, S1, max_reached)
		
		#addiu $s1,$s1,1           # s1 <- s1++
		#sw $s1, 0($s0)            # display2_num2 <= s1
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

	#li $s1, 1
	#beq $s0, $s1, num_2_code
	select_number_to_decode(S1, S0, num_2_code)
	
	num_1_code:
	
	la $s1, display1_num1 # s1 <- &display1_num1
	#lw $s2, 0($s1)        # s2 <- display1_num1
	load_variable_value(S1, S2)
	la $s3, bcd_1
	j code_0

	num_2_code:

	la $s1, display1_num2   # s1 <- &display1_num2
	#lw $s2, 0($s1)       # s2 <- display1_num2
	load_variable_value(S1, S2)
	la $s3, bcd_2
	
	# bcd selection area:
	
	code_0:
		#li $s1, 0
		#bne $s2, $zero, code_1
		#li $s4, 63
		#sw $s4, 0($s3) # bcd <- 0111111
		save_if_equal_if_not_branch(0, 63, code_1)
		j iterate
	code_1:
		#li $s1, 1
		#bne $s2, $s1, code_2
		#li $s4, 6    
		#sw $s4, 0($s3) # bcd <- 0000110
		save_if_equal_if_not_branch(1, 6, code_2)
		j iterate
	code_2:
		#li $s1, 2
		#bne $s2, $s1, code_3
		#li $s4, 91   
		#sw $s4, 0($s3) # bcd <- 1011011
		save_if_equal_if_not_branch(2, 91, code_3)
		j iterate
	code_3:
		#li $s1, 3
		#bne $s2, $s1, code_4
		#li $s4, 79   
		#sw $s4, 0($s3) # bcd <- 1001111
		save_if_equal_if_not_branch(3, 79, code_4)
		j iterate
	code_4:
		#li $s1, 4
		#bne $s2, $s1, code_5
		#li $s4, 102  
		#sw $s4, 0($s3) # bcd <- 1100110
		save_if_equal_if_not_branch(4, 102, code_5)
		j iterate
	code_5:
		#li $s1, 5
		#bne $s2, $s1, code_6
		#li $s4, 109  
		#sw $s4, 0($s3) # bcd <- 1101101
		save_if_equal_if_not_branch(5, 109, code_6)
		j iterate
	code_6:
		#li $s1, 6
		#bne $s2, $s1, code_7
		#li $s4, 125  
		#sw $s4, 0($s3) # bcd <- 1111101
		save_if_equal_if_not_branch(6, 125, code_7)
		j iterate
	code_7:
		#li $s1, 7
		#bne $s2, $s1, code_8
		#li $s4, 7    
		#sw $s4, 0($s3) # bcd <- 0000111
		save_if_equal_if_not_branch(7, 7, code_8)
		j iterate
	code_8:
		#li $s1, 8
		#bne $s2, $s1, code_9
		#li $s4, 127  
		#sw $s4, 0($s3) # bcd <- 1111111
		save_if_equal_if_not_branch(8, 127, code_9)
		j iterate
	code_9:
		#li $s1, 9
		#bne $s2, $s1, code_10
		#li $s4, 111  
		#sw $s4, 0($s3) # bcd <- 1101111
		save_if_equal_if_not_branch(9, 111, code_10)
		j iterate
	code_10:
		#li $s1, 10
		#bne $s2, $s1, code_11
		#li $s4, 119  
		#sw $s4, 0($s3) # bcd <- 1110111
		save_if_equal_if_not_branch(10, 119, code_11)
		j iterate
	code_11:
		#li $s1, 11
		#bne $s2, $s1, code_12
		#li $s4, 94   
		#sw $s4, 0($s3) # bcd <- 1011110
		save_if_equal_if_not_branch(11, 94, code_12)
		j iterate
	code_12:
		#li $s1, 12
		#bne $s2, $s1, code_13
		#li $s4, 57   
		#sw $s4, 0($s3) # bcd <- 0111001
		save_if_equal_if_not_branch(12, 57, code_13)
		j iterate
	code_13:
		#li $s1, 13
		#bne $s2, $s1, code_14
		#li $s4, 124  
		#sw $s4, 0($s3) # bcd <- 1111100
		save_if_equal_if_not_branch(13, 124, code_14)
		j iterate
	code_14:
		#li $s1, 14
		#bne $s2, $s1, code_15
		#li $s4, 121  
		#sw $s4, 0($s3) # bcd <- 1111001
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
