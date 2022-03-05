# Programa: BubbleSort
# Descri��o: Ordena��o crescente

.text
startApp:
BubbleSort:
    addiu   $t8, $zero, 1           # APP's CODE START .t8 = 1: swap performed   
    
while:
    beq     $t8, $zero, end         # Verifies if a swap has ocurred
    la      $t0, array              # t0 points the first array element
    la      $t6, size               # 
    lw      $t6, 0($t6)             # t6 <- size    
    addiu   $t8, $zero, 0           # swap <- 0
    
inner_loop:    
    beq     $t6, $zero, while       # Verifies if all elements were compared
    lw      $t1, 0($t0)             # t1 <- array[i]
    lw      $t2, 4($t0)             # t2 <- array[i + 1]
    slt     $t7, $t2, $t1           # array[i+1] < array[i] ?
    beq     $t7, $zero, continue    # if (array[i + 1] < array[i])
        addiu   $a0, $t0, 0         #     swap(&array[i], &array[i + 1])
        addiu   $a1, $t0, 4         #
        jal     swap                #
        addiu   $t8, $zero, 1       # Indicates a swap performed

continue:
    addiu   $t0, $t0, 4             # t0 points the next element
    addiu   $t6, $t6, -1            # size--
    j       inner_loop               

# Swaps array[i] and array[i + 1]
swap:
    addiu   $sp, $sp, -8	    # Allocate stack space for registers storing
    sw      $t0, 0($sp)             # Save used registers. ta salvando na pilha do kernel
    sw      $t1, 4($sp)             #
    
    lw      $t0, 0($a0)             # t0 <- array[i]
    lw      $t1, 0($a1)             # t1 <- array[i + 1]
    sw      $t1, 0($a0)             # array[i] <- t1
    sw      $t0, 0($a1)             # array[i + 1] <- t0
    
    lw      $t0, 0($sp)             # Restore used registers
    lw      $t1, 4($sp)             # 
    addiu   $sp, $sp, 8	            # Release stack space
    jr $ra                          # return 1
    
end: 
    #add $t9, $zero, $zero 
    j       end                    # APP's CODE END

.data 
    var3:       .word 30
    array:      .word 4 2 1 5 4 7 3
    size:       .word 7
