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