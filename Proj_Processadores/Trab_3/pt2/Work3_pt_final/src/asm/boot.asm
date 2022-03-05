
.eqv ASS 0x10010230 # Application Stack Start

.macro boot()
	addiu $t0, $zero, 0x80000000  # t0 <= PortEnable address BOOT's CODE START
	addiu $t1, $zero, 0x80000001  # t1 <= PortConfig address
	addiu $t2, $zero, 0x80000002  # t2 <= PortData   address
	addiu $t3, $zero, 0x80000003  # t3 <= IrqEnable  address
	
	addiu $t4, $zero, 0x0000ffff  # All wires are enabled
	sw $t4, 0($t0)                # PortEnable <= t4
	
	addiu $t4, $zero, 0x00000003  # At this app there is 2 entries and 11 outputs
	sw $t4, 0($t1)                # PortConfig <= t4
	
	addiu $t4, $zero, 0x00000003 # The two entries will be used to generate an interrupt
	sw $t4, 0($t3)                # IrqEnable <= t4
	
	# Set up sp
	addiu $sp, $zero, ASS
.end_macro


.text
	boot()
	j startApp   # BOOT's CODE
