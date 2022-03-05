

.text
	lui $sp	, 0x1001
	ori $sp,$sp,0x0080

	addiu $t0, $zero, 0x80000000  # t0 <= PortEnable address
	addiu $t1, $zero, 0x80000001  # t1 <= PortConfig address
	addiu $t2, $zero, 0x80000002  # t2 <= PortData address

	#addiu $t0, $zero, 0x10010028  # t0 <= PortEnable address
	#addiu $t1, $zero, 0x1001002c  # t1 <= PortConfig address
	#addiu $t2, $zero, 0x10010030  # t2 <= PortData address
			
	addiu $t3, $zero, 0x0000ffff  # All wires are enabled
	sw $t3, 0($t0)                # PortEnable <= t3
	
	addiu $t3, $zero, 0x00000003  # Only the 2 button bits are to be read, the is to write
	sw $t3, 0($t1)                # PortConfig <= t3
	
	#addiu $t3, $zero, 0x00000001  #
	#sw $t3, 0($t2)                # PortData <= 0010, button up pressed
	
	subu $t5, $zero, 1
	addiu $t5, $zero, 3
	
	#	
	# int main(){
	#   if( BtUp == 1 && Up_Signal == 0)
	#     Up_Signal = 1;
	#   
	#   if(BtUp == 0 && Up_Signal == 1){
	#     btn_up_pressed();
	#     Up_Signal = 0;
	#   }  
	#   if( BtDown == 1 && Down_Signal == 0)
	#     Down_Signal = 2;
	#   
	#   if(BtDown == 1 && Down_Signal == 2){
	#     btn_down_pressed();
	#     Down_Signal = 0;
	#   }
	#
	# At the main code assembly:
	# 
	# t4 => works like Btup and BtDown variables
	# t7 => works like Up_Signal variable
	# t8 => works like Down_Signal variable
	
main_loop:
	
	sw $t3, 0($t2)
	lw $t3, 0($t2)                 # t3 <- PortData
	
	andi $t4, $t3,0x0001           # t4 <- BtUp 
	          
	beq $t4, $zero, btn_up_condittion   
	bne $t7, $zero, check_btn2
	li $t7,1                       # Up_Signal = 1
	j check_btn2

	btn_up_condittion:
	li $t6, 1
	bne $t7, $t6, check_btn2
	jal btn_up_pressed             # if (PortData[0] == 1) btn_up_pressed()
	li $t7, 0                      # Up_Signal = 0 
	
	check_btn2:
	
	andi $t4,$t3, 0x0002          # t4 <- BtDown
	
	beq $t4, $zero, btn_down_condittion   
	bne $t7, $zero, show_number
	li $t8,2                       # Down_Signal = 1
	j show_number

	btn_down_condittion:
	li $t6, 2
	bne $t8, $t6, show_number
	jal btn_down_pressed           # if (PortData[0] == 1) btn_up_pressed()
	li $t8, 0                      # Up_Donw_Signal = 0 
	#beq $t4, $zero, show_number
	#jal btn_down_pressed           # if (PortData[1] == 1) btn_down_pressed()
	
	show_number:
	
	show_num_1:
		bgez $t5, show_num_2   # if (t5 >= 0) show_num_2
		la $t3, bcd_1         
		lw $t3, 0($t3)         # t3 <- bcd_1
		sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		
		#ori $t3, $t3, 1
		
		ori $t3, $t3, 4        # t3[2] <- 1, enabling first display. OBS: enable = t5(5 downto 2)
		sw $t3, 0($t2)	       # Stores bcd code and enable in PortData
		addiu $t5, $zero, 1    # sets t5 in order to display num_2 next round
		j iterate_loop
	
	show_num_2:
		la $t3, bcd_2          
		lw $t3, 0($t3)         # t3 <- bcd_2
		sll $t3, $t3, 6        # t3 <- t3 << 6, 2 shifts for buttons and 4 for enable
		
		#ori $t3, $t3, 1
		
		ori $t3, $t3, 8        # t3[3] <- 1, enabling second display. OBS: enable = t5(5 downto 2)
		sw $t3, 0($t2)         # Stores bcd code and enable in PortData
		subu $t5, $zero, 1     # sets t5 in order to display num_1 next round
	
	iterate_loop:
	
	j main_loop
	
btn_up_pressed:

	subu $sp, $sp, 32
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $ra, 28($sp)

	la $s0, num_disp_1   # s0 <- &num_disp_1
	lw $s1, 0($s0)       # s1 <- num_disp_1
	
	li $s2,15
	beq $s1, $s2, up_dec # if(num_disp_1 == 15) goto inc_dec
	
	addiu $s1,$s1,1      # s1 <- s1++
	sw $s1, 0($s0)       # num_disp_1 <= s1
	j end_up

	up_dec:
	
		sw $zero, 0($s0)          # num_disp_1 <- 0
		la $s0, num_disp_2        # s0 <- &num_disp_2
		lw $s1, 0($s0)            # s1 <- num_disp_2
		
		li $s2,15
		beq $s1, $s2, max_reached # if(num_disp_2 == 15) goto max_reached
		
		addiu $s1,$s1,1           # s1 <- s1++
		sw $s1, 0($s0)            # num_disp_1 <= s1
		j end_up
		
	max_reached:
	
		sw $zero, 0($s0)          # num_disp_2 <- 0
		
	end_up:
		jal code_bcd
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $s2, 24($sp)
		lw $ra, 28($sp)
		addiu $sp, $sp, 32
		
		jr $ra

btn_down_pressed:

	subu $sp, $sp, 28
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $ra, 24($sp)

	la $s0, num_disp_1   # s0 <- &num_disp_1
	lw $s1, 0($s0)       # s1 <- num_disp_1
	
	beq $s1, $zero, down_dec # if(num_disp_1 == 0) goto down_dec
	
	subu $s1,$s1,1       # s1 <- s1--
	sw $s1, 0($s0)       # num_disp_1 <= s1
	j end_down
	
	down_dec:
	
		li $s1, 0xf
		sw $s1, 0($s0)               # num_disp_1 <- 15
		
		la $s0, num_disp_2           # s0 <- &num_disp_2
		lw $s1, 0($s0)               # s1 <- num_disp_2
		
		beq $s1, $zero, min_reached  # if(num_disp_2 == 0) goto min_reached
		
		subu $s1,$s1,1               # s1 <- s1--
		sw $s1, 0($s0)               # num_disp_2 <= s1
		j end_down
		
	min_reached:
	
		li $s1, 0xf
		sw $s1, 0($s0)               # num_disp_2 <- 15

	end_down:
	
		jal code_bcd
		lw $s0, 16($sp)
		lw $s1, 20($sp)
		lw $ra, 24($sp)
		addiu $sp, $sp, 28
		
		jr $ra

code_bcd:

	subu $sp, $sp, 40
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	sw $ra, 36($sp)

	li $s0, 2            # s0 controls the loop. If s0 = 2, make the bcd for num_1
			     #                       if s0 = 1, make the bcd for num_2
	coding:

	li $s1, 1
	beq $s0, $s1, num_2_code
	
	num_1_code:
	
	la $s1, num_disp_1   # s1 <- &num_disp_1
	lw $s2, 0($s1)       # t2 <- num_disp_1
	la $s3, bcd_1
	j code_0

	num_2_code:

	la $s1, num_disp_2   # s1 <- &num_disp_2
	lw $s2, 0($s1)       # s2 <- num_disp_2
	la $s3, bcd_2
	
	# bcd selection area:
	
	code_0:
		bne $s2, $zero, code_1
		li $s4, 63
		sw $s4, 0($s3) # bcd <- 0111111
		j iterate
	code_1:
		li $s1, 1
		bne $s2, $s1, code_2
		li $s4, 6    
		sw $s4, 0($s3) # bcd <- 0000110
		j iterate
	code_2:
		li $s1, 2
		bne $s2, $s1, code_3
		li $s4, 91   
		sw $s4, 0($s3) # bcd <- 1011011
		j iterate
	code_3:
		li $s1, 3
		bne $s2, $s1, code_4
		li $s4, 79   
		sw $s4, 0($s3) # bcd <- 1001111
		j iterate
	code_4:
		li $s1, 4
		bne $s2, $s1, code_5
		li $s4, 102  
		sw $s4, 0($s3) # bcd <- 1100110
		j iterate
	code_5:
		li $s1, 5
		bne $s2, $s1, code_6
		li $s4, 109  
		sw $s4, 0($s3) # bcd <- 1101101
		j iterate
	code_6:
		li $s1, 6
		bne $s2, $s1, code_7
		li $s4, 125  
		sw $s4, 0($s3) # bcd <- 1111101
		j iterate
	code_7:
		li $s1, 7
		bne $s2, $s1, code_8
		li $s4, 7    
		sw $s4, 0($s3) # bcd <- 0000111
		j iterate
	code_8:
		li $s1, 8
		bne $s2, $s1, code_9
		li $s4, 127  
		sw $s4, 0($s3) # bcd <- 1111111
		j iterate
	code_9:
		li $s1, 9
		bne $s2, $s1, code_10
		li $s4, 111  
		sw $s4, 0($s3) # bcd <- 1101111
		j iterate
	code_10:
		li $s1, 10
		bne $s2, $s1, code_11
		li $s4, 119  
		sw $s4, 0($s3) # bcd <- 1110111
		j iterate
	code_11:
		li $s1, 11
		bne $s2, $s1, code_12
		li $s4, 94   
		sw $s4, 0($s3) # bcd <- 1011110
		j iterate
	code_12:
		li $s1, 12
		bne $s2, $s1, code_13
		li $s4, 57   
		sw $s4, 0($s3) # bcd <- 0111001
		j iterate
	code_13:
		li $s1, 13
		bne $s2, $s1, code_14
		li $s4, 124  
		sw $s4, 0($s3) # bcd <- 1111100
		j iterate
	code_14:
		li $s1, 14
		bne $s2, $s1, code_15
		li $s4, 121  
		sw $s4, 0($s3) # bcd <- 1111001
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
	
end:
	j end

.data

	num_disp_1:     .word 0
	num_disp_2:     .word 0
	bcd_1:          .word 0
	bcd_2:		.word 0
	enable:         .word 1
