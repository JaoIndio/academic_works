




* no diretorio que se encontra o código fonte crie os diretórios bin e data
* compile e execute

COMANDOS PARA COMPILAR: gcc painel.c   -o bin/painel   -lpthread -lm -lrt
                        gcc inversor.c -o bin/inversor -lpthread -lm -lrt
                        gcc monitor.c  -o bin/monitor  -lpthread -lm -lrt

Exemplo:

/diretorio_codigos
               |
               |
               ----> /bin
               |
               |---> /data
               |
               ----> painel.c
               |
               |
               ---> inversor.c
               |
               |
               ---> monitor.c


Para rodar o simulador corretamente execute primeiro painel depois inversor e por fim monitor.

Em anexo, seguem arquivos .ods e xlsx que demonstram os resultados das variavies de uma simulação.
Para facilitar a visualização, vc pode plotar os resultados nas planilhas do Google Drive.
