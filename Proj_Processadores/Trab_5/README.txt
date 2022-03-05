------------------------------------------------------------------------

  Parte 1 : 
    - Adicionar módulo de transmissão serial ao MIPS_uC
      
      * Na interface do MIPS_uC deve ser adicionada uma
        saída serial de 1 bit (tx)

    - Implementar em assembly as seguintes funções
      
      * void PrintString (char *string)
        + Manda todos os caracteres de uma string para o módulo de
          transmissão serial
        + Considerar que o final de uma string é indicado pelo byte 0
      
      * char *IntegerToString (int n)
        + A função deve converter o número n em uma string finalizada
          com o byte 0
        + Retorna um ponteiro para a área de memória onde está a string
          correspondente ao parâmetro n

    - Aplicação

      * Mesma do trabalho 4 – parte 2 (Bubble sort + Cryptos)
        + As funções implementadas devem ser utilizadas pelo BubbleSort 
          e pelos Handlers para enviar ao módulo de transmissão serial  
        + BubbleSort
          . “Array inicial: 9 4 39 …”
          . “Array final: 1 2 3 …”
        + Handlers
          . Mensagens dos CriptoMessages (não precisam ser armazenadas)


-------------------------------------------------------------------------


------------------------------------------------------------------------

  Parte 2 : 
    - Adicionar suporte à exceções síncronas (traps) ao processador MIPS

    - Sempre que uma exceção síncrona ocorrer, a execução deve desviar 
      para um endereço fixo onde iniciará a execução da rotina de tra-
      tamento de exceções (ESR - Exception Service Routine)
      
      * Ao entrar nesta rotina, as interrupções externas devem ser
        desabilitadas via hardware e reabilitadas no final através da
        instrução ERET
      * O endereço de retorno deve ser armazenado no EPC

    - O endereço da ESR deve ser armazenado no registrador ESR_AD 
      através da instrução MTC0

      * Adicionar o registrador ESR_AD no data path e mapear no regis-
        trador C0[30]

    - As exceções que fazem chamadas de sistema são geradas a partir 
      da instrução syscall (implementar)
    
    - Neste trabalho teremos três chamadas de sistema
      * 0: PrintString
      * 1: IntegerToString
      * 2: IntegerToHexString
    
    - Para identificar a função a ser chamada, deve-se utilizar o
      registrador v0
        * li $v0, 0 # PrintString
        * la $a0, msg
        * syscall # Salta para a rotina de tratameto de exceção
    
    - O handler da exceção SYSCALL deve verificar a função solicitada
      ($v0) e chamar a função correspondente
        *Jump table (definir array com os endereços das três funções)

-------------------------------------------------------------------------