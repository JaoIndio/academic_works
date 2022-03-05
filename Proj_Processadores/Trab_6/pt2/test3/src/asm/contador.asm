
.eqv INST_MEM_DYNAMIC_START_ADDRESS 0x00401900

# Start address of data memory
.eqv DATA_MEM_START_ADDRESS 0x10010000

# Start address of programmable area of data memory
.eqv DATA_MEM_DYNAMIC_START_ADDRESS 0x100100ec

# OFFSET os addresses
.eqv OFFSET 0xec

# UART_TX ADDRESS
.eqv TX_Addr 0x80000020

# UART_RX ADDRESS
.eqv RX_Addr 0x80000030

.text

App1:	
	la $t0, var1
	addiu $t0, $t0, OFFSET
	lw $t1,0($t0)
	addiu $t1, $t1, 1
	sw $t1, 0($t0)
	la $t0, INST_MEM_DYNAMIC_START_ADDRESS
	jr $t0

	nop 

App2:
  lw $t2, RX_Addr
  sw $t2, TX_Addr

  # come back to ISR end
	jr $a0

.data
    var1:      .word 0xa0
    var2:      .word 0xffffffff
