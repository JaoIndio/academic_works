

.text


startApp:
	#INSTRUCTION MEM[0] = 0x1234abcd
  addiu $t0, $zero, 0x000000cd
	sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000ab
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000034
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000012
  sw $t0, TX_Addr
  jal Delay

  #INSTRUCTION MEM[1] = 0xabcd1234
  addiu $t0, $zero, 0x00000034
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000012
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000cd
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000ab
  sw $t0, TX_Addr
  jal Delay

  # 544.22 us

  #DATA MEM[0] = 0x1234abcd
  addiu $t0, $zero, 0x000000cd
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000ab
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000034
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000012
  sw $t0, TX_Addr
  jal Delay

  #DATA MEM[1] = 0xabcd1234
  addiu $t0, $zero, 0x00000034
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x00000012
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000cd
  sw $t0, TX_Addr
  jal Delay

  addiu $t0, $zero, 0x000000ab
  sw $t0, TX_Addr
  jal Delay

loop:	
	addiu $t0, $t0, 1
	j loop

Delay:
  subu $sp, $sp, 28
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $ra, 24($sp)

  addiu $s0, $zero, 0xf8
  addiu $s1, $zero, 0
  
  DelayLoop:
    beq $s1, $s0, Delay_end
    addiu $s1, $s1, 1
    j DelayLoop

  Delay_end:

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $ra, 24($sp)
  addiu $sp, $sp, 28

  jr $ra
