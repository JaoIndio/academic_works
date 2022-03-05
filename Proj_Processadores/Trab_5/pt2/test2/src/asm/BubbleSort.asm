.text
startApp:

Print_Start_Array:
    jal convertion

    la $t0, size
    lw $t0, 0($t0)                  # t0 = size
    la $t5, Pstring

    show_next_number:
    
    beqz $t0, Print_Start_Array_end
      
      addiu $t0, $t0, -1
      addiu $a0, $t5, 0
      
      li $v0, 0
      syscall                       # jal printString

      jal Delay
      addiu $t5, $t5, 4
    
    j show_next_number

Print_Start_Array_end:
    
    addiu $a0, $zero, 0             # crecent order
    jal BubbleSort
    jal show_ordenation
    jal Delay
    
    j ForceException

BubbleSort:
    addiu   $sp, $sp, -4
    sw $ra, 0($sp)

    addiu   $t4, $a0, 0
    addiu   $t8, $zero, 1             # t8 = 1: swap performed
    
  while: 
    beq     $t8, $zero, endBubble     # Verifies if a swap has ocurred
      
      la      $t0, array              # t0 points the first array element
      la      $t6, size               # 
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

    lw $ra, 0($sp)
    addiu $sp, $sp, 4

    jr $ra

# Swaps array[i] and array[i + 1]
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
   
show_ordenation:
    
    addiu $sp, $sp, -4
    sw    $ra, 0($sp)

    jal convertion
    
    la $t0, size
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
      lw    $ra, 0($sp)
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
    la $t2, array
    la $t0, size
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
    
    la $t0, size
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

ForceException:
  
  addiu $a0, $zero, 1     
  jal BubbleSort           # decrescent order
  jal show_ordenation


  li $8, 0x7fffffff        # r8 <- greatest positive number (2's) 
  addiu $9, $8, 1          # Ignore overflow  
  addi $10, $8, 1          # Overflow!
  jal Delay

  li $8, 0x80000000        # r8 <- smallest negative number (2's)
  addiu $9, $8, -1         # Ignore overflow
  addi $10, $8, -1         # Overflow!
  jal Delay


  add.s $f0, $f1, $f2      # Invalid instruction
  jal Delay

  li $t0, 1
  li $8, 0x7fffffff
  add $t0, $t0, $8         # Overflow
  jal Delay

  li $t0, 1
  li $8, 0x80000000        # r8 <- smallest negative number (2's)
  sub $t0, $8, $t0         # Overflow
  jal Delay

  addiu $t0, $zero, 1
  divu $8, $0              # Division by 0
  jal Delay

endCode:
  j endCode 

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


.data 
    array:      .word 4 2 1 5 4 7 3
    size:       .word 7
    Pstring:    .word 6 6 6 1 6 6 6

