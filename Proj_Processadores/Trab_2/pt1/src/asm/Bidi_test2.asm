

.text

	addiu $t2, $zero, 0x80000000  # t2 <= PortEnable address
	addiu $t3, $zero, 0x80000001  # t3 <= PortConfig address
	addiu $t4, $zero, 0x80000002  # t4 <= PortData address
	la $t5, data_address  # t5 <= &data_address
	
# Read External_World value at register t1
	addiu $t1, $zero, 0x0000ffff  # All wires are enable
	sw $t1, 0($t2)                #  PortEnable <= t1
	# sei que eh redunte as atribuicoes de t1, mas eh pra ficar clara a visualisacao da configuracao de PortEnable e PortConfig
	addiu $t1, $zero, 0x0000ffff  # All wires are in
	sw $t1, 0($t3)                # PortConfig <= t1
	sw $zero, 0($t4)              # PortData <= External_World value
	lw $t1, 0($t4)                # t1 <= External_World value
	
	addiu $t1,$t1,1
	sw $t1, 0($t5)  # *t5 = t1	
#  Read MEM(t5)
	lw $t6, 0($t5)  #  t6 <= MEM(t5)
	addiu $t6, $t6, 1  # t6 <= t6 + 1
	
#  Write P1_0 <= MEM(t5) +1
	addiu $t1, $zero, 0x0000ffff
	sw $t1, 0($t2)
	addiu $t1, $zero, 0x00000000
	sw $t1, 0($t3)
	sw $t6, 0($t4)        # PortData <= t6
	sw $zero, 0x80000010  # P1_0 <= PortData_value
	
#  Read P1_0
	addiu $t1, $zero, 0x0000ffff
	sw $t1, 0($t2)
	addiu $t1, $zero, 0x0000ffff
	sw $t1, 0($t3)
	lw $zero, 0x80000010  # Bidirectional_Port <= P_0
	sw $zero, 0($t4)      # PortData <= P_0
	lw $t1, 0($t4)        # t1 <= PortData
	
	addiu $t1, $t1, 1
	sw $t1, 4($t5)
	
#  Write P2_2 <= P1_0 + 1
	addiu $t1, $zero, 0x0000ffff
	sw $t1, 0($t2)
	addiu $t1, $zero, 0x00000000
	sw $t1, 0($t3)
	
	lw $t1, 4($t5)
	sw $t1, 0($t4)
	sw $zero, 0x80000022
	
end:
	j end

.data

	data_address: 	.word 4