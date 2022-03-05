  # a0 = NUM
  # a1 = num ref 1 IN 100
  # a2 = num ref 2 IN 10
  # a3 = num ref 3 IN 10

  subu $sp, $sp, 24
  sw $s0, 16($sp)
  sw $ra, 20($sp)

  addiu $s0, $a0, $zero
while:
  blt $s0, $a1, end_while     # if(num_aux < 100) jump
  subu $s0, $s0, $a1          # num_aux -=100 
end_while:
  
  
  blt $a2, $a2, save_0

  addu $a2, $a2, $a3    # a2 +=a3; a2+=10
  blt $s0, $a2, save_1

  addu $a2, $a2, $a3
  blt $s0, $a2, save_2

  addu $a2, $a2, $a3
  blt $s0, $a2, save_3

  addu $a2, $a2, $a3
  blt $s0, $a2, save_4

  addu $a2, $a2, $a3
  blt $s0, $a2, save_5

  addu $a2, $a2, $a3
  blt $s0, $a2, save_6

  addu $a2, $a2, $a3
  blt $s0, $a2, save_7

  addu $a2, $a2, $a3
  blt $s0, $a2, save_8
  j save_9

save_0:
  addiu $v0, $zero, 0
  j save
save_1:
  addiu $v0, $zero, 1
  j save
save_2:
  addiu $v0, $zero, 2
  j save
save_3:
  addiu $v0, $zero, 3
  j save
save_4:
  addiu $v0, $zero, 4
  j save
save_5:
  addiu $v0, $zero, 5
  j save
save_6:
  addiu $v0, $zero, 6
  j save
save_7:
  addiu $v0, $zero, 7
  j save
save_8:
  addiu $v0, $zero, 8
  j save
save_9:
  addiu $v0, $zero, 9
  j save

save:
  lw $s0, 16($sp)
  lw $ra, 20($sp)
  addiu $sp, $sp, 24
  
  jr $ra