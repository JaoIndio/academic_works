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

# Save CONTEXT OF PROCESSOR
.macro save_context()
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

.end_macro
# SAVE CONTEXT OF REGISTER
.macro save_register(%register_to_save, %byte_distance)

	addiu $k0, %register_to_save, 0
	sw $k0, %byte_distance($k1)

.end_macro

# RECOVER CONTEXT TO PROCESSOR
.macro return_context()
  return_register(AT, 0)
  
  # if a syscall excpetion was called, v0 will keep value
    addiu $t0, $zero, 8     # t5 = cause
    mfc0 $t5, $13           # t5 = cause
    beq $t5, $t0, dont_recoverV0
  
    return_register(V0, 4)

dont_recoverV0:
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
.end_macro


# RECOVER CONTEXT TO REGISTER
.macro return_register(%register_to_save, %byte_distance)

	lw $k0, %byte_distance($k1)
	addiu %register_to_save, $k0, 0

.end_macro

# JUMP TO HANDLER OF DETECTED EXCEPTION
.macro jump_to_Exception_Handler()
  addiu $t0, $zero, 1
  beq $t5, $t0, CAUSE_1     # Invalid Instruction
  addiu $t0, $zero, 8
  beq $t5, $t0, CAUSE_8     # SYSCALL
  addiu $t0, $zero, 12
  beq $t5, $t0, CAUSE_12    # OverFlow
  j CAUSE_15                # Division By Zero

  CAUSE_1:
  addiu $t0, $zero, 0
  j go_to_exception_handler

  CAUSE_8:
  addiu $t0, $zero, 4
  j go_to_exception_handler
  
  CAUSE_12:
  addiu $t0, $zero, 8
  j go_to_exception_handler
  
  CAUSE_15:
  addiu $t0, $zero, 12

  go_to_exception_handler:
  la $t1, esr_handlers
  addu $t1, $t1, $t0
  lw $t1, 0($t1)        # t1 = exception handler address
  jr $t1

.end_macro

# SEND MASSAGE TO TX
.macro send_TX_massage(%exception_number)
  # acho que da pra mudar
    addiu $a0, $zero, %exception_number
    jal IntToString 

    addu $t0, $zero, $v0
    addu $a0, $zero, $v0
    addiu $a1, $a1, -1
    jal reverse

    addiu $a0, $t0, 0
    jal printString

    # send to TX the instruction address which cause the exception
    mfc0 $t6, $14                 # t6 <= $14
    addiu $a0, $t6, 0 
    jal IntToHexString
    
    addu $t0, $zero, $v0
    addu $a0, $zero, $v0
    addiu $a1, $a1, -1
    jal reverse

    # Exemple

    #  MEM
    #1210
    #\040

    # After reverse()
    #0121
    #\004

    # how RX need to receive
    #2104
    #\001
    
    la $t1, stringHex
    lw $t2, 0($t1)      # t2 = 0121
    lw $t3, 4($t1)      # t3 = \004

    andi $t4, $t2, 0x0000ff00 # t4 = _ _ 2 _
    andi $t5, $t2, 0x000000ff # t5 = _ _ _ 1 
    
    andi $t6, $t3, 0x000000ff # t6 = _ _ _ 4
    andi $t7, $t3, 0x0000ff00 # t7 = _ _ 0 _

    sll $t5, $t5, 16          # t5 = _ 1 _ _
    sll $t4, $t4, 16          # t4 = 2 _ _ _

    or $t6, $t6, $t7 
    or $t6, $t6, $t5 
    or $t6, $t6, $t4

    #t6 = 2104 

    lw $t2, 0($t1)      # t2 = 0121
    lw $t3, 4($t1)      # t3 = \004
    #\001

    andi $t4, $t2, 0x00ff0000 # t4 = _ 1 _ _
    andi $t5, $t2, 0xff000000 # t5 = 0 _ _ _

    srl $t4, $t4, 16          # t4 = _ _ _ 1 
    srl $t5, $t5, 16          # t5 = _ _ 0 _

    andi $t3, $t3, 0x00000000 
    or $t3, $t4, $t3
    or $t3, $t5, $t3
    # t3 = \001

    sw $t6, 0($t1) 
    sw $t3, 4($t1)

    addiu $a0, $t0, 0
    jal printString

.end_macro

# READ IRQ NUMBER FROM PROCESSOR INTERRUPT CONTROLLER
.macro read_PIC()

	lw $t0, PIC_Data_Addr    # t0 <- PICData
	addu $s0, $zero, $t0     # salva numero da interrupt

.end_macro


# JUMP TO HANDLER OF DETECTED INTERRUPTION
.macro jump_to_handler()

    la $t1, irq_handlers # load irq_handlers addr
    addu $t1, $t1, $s0   # add current interruption number
    lw $t1, 0($t1)       # load current interruption handler addr 
	jr $t1                 # jump to handler

.end_macro


# WRITE A NEW VALUE ON THE BIDIRECTIONAL PORT WITHOUT OVERWRITING AN OLD ONE
.macro write_bidirectionalPort(%value)

	or $t0, $t9, %value
	sw $t0, BidiPort_PortData_Addr

.end_macro


# LOAD A BYTE FROM THE BIDIRECTIONAL PORT
.macro load_byte(%register_to_save)

	lw $t0, BidiPort_PortData_Addr     # t0 <- PortData
	andi $t0, $t0, 0x000000ff          # Consider only the first byte
	addiu %register_to_save, $t0, 0x0

.end_macro


# LOAD DATA_AV FROM THE CURRENT SELECTED CRYPTOMESSAGE
.macro load_data_av(%register_to_save)

	lw $t0, BidiPort_PortData_Addr  # t0 <- PortData
	andi $t0, $t0, 0x00006f00       # consider only positions of sel_cripto and data_av
	srl $t1, $t0, 13                # t1 <- sel_crypto (irq num)
	srl $t0, $t0, 8
	andi $t0, $t0, 0x0000000f       # t0 <- data_av

	get_irq_bit:
	    blez $t1, return_irq_bit
        srl $t0, $t0, 1
        addiu $t1, $t1, -1
        j get_irq_bit            

    return_irq_bit:
        andi $t0, $t0, 1
	      addiu %register_to_save, $t0, 0x0

.end_macro


# LOAD EOM INDICATOR FROM THE BIDIRECTIONAL PORT
.macro load_eom(%register_to_save)

	lw $t0, BidiPort_PortData_Addr    # t0 <- PortData
	andi $t0, $t0, 0x00001000         # t0 <- eom
	addiu %register_to_save, $t0, 0x0

.end_macro


# SEND AND ACK TO THE CURRENT CRYPTOMESSAGE
.macro set_ack(%set_ack) 

	addiu $t0, $zero, %set_ack
	sll $t0, $t0, 15
	write_bidirectionalPort(T0)

.end_macro

.macro save()
  or $s3, $s3, $s6
  or $s3, $s3, $s7
  sw $s3, 0($a3)
.end_macro

.macro select_position()
  lw $s7, 0($a3)
  lw $s6, 0($a3)

  and $s7, $s7, $s1           # s7 = s[i]
  and $s6, $s6, $s2           # s6 = s[j]

  lw $s3, 0($a3)              # s3 = string
  xori $s5, $s2, 0xffffffff   # s5 = not l
  and $s3, $s5, $s3           # s3 = string and (not l)
  xori $s5, $s1, 0xffffffff   # s5 = not k
  and $s3, $s5, $s3           # s3 = string and (not l) and (not k)   

  sll $s1, $s1, 8
  srl $s2, $s2, 8
.end_macro

.macro desloc_rigth(%reg_to_desloc, %reg_ref, %reg_fix)
set_r:
  subu %reg_ref, %reg_ref, %reg_fix   # s3 = s3 -1
  srl %reg_to_desloc, %reg_to_desloc, 8       # s2 = 0xff << ( 8*(len -1) )
  bgtz %reg_ref, set_r

.end_macro

.macro desloc_left(%reg_to_desloc, %reg_ref, %reg_fix)
set_l:
  subu %reg_ref, %reg_ref, %reg_fix   # s3 = s3 -1
  sll %reg_to_desloc, %reg_to_desloc, 8       # s2 = 0xff << ( 8*(len -1) )
  bgtz %reg_ref, set_l
  
.end_macro

# SAVE DECRYPTED MESSAGE ON MEMORY
#.macro save_msg(%index_position, %decrypted_byte)

    ## this code allows to save up to 4 chars at each memory position
	#la $t0, msg                                 # &msg[0]
	#addu $t0, $t0, %index_position              # &msg[i]
	
	#beq $s6, $s7, save_byte_1_0                # if(index_aux == 2) jump
	#lw $t1, 0($t0)                             # t1 = msg[i]
	#sll $t1, $t1, 16                           # t1 = t1 << 16 
	#or $t1, $t1, %decrypted_byte               # t1 = t1 OR decrypted_byte
	#sw $t1, 0($t0)
	#j end_save_2

    #save_byte_1_0:
	    #addiu $t1, %decrypted_byte, 0
	    #sw $t1, 0($t0)                  # msg[i] = | byte_out_1 | | byte_out_2 |
	    #j end_save_1

    #end_save_2:
	    #addiu $s6, $zero, 0            # index_aux = 0
	    #addiu $s3, $s3, 4              # index++

    #end_save_1:
			
#.end_macro


.text	

  ExceptionServiceRoutine:
  
  save_context()
  mfc0 $t5, $13                 # t5 = CAUSE value
  
  jump_to_Exception_Handler()
  ESR_end:

  return_context()
  eret

    InvalidInstructionHandler:
    
    subu $sp, $sp, 28
    sw $a0, 16($sp)
    sw $v0, 20($sp)
    sw $ra, 24($sp)

    send_TX_massage(1) 

    lw $a0, 16($sp)
    lw $v0, 20($sp)
    lw $ra, 24($sp)
    addiu $sp, $sp, 28

    j ESR_end

    SYSCALLHandler:
    subu $sp, $sp, 28
    sw $s0, 16($sp)
    sw $s1, 20($sp)
    sw $ra, 24($sp)

    la $s1, syscall_array

    addiu $s0, $zero, 0
    beq $v0, $s0, SYSCALL_0

    addiu $s0, $zero, 1
    beq $v0, $s0, SYSCALL_1
    j SYSCALL_2

      SYSCALL_0:
      jal printString
      j end_syscall

      SYSCALL_1:
      jal IntToString
      j end_syscall

      SYSCALL_2:
      jal IntToHexString
      

      end_syscall:
      lw $s0, 16($sp)
      lw $s1, 20($sp)
      lw $ra, 24($sp)
      addiu $sp, $sp, 28

      j ESR_end

    OverFlowHandler:
    subu $sp, $sp, 28
    sw $a0, 16($sp)
    sw $v0, 20($sp)
    sw $ra, 24($sp)

    send_TX_massage(12)        # RX will receive the number 12
    
    lw $a0, 16($sp)
    lw $v0, 20($sp)
    lw $ra, 24($sp)
    addiu $sp, $sp, 28

    j ESR_end

    DivisionByZeroHandler:
    subu $sp, $sp, 28
    sw $a0, 16($sp)
    sw $v0, 20($sp)
    sw $ra, 24($sp)

    send_TX_massage(15)       # RX will receive the number 15

    lw $a0, 16($sp)
    lw $v0, 20($sp)
    lw $ra, 24($sp)
    addiu $sp, $sp, 28

    j ESR_end
    

	InterruptServiceRoutine:
	save_context()
	
	# Set sp to kernel stack
	addiu $sp, $zero, KSS

	# Find irq number
	# irq number saved on $s0
	read_PIC()

	sll $s1, $s0, 13            # irq number on position to write on sel_crypto

	addu $t9, $s1, $zero        # t9 is used to hold a value that must remain unchanged when writing on the BidirectionalPort 

	write_bidirectionalPort(S1) # write irq number on sel_crypto 
	
	# Jump to handler of Interrrupt
	jump_to_handler()
	
	j ISR_end
	
crypto_message_intr:
	jal decryption
	j ISR_end
	 
ISR_end:
    sw $s0, PIC_Ack_Addr  # Interrupt Control ACK
	j return_to_user
	
	
# execute decryption Handler
decryption:                  

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
	addiu $s5, $zero, 0                   # bytes read
	addiu $s6, $zero, 0                   # index_aux
	addiu $s7, $zero, 2                   # ref_number
	
	set_ack(0)
	li $s3, 0   # s3 = index of msg array. msg[0]

	# reads byte from CryptoMessage 
	read_byte:

		load_byte(S0)                      # s0 <- byte from CryptoMessage
		beq $s5, $zero, byte_0             # if it is the first byte, follow the protocol
		j ExpMOD                           # if it is the second byte, decrypt it first

	# waits for data_av = 0
	data_av_polling_0:

		load_data_av(S1)                   # pooling of data_av
		bne $s1, $zero, data_av_polling_0  
		set_ack(0)                         # signal byte received                
		j data_av_polling_1                # pooling for next bytes 

	# waits for data_av = 1	
	data_av_polling_1:

		load_data_av(S1)
		beq $s1, $zero, data_av_polling_1
		j read_byte

	ExpMOD:

		addiu $s5, $zero, 0                # resets $s5 for next round of decryption
		or $a0, $a0, $s0                   # a0 <- | byte_1 |  | byte_2 |

		jal ExpMod32                       # v0 <- plain_Block

    	# save message on memory
    	#addiu $s6, $s6, 2
		#save_msg(S3, V0)

    	# small code to invert charachters and print in right order
		srl $t0, $v0, 8
		andi $t1, $v0, 0x000000ff
		sll $t1, $t1, 8
		or $v0, $t0, $t1

        # prepare and call printString
		la $a0, printMsg
		sw $v0, 0($a0)
		jal printString

		j set_ack
	
	# since two two bytes are decryped together everytime
	# prepare to receive second byte
	byte_0:
		addiu $s5, $s5, 1
		sll $s0, $s0, 8
		addiu $a0, $s0, 0         #a0 <- byte_1

    # sets ack to 1 and checks end of message
	set_ack:
		set_ack(1)
		load_eom(S2)
		bgtz $s2, end_decryption # if eom = 1 jump to end decryption
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
	
# recover context
return_to_user:
  return_context()

	eret                     


	
####################	
#                  #
# FUNCTIONS REGION #
#                  #
####################



# ExpMod32: used to decrypt two bytes with the RSA algorithm

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
	li $s6, 0x80000000                
	
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


# printString: receives the address of a string and sends its characters to UART_TX

printString: # args: $a0 <- initial address of string to send
    
    subu $sp, $sp, 32
    sw $s0, 16($sp)
    sw $s1, 20($sp)
    sw $s2, 24($sp)
    sw $ra, 28($sp)
    
    addiu $s0, $zero, 4         # byte count inside word
    lw $s1, 0($a0)              # load first word pointed by the address
    
    tx_loop:

        lw $s2, TX_Addr
        beq $s2, $zero, tx_loop     # wait for tx to be ready
            
    	andi $s2, $s1, 0x000000ff     # get the byte from the word
    	beq $s2, $zero, end_of_string # if byte is zero, this is the end of the string
    	    
    	sw $s2, TX_Addr               # if byte is not zero, send it to tx
    	    
    	srl $s1, $s1, 8               # prepare to send next byte
    	    
    	addiu $s0, $s0, -1            # subtract from byte count
    	    
    	bne $s0, $zero, tx_loop       # if byte count is not zero, go to the next loop
    	    
    	addiu $a0, $a0, 4             # prepare address for next word
    	addiu $s0, $s0, 4             # reset byte count
    	lw $s1, 0($a0)                # load next word
        j tx_loop                     # go to next loop
    
    end_of_string:
    
        lw $s0, 16($sp)
        lw $s1, 20($sp)
        lw $s2, 24($sp)
        addiu $sp, $sp, 28
        jr $ra


#save_number(){
#  if(i==0){
#    &string[0] = number
#    i++
#  }
#  if(i<4){
#    t9 = Todos os elementos da posiçao de mem
#    t9 << 8    
#    &string[i] = number OR t9
#    i++
#  }else{
#    &string += 4
#    i = 0 
#  }

.macro save_number(%reg_to_save, %finish_flag, %label_to_jump)

  addiu $t8, $zero, %finish_flag
i_equal_zero:

  bgtz $s0, i_not_zero
    sw %reg_to_save, 0($s1)
    addiu $s0, $s0, 1
    j SaveNumber_flag

i_not_zero:

  beq $s0, $s7, end_string_plus4
    lw $t9, 0($s1)
    sll $t9, $t9, 8
    or %reg_to_save, %reg_to_save, $t9   
    sw %reg_to_save, 0($s1)
    addiu $s0, $s0, 1
    j SaveNumber_flag

end_string_plus4:
  addiu $s1, $s1, 4
  addiu $s0, $zero, 0
  j i_equal_zero 

SaveNumber_flag:
  addiu $a1, $a1, 1
  beqz $t8, %label_to_jump
.end_macro

.text

#reverse()
# if(len > 4){
#   tamanho -=4
#   swap(4, &string)
#   &string +=4
# }else{
#   swap(len, &string)
#   jal $ra
# }
# swap(len)
#   i = 0
#   j = len
#   k = 0x000000ff
#   l = 0x000000ff << (8*(j-1))
#
#   for(; i < j; i++, j--){
#     s7 = string
#     s6 = string
#     s7 = s7 AND k     // s7 = s[i]
#     s6 = s7 AND l     // s7 = s[j]
#     
#     s3 = string
#     s3 = string AND (NOT k) AND (NOT l)
#     
#     s7 = s7 << (8*numero_adequado())
#     s6 = s6 >> (8*numero_adequado())
#     
#     s3 = string OR (S6) OR (S7)
#     k << 8 
#     j >> 8 
#   }
#
swap1:
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

  # s0 = i
  # a0 = len
  # a3 = &string
  # s1 = k
  # s2 = l
  # s3 = 8*len e string
  # s4 = 1 e c
  # s5 = (not l) e (not k) 
  # s6 = s[i]
  # s7 = s[j]

  addiu $s0, $zero, 0
  addiu $s1, $zero, 0xff
  addiu $s2, $zero, 0xff
  addiu $s3, $a0, 0 
  addiu $s4, $zero, 1 

  subu $s3, $s3, $s4    # s3 = len - 1
set_l:
  sll $s2, $s2, 8       # s2 = 0xff << ( 8*(len -1) )
  subu $s3, $s3, $s4    # s3 = s3 -1
  bgtz $s3, set_l

  la $s3, string

swap_select:
# numero_adequado(){
  addiu $s4, $zero, 4
  beq $a0, $s4, j_4

  addiu $s4, $zero, 3
  beq $a0, $s4, j_3
  
  addiu $s4, $zero, 2
  beq $a0, $s4, j_2
#}

j_4:
  select_position()
  
  addiu $s5, $zero, 3
  addiu $s4, $zero, 1
  # num_3 >> 8*3 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 3
  addiu $s4, $zero, 1
  #num_0 << 8*3
  desloc_left(S7, S5, S4)
  # save 1
  save()

  select_position()

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_2 >> 8 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_1 << 8
  desloc_left(S7, S5, S4)
  # save 2
  save()

  j end_for

j_3:
  select_position()

  addiu $s5, $zero, 2
  addiu $s4, $zero, 1
  # num_2 >> 8*2 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 2
  addiu $s4, $zero, 1
  # num_0 << 8*2
  desloc_left(S7, S5, S4)
  # save 2
  save()
  j end_for

j_2:
  select_position()

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_1 >> 8 
  desloc_rigth(S6, S5, S4)
  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_0 << 8
  desloc_left(S7, S5, S4)
  # save 2
  save()
  j end_for
 
end_for:

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

reverse:
  subu $sp, $sp, 32
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $ra, 28($sp)

  # a0 = &string
  # a1 = len
  # s0 = 4
  # s1 = a1 = len
  # s2 = a0 = &string
  
  addiu $s0, $zero, 4
  addiu $s1, $a1, 0
  addiu $s2, $a0, 0

reverse_if:

  blt $s1, $s0, reverse_else
    subu $s1, $s1, $s0
    addiu $a0, $zero, 4
    addiu $a3, $s2, 0
    jal swap1
    addiu $s2, $s2, 4
  j reverse_if

  reverse_else:
    addiu $a0, $s1, 0
    addiu $a3, $s2, 0
    jal swap1

end_reverse:

  #addiu $a0, $zero, 0  
  #addiu $a1, $zero, 0  
  #addiu $a2, $zero, 0  
  #addiu $a3, $zero, 0  

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $ra, 28($sp)
  addiu $sp, $sp, 32
  
  jr $ra

IntToString:
  
  subu $sp, $sp, 52
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $s3, 28($sp)
  sw $s4, 32($sp)
  sw $s5, 36($sp)
  sw $s6, 40($sp)
  sw $ra, 48($sp)

  # a0 n
  # s0 i
  # s1 &string
  # s2 sign
  # s3 10
  # s4 n % 10
  # s5 -1
  # s6 
  # s7 4
  addiu $a1, $zero, 0
  la $s1, string
  addiu $s5, $zero, -1
  addiu $s0, $zero, 0
  addiu $s3, $zero, 10
  addiu $s7, $zero, 4
  sw $s0, 0($s1)
  
  bltz $a0, negative_sign
  addiu $s2, $zero, 0
  multu $s3, $s7           # test
  j generate_string

negative_sign:
  addiu $s3, $zero, 1
  multu $a0, $s5
  mflo $a0                  # a0 = -a0

generate_string:
#do
  divu $a0, $s3             # a0/s3 = number/10
  mfhi $s4                  # s4 = n % 10
  addiu $s4, $s4, 48        # s4 = s4 + '0'

  save_number(S4, 0, div_n)
  
div_n:

  divu $a0, $s3             # number/10
  mflo $a0                  # a0 = number/10
  bgtz $a0, generate_string  
# while(a0 > 10)
  
  bgtz $s2, save_neg
  j end_IntToString

save_neg:
  addiu $s2, $zero, 45      # s2 = '-'
  save_number(S2, 0, div_n)

end_IntToString:
  addiu $s4, $zero, 0
  save_number(S4, 1, div_n)         # string[i] = '\0'
  la $a0, string
  jal reverse

  la $v0, string

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $s3, 28($sp)
  lw $s4, 32($sp)
  lw $s5, 36($sp)
  lw $s6, 40($sp)
  #lw $a1, 48($sp)
  lw $ra, 48($sp)
  addiu $sp, $sp, 52
  
  jr $ra 



IntToHexString:
  subu $sp, $sp, 52
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $s3, 28($sp)
  sw $s4, 32($sp)
  sw $s5, 36($sp)
  sw $s6, 40($sp)
  #sw $a1, 48($sp)
  sw $ra, 48($sp)

  # a0 n
  # s0 i
  # s1 &string
  # s2 sign
  # s3 16
  # s4 n % 10
  # s5 -1
  # s6 10
  # s7 4
  # t0 aux salvar dps
  addiu $a1, $zero, 0
  la $s1, stringHex
  addiu $s5, $zero, -1
  addiu $s0, $zero, 0
  addiu $s3, $zero, 16
  addiu $s6, $zero, 10
  addiu $s7, $zero, 4
  sw $s0, 0($s1)
  
  bltz $a0, negative_sign_HEX
  addiu $s2, $zero, 0
  j generate_string_HEX

negative_sign_HEX:
  addiu $s2, $zero, 1
  multu $a0, $s5
  mflo $a0                  # a0 = -a0

generate_string_HEX:
#do
    divu $a0, $s3             # s0/s3 = number/16
    mfhi $s4                  # s4 = n % 16
  
    slti $s6, $s4, 10         # s6 = 1 if(s4 < 10)
    bgtz $s6, DecConvertion_HEX  
      addiu $s4, $s4, -10       # s4 = s4 - 10
      addiu $s4, $s4, 65        # s4 = s4 + 65
      j save_number_Hex

    DecConvertion_HEX:
      addiu $s4, $s4, 48        # s4 = s4 + 65

  save_number_Hex:

    save_number(S4, 0, div_n_HEX)
  
  div_n_HEX:

    divu $a0, $s3             # number/16
    mflo $a0                  # a0 = number/16
  bgtz $a0, generate_string_HEX  
# while(a0 > 0)
  
  bgtz $s2, save_neg_HEX
  j end_IntToHexString

save_neg_HEX:
  addiu $s2, $zero, 45      # s2 = '-'
  save_number(S2, 0, div_n_HEX)

end_IntToHexString:
  addiu $s4, $zero, 0
  save_number(S4, 1, div_n_HEX)         # string[i] = '\0'
  la $a0, stringHex 
  jal reverse

  la $v0, stringHex

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $s3, 28($sp)
  lw $s4, 32($sp)
  lw $s5, 36($sp)
  lw $s6, 40($sp)
  #lw $a1, 48($sp)
  lw $ra, 48($sp)
  addiu $sp, $sp, 52
  
  jr $ra 


#==========================================
.data
	PCB:                   .space 116
	irq_handlers:          .word  0 0 0 0
  esr_handlers:          .word  0 0 0 0
	syscall_array:         .word  0 0 0
  msg:                   .word  0
	printMsg:              .space 80
  string:                .space 4
  stringHex:             .word  0 0
