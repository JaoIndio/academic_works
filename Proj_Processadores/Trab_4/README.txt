------------------------------------------------------------------------

  Parte 1 : 
    - Conectar um periférico externo ao MIPS_uC através da porta de E/S

    - CryptoMessage
        
      *Envia mensagens criptografadas lidas de uma arquivo texto
        
      * Implementar em VHDL (não sintetizável)

    - Ligar o CryptoMessage ao MIPS_uC
      
      * CryptoMessage deve operar na metade da frequência do MIPS
      
    - Deve-se configurar adequadamente os bits da porta
      de E/S a fim que o MIPS_uC tenha acesso à interface
      do CryptoMessage

    - A saída data_av do CryptoMessage deve interromper
      o MIPS quando disponibiliza o primeiro byte da
      mensagem a ser transmitida (hardware)

    - Durante o tratamento da interrução, o MIPS deve
      fazer polling em data_av a fim de detectar um novo
      byte da mensagem (software), além de fazer polling
      em eom a fim de detectar o final da mensagem

    - Adicionar ao processador dois registradores especiais de
      32 bits: hi e lo. Estes registradores devem armazenar o
      resultado das instruções de multiplicação e divisão
    
    - Implementar as instruções MULTU, DIVU, MFHI e MFLO
    
    - Para implementar as instruções MULTU e DIVU em
      VHDL no datapath, utilizar os operadores *, / e mod

    - Aplicação
      
      * A aplicação principal executada pelo processador será o
        bubbleSort
          + Aumentar o tamanho do array para 50 elementos

      * Ao ser interrompido pelo CryptoMessage, o processador
        deve ler uma mensagem completa (eom = 1) e armazenar
        em um array
          + msg: .space 80 // Aloca 80 bytes
          + Este array deve ser sobreescrito quado o CryptoMessage
            enviar uma nova mensagem

      * O arquivo contendo as as mensagens enviadas pelo
        CryptoMessage será fornecidos junto com o CryptoMessage.vhd

-------------------------------------------------------------------------


------------------------------------------------------------------------

  Parte 2 : 
    - Adicionar um controlador de interrupções (PIC) ao MIPS_µC
    
      * Os bits (15:12) da porta de E/S podem ser utilizados como entradas
        externas de interrupção e devem ser ligadas ao PIC
      
      * Utilizar as entradas de interrupção do PIC de 7:4 (menor prioridade)
      
      * As demais entradas de interrupção do PIC (3:0) devem ser mantidas
        em 0 (fazer isso no port map em MIPS_uC.vhd)

    - Instrução MTC0
      
      * Adicionar ao data path um registrador que armazene o endereço da ISR
        + ISR_AD
      
      * O registrador deve ser escrito através da instrução MTC0
        + O registrador ISR_AD deve ser identificado como registrador $31 
        do CP0

      * Setar ISR_AD no boot com o endereço da ISR
        + la $t0, InterruptServiceRoutine # Pega endereço do label
        + mtc0 $t0, $31 # ISR_AD ← $t0

-------------------------------------------------------------------------