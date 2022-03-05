------------------------------------------------------------------------

  Parte 1 : 
    - Adicionar ao processador MIPS capacidade de atender
      interrupções
    
      *  Sempre que um pedido de interrupção for feito, o
        processador deve saltar para uma ISR e executar o
        handler de acordo com o periférico que gerou a
        interrupção
    
      * Ao encerrar a ISR, a execução deve retornar de onde
        foi interrompida
    
      * Na interface do processador deve ser adicionado uma
        entrada de interrupção intr (interrput request)

    - Aplicação
      
      * Executar o bubble sort como programa em execução
        (processo)
      
        + Nova versão no moodle (utilizando pilha)
      
      * Implementar um handler que controla um contador de 8
        bits na porta de E/S
      
        + A valor da contagem fica armazenado no registrador portData e
          deve aparecer em 8 bits da porta de E/S configurados como
          saídas
      
      * Configurar um bit da porta de E/S como entrada de
        interrupção
      
        + A cada interrução gerada o contador deve ser incrementado

        + As interrupções devem ser geradas via test-bench
        
        + A execução do bubble sort deve ser interrompida várias vezes a
          fim de verificar o funcionamento do suporte a interrupções
          (hardware/software)

-------------------------------------------------------------------------


------------------------------------------------------------------------

  Parte 2 : 
    - Prototipação em FPGA do sistema implementado na parte 1 a fim de
      verificar o funcionamento da infraestrutura de suporte a
      interrupções
    
    - A aplicação a ser desenvolvida deve reutilizar o
      controle dos displays implementado em software no
      trabalho 2

-------------------------------------------------------------------------