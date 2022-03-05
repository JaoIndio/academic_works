
.eqv ASS 0x100100c0 # Application Stack Start

.macro boot()
	addiu $t0, $zero, 0x80000000  # t0 <= PortEnable address BOOT's CODE START
	addiu $t1, $zero, 0x80000001  # t1 <= PortConfig address
	addiu $t2, $zero, 0x80000002  # t2 <= PortData   address
	addiu $t3, $zero, 0x80000003  # t3 <= IrqEnable  address
	
	addiu $t4, $zero, 0x0000ffff  # All wires are enabled
	sw $t4, 0($t0)                # PortEnable <= t4
	
	addiu $t4, $zero, 0x00000001  # Only the interrupt bit is to be read
	sw $t4, 0($t1)                # PortConfig <= t4
	
	addiu $t4, $zero, 0x00000001  # Only the interrupt bit is to be read
	sw $t4, 0($t3)                # IrqEnable <= t4
	
	# Set up sp
	addiu $sp, $zero, ASS
.end_macro


.text
	boot()
	j startApp   # BOOT's CODE
