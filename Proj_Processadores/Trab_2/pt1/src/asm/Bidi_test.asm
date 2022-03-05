

.text

	addiu $t2, $zero, 0x80000000  # t2 <= PortEnable address
	addiu $t3, $zero, 0x80000001  # t3 <= PortConfig address
	addiu $t4, $zero, 0x80000002  # t4 <= PortData address
	la $t5, data_address  # t5 <= &data_address
	
	
	addiu $t1, $zero, 0x0000ffff  # All wires are enable
	sw $t1, 0($t2)
	
	# sei que eh redunte as atribuicoes de t1, mas eh pra ficar clara a visualisacao da configuracao de PortEnable e PortConfig
	addiu $t1, $zero, 0x0000ffff  # All wires are in
	sw $t1, 0($t3)
	
	sw $zero, 0($t4)  # write External_World value in PortData register
	
	lw $t1,0($t4)  # t1 <= External_World value
	addiu $t1,$t1,1
	sw $t1,0($t5)  # *t5 = t1
end:
	j end

.data

	data_address: 	.word 4