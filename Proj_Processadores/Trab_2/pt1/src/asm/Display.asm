
.text 

# Button Up   address : 0x80000010
# Button Down address : 0x80000020
# Display     address : 0x80000030

# PortEnable  address : 0x80000000
# PortConfig  address : 0x80000001
# PortData    address : 0x80000002

# Esse codigo eh funcional

# 1. Porem port_io por alguns segundos emite sinais problematicos
#   para mitigar esse problema é preciso escrever em alguns dos registradores
#   os valores de enable.

# 2. Mudar MIPS_uC pra ficar mais bonito o codigo

# 3. Prototipar.

# 4. Escrever outro codigo .asm segundo os requisitos do Carara

# 5. Fazer tarefas explicativas a respeito da funcinalidade dos componentes criados

	addiu $t2, $zero, 0x00008000  # Up Value    
	addiu $t3, $zero, 0x00004000  # Down Value
	addiu $t4, $zero, 0x0000c3fc  # Enable value 1
	addiu $t5, $zero, 0x00000000
	addiu $t6, $zero, 0x80000030
	addiu $t7, $zero, 0x0000c000  # Enable value 2
	addiu $t8, $zero, 0x80000000
	addiu $t9, $zero, 0x80000002
	
	
	#addiu $t1, $zero, 0x0000c3fc  
	#sw $t1, 0x80000000           # PortEnable <= t1
	#sw $t4, 0x80000000

	#sw $t4, 0($t8)
	
# | in | | in | | out | | out | | out | | out | | out | | out | | out | | out | | out | | out | | out | | out | | in | | in | <= Bidirectional Port Config
	addiu $t1, $zero, 0x0000c003 
	sw $t1, 0x80000001           # PortConfig <= t1 
	
	#sw $t5, 0x80000002           # Display_out need to be disable at this point
	#sw $t5, 0($t9)
	#sw $t5, 0x80000030 	     # Display_number <= PortData . Display_out need to be disable at this point
	#sw $t5, 0($t6)
# Disable BidirectionalPort(9 downto 3) to realese to display_out signal
	#addiu $t1, $zero, 0x0000c000
	#sw $t1, 0x80000000           # PortEnable <= t1
	#sw $t7, 0x80000000
	sw $t7, 0($t8)
	 
#init: 
#	j init
	
read_button_UP:
	lw $t0, 0x80000010     # Bidirectional_Port <= Reg_Button_UP
	#sw $t1, 0x80000002     # PortDta <= Bidirectional_Port
	#lw $t1, 0x80000002     # t1 <= PortData
	sw $t1, 0($t9)
	lw $t1, 0($t9) 
	andi $t1, $t1, 0x4000  # t1 <= t1 AND 0x4000
	
	beq $t1, $t3, sum
        #j read_button_DOWN
	
read_button_DOWN:
	lw $t0, 0x80000020     # Bidirectional_Port <= Reg_Button_Down
	#sw $t1, 0x80000002     # PortDta <= Bidirectional_Port
	#lw $t1, 0x80000002     # t1 <= PortData
	sw $t1, 0($t9)
	lw $t1, 0($t9)
	andi $t1, $t1, 0x8000  # t1 <= t1 AND 0x4000
	
	beq $t1, $t2, subtraction
	j read_button_UP
	
sum:
	addiu $t5, $t5, 4     # number = number + 1
	#addiu $t1, $zero, 0x0000c3fc
	#sw $t1, 0x80000000            # PortEnable <= t1 . Display_out need to be disable at this point
	#sw $t4, 0x80000000
	#sw $t5, 0x80000002
	sw $t4, 0($t8)
	sw $t5, 0($t9)
	#sw $t7, 0x80000030            # Display_out need to be disable at this point
	sw $t7, 0($t6)
	
	#addiu $t1, $zero, 0x0000c000
	#sw $t1, 0x80000000            # PortEnable <= t1 .Display_out need to be enable at this point. This mean that BidirectionalPort(9 downto 3) are free to display_out signal
	#sw $t7, 0x80000000
	sw $t7, 0($t8)
	j read_button_DOWN

subtraction:
	subiu $t5, $t5, 4     # number = number + 1
	#addiu $t1, $zero, 0x0000c3fc
	#sw $t1, 0x80000000            # PortEnable <= t1 . Display_out need to be disable at this point
	#sw $t4, 0x80000000
	#sw $t5, 0x80000002
	sw $t4, 0($t8)
	sw $t5, 0($t9)
	#sw $t7, 0x80000030            # Display_out need to be disable at this point
	sw $t7, 0($t6)
	
	#addiu $t1, $zero, 0x0000c000 
	#sw $t1, 0x80000000            # PortEnable <= t1 .Display_out need to be enable at this point. This mean that BidirectionalPort(9 downto 3) are free to display_out signal
	#sw $t7, 0x80000000
	sw $t7, 0($t8)
	j read_button_UP
	
.data
	number: .word 0
