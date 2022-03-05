

.text
startApp:   # acho que aqui é o INST_MEM_DYNAMIC_START_ADDRESS

loop:	
    lw $t1, BidiPort_PortData_Addr          # t1 <= ConfigMode
    andi $t1, $t1, 0x00000003
    addiu $t1, $t1, -1
    blez $t1, loop
    la $t1, INST_MEM_DYNAMIC_START_ADDRESS
	jr $t1
