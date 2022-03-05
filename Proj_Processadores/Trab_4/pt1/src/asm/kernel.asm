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

.eqv PRIVATE_KEY 0x00003a41
.eqv N 0x0000ffc1

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

.macro load_byte(%register_to_save)
	lw $t0, 0x80000002 # t0 <- PortData
	andi $t0, $t0, 0x000000ff # t0 <- byte_out
	addiu %register_to_save, $t0, 0x0
.end_macro

.macro load_data_av(%register_to_save)
	lw $t0, 0x80000002 # t0 <- PortData
	andi $t0, $t0, 0x00000100 # t0 <- data_av
	addiu %register_to_save, $t0, 0x0
.end_macro

.macro load_eom(%register_to_save)
	lw $t0, 0x80000002 # t0 <- PortData
	andi $t0, $t0, 0x00000400 # t0 <- eom
	addiu %register_to_save, $t0, 0x0
.end_macro

.macro set_ack(%set_ack)
	addiu $t0, $zero, %set_ack
	sll $t0, $t0, 9
	sw $t0, 0x80000002        # ack <- t0
.end_macro

.macro check_peripheral(%Handler_position, %handler_Name)	
	andi $t1, $t0, %Handler_position
	bne $t1, $zero, %handler_Name
.end_macro

.macro save_msg(%index_position, %decrypted_byte)

# this code allow to save until 4 chars at each memory position
	la $t0, msg                                 # &msg[0]
	addu $t0, $t0, %index_position              # &msg[i]
	
	beq $s6, $s7, save_byte_1_0                # if(index_aux == 2) jump
	lw $t1, 0($t0)                             # t1 = msg[i]
	sll $t1, $t1, 16                           # t1 = t1 << 16 
	or $t1, $t1, %decrypted_byte               # t1 = t1 OR decrypted_byte
	sw $t1, 0($t0)
	j end_save_2

save_byte_1_0:
	addiu $t1, %decrypted_byte, 0
	sw $t1, 0($t0)                  # msg[i] = | byte_out_1 | | byte_out_2 |
	j end_save_1

end_save_2:
	addiu $s6, $zero, 0            # index_aux = 0
	addiu $s3, $s3, 4              # index++

end_save_1:
		
	
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
	
	check_peripheral(256, decryption_label) #first, data_av need to be check
	
	
	j ISR_end
	
	# decryption()
decryption_label:
	jal decryption
	j ISR_end
	 
ISR_end:
	j return_to_user
	
	
# execute decryption Handler
decryption:                  #decryption Handler

	subu $sp, $sp, 52
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	sw $s5, 36($sp)
	sw $s6, 40($sp)
	sw $s7, 44($sp)
	sw $ra, 48($sp)
	
	#Handler
	addiu $s4, $zero, 0x100
	addiu $s5, $zero, 0                   # bytes readed
	addiu $s6, $zero, 0                   # index_aux
	addiu $s7, $zero, 2                   # ref_number
	
	set_ack(0)
	li $s3, 0   # s3 = index of msg array. msg[0]
	# tem q setar o msg inteiro???

read_byte:

	load_byte(S0)                          # s0 <- byte_out
	j decrypt_a_block
	
data_av_polling_0:
	load_data_av(S1)                       # faz o polling de data_av
	bne $s1, $zero, data_av_polling_0  
	set_ack(0)
	j data_av_polling_1
	
data_av_polling_1:
	load_data_av(S1)                       # espera data_av = 1
	bne $s1, $s4, data_av_polling_1
	j read_byte
 
decrypt_a_block:
	beqz $s5, byte_0
	
	addiu $s5, $zero, 0
	or $a0, $a0, $s0                       #a0 <- | byte_out_1 |  | byte_out_2 |

ExpMOD:
	jal ExpMod32
	# v0 <- plain_Block 
	addiu $s6, $s6, 2
	save_msg(S3, V0)                       
	j set_ack
	
byte_0:
	addiu $s5, $s5, 1
	sll $s0, $s0, 8
	addiu $a0, $s0, 0                       #a0 <- byte_out_1

set_ack:
	set_ack(1)
	load_eom(S2)
	bgtz $s2, end_decryption             # if eom = 1 jump to end decryption
	j data_av_polling_0
	
end_decryption:
	set_ack(0)
	
	
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	lw $s5, 36($sp)
	lw $s6, 40($sp)
	lw $s7, 44($sp)
	lw $ra, 48($sp)
	addiu $sp, $sp, 52
		
	jr $ra
	

ExpMod32:

subu $sp, $sp, 52
sw $s0, 16($sp)
sw $s1, 20($sp)
sw $s2, 24($sp)
sw $s3, 28($sp)
sw $s4, 32($sp)
sw $s5, 36($sp)
sw $s6, 40($sp)
sw $s7, 44($sp)
sw $ra, 48($sp)


exp_mod_for: # args: expects two chars to be in $a0 
	
	# LOAD DATA	
	addiu $s1, $zero, PRIVATE_KEY

	addiu $s2, $zero, N
	
	# PREPARE ITERATORS AND VARIABLES
	li $s4, 1  # $s4 is f
	li $s5, 31 # $s5 is i
	li $s6, 0x80000000                # esse numero não é 31
	
	# MAIN LOOP
	decrypt_loop:
	
	    # while(i >= 0)
	    bltz $s5, end__decrypt_loop 
	    
	    # f = f*f mod n
	    multu $s4, $s4
	    mflo $s4
	    divu $s4, $s2
	    mfhi $s4
	    
	    # if b[i] = 1
	    and $s7, $s1, $s6
	    bgtz $s7, condition_true
	    
	    iterate_decrypt_loop:
	    
	    	# $s6 >> 1
	    	# i = i - 1
	    	srl $s6, $s6, 1
	    	addiu $s5, $s5, -1
	    	j decrypt_loop
	    	
	    condition_true:
	    	
	    	# f = f*a mod n
	    	multu $s4, $a0
	    	mflo $s4
	    	divu $s4, $s2
	    	mfhi $s4
	    	j iterate_decrypt_loop
	
	
	end__decrypt_loop:
				
	addu $v0, $zero, $s4  # v0 = f; return f
	
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	lw $s5, 36($sp)
	lw $s6, 40($sp)
	lw $s7, 44($sp)
	lw $ra, 48($sp)
	addiu $sp, $sp, 52
	
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
	msg:                   .space 80
	
