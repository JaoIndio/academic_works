------------------------------------------------------------------------

  Parte 1 : 
    - Adicionar as seguintes instruções à descrição
        * BNE, XOR, XORI, NOR, ANDI, SLL, SRL, SLTU, SLTI,
          SLTIU, BGEZ, BLEZ, BLTZ, BGTZ, JALR

    - Programa de teste: inst_test.asm (/src/asm)
        * Conferir o valor dos registradores e da memória da
          simulação VHDL com a execução o programa no MARS


-------------------------------------------------------------------------


------------------------------------------------------------------------

  Parte 2 : 
    - Fazer a prototipação em FPGA do processador MIPS

    - Aplicação
        * Implementar um contador hexadecimal com incremento de 1
          segundo

        * Considerar o tempo de execução das instruções e a frequência a
          fim de atingir um incremento o mais próximo possível de 1
         segundo
        
        * Sequência sugerida para o desenvolvimento
            1. Adicionar DCM e sincronização do reset ao projeto atual e
               simular
            2. Criar a entity MIPS_FPGA_TEST contendo MIPS, memórias,
               DCM e sincronização do reset. Criar test bench para gerar clock
               e reset para a entity MIPS_FPGA_TEST e simular
            3. Adicionar a parte relativa à interface com os displays e simular
            4. Prototipar

-------------------------------------------------------------------------