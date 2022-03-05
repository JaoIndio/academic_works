

.text
startApp:

addiu $t0, $zero, 0

    #addiu $t0, $t0, 1
    #addiu $t1, $zero, 0x000001a0
    #beq $t0, $t1, call_read
    #j loop

#call_read:
#    addiu $t0, $zero, 1

loop:
    addiu $v0, $zero, 3
    la $a0, rx_buffer
    addiu $a1, $zero, 20
    syscall

    bnez $v0, DoConvertion  
    j loop

    DoConvertion:
      addiu $a0, $v0, 0                       # a0 = read return value
      jal StringToInt
    j loop

    #lw $t1, BidiPort_PortData_Addr          # t1 <= ConfigMode
    #andi $t1, $t1, 0x00000003
    #addiu $t1, $t1, -1
    #blez $t1, loop
    #la $t1, INST_MEM_DYNAMIC_START_ADDRESS
	#jr $t1

StringToInt:
  addiu   $sp, $sp, -52           # Allocate stack space for registers storing
  sw      $t0, 0($sp)             # Save used registers
  sw      $t1, 4($sp)             #
  sw      $t2, 8($sp)             #
  sw      $t3, 12($sp)            #
  sw      $t4, 16($sp)            #
  sw      $t5, 20($sp)            #
  sw      $t6, 24($sp)            #
  sw      $t7, 28($sp)            #
  sw      $t8, 32($sp)            #
  sw      $t9, 36($sp)            #
  sw      $s0, 40($sp)            #
  sw      $s1, 44($sp)            #
  sw      $ra, 48($sp)            #

  # Convertion Flow:

  # 1. Number = 0
  # 2. Load rx_buffer
  # 3. Isolate a specific postition from rx_buffer
  # 4. Do the Isolated Number Convertion (INC)
  # 5. This new number will be multiplicate by correct ten power
  # 6. Number and ISC will be added
  # 7. If all convertion wasn't finished come back to third step

  # 1.
  la $t0, num
  sw $zero, 0($t0)

  # 2. s0 and s1 are used to manage the rx_buffer index
  la $t0, rx_buffer
  lw $t0, 0($t0)                  # t0 = rx_buffer[0]
  addiu $s0, $zero, 0
  addiu $s1, $zero, 4

  # t2 is used to do the isolatment step
  # t5 is used to find the maximum ten power 
  addiu $t2, $zero,0xff
  addiu $t5, $a0, -1

  addiu $t6, $zero, 1             # t6 = maximum ten power
  addiu $t7, $zero, 10

repet:
  beqz $t5, keepGoing 
    
    multu $t6, $t7
    mflo $t6
    addiu $t5, $t5, -1
  
  j repet

keepGoing:
  
  #t9 and t3 are used to manage the isolatment step
  addiu $t9, $zero, 0
  addiu $t3, $zero, 0

String_LOOP:
  # 7.
  beqz $a0,end_StringToInt
    
    bne $s0, $s1, keep_position 
      
      # rx_buffer position need to be added 
      # registers which are used at isolatement step need be reseted
      la $t0, rx_buffer
      addu $t0, $t0, $s0          # t0 = rx_buffer + s0
      lw $t0, 0($t0)
      addiu $t2, $zero,0xff
      addiu $t3, $zero, 0
      addiu $s1, $s1, 4

keep_position:
    la $t1, num
    lw $t1, 0($t1)                # t1 = num

    and $t4, $t0, $t2             # t4 = INC

    addiu $t9, $t3, 0

    # shift_number label guarentees that INC will be at first byte position 
shift_number:
    beqz $t9, convertion
      srl $t4, $t4, 8
      addiu $t9, $t9, -1
      
    j shift_number
    
convertion:
    # conversao
    #//======// =======// =========// =======

    #//======// =======// =========// =======

    # Step 5
    multu $t6, $t4
    mflo $t4                      

    divu $t6, $t7
    mflo $t6              # t6 = new power ten

    la $t5, num
    lw $t5, 0($t5)

    # Step 6
    addu $t5, $t4, $t5

    la $t8, num
    sw $t5, 0($t8) 

    sll $t2, $t2, 8
    addiu $a0, $a0, -1
    addiu $t3, $t3, 1
    addiu $s0, $s0, 1
    j String_LOOP



end_StringToInt:

  lw      $t0, 0($sp)             # Restore used registers
  lw      $t1, 4($sp)             # 
  lw      $t2, 8($sp)             # 
  lw      $t3, 12($sp)            # 
  lw      $t4, 16($sp)            # 
  lw      $t5, 20($sp)            # 
  lw      $t6, 24($sp)            # 
  lw      $t7, 28($sp)            # 
  lw      $t8, 32($sp)            # 
  lw      $t9, 36($sp)            # 
  lw      $s0, 40($sp)            # 
  lw      $s1, 44($sp)            # 
  lw      $ra, 48($sp)            # 
  addiu   $sp, $sp, 52            # Release stack space
  jr $ra 


.data 

rx_buffer: .word  1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
num: .word 0
