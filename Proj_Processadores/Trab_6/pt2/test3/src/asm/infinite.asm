

.text
startApp:

loop:
    jal firts_aplication
    jal show_ordenation
    #addiu $v0, $zero, 3
    #la $a0, rx_buffer
    #addiu $a1, $zero, 20
    #syscall

    #bnez $v0, DoConvertion  
    #j loop

    #DoConvertion:
      #addiu $a0, $v0, 0                       # a0 = read return value
      #jal StringToInt
      #jal Do_Invertion
      #syscall printString
      #jal show_ordenation
      #jal Delay

infinite_loop:
  # tamanho
wait_size:
  
    addiu $v0, $zero, 3
    la $a0, rx_buffer
    addiu $a1, $zero, 20
    syscall
  
  beqz $v0, wait_size
  
  addiu $a0, $v0, 0
  jal StringToInt

  la $t0, num
  lw $t0, 0($t0)                # t0 = array_size 

  la $t1, array_size
  sw $t0, 0($t1)

  la $t2, num
  # addiu $t0, $t0, -1
  la $t1, App_array

read_elements:
  beqz $t0, read_ordernation
    # elementos
    wait_element:

      addiu $v0, $zero, 3
      la $a0, rx_buffer
      addiu $a1, $zero, 20
      syscall
    
    addiu $a0, $v0, 0
    beqz $v0,wait_element
    
    jal StringToInt
    
    lw $t3, 0($t2)
    sw $t3, 0($t1)              # App_array[x] = num
    addiu $t1, $t1, 4
    addiu $t0, $t0, -1
  j read_elements 

read_ordernation:
  # ordenação
  wait_order:

    addiu $v0, $zero, 3
    la $a0, rx_buffer
    addiu $a1, $zero, 20
    syscall
    beqz $v0,wait_order
  
  addiu $a0, $v0, 0
  jal StringToInt

  la $t0, num
  lw $a0, 0($t0)                  # a0 = array_order

  # Do bubble
  # a0 == 0 => CrecentOrder
  # a0 == 1 => DecrecentOrder
  jal BubbleSort

  # syscall PrintString
  jal show_ordenation
  jal Delay

  j infinite_loop

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
    beqz $t9, ASCIIconvertion
      srl $t4, $t4, 8
      addiu $t9, $t9, -1
      
    j shift_number
    
ASCIIconvertion:
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


BubbleSort:
    addiu   $sp, $sp, -32
    sw      $t0, 0($sp)               # Save used registers
    sw      $t1, 4($sp)               
    sw      $t2, 8($sp)               
    sw      $t4, 12($sp)              
    sw      $t6, 16($sp)              
    sw      $t7, 20($sp)              
    sw      $t8, 24($sp)              
    sw      $ra, 28($sp)

    addiu   $t4, $a0, 0
    addiu   $t8, $zero, 1             # t8 = 1: swap performed
    
  while: 
    beq     $t8, $zero, endBubble     # Verifies if a swap has ocurred
      
      la      $t0, App_array          # t0 points the first array element
      la      $t6, array_size         # 
      lw      $t6, 0($t6)             # t6 <- size    
      addiu   $t6, $t6, -1
      addiu   $t8, $zero, 0           # swap <- 0
    
      inner_loop:    
      beq     $t6, $zero, while         # Verifies if all elements were compared
        lw      $t1, 0($t0)             # t1 <- array[i]
        lw      $t2, 4($t0)             # t2 <- array[i + 1]
        
        beqz $t4, crecentOrder          # if(t4 == 0) crecentOrder
                                        # else decrescentOrder

          slt $t7, $t1, $t2             # array[i+1] > array[i] ?
          beq $t7, $zero, continue      # if (array[i + 1] > array[i])
          j condition                   #   swap(&array[i], &array[i + 1])

        crecentOrder:
          slt     $t7, $t2, $t1         # array[i+1] < array[i] ?
          beq     $t7, $zero, continue  # if (array[i + 1] < array[i])
      
          condition:
          addiu   $a0, $t0, 0           #   swap(&array[i], &array[i + 1])
          addiu   $a1, $t0, 4           #
          jal     swap                  #
          addiu   $t8, $zero, 1         # Indicates a swap performed

      continue:
        addiu   $t0, $t0, 4             # t0 points the next element
        addiu   $t6, $t6, -1            # size--
        j       inner_loop               

endBubble:

    lw      $t0, 0($sp)               # Save used registers
    lw      $t1, 4($sp)               
    lw      $t2, 8($sp)               
    lw      $t4, 12($sp)              
    lw      $t6, 16($sp)              
    lw      $t7, 20($sp)              
    lw      $t8, 24($sp)              
    lw      $ra, 28($sp)

    addiu $sp, $sp, 32

    jr $ra

Delay:
  subu $sp, $sp, 28
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $ra, 24($sp)

  addiu $s0, $zero, 0xf8
  addiu $s1, $zero, 0
  
  DelayLoop:
    beq $s1, $s0, Delay_end
    addiu $s1, $s1, 1
    j DelayLoop

  Delay_end:

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $ra, 24($sp)
  addiu $sp, $sp, 28

  jr $ra

show_ordenation:
    
    addiu $sp, $sp, -12
    sw    $t0, 0($sp)
    sw    $t5, 4($sp)
    sw    $ra, 8($sp)

    jal convertion
    
    la $t0, array_size
    lw $t0, 0($t0)                  # t0 = size
    la $t5, Pstring

    endBubleLoop:
      beqz $t0, end_show_ordenation
        
        addiu $t0, $t0, -1
        addiu $a0, $t5, 0
        li $v0, 0
        syscall                    # jal printString
        addiu $t5, $t5, 4
      
      j endBubleLoop

    end_show_ordenation:
      
      lw    $t0, 0($sp)
      lw    $t5, 4($sp)
      lw    $ra, 8($sp)
      addiu $sp, $sp, -4

      jr $ra

convertion:

    subu $sp, $sp, 48

    sw $t0, 16($sp)
    sw $t1, 20($sp)
    sw $t2, 24($sp)
    sw $t3, 28($sp)
    sw $t5, 32($sp)
    sw $v0, 36($sp)
    sw $a0, 40($sp)
    sw $ra, 44($sp)


    addiu $t1, $zero, 1
    
    la $t5, Pstring
    la $t2, App_array
    la $t0, array_size
    lw $t0, 0($t0)                  # t0 = size
    
    convert_Lopp:
      beqz $t0, end_convertion
        subu $t0, $t0, $t1              # t0--
        li $v0, 1
        lw $a0, 0($t2)                  # a0 = array[i]
        syscall
        jal Delay
        #jal IntToString
    
        lw $t3, 0($v0)                  # t3 = int converted 
        sw $t3, 0($t5)                  # Pstring[i] = t3
        addiu $t2, $t2, 4               # &array++
        addiu $t5, $t5, 4               # &Pstring++
      j convert_Lopp

end_convertion:
    
    la $t0, array_size
    lw $t0, 0($t0)                  # t0 = size
    la $t5, Pstring

    lw $t0, 16($sp)
    lw $t1, 20($sp)
    lw $t2, 24($sp)
    lw $t3, 28($sp)
    lw $t5, 32($sp)
    lw $v0, 36($sp)
    lw $a0, 40($sp)
    lw $ra, 44($sp)

    addiu $sp, $sp, 48
    jr $ra

swap:
    
    addiu   $sp, $sp, -12           # Allocate stack space for registers storing
    sw      $t0, 0($sp)             # Save used registers
    sw      $t1, 4($sp)             #
    sw      $ra, 8($sp)             #
    
    lw      $t0, 0($a0)             # t0 <- array[i]
    lw      $t1, 0($a1)             # t1 <- array[i + 1]
    sw      $t1, 0($a0)             # array[i] <- t1
    sw      $t0, 0($a1)             # array[i + 1] <- t0
    
    lw      $t0, 0($sp)             # Restore used registers
    lw      $t1, 4($sp)             # 
    lw      $ra, 8($sp)             # 
    addiu   $sp, $sp, 12            # Release stack space
    jr $ra                          # return 1

firts_aplication:
  addiu   $sp, $sp, -4           # Allocate stack space for registers storing
  sw      $ra, 0($sp)
wait_size1:

    addiu $v0, $zero, 3
    la $a0, rx_buffer
    addiu $a1, $zero, 20
    syscall
  
  beqz $v0, wait_size1
  addiu $t0, $zero, 81

  sltu $t0, $v0, $t0
  beqz $t0, wait_size1
  
  addiu $a0, $v0, 0
  jal StringToInt

  la $t0, num
  lw $t0, 0($t0)                # t0 = array_size 

  la $t1, array_size
  sw $t0, 0($t1)

  la $t2, num
  # addiu $t0, $t0, -1
  la $t1, App_array

read_elements1:
  beqz $t0, end_first_aplication
    # elementos
    wait_element1:

      addiu $v0, $zero, 3
      la $a0, rx_buffer
      addiu $a1, $zero, 20
      syscall
    
    addiu $a0, $v0, 0
    beqz $v0,wait_element1
    
    jal StringToInt
    
    lw $t3, 0($t2)
    sw $t3, 0($t1)              # App_array[x] = num
    addiu $t1, $t1, 4
    addiu $t0, $t0, -1
  j read_elements1

end_first_aplication:
  # array invertion

  addiu $t0, $zero, 0
  la $t1, array_size
  lw $t1, 0($t1)
  addiu $t1, $t1, -1

  la $t2, App_array
  addiu $t3, $zero, 4 

  multu $t1, $t3            
  mflo $t1                  # t1 = j*4

Do_Invertion:
  beq $t1, $t0, end_invertion
      
    addu $t4, $t0, $t2       # t4 = &s[i]
    addu $t7, $t1, $t2       # t7 = &s[j]

    lw $t5, 0($t4)            # t5 = s[i] 
    lw $t6, 0($t7)            # t6 = s[j]

    sw $t6, 0($t4)            # s[i] = s[j]
    sw $t5, 0($t7)            # s[j] = t5

    addiu $t0, $t0, 4
    addiu $t1, $t1, -4

    j Do_Invertion


end_invertion:
  lw      $ra, 0($sp)             # 
  addiu   $sp, $sp, 4
  jr $ra

.data 

rx_buffer:  .word 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
num:        .word 0
array_size: .word 1
order_sort: .word 1
Pstring:    .word 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99 99
App_array:  .word 9
