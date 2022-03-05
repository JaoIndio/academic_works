.eqv ASS 0x10010230 # Application Stack Start

# BIDIRECTIONAL PORT REGISTER ADDRESSES
.eqv BidiPort_PortEnable_Addr 0x80000000
.eqv BidiPort_PortConfig_Addr 0x80000001
.eqv BidiPort_PortData_Addr   0x80000002
.eqv BidiPort_IrqEnable_Addr  0x80000003

# INTERRUP CONTROLLER REGISTER ADDRESSES
.eqv PIC_Mask_Addr 0x80000011
.eqv PIC_Ack_Addr  0x80000012
.eqv PIC_Data_Addr 0x80000013

# UART_TX ADDRESS
.eqv TX_Addr 0x80000020

.macro boot()
	
	addiu $t0, $zero, 0x0000ffff      # All wires are enabled
	sw $t0, BidiPort_PortEnable_Addr  # PortEnable <= t0
	
	addiu $t0, $zero, 0x00001fff      # | ack (1b, out) | | crypto_sel (2b, out) | | eom (1b, in) | | interrupts (4b, in) | | data (8b, in) |
	sw $t0, BidiPort_PortConfig_Addr  # PortConfig <= t0
	
	addiu $t0, $zero, 0x00000f00      # four interrupt bits
	sw $t0, BidiPort_IrqEnable_Addr   # IrqEnable <= t0

    # Save on ISR_ADDR register the kernel start address
	la $t0, InterruptServiceRoutine
	mtc0 $t0, $31 

    # Configure irq_handlers
    la $t0, irq_handlers
    la $t1, crypto_message_intr
    sw $t1, 0($t0)
    sw $t1, 4($t0)
    sw $t1, 8($t0)
    sw $t1, 12($t0)
    sw $t1, 16($t0)
    sw $t1, 20($t0)
    sw $t1, 24($t0)
    sw $t1, 28($t0)

    # Save on ESR_ADDR register the EST start address
  la $t0, ExceptionServiceRoutine
  mtc0 $t0, $30

    # Configure esr_handlers
    la $t0, esr_handlers
    la $t1, InvalidInstructionHandler
    sw $t1, 0($t0)
    
    la $t1, SYSCALLHandler
    sw $t1, 4($t0)
    
    la $t1, OverFlowHandler
    sw $t1, 8($t0)
    
    la $t1, DivisionByZeroHandler
    sw $t1, 12($t0)

  # Save SYSCALL functions addres
  la $t0, syscall_array
  
  la $t1, printString
  sw $t1, 0($t0)

  la $t1, IntToString
  sw $t1, 4($t0)

  la $t1, IntToHexString
  sw $t1, 8($t0)

	# Set up sp
	addiu $sp, $zero, ASS

    # Interrupts enabled only after the store
    addiu $t0, $zero, 0x0000000f  # four interrupt bits
    sw $t0, PIC_Mask_Addr         # mask <= t0

.end_macro


.text
	boot()
	j startApp   # JUMP TO MAIN APPLICATION
