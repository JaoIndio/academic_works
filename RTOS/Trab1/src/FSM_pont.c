#include <stdio.h>
#include <stdint.h>
#include <sys/time.h>

#define MAX_BUFFER 512
#define STX     0x02
#define ETX     0x03
//****************************************************************************//
// State table typedef
//****************************************************************************//
typedef struct
{
  int (*ptrFunc) (uint8_t data);  // ponteiro de funcao
  uint8_t NextState;
} FSM_STATE_TABLE;

struct GlobalVariabels            // estrutura dos dados presentes no protocolo de comunicacao
{
  uint8_t buffer[MAX_BUFFER];
  uint8_t chkBuffer;
  uint16_t indBuffer;
  uint16_t qtdBuffer;
} gv;


/*
Tabela estados/eventos, func/prox = funcao (pode ser NULL) 
e proximo estado (pode ser o atual)
formato:
      evento 0  - evento 1 - ... - evento N
estado 0 - func/prox - func/prox - ...- func/prox
...
estado N - func/prox - func/prox - ...- func/prox
*/

#define NR_STATES 5
#define NR_EVENTS 2

#define EVENTO_0   0
#define EVENTO_1   1

typedef enum { 
    ST_STX = 0, ST_QTD, ST_DATA, ST_CHK, ST_ETX
} States;

void handlePackage(uint8_t *data, uint16_t qtd)
{
  uint16_t i;
  printf("Imprimindo dados recebidos...\n");
  for (i = 0; i < qtd; i++)
    printf("Data[%d]=%d\n", i, data[i]);
}

double time_verification(clock begin){
  
  clock end = clock();
  return (double)(end - begin)/CLOCK_PER_SEC;

}

//     ......................... Logica do protocolo .....................
int stSTX(uint8_t data){
  if (data == STX){
    gv.indBuffer = gv.qtdBuffer = 0;
    gv.chkBuffer = 0;
    return 1;
    //sm.state = ST_QTD;
  }else
    return 0;
}


int stQtd(uint8_t data){
  gv.qtdBuffer = data;
  return 1;
  //sm.state = ST_DATA;
}


int stData(uint8_t data){
  gv.buffer[gv.indBuffer++] = data;
  gv.chkBuffer ^= data;
  if (--gv.qtdBuffer == 0){
    return 1;
      //sm.state = ST_CHK;
  }else
    return 0;
}


int stChk(uint8_t data){
  if (data == gv.chkBuffer){
    return 1;
    //sm.state = ST_ETX;
  }
  else{
    return 0;
    //sm.state = ST_STX;
  }
}


int stETX(uint8_t data){
  if (data == ETX){
    handlePackage(gv.buffer, gv.indBuffer);
  }
  return 1;
  //sm.state = ST_STX;
}

//     ......................... Logica do protocolo .....................


//StateTable = matriz da struct FSM_STATE_TABLE
const FSM_STATE_TABLE StateTable [NR_STATES][NR_EVENTS] =
{
//   Evento 0                        Evento 1
//pont_funcao, prox_estado,  pont_funcao, prox_estado

  stSTX,  ST_STX,                 stSTX,  ST_QTD,
  stQtd,  ST_QTD,                 stQtd,  ST_DATA,
  stData, ST_DATA,                stData, ST_CHK,
  stChk,  ST_CHK,                 stChk,  ST_ETX,
  stETX,  ST_ETX,                 stETX,  ST_STX
};


/* main para simular o uso da maquina de estados */
void handleRx(uint8_t *data, uint8_t qtd){
  uint8_t i;
  static uint8_t evento = 0;
  static uint8_t ActState = ST_STX;
  
  for(i = 0; i < qtd; i++){
    if (StateTable[ActState][evento].ptrFunc != NULL)
      evento = StateTable[ActState][evento].ptrFunc(data[i]);

    ActState = StateTable[ActState][evento].NextState;
  }
}

void fsm_ponteiro_teste(void){
  
  double time;
  clock begin = clock();

  uint8_t data1[] = { STX, 5, 11, 22, 33, 44 };
  uint8_t data2[] = { 55, 39, ETX };
  uint8_t resultado_esperado[] = {11, 22, 33, 44, 55};


  handleRx(data1, sizeof(data1));
  handleRx(data2, sizeof(data2));

  time = time_verification(begin);
  printf("\n\t\ttempo %d",time);

  if(memcmp(resultado_esperado,gv.buffer,sizeof(resultado_esperado)) == 0){
    printf("teste: PASSOU\n");
  }else{
    printf("teste: FALHOU\n");
  }
}