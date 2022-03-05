------------------------------------------------------------------------

  Parte 1 : 
    - Interface entre Processador e Periféricos
        * A porta de E/S deve ter 16 bits para interface com o mundo externo
        
        * Os bits da porta devem ser individualmente configuráveis como ent-
          rada ou saída
            Exemplo
              bits(15:10) e bits(1:0) - entrada
              bits(9:2) - saída
        
        * A configuração dos bits é controlada por um registrador (16 bits) 
          onde cada bit corresponde à configuração de um bit da porta
              0: saída (output)
              1: entrada (input)
        
        * Deve haver também um registrador que habilita individualmente a uti-
          lização dos bits da porta de E/S e um registrador de dados (ambos 16 bits)


-------------------------------------------------------------------------
