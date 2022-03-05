

.text
	
	la $t1, address  # t1 <- &address[0] 
	lw $t2, 4($t1)   # t2 <- address[1]. t1 = 5Milhoes
	lw $t1, 0($t1)	 # t1 <- address[0]
	addiu $t3, $t1, 0   # t3 <- 0 
	addiu $t4, $t1, 15   # t4 <- 9
	
	# Objetivo
	# while(t3 < 9)o
	#   t3++
sum_number:
	beq $t3, $t4, end
	  #add $t2, $t1, $zero
	  sw $t3, ($t3)
	# vai para lopp de 1 segundo. considerando um clock de 100MHz
	  addiu $t5,$zero,0  # t5 <- 0
	  j loop_time
return:
	  addiu $t3, $t3, 1
	  sw $t3, ($t3)
	  j sum_number
loop_time:
          beq $t5,$t2, return
          #if (t5 == 5Milhoes)
          #  sai do loop
          #else
          #  continua no loop    
            addiu $t5,$t5,1
            j loop_time
end:
	j end
.data
	address:	.word 0x80000000 0x004c4b40 0x00000100
