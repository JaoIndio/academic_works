    
    .text                           # Declaração de início do segmento de texto
    .globl  main                    # Declaração de que o rótulo main é global

########################################
# testes de instruções individuais
########################################
main:   
    lui     $t0,0xf3                #
    ori     $t0,$t0,0x23            # $t0<= 0x00f30023
    lui     $t1,0x52                #
    ori     $t1,$t1,0xe2            # $t1<= 0x005200e2
    lui     $t2,0x00                #
    ori     $t2,$t2,0x8f            # $t2<= 0x0000008f
    beq     $t1,$t2,loop            # Obviamente, esta instrução nunca deve saltar
    bne     $t1,$t2,next_i          # Obviamente, esta instrução sempre deve saltar
    addiu   $t2,$t2,0x8f            # Obviamente, esta instrução nunca deve executar

next_i:    
    addu    $t3,$t0,$t1             # $t3<= 0x00f30023 + 0x005200e2 = 0x01450105
    subu    $t4,$t0,$t1             # $t4<= 0x00f30023 - 0x005200e2 = 0x00a0ff41
    subu    $t5,$t1,$t1             # $t5<= 0x0
    and     $t6,$t0,$t1             # $t6<= 0x00f30023 and 0x005200e2 = 0x00520022
    or      $t7,$t0,$t1             # $t7<= 0x00f30023 or  0x005200e2 = 0x00f300e3
    xor     $t8,$t0,$t1             # $t8<= 0x00f30023 xor 0x005200e2 = 0x00a100c1
    nor     $t9,$t0,$t1             # $t9<= 0x00f30023 nor 0x005200e2 = 0xff0cff1c
    addiu   $t0,$t0,0x00ab          # $t0<= 0x00f30023  +  0x000000ab = 0x00f300ce
    andi    $t0,$t0,0x00ab          # $t0<= 0x00f300ce and 0x000000ab = 0x0000008a
    xori    $t0,$t0,0xffab          # $t0<= 0x0000008a xor 0x0000ffab = 0x0000ff21
    sll     $t0,$t0,4               # $t0<= 0x000ff210 (deslocado 4 bits para a esquerda)
    srl     $t0,$t0,9               # $t0<= 0x000007f9 (deslocado 9 bits para a direita)
    addiu   $t0,$zero,0x1           # $t0<= 0x00000001
    subu    $t0,$zero,$t0           # $t0<= 0xffffffff
    bgez    $t0,loop                # Esta instrução nunca deve saltar, pois $t0 = -1
    slt     $t3,$t0,$t1             # $t3<= 0x00000001, pois -1 < 10
    sltu    $t3,$t0,$t1             # $t3<= 0x00000000, pois (2^32)-1 > 10
    addiu   $t8,$zero,-8
    li      $t9, -9
    slti    $t8,$t0,0x1             # $t8<= 0x00000001, pois -1 < 1
    sltiu   $t9,$t0,0x1             # $t9<= 0x00000000, pois (2^32)-1 > 1
    bgez    $t0,bgez_error          # Este salto não deve ocorrer pois $t0 < 0 (-1)
    bgez    $t9, soma_ct            # Este salto deve ocorrer pois $t9 = 0
bgez_error:
    j       bgez_error              # Este loop não deve ser executado
    
########################################
# soma uma constante a um vetor
########################################
soma_ct:
    la      $t0,array               # coloca em $t0 o endereço do vetor (0x10010000)
    la      $t1,size                # coloca em $t1 o endereço do tamanho do vetor 
    lw      $t1,0($t1)              # coloca em $t1 o tamanho do vetor
    la      $t2,const               # coloca em $t2 o endereço da constante
    lw      $t2,0($t2)              # coloca em $t2 a constante
loop:    
    blez    $t1,end_add             # se/quando tamanho é/torna-se 0, fim do processamento
    lw      $t3,0($t0)              # coloca em $t3 o próximo elemento do vetor
    addu    $t3,$t3,$t2             # soma constante
    sw      $t3,0($t0)              # atualiza no vetor o valor do elemento
    addiu   $t0,$t0,4               # atualiza ponteiro do vetor. Lembrar, 1 palavra=4 posições de memória
    addiu   $t1,$t1,-1              # decrementa contador de tamanho do vetor
    j       loop                    # continua execução
end_add: 
    blez $t2, sub_routine           # Este salto deve ocorrer pois $t2 < 0 (-1)

blez_error:
    j  blez_error                   # Este loop não deve ser executado
            
########################################
# teste de subrotinas aninhadas
########################################
sub_routine: 
    li      $sp, 0x10010060         # inicializa stack pointer (sp). Atenção ao tamanho da memória de dados!!!
    addiu   $sp,$sp,-4              # aloca espaço na pilha para uma palavra
    sw      $t3,0($sp)              # salva t2 na pilha
    jal     sum_tst                 # salta para subrotina sum_tst
    lw      $ra,0($sp)              # ao retornar, recupera endereço de retorno da pilha
    addiu   $sp,$sp,4               # atualiza apontador de pilha 

#######################
# testa bltz e bgtz   
#######################
    bltz $zero,bltz_error           # Este salto nunca deve ocorrer pois $zero = 0 
    addiu $t0,$zero,-1
    bltz $t0,bgtz_test              # Este  deve ocorrer pois $t0 < 0 (-1)
bltz_error:
    j  bltz_error                   # Este loop não deve ser executado    
        
bgtz_test:
    bgtz $t0,bgtz_error             # Este salto nunca deve ocorrer pois $t0 < 0 (-1)
    addiu $t0,$t0,1               
    bgtz $t0,bgtz_error             # Este salto nunca deve ocorrer pois $t0 = 0
    addiu $t0,$zero,1
    bgtz $t0,end                    # Este salto  deve ocorrer pois $t0 > 0 (1)

bgtz_error: 
    j bgtz_error
     
end:                     
    #jr      $ra                    # volta para o "sistema operacional" (PROGRAMA ACABA AQUI)
    j end                           # O programa encerra neste laço infinito

#############################################
# Início da primeira subrotina: sum_tst
############################################
sum_tst:
    la      $t0,var_a               # pega endereço da primeira variável (pseudo-instrução)
    lw      $t0,0($t0)              # toma o valor de var_a e coloca em $t0
    la      $t1,var_b               # pega endereço da segunda variável (pseudo-instrução)
    lw      $t1,0($t1)              # toma o valor de var_b e coloca em $t1
    addu    $t2,$t1,$t0             # soma var_a com var_b e coloca resultado em $t2
    addiu   $sp,$sp,-8              # aloca espaço na pilha
    sw      $t2,0($sp)              # no topo da pilha coloca o resultado da soma
    sw      $ra,4($sp)              # abaixo do topo coloca o endereço de retorno
    la      $t3,ver_ev              # pega endereço da subrotina ver_ev (pseudo-instrução)
    jalr    $ra,$t3                 # chama subrotina que verifica se resultado da soma é par
    lw      $ra,4($sp)              # ao retornar, recupera endereço de retorno da pilha
    addiu   $sp,$sp,8               # atualiza apontador de pilha
    jr      $ra                     #  Retorna para quem chamou

######################################################        
# Início da segunda subrotina: ver_ev. 
# Trata-se de subrotina folha, que não usa pilha
#####################################################
ver_ev:    
    lw      $t3,0($sp)              # tira dados do topo da pilha (parâmetro)
    andi    $t3,$t3,1               # $t3 <= 1 se parâmetro é ímpar, 0 caso contrário
    jr      $ra                     # e retorna

########################################
# área de dados
########################################
    .data
# para trecho que soma constante a vetor
# byte 2 da segunda palavra (0xef) vira 0x10 antes de exec soma_ct
array:      .word    0xabcdef03 0xcdefab18 0xefabcd35 0xbadcfeab 0xdcfebacd 0xfebadc77 0xdefabc53 0xcbafed45
size:       .word    0x8            # número de elementos do vetor
const:      .word    0xffffffff     # constante -1 em complemento de 2

# para trecho de teste de chamadas de subrotinas
var_a:      .word    0xff           # 
var_b:      .word    0x100          #

# para testar acesso a memoria com half word
var_c:      .word    0

