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

//#define ELETRICAL_PERIOD 10 000 000 // 10 SEGUNDOS
//#define TEMP_PERIOD      11 000 000 // 11 SEGUNDOS

//   !!! [ PERIODOS ESTAO EM us ] !!!
#define ELETRICAL_PERIOD 50000    // 0,05 SEGUNDOs
#define RCV_PERIOD       1000      // 0,006 SEGUNDOs
#define TEMP_PERIOD      5000   // 0,03 SEGUNDOs

#define INV_IP           "127.0.0.1"
#define PNL_IP           "127.0.0.1"
#define INV_LISTENING    8080
#define PNL_LISTENING    8081
// ================ GLOBAL VARIABLES ================   ================ GLOBAL VARIABLES ================    ================ GLOBAL VARIABLES ================
float       potencia;
float       voltage;
float       current;
float       temperature;
int         ref_lic;


pthread_mutex_t eletrical_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t temp_mutex      = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t sock_rcv_mutex  = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t ref_lic_mutex   = PTHREAD_MUTEX_INITIALIZER;
// ================ STRUCTS =========================    ================ STRUCTS ========================    ================ STRUCTS =========================

struct periodic_info{
  int sig;
  sigset_t alarm_sig;
};

struct inv_socket_infos{
  
  struct sockaddr_in inv_data;
  socklen_t          inv_Len;
  int                sock_rcv_FD;
};

// ================ FUNCTIONS =======================   ================ FUNCTIONS =======================   ================ FUNCTIONS =======================
void read_buffer(char *answare, char *r_buffer, char *search_string){
  char aux1[256];

  strncpy(aux1, r_buffer, strlen(search_string));
  aux1[strlen(search_string)] = '\0';

  if(strcmp(aux1, search_string)==0){
    strcpy(answare, search_string);
    answare[strlen(search_string)] = '\0';
  }else
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
  sigev.sigev_notify = SIGEV_SIGNAL;  // açao: sinal q acorda
  sigev.sigev_signo = info->sig;      // Indica qual sinal faz isso
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
  itval.it_interval.tv_sec = sec;
  itval.it_interval.tv_nsec = ns;
  
  // Insntante em q o timer vai começar a contar
  itval.it_value.tv_sec = sec;  
  itval.it_value.tv_nsec = ns;
  ret = timer_settime (timer_id, 0, &itval, NULL);
  return ret;
}

static void wait_period(struct periodic_info *info){
  int sig;
  sigwait(&(info->alarm_sig), &sig);
}

// ================ THREADS =========================    ================ THREADS =========================    ================ THREADS =========================

// temperatura varia de acordo com o horario, com a poten-
//   cia produzida e o liquido de refrigeracao
void *temperatura(void *arg){
  
  /*  A temperatura aumenta das 7hrs ate as 13hrs
        dps disso ela comeca a rebaixar de modo 
        que reducer_factor tenta fazer com q:
          * temp as 14hrs = temp as 12hrs;
          * temp as 15hrs = temp as 11hrs;
          * temp as 16hrs = temp as 10hrs;
             ........
  */
  int                  i       = 0;
  int                  n;
  int                  min     = 0;
  int                  hra     = 0;
  int                  reducer_factor;
  
  float                temp;
  float                inc;
  long double          pot;
  int                  ref_lic_local = 50;     // nao tera valor fixo no futuro
  
  // 1. Configura timer
  struct periodic_info periodic_temp;
  make_periodic(TEMP_PERIOD, &periodic_temp);

  // 2. Abre ou cria arquivo de temperatura
  FILE *Temp_file;
  Temp_file = fopen("../data/temp.txt", "w");
  fclose(Temp_file);
  
  char message[]  = "tensao===========================================";
  char conv_int[] = "1234============================================="; 
  // sao necessario 780 min pra se chegar as 13 hrs
  while(1){
    
    // 3. Aguarda sinal do timer
    wait_period(&periodic_temp);  
    Temp_file = fopen("../data/temp.txt", "a");
    
    // SEMAFARO
    // 4. le valor de potencia e refrigeracao
    pthread_mutex_lock(&eletrical_mutex);
      pot = potencia;
    pthread_mutex_unlock(&eletrical_mutex);


    pthread_mutex_lock(&ref_lic_mutex);
      ref_lic_local = ref_lic;
    pthread_mutex_unlock(&ref_lic_mutex);
    /* Este aumento e reducao sao apenas esbosos
         isso pq a reducao e o aumento serao ade-
         quandos no momento que ref_lic tiver va-
         lores variaveis.
    */
    // 5. Define se deve incrementar ou decrementar temperatura
    if( (7 < hra) && (hra < 14) ){
      
      inc = ((pot + hra) - ref_lic_local)/1000;
      temp += inc;
      reducer_factor = 2;
    }
    else if( (hra <=7) || (hra>=14) ){
      if(hra >=14){
        if(temp > -5){
          inc   = (( pot + (hra-reducer_factor) + ref_lic_local ))/1000000;
          temp -= inc;
          reducer_factor+=2;
        }
      
      }else
        if(temp > -5)
          inc   = (( pot + (hra) + ref_lic_local ))/1000000;
          temp -= inc;
    }

    // seta hora e min
    // 6. Aumenta minuto em 1
    min++;
    // 7. Verifica se minuto e hora devem ser setados
    if(min >= 60){
      min = 0;
      hra++;
    }
    if(hra == 24) hra = 0;
    
    // 8. Escreve valor da temperatura calculada no arquivo txt
    fprintf(Temp_file, "%f\n", temp);
    fclose(Temp_file);
      
    // 9. Atualiza valor da temperatura global
    pthread_mutex_lock(&temp_mutex);
      temperature = temp;
    pthread_mutex_unlock(&temp_mutex);
  
    // 10. Volta ao passo 3
  }
}



void *receive_info(void *arg){
  
  struct inv_socket_infos *inv_ref;
  inv_ref  = arg;
  char buffer[256];
  char answare[256];
  int inv_fd;
  int n, z;

  char conv_int[256];
  char message [256];
  char msg[256];
  char buffer_cut[256];

  char *code_string[4];
  float *variables[4];

  // 1. Armazena referencia das variaveis fisicas
  pthread_mutex_lock(&eletrical_mutex);
    variables[0] = &voltage;
    variables[1] = &current;
    variables[2] = &potencia;
  pthread_mutex_unlock(&eletrical_mutex);
  
  pthread_mutex_unlock(&temp_mutex);
    variables[3] = &temperature;
  pthread_mutex_unlock(&temp_mutex);
  
  // 2. Define sting associada a cada variavel
  code_string[0] = "TENSAO: ";
  code_string[1] = "CORRENTE: ";
  code_string[2] = "POTENCIA: ";
  code_string[3] = "TEMPERATURA: ";

  struct periodic_info periodic_rcv;
  make_periodic(RCV_PERIOD, &periodic_rcv);

  // 3. Aguarda requisicao de conexao
  inv_fd = accept(inv_ref->sock_rcv_FD,(struct sockaddr *) &(inv_ref->inv_data), &(inv_ref->inv_Len) );
  while(1){
    
    // 4. Aguarda requisicao de dados
    n      = read(inv_fd, buffer, 50);
    char search[] = "|#|WRITE_refr|#|";
    read_buffer(&answare, &buffer, &search);
    /* painel verifica se deve modificar variavel
         de refrigeracao ou se deve informar
         valores de medicao.
    */
    // 5. Descobre se requisicao eh de leitura ou escrita
    if(strcmp(answare,"|#|WRITE_refr|#|")==0){
      
      // 6. Modofica valor de refregeracao
      strcpy(msg, &buffer[16]);
      pthread_mutex_lock(&ref_lic_mutex);
        ref_lic = atoi(msg); 
      pthread_mutex_unlock(&ref_lic_mutex);
    
    }else{
      strcpy(search, "|#|READ_DATA|#|");
      read_buffer(&answare, &buffer, &search);
      if(strcmp(answare,"|#|READ_DATA|#|")==0){
        
        for(z=0; z<4; z++){
          
          // 7. Descobre qual variavel o inversor quer receber
          strcpy(search, code_string[z]);
          strcpy(buffer_cut, &buffer[15]);

          read_buffer(&answare, &buffer_cut, &search);
          
          n = strcmp(code_string[z], answare);

          strcpy(conv_int, " "); //, sizeof(conv_int));
          strcpy(message,  code_string[z]);
          if(strcmp(code_string[z], "TEMPERATURA: ") == 0) pthread_mutex_lock(&temp_mutex);
          else                                             pthread_mutex_lock(&eletrical_mutex);    
          
            gcvt(*variables[z], 9, conv_int);
          
          if(strcmp(code_string[z],"TEMPERATURA: ") == 0) pthread_mutex_unlock(&temp_mutex);
          else                                            pthread_mutex_unlock(&eletrical_mutex);
          
          // 8. Cra mensagem do tipo "nome_da_variavel: valor_da_variavel"
          strcat(message, conv_int); // message+=conv_int;
          if(n == 0){
            // 9. Envia mensagem ao inversor
            write(inv_fd, message,     50);
            break;
          }
        }
      }
      // Volta ao passo 4
    }
  }
}

// ================ MAIN =====================    ================ MAIN =====================    ================ MAIN =====================
    
int main(){
    
  // ========   SOCKET CONFIG ==================    ========   SOCKET CONFIG ==================  ========   SOCKET CONFIG ==================

  // 1. Configuracao de Socket
  int                 sock_rcvFD;
  int                 inv_port, pnl_port, n;
  struct sockaddr_in  inv_addr, pnl_addr;    // referencia do inversor e painel
  pthread_t           thread_rcv;
  socklen_t           inv_len;
  
  pnl_port     = PNL_LISTENING;
  
   
  sock_rcvFD = socket(AF_INET, SOCK_STREAM, 0);
  printf("\n\t=== Valor de sockfd: %i  \n\n", sock_rcvFD);

  bzero((char *) &pnl_addr, sizeof(pnl_addr));
  
  // configuracoes do socket do painel (rcv)
  pnl_addr.sin_family      = AF_INET;
  pnl_addr.sin_addr.s_addr = INADDR_ANY;
  pnl_addr.sin_port        = htons(pnl_port);

  int bind_r =1;
  printf("\n\t\t vai FAZER BIND");
  bind_r = bind(sock_rcvFD, (struct sockaddr *) &pnl_addr, sizeof(pnl_addr)); 
  printf("\n\t\t bind: %i", bind_r);
  if (bind_r < 0) {
    printf("\n\t\tErro fazendo bind! %i", bind_r);
  }
  
  // painel soh sera capaz de ouvir de 1 maquina distinta
  listen(sock_rcvFD, 2);
  printf("\n\t\t CRIOU SOCKET");
  
  struct inv_socket_infos inv_datas;
  inv_datas.inv_data    = inv_addr;
  inv_datas.inv_Len     = inv_len;
  inv_datas.sock_rcv_FD = sock_rcvFD;


  // ============ SOCKET MESSAGES ================
  char conv_int[] = "1234===========================================";
  char message [] = " TENSAO: ======================================";


  // ============ ELETRICAL VARIABLES ============   ============ ELETRICAL VARIABLES ============   ============ ELETRICAL VARIABLES ============
  pthread_t thread_temp;
  sigset_t  alarm_sig;
  
  struct periodic_info periodic_eletric_vars;

  int   grow_flag   = 1;
  int   grow_factor = -2; 
  int   i;
  float tensao, corrente, var_gauss = -1;
  float pot;

  // 2. Definicao de arquivos
  FILE *current_file, *voltage_file,
       *pot_file    , *gauss_file;
  
  current_file = fopen("../data/current.txt", "w");
  voltage_file = fopen("../data/voltage.txt", "w");
  gauss_file   = fopen("../data/gauss.txt",   "w");
  pot_file     = fopen("../data/pot.txt",     "w");
  
  fclose(current_file);
  fclose(voltage_file);
  fclose(gauss_file);
  fclose(pot_file);


  printf("\n\t\t CRIOU ARQUIVOS");
  
    /* Block all real time signals so they can be used for the timers.
        Note: this has to be done in main() before any threads are created
        so they all inherit the same mask. Doing it later is subject to
        race conditions */

  // 3. Configuracao previa do conjunto de sinais
  sigemptyset (&alarm_sig);
  for (i = SIGRTMIN; i <= SIGRTMAX; i++)
    // add todos os sinais de tempo real ao conjunto de sinais do processo
    // Ou seja, todos os sinias de tempo real do SO serao transparentes ao
    // processo
    sigaddset (&alarm_sig, i);
  
  sigprocmask (SIG_BLOCK, &alarm_sig, NULL);
  
  // 4. Cria threads
  pthread_create(&thread_temp, NULL, temperatura,  NULL);
  pthread_create(&thread_rcv,  NULL, receive_info, (void *)&inv_datas );
  printf("\n\t\t CRIOU THREAD TEMP");
  
  // 5. Configura timer
  make_periodic(ELETRICAL_PERIOD, &periodic_eletric_vars);
    /* !!!!talvez vale a pena calcular to-
         das as variaveis fisicas em um lo-
         op infinito na main !!!!

        # Na thread temperatura, temp espera sinal 
    */

  // 6. Parametros de incremento da curva gaussiana
  int x = 0;
  float rad         = 0;
  float cos_value   = 0;
  float micro_conv  = 1000000;

  int final   = 1;
  int inicial = -1;

  /* 780, pq sao necessario 780 min pra se chegar ate 13hrs
       o incremento eh tal que tem seu valor maximo as 13hrs,
       apos esse valor se inicia o decremento, ate q o ponto
       em que var_gauss <= -1, para q o processo se inicie, 
       com var_gauss aumentando novamente.

     Basicamente:

        eletric_increment = (ponto_final - ponto_inicial)/(ciclos necessarios para se chegar ate as 13hrs)
  */
  long double eletric_increment = (final - inicial)/( ((TEMP_PERIOD/micro_conv)*780)/(ELETRICAL_PERIOD/micro_conv) );
  
  while(1){
    
    // 7. Aguarda sinal do timer.
    wait_period(&periodic_eletric_vars);
 
    // 8. Abre arquivos das variaveis eletricas
    current_file = fopen("../data/current.txt", "a");
    voltage_file = fopen("../data/voltage.txt", "a");
    pot_file     = fopen("../data/pot.txt",     "a");
    gauss_file   = fopen("../data/gauss.txt",   "a");

    // 9. Incrementa ou decrementa curva "gaussiana"
    if( (var_gauss < 1) && (grow_flag == 1) ){
      var_gauss+=eletric_increment;
    }else{
      var_gauss-=eletric_increment;
      grow_flag = 0;
    }
  
    if(var_gauss <= -1) grow_flag = 1;
    
    /* 
      A potencia gerada por um painel fotovoltaico eh
        do tipo CC, portanto a variacao cosseno serve
        para simular os picos de producao.
    */
    // 10. Calcula corrente, tensao e potencia
    if(var_gauss > 0){
      corrente = var_gauss*5;
      tensao   = var_gauss*10;
    }else{
      corrente = var_gauss*(-0.005);
      tensao   = var_gauss*(-0.01);
    }

    // SEMAFORO
    // 11. Escrve valores em arquivos
    pthread_mutex_lock(&eletrical_mutex);
      potencia = tensao*corrente;
      pot      = potencia;
      voltage  = tensao;
      current  = corrente;
      fprintf(pot_file,   "%f\n", potencia);
    pthread_mutex_unlock(&eletrical_mutex);
    
    fprintf(current_file, "%f\n", corrente);
    fprintf(voltage_file, "%f\n", tensao);
    fprintf(gauss_file,   "%f\n", var_gauss);
    x++;
    
    // 12. Fecha os arquivos 
    fclose(current_file);
    fclose(voltage_file);
    fclose(gauss_file);
    fclose(pot_file);

    // 13. Volta ao passo 7

  }
  close(sock_rcvFD);
}
