------------------------------------------------------------------------

  Parte 1 : 
    - Adicionar módulo de recepção serial ao MIPS_uC
      
      * Na interface do MIPS_uC deve ser adicionada a entrada serial
        de 1 bit (rx)
      
      * A saída data_av do módulo RX deve ser ligada à irq(3) do PIC a
        fim de interromper o processador sempre um dado está
        disponível na saída data_out

    - Modificar o MIPS_uC de maneira que seja possível carregar as me-
      mórias com programa/dados através do módulo RX

    - Sugestão
      
      * Utilizar os slide-switches da placa para selecionar o modo
        de operação do MIPS_uC
        + Modo de programação da memória de instruções
        + Modo de programação da memória de dados
        + Modo de execução

      * Adicionar à interface do MIPS_uC entradas correspondente aos 
        slide-switches que forem utilizados

    - Aplicações
      
      * As aplicações devem ser carregadas via módulo RX
        + O programa principal deve configurar a velocidade de comunicação
          dos módulos para 57600 bps e entrar em um loop infinito esperando 
          pela carga de uma aplicação

      * App1: contador
        + Utilizar o contador com incremento de 1 segundo dos trabalhos anteriores
        + O código deve utilizar variáveis

      * App2: Echo (semelhante ao uart_terminal.bit)
        + Adicionar um handler para tratar dados recebidos pelo módulo RX 
          através de um programa de comunicação serial (e.g. PuttY) quando uma 
          tecla é pressionada
        + O handler deve simplesmente enviar de volta para o terminal 
          (via módulo TX) o código ASCII da tecla pressionada

-------------------------------------------------------------------------


------------------------------------------------------------------------

  Parte 2 : 
    - Leitura do teclado
      
      * Aplicações que requerem entrada de dados através do teclado, via 
        terminal serial, devem utilizar a chamada de sistema read
        + int read (char *buffer, int size)
          . buffer: endereço onde devem ser armazenados os caracteres lidos
          . size:   número máximo de caracteres que podem ser armazenados em 
                    buffer contando o final de string 0
          . Retorna
            - 0 caso <ENTER> ainda não tenha sido pressionado ou
            - o número de caracteres armazenados após <ENTER> ter sido pressionado
          
          . buffer deve conter uma string finalizada com 0. <ENTER> não
            deve ser armazenado

-------------------------------------------------------------------------