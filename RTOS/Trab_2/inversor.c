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

//#define ELETRICAL_PERIOD 10000000 // 10 SEGUNDOS
//#define TEMP_PERIOD      11000000 // 11 SEGUNDOS

//   !!! [ PERIODOS ESTAO EM us ] !!!
#define READ_PERIOD    10000    // 0,5 SEGUNDOs
#define WRITE_PERIOD   50000    // 0,01 SEGUNDOs
#define BATTERY_PERIOD 50000   // 0,01 SEGUNDOs
#define MAX_CHARGE     50000

#define INV_IP           "127.0.0.1"
#define PNL_IP           "127.0.0.1"
#define INV_LISTENING    8080
#define PNL_LISTENING    8081
// ================ GLOBAL VARIABLES ================   ================ GLOBAL VARIABLES ================    ================ GLOBAL VARIABLES ================
float       potencia;
float       voltage;
float       current;
float       temperature;
float       total_pot = 0;

int         temp_lim  = 1000000;
int         consume_flag = 2;
int         charge_flag  = 2;
int         voltage_flag = 2;
int         threads_cond = 0;

int         sock_sndFD;

pthread_mutex_t eletrical_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t battery_mutex   = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t va_mutex        = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t consume_mutex   = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t charge_mutex    = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t temp_mutex      = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t temp_Lim_mutex  = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t sock_snd_mutex  = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t turn_mutex      = PTHREAD_MUTEX_INITIALIZER;

pthread_mutex_t va_cond         = PTHREAD_COND_INITIALIZER;
pthread_mutex_t turn_cond       = PTHREAD_COND_INITIALIZER;
// ================ STRUCTS =========================    ================ STRUCTS ========================    ================ STRUCTS =========================

struct periodic_info{
  int sig;
  sigset_t alarm_sig;
};

struct member_socket_infos{
  
  struct sockaddr_in data;
  socklen_t          len;
  int                sock_FD;
};

// ================ FUNCTIONS =======================   ================ FUNCTIONS =======================   ================ FUNCTIONS =======================

void read_buffer(char *answare, char *r_buffer, char *search_string){                                                               
  char aux1[256];                                                                                                                                                        
  strncpy(aux1, r_buffer, strlen(search_string));                                                                                                                        
  aux1[strlen(search_string)] = '\0';                                                                                                                                    
  if(strcmp(aux1, search_string)==0)                                                                                                                                     
    strcpy(answare, search_string);                                                                                                                                      
  else                                                                                                                                                                   
    strcpy(answare, "NOP");                                                                                                                                              
}

static int make_periodic (int unsigned period, struct periodic_info *info){

  struct itimerspec itval;  //               
  struct sigevent   sigev;  // Estrutura para notificacao de funcoes asincronas
  unsigned int      ns;
  unsigned int      sec;
  static int        next_sig;
  timer_t           timer_id;
  int               ret;

  // ASSOCIA 1 SINAL AO CONJUNTO Q IRA PERTENCER A THREAD
  //                            ====
  /* Initialise next_sig first time through. We can't use static
     initialisation because SIGRTMIN is a function call, not a constant */
  if (next_sig == 0)
    next_sig = SIGRTMIN;
  /* Check that we have not run out of signals */
  if (next_sig > SIGRTMAX)
    return -1;
  info->sig = next_sig;
  next_sig++;
  /* Create the signal mask that will be used in wait_period */
  sigemptyset (&(info->alarm_sig));
  sigaddset (&(info->alarm_sig), info->sig);
  // ASSOCIA 1 SINAL AO CONJUNTO Q IRA PERTENCER A THREAD
  //                            ====

   
  // ASSOCIA E CONFIGURA TIMER
  /* Create a timer that will generate the signal we have chosen */
  sigev.sigev_notify          = SIGEV_SIGNAL;  // açao: sinal q acorda
  sigev.sigev_signo           = info->sig;      // Indica qual sinal faz isso
  sigev.sigev_value.sival_ptr = (void *) &timer_id;
  
  // Define Clock e sinais associados ao timer
  ret = timer_create(CLOCK_MONOTONIC, &sigev, &timer_id);
  if (ret == -1)
    return ret;

  /* Make the timer periodic 
        period eh em [ us ]
  */
  sec = period/1000000;
  ns = (period - (sec * 1000000)) * 1000;
  // Duracao do timer
  itval.it_interval.tv_sec  = sec;
  itval.it_interval.tv_nsec = ns;
  
  // Insntante em q o timer vai começar a contar
  itval.it_value.tv_sec  = sec;  
  itval.it_value.tv_nsec = ns;
  ret = timer_settime (timer_id, 0, &itval, NULL);
  return ret;
}

static void wait_period(struct periodic_info *info){
  int sig;
  sigwait(&(info->alarm_sig), &sig);
}

void battery_charge(float value){

  pthread_mutex_lock(&battery_mutex);
  pthread_mutex_lock(&charge_mutex);
    
    if(charge_flag == 1){
      if( (total_pot + value) < MAX_CHARGE ){
        total_pot+=value;
      }
    }

  pthread_mutex_unlock(&charge_mutex);
  pthread_mutex_unlock(&battery_mutex);
}

// ================ THREADS =========================    ================ THREADS =========================    ================ THREADS =======================ar=
void *read_vars(void *arg){
  
  int                  i       = 0;
  int                  n;
    
  // 1. Configura timer
  struct periodic_info periodic_read;
  make_periodic(READ_PERIOD, &periodic_read);

  char *values_to_read[4];
  char rcv_buffer[256];
  char search_var[256];
  char answare[256];
  
  float *variables[4];

  // 2. Armazena as referencias das variaveis que receberao os valores das respostas do socket
  pthread_mutex_lock(&eletrical_mutex);
    variables[0] = &voltage;
    variables[1] = &current;
    variables[2] = &potencia;
  pthread_mutex_unlock(&eletrical_mutex);
  
  pthread_mutex_unlock(&temp_mutex);
    variables[3] = &temperature;
  pthread_mutex_unlock(&temp_mutex);

  // 3. Define strings dos nomes das requisicoes
  values_to_read[0] = "|#|READ_DATA|#|TENSAO: ";
  values_to_read[1] = "|#|READ_DATA|#|CORRENTE: ";
  values_to_read[2] = "|#|READ_DATA|#|POTENCIA: ";
  values_to_read[3] = "|#|READ_DATA|#|TEMPERATURA: ";
  
  FILE *file_vars, *voltage_file,
       *pot_file    , *temp_file;

  FILE *file_var[4];
  char *file_path[4];

  // 4. Registra nomes dos arquivos de debug
  file_path[0] = "../data/InvVoltage.txt";
  file_path[1] = "../data/InvCurrent.txt";
  file_path[2] = "../data/InvPot.txt";
  file_path[3] = "../data/InvTemp.txt";

  float value;
  int j,z;
  while(1){
    
    // variavel de condicao
    pthread_mutex_lock(&turn_mutex);
      while(threads_cond != 0){
        pthread_cond_wait(&turn_cond, &turn_mutex);
      }
      threads_cond = 1;
      for(z =0; z<4; z++){
        pthread_mutex_lock(&sock_snd_mutex);
          // 5. Encaminha requisiacao de leitura de variavel
          send(sock_sndFD, values_to_read[z], 50, 0);
          // 6. Aguarda resposta
          recv(sock_sndFD, rcv_buffer, 50, 0);
        pthread_mutex_unlock(&sock_snd_mutex);

        // 7. Descobre qual requisicao foi respondida
        for(j=0; j<4; j++){
          
          strcpy(search_var, &values_to_read[j][15]);
          read_buffer(&answare, &rcv_buffer, &search_var);
          
          if(strcmp(search_var, answare)==0){

            // 8. Abre arquivo associado a variavel respondida
            file_vars = fopen(file_path[j], "a");

            if(j!=3) pthread_mutex_lock(&eletrical_mutex);
            else     pthread_mutex_lock(&temp_mutex);
              
              // 9. Acessa valor
              strcpy(answare, &rcv_buffer[strlen(search_var)]);
              value = atof(answare);

              // 10. Caso o nome seja de potencia, encaminha valor para possivel carga
              if(strcmp(search_var, "POTENCIA: ") == 0 ) battery_charge(value);
              
              // 11. Verifica se nome eh tensao
              if (strcmp(search_var, "TENSAO: ") == 0){ 
                  
                pthread_mutex_lock(&va_mutex);
                  if(voltage_flag == 1){
                    
                    // 13. Armazena valor de tensao na variavel e no arquivo
                    **(variables+j) = value;
                    fprintf(file_vars,     "%f\n", value);
                  }
                pthread_mutex_unlock(&va_mutex);
                
              }else if(strcmp(search_var, "CORRENTE: ") == 0){
                 
                pthread_mutex_lock(&va_mutex);
                if(voltage_flag == 0){
                  
                  // 17. Armazena valor de corrente na variavel e no arquivo
                  **(variables+j) = value;
                  fprintf(file_vars,     "%f\n", value);
                }
                pthread_mutex_unlock(&va_mutex);
                
              }else{
                
                // 19. Armazena valor de temperatura ou potencia na variavel e no arquivo
                **(variables+j) = value;
                fprintf(file_vars,     "%f\n", value);
              }

            if(j!=3) pthread_mutex_unlock(&eletrical_mutex);
            else     pthread_mutex_unlock(&temp_mutex);
            
            fclose(file_vars);
            
            break;
          }
        }
        wait_period(&periodic_read);
      }
      pthread_cond_broadcast(&turn_cond);
    pthread_mutex_unlock(&turn_mutex);

    // 21. Volta ao passo 5
  }
}

void *write_refr_value(void *arg){
  
  struct inv_socket_infos *inv_ref;
  inv_ref  = arg;
  char msg[256];
  char refr_char[256];
  int n;

  float read_temp, refr_value;
  
  // 1. Configura timer
  struct periodic_info periodic_write;
  make_periodic(WRITE_PERIOD, &periodic_write);
  
  printf("\n\t\t |||[ FINALIZOU INICIALIZACAO DE WRITE REFRI ]");
  while(1){
    
    // variavel de condicao
    pthread_mutex_lock(&turn_mutex);
      while(threads_cond != 1){
        pthread_cond_wait(&turn_cond, &turn_mutex);
      }
      threads_cond = 2;

      // 2 e 3. Acessa tempratura atual e temperatura limite
      pthread_mutex_lock(&temp_mutex);
        read_temp = temperature;
      pthread_mutex_unlock(&temp_mutex);
      
      pthread_mutex_lock(&temp_Lim_mutex);
        // 4. Calcula valor da refrigeracao
        if(read_temp > temp_lim) 
          refr_value = 4*(read_temp - temp_lim);
        else
          refr_value = 0;

      pthread_mutex_unlock(&temp_Lim_mutex);
   
      // 5. Estrutura mensagem para escrever valor calculado
      gcvt(refr_value, 9, refr_char);
      strcpy(msg, "|#|WRITE_refr|#|");
      strcat(msg, refr_char);
      
      // 6. Faz requisicao de escrita no painel
      pthread_mutex_lock(&sock_snd_mutex);
        send(sock_sndFD, msg, 50, 0);
      pthread_mutex_unlock(&sock_snd_mutex);
      
      wait_period(&periodic_write);
      pthread_cond_broadcast(&turn_cond);
    pthread_mutex_unlock(&turn_mutex);

    // 7. Volta ao passo 2

  }
}

void *battery_consumer(void *arg){
  
  // 1. Configura timer
  struct periodic_info periodic_consumer;
  make_periodic(BATTERY_PERIOD, &periodic_consumer);

  // 2. Inicializa valor de consumo
  float consumer_factor = 2.5;

  while(1){
    
    pthread_mutex_lock(&turn_mutex);
      while(threads_cond != 2){
        pthread_cond_wait(&turn_cond, &turn_mutex);
      }
      threads_cond = 0;
      
      // 3 e 4. Acessa flag e potencia total
      pthread_mutex_lock(&consume_mutex);
      pthread_mutex_lock(&battery_mutex);
        
        if(consume_flag == 1){
          if( (total_pot - consumer_factor) > 0 ){
            // 6. Decrementa potencia total
            total_pot-=consumer_factor;
          }
        }

      // 7. Aguarda sinal do cronometro
      wait_period(&periodic_consumer);

      // 8. Libera recursos criticos
      pthread_mutex_unlock(&battery_mutex);
      pthread_mutex_unlock(&consume_mutex);
      pthread_cond_broadcast(&turn_cond);
    pthread_mutex_unlock(&turn_mutex);

    // 9. Volta ao passo 3
  }
  
}

void *inv_commands(void *arg){
  // recebe comando de CONSUMIR e ARMAZENAR
  
  struct member_socket_infos *mnt_ref;
  mnt_ref = arg;
  
  char buffer[256];
  char buffer_cut[256];
  char answare[256];
  int mnt_fd;
  int n, z;

  char conv_int[256];
  char message [256];
  char msg[256];

  char  *wr_string[4];
  char  *rd_string[4];
  int   *wr_variables[4];
  float *rd_variables[4];


  printf("\n\t\t||||| [ COMECANDO INV_COMMANDS ]");
  // 1. Armazena referencia das variaveis que serao escritas
  pthread_mutex_lock(&consume_mutex);
    wr_variables[0] = &consume_flag;
  pthread_mutex_unlock(&consume_mutex);
    
  pthread_mutex_lock(&charge_mutex);
    wr_variables[1] = &charge_flag;
  pthread_mutex_unlock(&charge_mutex);
    
  pthread_mutex_lock(&va_mutex);
    wr_variables[2] = &voltage_flag;
  pthread_mutex_unlock(&va_mutex);

  pthread_mutex_lock(&temp_Lim_mutex);
    wr_variables[3] = &temp_lim;
  pthread_mutex_unlock(&temp_Lim_mutex);
  
  // 2. Armazena referencia das variaveis que serao lidas
  pthread_mutex_lock(&eletrical_mutex);
    rd_variables[0] = &voltage;
    rd_variables[1] = &current;
  pthread_mutex_unlock(&eletrical_mutex);
  
  pthread_mutex_lock(&battery_mutex);
    rd_variables[2] = &total_pot;
  pthread_mutex_unlock(&battery_mutex);
  
  pthread_mutex_lock(&temp_mutex);
    rd_variables[3] = &temperature;
  pthread_mutex_unlock(&temp_mutex);

  //  3. Define strings dos nomes que serao usados nas leituras e escritas
  wr_string[0] = "CONSUMIR: ";
  wr_string[1] = "ARMAZENAR: ";
  wr_string[2] = "LER_VA: ";
  wr_string[3] = "TEMPERATURA_LIMITE: "; 
  
  rd_string[0] = "LER_VA: ";
  rd_string[1] = "LER_VA: ";
  rd_string[2] = "CONSUMIR: ";
  rd_string[3] = "TEMPERATURA_LIMITE: ";

  printf("\n\t\t||||| [ TERMINOU INICIALIZACAO INV_COMMANDS ]");         

  // 4. Aguarda requisicao de conexao
  mnt_fd = accept(mnt_ref->sock_FD,(struct sockaddr *) &(mnt_ref->data), &(mnt_ref->len) );
  printf("\n\t\t||||| [ INV_COMMANDS SE CONECTOU ]");                       
  char search[256];
  while(1){

    // 5. Aguarda requisicao de dados
    n      = read(mnt_fd, buffer, 50);

    strcpy(search, "|#|WRITE_DATA|#|");
    read_buffer(&answare, &buffer, &search);
    
    // 6. Descobre se requisicao eh de escrita ou leitura
    if(strcmp(answare, "|#|WRITE_DATA|#|") == 0){
      
      // 8. Desreferencia variavel adequada
      for(int i=0; i<4; i++ ){
        strcpy(search, wr_string[i]);
        strcpy(buffer_cut, &buffer[16]);
        read_buffer(&answare, &buffer_cut, &search);
        
        if(strcmp(answare, wr_string[i]) == 0){
          strcpy(answare, &buffer_cut[strlen(wr_string[i])]);
          int command = atoi(answare);
          
          printf("var %s = %i", answare, command);
          if( strcmp(wr_string[i],"CONSUMIR: ")    == 0) pthread_mutex_lock(&consume_mutex);
          if( strcmp(wr_string[i],"ARMAZENAR: ")   == 0) pthread_mutex_lock(&charge_mutex);
          if( strcmp(wr_string[i],"LER_VA: ")      == 0) pthread_mutex_lock(&va_mutex);
          if( strcmp(wr_string[i],"TEMPERATURA: ") == 0) pthread_mutex_lock(&temp_Lim_mutex);
            
            // 8.2 Atrbui valor contido no buffer
            *(wr_variables[i]) = command;
        
          if( strcmp(wr_string[i],"TEMPERATURA: ") == 0) pthread_mutex_unlock(&temp_Lim_mutex);
          if( strcmp(wr_string[i],"CONSUMIR: ")    == 0) pthread_mutex_unlock(&consume_mutex);
          if( strcmp(wr_string[i],"ARMAZENAR: ")   == 0) pthread_mutex_unlock(&charge_mutex);
          if( strcmp(wr_string[i],"LER_VA: ")      == 0) pthread_mutex_unlock(&va_mutex);
        
          break;
        }
      }
    }else{
      strcpy(search, "|#|READ_DATA|#|");
      read_buffer(&answare, &buffer, &search);
        
      if(strcmp(answare, "|#|READ_DATA|#|") == 0){
      
        // 10. Descobre nome do recurso que monitor deseja conhecer
        for(int i=0; i<4; i++ ){
          strcpy(search, rd_string[i]);
          strcpy(buffer_cut, &buffer[15]);
          read_buffer(&answare, &buffer_cut, &search);
          
          if(strcmp(answare, rd_string[i]) == 0) {
            strcpy(conv_int, " ");
            strcpy(message, rd_string[i]);

            if( strcmp(rd_string[i],"TEMPERATURA_LIMITE: ") == 0) pthread_mutex_lock(&temp_Lim_mutex);
            if( strcmp(rd_string[i],"CONSUMIR: ")           == 0) pthread_mutex_lock(&battery_mutex);
            if( strcmp(rd_string[i],"LER_VA: ")             == 0) pthread_mutex_lock(&va_mutex);
  
              // 11. Desreferencia valor da variavel e escreve no buffer
              if (strcmp(rd_string[i], "LER_VA: ") == 0){ 
                if(voltage_flag == 1)
                  gcvt(*rd_variables[0], 9, conv_int);
                else
                  gcvt(*rd_variables[1], 9, conv_int);
                
              }else
                gcvt(*rd_variables[i], 9, conv_int);
            
            if( strcmp(rd_string[i],"TEMPERATURA_LIMITE: ") == 0) pthread_mutex_unlock(&temp_Lim_mutex);
            if( strcmp(rd_string[i],"CONSUMIR: ")           == 0) pthread_mutex_unlock(&battery_mutex);
            if( strcmp(rd_string[i],"LER_VA: ")             == 0) pthread_mutex_unlock(&va_mutex);
            
            // 12. Concatena nome do recurso requisitado e seu respectivo valor
            strcat(message, conv_int);
            // 13. Encaminha mensasgem para monitor
            write(mnt_fd, message, 50);
            break;
          }
        }
      }
    } 
  }
}

// ================ MAIN =====================    ================ MAIN =====================    ================ MAIN =====================
    
int main(){
    
  // ========   SOCKET CONFIG ==================    ========   SOCKET CONFIG ==================  ========   SOCKET CONFIG ==================

  // 1 e 2. Configura socket cliente e socket servidor
  int                 i;
  int                 sock_rcvFD;
  int                 inv_port, pnl_port, n;
  struct sockaddr_in  inv_addr, pnl_addr, mnt_addr;    // referencia do inversor e painel
  pthread_t           thread_snd_Read, thread_snd_Write, threads_rcv, threads_rcv2;
  socklen_t           inv_len,  pnl_len, mnt_len;
  
  inv_port     = INV_LISTENING;
  pnl_port     = PNL_LISTENING;
  
  pthread_mutex_lock(&sock_snd_mutex);
    sock_sndFD = socket(AF_INET, SOCK_STREAM, 0);
  pthread_mutex_unlock(&sock_snd_mutex);

  sock_rcvFD = socket(AF_INET, SOCK_STREAM, 0);
   
  printf("\n\t=== Valor de sockfd: %i  \n\n", sock_rcvFD);

  bzero((char *) &pnl_addr, sizeof(pnl_addr));
  bzero((char *) &inv_addr, sizeof(inv_addr));
  
  // configuracoes do socket do painel (snd)
  pnl_addr.sin_family      = AF_INET;
  pnl_addr.sin_port        = htons(pnl_port);
  inet_aton(PNL_IP, &pnl_addr.sin_addr);

  // configuracoes do socket do inversor (rcv)
  inv_addr.sin_family      = AF_INET;
  inv_addr.sin_addr.s_addr = INADDR_ANY;
  inv_addr.sin_port        = htons(inv_port);

  int connect_r;

  printf("\n\t\t[ FAZENDO CONNECT ]");
  pthread_mutex_lock(&sock_snd_mutex);

    connect_r = connect(sock_sndFD, 
                        (struct sockaddr *) &pnl_addr, 
                        sizeof(pnl_addr)); 
  
  pthread_mutex_unlock(&sock_snd_mutex);
      
  if (connect_r < 0) {  
    printf("\n\t\tErro fazendo connect! %i", connect_r);
    //return -1;
  }
  
  int bind_r;
  bind_r = bind(sock_rcvFD, 
                (struct sockaddr *) &inv_addr, 
                sizeof(inv_addr)); 

  if (bind_r < 0) {
      printf("\n\t\tErro fazendo bind! %i", bind_r);
    //return -1;
  }
  // inversor soh sera capaz de ouvir da maquina monitor
  listen(sock_rcvFD, 2);
  
  struct member_socket_infos mnt_datas;
  mnt_datas.data      = mnt_addr;
  mnt_datas.len       = mnt_len;
  mnt_datas.sock_FD = sock_rcvFD;

  struct member_socket_infos pnl_datas;
  pnl_datas.data      = pnl_addr;
  pnl_datas.len       = pnl_len;
  
  pthread_mutex_lock(&sock_snd_mutex);
    pnl_datas.sock_FD = sock_sndFD;
  pthread_mutex_unlock(&sock_snd_mutex);
  
  // aqui threads de escrita e leitura ja podem ser criadas
  // cliente E servidor de inversor ja esta configurado
  
  // 3. Configuracao previa dos sinias periodicos
  sigset_t alarm_sig;

  sigemptyset (&alarm_sig);
  for (i = SIGRTMIN; i <= SIGRTMAX; i++)
    sigaddset (&alarm_sig, i);
  sigprocmask (SIG_BLOCK, &alarm_sig, NULL);
  
  // 4. Cria ou abre arquivos de debug
  FILE *current_file, *voltage_file,                                                                                                                                     
       *pot_file    , *temp_file;                                                                                                                                       
                                                                                                                                                                       
  current_file = fopen("../data/InvCurrent.txt", "w");                                                                                                                  
  voltage_file = fopen("../data/InvVoltage.txt", "w");                                                                                                                
  temp_file    = fopen("../data/InvTemp.txt",    "w");                                                                                                                
  pot_file     = fopen("../data/InvPot.txt",     "w");                                                                                                         
                                                                                                                                                                      // 5. Fecha arquivos 
  fclose(current_file);                                                                                                                                                  
  fclose(voltage_file);                                                                                                                                                  
  fclose(temp_file);                                                                                                                                                    
  fclose(pot_file);

  // 6. Cria todas as threads
  pthread_create(&threads_rcv2,     NULL, inv_commands,     (void*)&mnt_datas);
  printf("\n\t\t*** [ THREAD 1: inv_commands ]");
  
  pthread_create(&thread_snd_Read,  NULL, read_vars,        (void*)&pnl_datas);
  printf("\n\t\t*** [ THREAD 2: read_vars ]");
  
  pthread_create(&thread_snd_Write, NULL, write_refr_value, (void*)&pnl_datas);
  printf("\n\t\t*** [ THREAD 3: write_refr ]");
  
  pthread_create(&threads_rcv,      NULL, battery_consumer, (void*)&mnt_datas);
  printf("\n\t\t*** [ THREAD 4: battery_consumer ]");
  
  // 7. Faz join() de todas as threads
  pthread_join(thread_snd_Read,  NULL);
  pthread_join(thread_snd_Write, NULL);
  pthread_join(threads_rcv,      NULL);
  pthread_join(threads_rcv2,     NULL);

  // 8. Fecha socket cliente
  pthread_mutex_lock(&sock_snd_mutex);
    close(sock_sndFD);
  pthread_mutex_unlock(&sock_snd_mutex);

}
