.eqv ZERO $zero
.eqv S0 $s0
.eqv S1 $s1
.eqv S2 $s2
.eqv S3 $s3
.eqv S4 $s4
.eqv S5 $s5
.eqv S6 $s6
.eqv S7 $s7

.macro save()
  or $s3, $s3, $s6
  or $s3, $s3, $s7
  sw $s3, 0($a3)
.end_macro

.macro select_position()
  lw $s7, 0($a3)
  lw $s6, 0($a3)

  and $s7, $s7, $s1           # s7 = s[i]
  and $s6, $s6, $s2           # s6 = s[j]

  lw $s3, 0($a3)              # s3 = string
  xori $s5, $s2, 0xffffffff   # s5 = not l
  and $s3, $s5, $s3           # s3 = string and (not l)
  xori $s5, $s1, 0xffffffff   # s5 = not k
  and $s3, $s5, $s3           # s3 = string and (not l) and (not k)   

  sll $s1, $s1, 8
  srl $s2, $s2, 8
.end_macro

.macro desloc_rigth(%reg_to_desloc, %reg_ref, %reg_fix)
set_r:
  subu %reg_ref, %reg_ref, %reg_fix   # s3 = s3 -1
  srl %reg_to_desloc, %reg_to_desloc, 8       # s2 = 0xff << ( 8*(len -1) )
  bgtz %reg_ref, set_r

.end_macro

.macro desloc_left(%reg_to_desloc, %reg_ref, %reg_fix)
set_l:
  subu %reg_ref, %reg_ref, %reg_fix   # s3 = s3 -1
  sll %reg_to_desloc, %reg_to_desloc, 8       # s2 = 0xff << ( 8*(len -1) )
  bgtz %reg_ref, set_l
  
.end_macro

#save_number(){
#  if(i==0){
#    &string[0] = number
#    i++
#  }
#  if(i<4){
#    t9 = Todos os elementos da posiçao de mem
#    t9 << 8    
#    &string[i] = number OR t9
#    i++
#  }else{
#    &string += 4
#    i = 0 
#  }

.macro save_number(%reg_to_save, %finish_flag)

  addiu $t8, $zero, %finish_flag
i_equal_zero:

  bgtz $s0, i_not_zero
  sw %reg_to_save, 0($s1)
  addiu $s0, $s0, 1
  j SaveNumber_flag

i_not_zero:

  beq $s0, $s7, end_string_plus4
  lw $t9, 0($s1)
  sll $t9, $t9, 8
  or %reg_to_save, %reg_to_save, $t9   
  sw %reg_to_save, 0($s1)
  addiu $s0, $s0, 1
  j SaveNumber_flag
  #j div_n 

end_string_plus4:
  addiu $s1, $s1, 4
  addiu $s0, $zero, 0
  j i_equal_zero 

SaveNumber_flag:
  addiu $a1, $a1, 1
  beqz $t8, div_n
  
.end_macro

.text

#  addiu $sp, $zero, 0x10010230
#main:

#  addiu $a0, $zero, 45
#  jal IntToString
#  addiu $a0, $zero, 345
#  jal IntToString
#  addiu $a0, $zero, 1234
#  jal IntToString
#  addiu $a0, $zero, 12345
#  jal IntToString
#  addiu $a0, $zero, 123456
#  jal IntToString
#  addiu $a0, $zero, 7654321
#  jal IntToString
#  addiu $a0, $zero, 987654321
#  jal IntToString
#loop:
#  j loop

#reverse()
# if(len > 4){
#   tamanho -=4
#   swap(4, &string)
#   &string +=4
# }else{
#   swap(len, &string)
#   jal $ra
# }
# swap(len)
#   i = 0
#   j = len
#   k = 0x000000ff
#   l = 0x000000ff << (8*(j-1))
#
#   for(; i < j; i++, j--){
#     s7 = string
#     s6 = string
#     s7 = s7 AND k     // s7 = s[i]
#     s6 = s7 AND l     // s7 = s[j]
#     
#     s3 = string
#     s3 = string AND (NOT k) AND (NOT l)
#     
#     s7 = s7 << (8*numero_adequado())
#     s6 = s6 >> (8*numero_adequado())
#     
#     s3 = string OR (S6) OR (S7)
#     k << 8 
#     j >> 8 
#   }
#
swap1:
  subu $sp, $sp, 52
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $s3, 28($sp)
  sw $s4, 32($sp)
  sw $s5, 36($sp)
  sw $s6, 40($sp)
  sw $s7, 44($sp)
  sw $ra, 48($sp)

  # s0 = i
  # a0 = len
  # a3 = &string
  # s1 = k
  # s2 = l
  # s3 = 8*len e string
  # s4 = 1 e c
  # s5 = (not l) e (not k) 
  # s6 = s[i]
  # s7 = s[j]

  addiu $s0, $zero, 0
  addiu $s1, $zero, 0xff
  addiu $s2, $zero, 0xff
  addiu $s3, $a0, 0 
  addiu $s4, $zero, 1 

  subu $s3, $s3, $s4    # s3 = len - 1
set_l:
  sll $s2, $s2, 8       # s2 = 0xff << ( 8*(len -1) )
  subu $s3, $s3, $s4    # s3 = s3 -1
  bgtz $s3, set_l

  la $s3, string

swap_select:
# numero_adequado(){
  addiu $s4, $zero, 4
  beq $a0, $s4, j_4

  addiu $s4, $zero, 3
  beq $a0, $s4, j_3
  
  addiu $s4, $zero, 2
  beq $a0, $s4, j_2
#}

j_4:
  select_position()
  
  addiu $s5, $zero, 3
  addiu $s4, $zero, 1
  # num_3 >> 8*3 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 3
  addiu $s4, $zero, 1
  #num_0 << 8*3
  desloc_left(S7, S5, S4)
  # save 1
  save()

  select_position()

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_2 >> 8 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_1 << 8
  desloc_left(S7, S5, S4)
  # save 2
  save()

  j end_for

j_3:
  select_position()

  addiu $s5, $zero, 2
  addiu $s4, $zero, 1
  # num_2 >> 8*2 
  desloc_rigth(S6, S5, S4)

  addiu $s5, $zero, 2
  addiu $s4, $zero, 1
  # num_0 << 8*2
  desloc_left(S7, S5, S4)
  # save 2
  save()
  j end_for

j_2:
  select_position()

  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_1 >> 8 
  desloc_rigth(S6, S5, S4)
  addiu $s5, $zero, 1
  addiu $s4, $zero, 1
  # num_0 << 8
  desloc_left(S7, S5, S4)
  # save 2
  save()
  j end_for
 
end_for:

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $s3, 28($sp)
  lw $s4, 32($sp)
  lw $s5, 36($sp)
  lw $s6, 40($sp)
  lw $s7, 44($sp)
  lw $ra, 48($sp)
  addiu $sp, $sp, 52
  
  jr $ra

reverse:
  subu $sp, $sp, 32
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $ra, 28($sp)

  # a1 = len
  # s0 = 4
  # s1 = a0 = len
  # s2 = &string
  
  #jal find_len
  addiu $s0, $zero, 4
  addiu $s1, $a1, 0
  la $s2, string

reverse_if:

  blt $s1, $s0, reverse_else
  subu $s1, $s1, $s0
  addiu $a0, $zero, 4
  addiu $a3, $s2, 0
  jal swap1
  addiu $s2, $s2, 4
  j reverse_if

reverse_else:
  addiu $a0, $s1, 0
  addiu $a3, $s2, 0
  jal swap1

end_reverse:

  addiu $a0, $zero, 0  
  addiu $a1, $zero, 0  
  addiu $a2, $zero, 0  
  addiu $a3, $zero, 0  

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $ra, 28($sp)
  addiu $sp, $sp, 32
  
  jr $ra

IntToString:
  subu $sp, $sp, 56
  sw $s0, 16($sp)
  sw $s1, 20($sp)
  sw $s2, 24($sp)
  sw $s3, 28($sp)
  sw $s4, 32($sp)
  sw $s5, 36($sp)
  sw $s6, 40($sp)
  sw $a1, 48($sp)
  sw $ra, 52($sp)

  # a0 n
  # s0 i
  # s1 &string
  # s2 sign
  # s3 10
  # s4 n % 10
  # s5 -1
  # s6 
  # s7 4
  addiu $a1, $zero, 0
  la $s1, string
  addiu $s5, $zero, -1
  addiu $s0, $zero, 0
  addiu $s3, $zero, 10
  addiu $s7, $zero, 4
  sw $s0, 0($s1)
  
  bltz $a0, negative_sign
  addiu $s2, $zero, 0
  j generate_string

negative_sign:
  addiu $s3, $zero, 1
  multu $a0, $s5
  mflo $a0                  # a0 = -a0

generate_string:
#do
  divu $a0, $s3             # s0/s3. number/10
  mfhi $s4                  # s4 = n % 10
  addiu $s4, $s4, 48        # s4 = s4 + '0'

  save_number(S4, 0)
  
div_n:

  divu $a0, $s3             # number/10
  mflo $a0                  # a0 = number/10
  bgtz $a0, generate_string  
# while(a0 > 10)
  
  bgtz $s2, save_neg
  j end_IntToString

save_neg:
  addiu $s2, $zero, 45      # s2 = '-'
  save_number(S2, 0)

end_IntToString:
  addiu $s4, $zero, 0
  save_number(S4, 1)         # string[i] = '\0'
  jal reverse

  la $v0, string

  lw $s0, 16($sp)
  lw $s1, 20($sp)
  lw $s2, 24($sp)
  lw $s3, 28($sp)
  lw $s4, 32($sp)
  lw $s5, 36($sp)
  lw $s6, 40($sp)
  lw $a1, 48($sp)
  lw $ra, 52($sp)
  addiu $sp, $sp, 56
  
  jr $ra  

.data

  string:  .space 4
