# Programa: DecryptMessage
# Descri��o: Decripta bytes provindos do componente CryptoMessage.vhd

.text

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

la $a0, array # $s0 <- &array
lw $a1, 4($a0)
lw $a0, 0($a0)
sll $a0, $a0, 8
or $a0, $a0, $a1

exp_mod_for: # args: expects two chars to be in $a0 
	
	# LOAD DATA	
	la $s1, privateKey
	lw $s1, 0($s1) # $s1 <- privateKey

	la $s2, N
	lw $s2, 0($s2) # $s2 <- N
	
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
	    and $s7, $s1, $s6        # ta certo?? i é s5 e nao s1. s7 <- 10000 & private_key
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

.data 
    array:      .word 0xDF 0x45 0x16 0x7B 0x6F 0xE4
    privateKey: .word 14913
    N:          .word 65473 
