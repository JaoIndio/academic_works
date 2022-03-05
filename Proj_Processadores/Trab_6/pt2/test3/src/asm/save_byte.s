
.macro save_byte(%index_add, %value_add, %reg_to_save, %inst_value)

  lw $s1, 0(%index_add)
  addiu $s2, $zero, 4

i_equal_zero_MEM:

  bgtz $s1, i_not_zero_MEM            
    sw %reg_to_save, 0(%value_add)
    sw %reg_to_save, 0(%inst_value)
    addiu $s1, $s1, 1
    sw $s1, 0(%index_add)
    j end_save_byte

i_not_zero_MEM:

  beq $s1, $s2, end_string_plus4_MEM
    lw $t9, 0(%inst_value)
    
    sll $t9, $t9, 8
    or %reg_to_save, %reg_to_save, $t9   
    sw %reg_to_save, 0($s1)

    save_byte_add:
    or %reg_to_save, %reg_to_save, $t9   
    sw %reg_to_save, 0(%value_add)
    sw %reg_to_save, 0(%inst_value)
    
    addiu $s1, $s1, 1
    sw $s1, 0(%index_add)
    j end_save_byte

end_string_plus4_MEM:
  addiu %value_add, %value_add, 4
  addiu $s1, $zero, 0
  j i_equal_zero_MEM

end_save_byte: 

.end_macro

.macro save_number(%reg_to_save, %finish_flag, %label_to_jump)

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

end_string_plus4:
  addiu $s1, $s1, 4
  addiu $s0, $zero, 0
  j i_equal_zero 

SaveNumber_flag:
  addiu $a1, $a1, 1
  beqz $t8, %label_to_jump
.end_macro

.macro save_byte(%index_add, %value_add, %reg_to_save, %inst_value)

  lw $s1, 0(%index_add)
  addiu $s2, $zero, 4

i_equal_zero_MEM:

  bgtz $s1, i_not_zero_MEM            
    sw %reg_to_save, 0(%value_add)
    sw %reg_to_save, 0(%inst_value)
    addiu $s1, $s1, 1
    sw $s1, 0(%index_add)
    j end_save_byte

i_not_zero_MEM:

  beq $s1, $s2, end_string_plus4_MEM
    lw $t9, 0(%inst_value)
    
    addiu $s3, $zero, 1
    beq $s1, $s3, save_byte_shift_8

    addiu $s3, $zero, 2
    beq $s1, $s3, save_byte_shift_16

    j save_byte_shift_24
    #addiu $s3, $zero, 3
    #beq $s1, $s3, save_byte_shift_24
    
    save_byte_shift_8:
    sll %reg_to_save, %reg_to_save, 8
    j save_byte_add

    save_byte_shift_16:
    sll %reg_to_save, %reg_to_save, 16
    j save_byte_add    
    
    save_byte_shift_24:
    sll %reg_to_save, %reg_to_save, 24

    save_byte_add:
    or %reg_to_save, %reg_to_save, $t9   
    sw %reg_to_save, 0(%value_add)
    sw %reg_to_save, 0(%inst_value)
    
    addiu $s1, $s1, 1
    sw $s1, 0(%index_add)
    j end_save_byte

end_string_plus4_MEM:
  addiu %value_add, %value_add, 4
  addiu $s1, $zero, 0
  j i_equal_zero_MEM

end_save_byte: 

.end_macro