
.eqv KSS 0x100101b8 # Kernel Stack Start

.text

# Set up sp
#addiu $sp, $zero, KSS

#la $a0, array

#jal printString
#j counter

printString:
    
    subu $sp, $sp, 28
    sw $s0, 16($sp)
    sw $s1, 20($sp)
    sw $s2, 24($sp)
    
    addiu $s0, $zero, 4         # byte count inside word
    lw $s1, 0($a0)              # load first word pointed by the address
    
    tx_loop:

        lw $s2, 0x80000020
        beq $s2, $zero, tx_loop     # wait for tx to be ready
            
    	andi $s2, $s1, 0x000000ff     # get the byte from the word
    	beq $s2, $zero, end_of_string # if byte is zero, this is the end of the string
    	    
    	sw $s2, 0x80000020            # if byte is not zero, send it to tx
    	    
    	srl $s1, $s1, 8               # prepare to send next byte
    	    
    	addiu $s0, $s0, -1            # subtract from byte count
    	    
    	bne $s0, $zero, tx_loop       # if byte count is not zero, go to the next loop
    	    
    	addiu $a0, $a0, 4             # prepare address for next word
    	addiu $s0, $s0, 4             # reset byte count
    	lw $s1, 0($a0)                # load next word
        j tx_loop                   # go to next loop
    
    end_of_string:
    
        lw $s0, 16($sp)
        lw $s1, 20($sp)
        lw $s2, 24($sp)
        addiu $sp, $sp, 28
        jr $ra


counter:
    addiu $t0, $t0, 1
    j counter
    
#.data

#array:      .word 0xf0d0c0b0 0xa0908070 0x00605040
