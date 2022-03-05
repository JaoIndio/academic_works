
.eqv ASS 0x10010230 # Application Stack Start

.macro boot()
	addiu $t0, $zero, 0x80000000  # t0 <= PortEnable address BOOT's CODE START
	addiu $t1, $zero, 0x80000001  # t1 <= PortConfig address
	addiu $t2, $zero, 0x80000002  # t2 <= PortData   address
	addiu $t3, $zero, 0x80000003  # t3 <= IrqEnable  address

	addiu $t5, $zero, 0x80000011  # t5 <= InterrupControl mask address
	
	addiu $t4, $zero, 0x0000ffff  # All wires are enabled
	sw $t4, 0($t0)                # PortEnable <= t4
	
	addiu $t4, $zero, 0x00001fff  # | ack (1b, out) | | crypto_sel (2b, out) | | eom (1b, in) | | interrupts (4b, in) | | data (8b, in) |
	sw $t4, 0($t1)                # PortConfig <= t4
	
	addiu $t4, $zero, 0x00000f00  # four interrupt bits
	sw $t4, 0($t3)                # IrqEnable <= t4

	la $t4, InterruptServiceRoutine
	mtc0 $t4, $31 
	
 	 # save handlers add at irq_handlers array
	la $t4, irq_handlers
  	la $t6, decryption_0
  	sw $t6, 0($t4)
  	la $t6, decryption_1
  	sw $t6, 4($t4)
  	la $t6, decryption_2
  	sw $t6, 8($t4)
  	la $t6, decryption_3
  	sw $t6, 12($t4)

	# Set up sp
	addiu $sp, $zero, ASS
	
	addiu $t4, $zero, 0x0000000f  # four interrupt bits
	sw $t4, 0($t5)                # mask <= t4
	
.end_macro


.text
	boot()
	j startApp   # BOOT's CODE

#startApp:
#  j startApp

#InterruptServiceRoutine:
    # CONFERE EOM
#    lw $t4, 0($t2)
#    andi $t4, 0x00001000
#    bgtz $t4, return_routine

#    lw $t4, 0x80000013
#    andi $t4, $t4, 3  # LENDO INT NUM DO PIC E MANDANDO PRA PORTA BIDIRECIONAL
#    addiu $t7, $t4, 0 # SALVA O INT NUM PRA DEPOIS
#    sll $t8, $t4, 13  # SALVA O INT NUM NA POSICAO PRA N�O SOBRESCREVER DEPOIS
#    sll $t4, $t4, 13  # COLOCA O INT NUM NA POSICAO CERTA DE NOVO
#    sw $t4, 0($t2)    # ESCREVE NO sel_crypto O INT NUM
    
#    ori $t4, $t8, 0x00008000 
#    sw $t4, 0($t2) # ACK <- 1
    
    # CONFERE EOM
#    lw $t4, 0($t2)
#    andi $t4, 0x00001000
#    bgtz $t4, return_routine
    
#    ori $t4, $t8, 0x00000000   
#    sw $t4, 0($t2) # ACK <- 0

    # CONFERE EOM
#    lw $t4, 0($t2)
#    andi $t4, 0x00001000
#    bgtz $t4, return_routine

#    j InterruptServiceRoutine

#return_routine:

#    ori $t4, $t8, 0x00008000  
#    sw $t4, 0($t2) # ACK <- 1
#    ori $t4, $t8, 0x00000000  
#    sw $t4, 0($t2) # ACK <- 0
    
#    addiu $t4, $zero, 0x80000012
#    sw $t7, 0($t4) 

#    eret	

# nao sei se funciona assim
#decryption_0 decryption_1 decryption_2 decryption_3
