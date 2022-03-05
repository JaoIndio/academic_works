#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

// ================ DEFINES  ========================    ================ DEFINES  ========================   ================ DEFINES  ========================

#define INV_IP           "127.0.0.1"
#define INV_LISTENING    8080
// ================ GLOBAL VARIABLES ================   ================ GLOBAL VARIABLES ================    ================ GLOBAL VARIABLES ================
float       potencia;
float       voltage;
float       current;
float       temperature;
float       ref_lic;
float       total_pot = 0;
float       temp_lim  = 20;

int         VA_flag;
int         sockSndFD;

pthread_mutex_t sock_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t va_mutex = PTHREAD_MUTEX_INITIALIZER;
// ================ STRUCTS =========================    ================ STRUCTS ========================    ================ STRUCTS =========================

// ================ FUNCTIONS =======================   ================ FUNCTIONS =======================   ================ FUNCTIONS =======================

void read_buffer(char *answare, char *r_buffer, char *search_string){                                                               
  char aux1[256];                                                                                                                                                        
  

  bzero(aux1,sizeof(aux1));                                                                                                                                        
  strncpy(aux1, r_buffer, strlen(search_string));                                                                                                                        
  aux1[strlen(search_string)] = '\0';                                                                                                                                    
  
  if(strcmp(aux1, search_string)==0)                                                                                                                                     
    strcpy(answare, search_string);                                                                                                                                      
  else                                                                                                                                                                   
    strcpy(answare, "NOP");                                                                                                                                              
                                                                                                                                                                       
}

void printBuffer(char *buffer){
  char answare[256];
  char search[256];
  char *code_string[3];
  char buffer_cut[256];

  code_string[0]="TEMPERATURA_LIMITE: ";
  code_string[1]="CONSUMIR: ";
  code_string[2]="LER_VA: ";

  //printf("\n\t\t[ em printBuffer ]");
  for(int i=0; i<3; i++){
    strcpy(search, code_string[i]);
    read_buffer(&answare, buffer, &search);

    //printf("\n\n\t\t[answare] |%s|\n\t\t[ code_string ] |%s|\n\t\t[ buffer ] |%s|\n\n", answare, code_string[i], buffer);
    if(strcmp(answare, code_string[i]) ==0 ){
      strcpy(answare, &buffer[strlen(code_string[i])]);
      if(i == 0)
        printf("\n\t\t A temeperatura instantanea do painel eh de %s graus neste momento\n", answare);
      else if(i == 1)
        printf("\n\t\t A potencia total presente na bateria eh de %s W neste momento\n", answare);
      else{
        pthread_mutex_lock(&va_mutex);
          if(VA_flag == 1)
            printf("\n\t\t A tensao do painel eh de %s V neste momento\n", answare);
          else if(VA_flag == 0)
            printf("\n\t\t A corrente do painel eh de %s A neste momento\n", answare);
        pthread_mutex_unlock(&va_mutex);
      }
    }
  }
}

// ================ THREADS =========================    ================ THREADS =========================    ================ THREADS =======================ar=
//void *inv_comunication(void *arg){
//  char buffer[256];
//  int n;
//  //printf("\n\t\t Na thread inv_comunication");
//  while (1) {
//    bzero(buffer,sizeof(buffer)); 
//    n =1;
//    //pthread_mutex_lock(&sock_mutex);
//    //  n = recv(sockSndFD,buffer,50,0);
//    //pthread_mutex_unlock(&sock_mutex);
//    //printf("\n\t\t[ comunication result ] |%s|", buffer);
//    if (n <= 0) {                
//      //printf("Erro lendo do socket!\n");                                                                                                                                 
//      //exit(1);
//    }                                                                                                                                                                    
//    
//    //printf("MSG: %s",buffer);        
//  }   
//}

// ================ MAIN =====================    ================ MAIN =====================    ================ MAIN =====================
    
int main(){
    
  // ========   SOCKET CONFIG ==================    ========   SOCKET CONFIG ==================  ========   SOCKET CONFIG ==================

  //int                 sock_rcvFD;
  // monitor sera cliente de inversor
  int                 i;
  //int                 sockSndFD;
  int                 inv_port, n;
  struct sockaddr_in  inv_addr;    // referencia do inversor e painel
  pthread_t           thread_snd_Commands;
  socklen_t           inv_len;
  
  inv_port     = INV_LISTENING;
  
  pthread_mutex_lock(&sock_mutex);
    sockSndFD = socket(AF_INET, SOCK_STREAM, 0);
    printf("\n\t=== Valor de sockfd: %i  \n\n", sockSndFD);
  pthread_mutex_unlock(&sock_mutex);
  
  bzero((char *) &inv_addr, sizeof(inv_addr));
  
  // configuracoes do socket do inversor (snd)
  inv_addr.sin_family      = AF_INET;
  inet_aton(INV_IP, &inv_addr.sin_addr);
  inv_addr.sin_port        = htons(inv_port);

  int connect_r;

  printf("\n\t\t[ FAZENDO CONNECT ]");
  
  pthread_mutex_lock(&sock_mutex);
    printf("\n\t=== Valor de sockfd: %i  \n\n", sockSndFD);
    connect_r = connect(sockSndFD, 
                        (struct sockaddr *) &inv_addr, 
                        sizeof(inv_addr));
    
    printf("\n\t\t [ connect ] %i", connect_r);
  pthread_mutex_unlock(&sock_mutex);

  if (connect_r < 0) {  
    printf("\n\t\tErro fazendo connect! %i", connect_r);
  }
  
  // aqui threads de escrita e leitura ja podem ser criadas
  // cliente E servidor de inversor ja esta configurado
  
  // configuracao previa dos sinias periodicos
  
  //pthread_create(&thread_snd_Commands,  NULL, inv_comunication, NULL);
  //printf("\n\t\t*** [ THREAD 1: read_vars ]");
  
  //pthread_join(thread_snd_Commands,  NULL);

  char msg[256];
  char buffer[256];
  char answare[256];
  char search[256];

  do {                                                                                                                                                                   
    bzero(buffer,sizeof(buffer));                                                                                                                                        
    printf("\n\n\t\tDigite ler, configurar, ou sair:\t");                                                                                                         
    gets(buffer,50,stdin);
    printf("\n\t\t **** %s ****\n", buffer);
    
    if(strcmp(buffer, "ler") == 0){
      printf("\n\nVc quer ler qual variavel?\n\t\t*1. Potencia da Bateria,\n\t\t*2. Temperatura,\n\t\t*3. Variavies Eletricas.\t\t"); 

      gets(buffer,50,stdin);
      //printf("\n\t\t **** |%s| ****\n", buffer);
      
      pthread_mutex_lock(&sock_mutex);
        if(strcmp(buffer, "1") == 0){
          strcpy(msg,"|#|READ_DATA|#|CONSUMIR: ");
          send(sockSndFD, msg,50,0);
        }else if( (strcmp(buffer, "2") == 0)) {
          strcpy(msg,"|#|READ_DATA|#|TEMPERATURA_LIMITE: ");
          send(sockSndFD, msg,50,0);

        }else if( (strcmp(buffer, "3") == 0)) {
          strcpy(msg,"|#|READ_DATA|#|LER_VA: ");
          send(sockSndFD, msg,50,0);
        }

        //printf("\n\t\t **** sended msgm |%s| ****\n", msg);
        n = recv(sockSndFD,buffer,50,0);
      pthread_mutex_unlock(&sock_mutex);
    
      //n = recv(sockSndFD,buffer,50,0);
      printBuffer(&buffer);
      //printf("\n\t\t[ comunication result ] |%s|", buffer);

    }else if(strcmp(buffer, "configurar") == 0){
      printf("\n\nVc quer configurar qual variavel?\n\t\t1. Temperatura de Ativacao da Refrigeracao,");
      printf("\n\t\t2. Ler Corrente ou Tensao,");
      printf("\n\t\t3. Armazenar ou nao a energia,");
      printf("\n\t\t4. Consumir ou nao a energia da bateria\n\t\t");   
      gets(buffer,50,stdin);
      //printf("\n\t\t **** |%s| ****\n", buffer);

      pthread_mutex_lock(&sock_mutex);

        //printf("\n\t\t **** |%s| ****\n", buffer);
        if(strcmp(buffer, "1") == 0){
          strcpy(msg,"|#|WRITE_DATA|#|TEMPERATURA_LIMITE: ");
          printf("\nDigite valor da temperatura limite:   ");
          gets(buffer, 50, stdin);
          strcat(msg, buffer);
          send(sockSndFD, msg,50,0);
        
        }else if( (strcmp(buffer, "2") == 0)) {
          strcpy(msg,"|#|WRITE_DATA|#|LER_VA: ");
          printf("\nDigite 1 para ler tensao ou 0 para ler corrente:   ");
          gets(buffer, 50, stdin);
          strcat(msg, buffer);
          send(sockSndFD, msg,50,0);
          pthread_mutex_lock(&va_mutex);
            VA_flag = atoi(buffer);
          pthread_mutex_unlock(&va_mutex);

        }else if( (strcmp(buffer, "3") == 0)) {
          strcpy(msg,"|#|WRITE_DATA|#|ARMAZENAR: ");
          printf("\nDigite 1 para armazenar, do contrario digite 0:   ");
          gets(buffer, 50, stdin);
          strcat(msg, buffer);
          send(sockSndFD, msg,50,0);
        
        }else if( (strcmp(buffer, "4") == 0)) {
          strcpy(msg,"|#|WRITE_DATA|#|CONSUMIR: ");
          printf("\nDigite 1 para consumir, do contrario digite 0:   ");
          gets(buffer, 50, stdin);
          strcat(msg, buffer);
          send(sockSndFD, msg,50,0);
        }
      pthread_mutex_unlock(&sock_mutex);
        

    }else if (strcmp(buffer,"sair") == 0)
      break;

  }while (1);                                                                                                                                                           
   
  pthread_mutex_lock(&sock_mutex);
    close(sockSndFD);
  pthread_mutex_unlock(&sock_mutex);

return 0;
}
