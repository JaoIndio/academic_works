package CausalMulticast;

import java.io.IOException;

import java.net.DatagramSocket;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.UnknownHostException;

import java.util.Scanner;
import java.util.ArrayList;

public class Causal{

  private static int                       sizeMembers = 1;
  private static String                    Times       = "0";
  private static int                       TestNumb    = 0;
  private static String                    MyPort      = "1010";    // Porta de inicio
  private static int                       PortStable  = 0;
  private static String[]                  VC;
  private static String[][]                MC;
  private static String[]                  Buffer_pkg;
  private static int                       Buffer_size = 0;
  private static String                    ID_member;
  private static int                       MyPosition  = 0;
  private static String                    ipGroup;      // ip do grupo
  private static int                       portGroup;    // porta do grupo
  
  public  static ICausalMulticast          deliverRef;
  private static ArrayList<String>         IP_Members  = new ArrayList<String>();         // IP dos membros do grupo
  private static ArrayList<OBJ_Send_after> Late_sends  = new ArrayList<OBJ_Send_after>(); // mensagens atrasadas
  

  public Causal (String ID, ICausalMulticast ref){

    deliverRef = ref;

    Thread t1=new Thread(new FindMembers("239.0.0.0",4321, ID));
    Thread t2=new Thread(new rcv_pkg());
    Thread t4=new Thread(new Stabilize_pkgs());
    
    t1.start();
    t2.start();
    t4.start();
  
  }

  private static class OBJ_Send_after{
    public String msg;
    public String IP_dst;
    public String ID_member;
    public int    Port_dst;
    
    public OBJ_Send_after(String msg, String IP_dst, int Port_dst, String ID_member){
      this.msg       = msg;
      this.IP_dst    = IP_dst;
      this.Port_dst  = Port_dst; 
      this.ID_member = ID_member;
    }
  }
  
 public void mcsend(String msg, ICausalMulticast cliente){
    try{ 
      boolean sendFlag = true;
      // Enviar via socket UDP msg para todos os membros do grupo
      // ler IP, ler porta
      // criar socket
      // enviar msg
      DatagramSocket socketSend = new DatagramSocket();
      int i = 0;
      int read_port;
      String read_IP;
      
      // Posteriormente a funcao indexOf tera q ser usada para encontrar o VC 
      // presente na msgm

      // Estrutura de uma mensagem:
      // |#||MSG|.....|#|VECTOR_CLOCK|#|-VC[1]-VC[2]-...-VC[n]-|#||MC_CLOCK||#|.............|#||SNDR|...|#||VC[SENDER]|...|#||#||MY_PORT||#|....|#||DLVRD||#|
      // msg.VC <- VCi
      System.out.println("\n\t\t**************************\t\t**************************\t\t**************************\t\t**************************\n");
      System.out.println("************************************************  Configuracao de Envio  ***************************************************\n");
      System.out.println("\t\t\tVC quer enviar a msg para todo mundo? (sim/nao)");
      Scanner sc1 = new Scanner(System.in);
      String answare = sc1.next();
        
      if("-1".equals(MC[MyPosition][MyPosition]))  
        MC[MyPosition][MyPosition] = String.valueOf(Integer.parseInt(MC[MyPosition][MyPosition]) + 1);

      if("-1".equals(VC[MyPosition]))  
        VC[MyPosition] = String.valueOf(Integer.parseInt(VC[MyPosition]) + 1);
      
      // Adicao de informacoes na mensagem
      msg = "|#||MSG|"+msg+"|#||VECTOR_CLOCK||#|";
      msg = Add_vectors_at_msg(msg, "|#||VECTOR_CLOCK||#|"); // msg += VC
      msg = msg + "|#||MC_CLOCK||#|";                       
      msg = Add_vectors_at_msg(msg, "|#||MC_CLOCK||#|");     // msg += MC
      
      msg = msg + "|#||SENDER|"        + ID_member  +
                  "|#||VC[SENDER]|"    + MyPosition +
                  "|#||#||MY_PORT||#|" + MyPort     + 
                  "|#||DLVRD||#|0";

      // Do send(msg) to Px endDo
      String checkMSG             = msg.copyValueOf(msg.toCharArray(),8,16);
      if("UNICAST_IP_INFOS".equals(checkMSG)) sendFlag = false;
      
      //TestNumb++;
      if(sendFlag){
        
        if("sim".equals(answare)){
          send_to_all_members(msg,socketSend);
        }else if("nao".equals(answare)){
          String read_Member;

          // Cria objeto de atraso para cada futuro destinatario
          for(String interator : IP_Members){
            read_IP            = Get_String(interator, "", "|#||ID_MEMBER||#|");
            read_port          = Get_info(interator, "|#||MY_PORT||#|");
            read_Member        = Get_String(interator, "|#||ID_MEMBER||#|","|#||MY_PORT||#|");
            OBJ_Send_after obj = new OBJ_Send_after(msg, read_IP, read_port, read_Member);
            Late_sends.add(obj);
          }
          while(!Late_sends.isEmpty()){
            System.out.println("\t\t\t:::::::::::::::::::::: OPCOES DE ENVIO ATRASADO ::::::::::::::::::::::\n");
            System.out.println("\n\t\t\tComo vc quer enviar a mensagem? ");
            System.out.println("\t\t1 - Enviar mais tarde");
            i = 2;
            for(OBJ_Send_after interator : Late_sends){
              System.out.println("\t\t"+i+" - Enviar para IP: " + interator.IP_dst    +
                                                   "; Member: " + interator.ID_member +
                                                      "; msg: " + Get_String(interator.msg, "|#||MSG|", "|#||VECTOR_CLOCK||#|") +"\n");
              i++;
            }

            // |#||MSG|.....|#|VECTOR_CLOCK||#|-VC[1]-VC[2]-...-VC[n]-|#||SNDR|...|#||VC[SENDER]|...|#||#||MY_PORT||#|....|#||DLVRD||#|
            answare = sc1.next();
            if("1".equals(answare))
              break;
            else{
              // envia mensagem de acordo com a selecao do usuario
              int index = Integer.parseInt(answare) - 2;
              if((index)< Late_sends.size()){
                DatagramPacket pkg = new DatagramPacket( Late_sends.get(index).msg.getBytes(), 
                                                         Late_sends.get(index).msg.length(), 
                                                         InetAddress.getByName(Late_sends.get(index).IP_dst),
                                                         Late_sends.get(index).Port_dst);
            
                socketSend.send(pkg);
                Late_sends.remove(index);
              }
            }
            System.out.println("\t\t\t:::::::::::::::::::::: OPCOES DE ENVIO ATRASADO ::::::::::::::::::::::\n");
            Thread.sleep(100);
          }

        }
        /* Enviar para todos?
           Se sim{
             for(socket interator : Unicastsockets)
               interator.send(pkg);
           }
           Senao{
             for(String interator : IP_Members){
               OBJ_Send_after obj = new OBJ_Send_after(msg,read_IP, read_port);
               Late_sends.add(obj);
             }
             while(Late_sends != null){
               Enviar para qm?
                 #Enviar mais tarde BREAK;
                 #Mostrar todos os usuarios disponivies for(::) print(Late_sends[i].IP_dst e Late_sends[i].msg);
                    socketUDP.send(selecionado);
             }
           }
        */
        
        System.out.println("\n\t\t**************************\t\t**************************\t\t**************************\t\t**************************\n\n");
      }

      // atualiza vetor e matriz logica
      if("-1".equals(VC[MyPosition]))  
        VC[MyPosition] = String.valueOf(Integer.parseInt(VC[MyPosition]) + 1);

      VC[MyPosition]             = String.valueOf(Integer.parseInt( VC[MyPosition] ) + 1);
      MC[MyPosition][MyPosition] = String.valueOf(Integer.parseInt(MC[MyPosition][MyPosition]) + 1);
      System.out.println("\n\n");
      System.out.println("\n\n");
    }catch(Exception e){
       e.printStackTrace();
    }
  }

  private static class rcv_pkg implements Runnable{
    boolean VC_Order_OK = false;
    boolean Read_msg    = true;
    int     READ_VC_sender;
    String  Real_msg;
    String  msg;
    public rcv_pkg(){ }
    // ouvir socket na porta My_Port
    @Override
    public void run(){
      try{
        byte[] buffer           = new byte[1024];
        // Ouvir socket na porta My_Port
        DatagramPacket packet   = new DatagramPacket(buffer, buffer.length);
        DatagramSocket socket;
        
        // Aguarda FindMemebers definir a porta
        while(PortStable == 0){ 
          System.out.println("\n\t\tWaiting for Port Stabilization\n\n");
          Thread.sleep(1000);
        }

        // comeca a esperar por novas mensagens
        socket = new DatagramSocket(Integer.parseInt(MyPort));
        while(true){
          Read_msg = true;
          socket.receive(packet);
          msg             = new String(packet.getData(), packet.getOffset(), packet.getLength());
          String checkMSG = msg.copyValueOf(msg.toCharArray(),0,16);
          if("UNICAST_IP_INFOS".equals(checkMSG)){ Read_msg = false; }
          if(Read_msg){
            deposit_pkg(msg);
            Update_MC(msg);
            order_pkgs();
          } 
        }
      }catch (Exception e){
        e.printStackTrace();
      }
    }
  }

  private static class Stabilize_pkgs implements Runnable{
    
    int   i,j;
    int   min;
    int   msgSender;
    int[] msgVC;

    public Stabilize_pkgs(){}
    
    @Override
    public void run(){
      try{
        while(true){
          
          int size = Buffer_size;

          System.out.println("\n\n\t\t******* | STABILIZATION |  ******* ******* | STABILIZATION |  ******* ******* | STABILIZATION |  ******* \n\n");
          for(i =0; i<size; i++){
            min = 1000000000;
            if((i < Buffer_pkg.length)){
              if(Buffer_pkg[i]!= null ){
                
                msgSender = Get_info(Buffer_pkg[i], "|#||VC[SENDER]|");  // indice do remetente
                msgVC     = Get_msgVC(Buffer_pkg[i], "|#||MC_CLOCK||#|");
                
                System.out.print("\t\t");
                for(int j=0; j<msgVC.length; j++){
                  System.out.print(" | msgVC["+j+"]=>  "+msgVC[j]+" | ");
                }
                System.out.println("\n\n");

                for(j=0; j<MC[0].length; j++){
                  int intMC = Integer.parseInt(MC[j][msgSender]);
                  if(intMC < min) min = Integer.parseInt(MC[j][msgSender]);
                }
                if(min >= msgVC[msgSender]){
                  if(Buffer_size > 0){
                    int read_dlvrd = Get_info(Buffer_pkg[i], "|#||DLVRD||#|");
                    if(read_dlvrd == 1) discart(Buffer_pkg[i]);
                  }
                }
              }
            }
          }
          /*
              Caso o processo X tiver certeza que todos os demais 
              processos do grupo ja receberam determidada mensagem,
              entao esse dado nao precisa mais ser armazenado no 
              buffer.

              POR EXEMPLO: se todos os membros sabem q cada membro
              enviou 5 mensagens no grupo e existir um pacote no 
              buffer, indicando que, no contexto em q ele foi envi-
              ado, cada membro tinha enviado 3 mensagens, entao 
              este pacote pode seguramente ser excluido.
          */
          System.out.println("\n\n\t\t******* | STABILIZATION |  ******* ******* | STABILIZATION |  ******* ******* | STABILIZATION |  ******* \n\n");
          Thread.sleep(27000);
        }
      }catch(Exception e){
        e.printStackTrace();
      }
    }
    
  }

  private static class FindMembers implements Runnable { 
    
    public FindMembers(String ipGroupP, int portGroupP, String ID){
      ipGroup   = ipGroupP;
      portGroup = portGroupP;
      ID_member = ID;
    }

    @Override
    public void run(){
      try {
        byte[] buffer           = new byte[1024];
        
        // Descoberta do IP unicast da maquina via DNS da google
        DatagramSocket socketIP = new DatagramSocket();
        socketIP.connect(InetAddress.getByName("8.8.8.8"), 10002);
        String MyIP = socketIP.getLocalAddress().getHostAddress();
        
        // socket para IP Multicast
        MulticastSocket socket  = new MulticastSocket(portGroup);
        InetAddress group       = InetAddress.getByName(ipGroup);
        socket.joinGroup(group);

        boolean addIP_flag;
        String My_Unicast_IP;        
        while(true){
          addIP_flag = true;
          // define informacoes essencias para a thread FindMembers
          My_Unicast_IP = "UNICAST_IP_INFOS"+ MyIP +"|#||ID_MEMBER||#|"+ ID_member  +
                                                    "|#||MY_PORT||#|"  + MyPort     +
                                                    "|#||INDEX||#|"    + MyPosition +
                                                    "|#||TIMES||#|"    + Times      +
                                                    "|#||SP||#|"       + PortStable;

          DatagramPacket myIP_pkg = new DatagramPacket(My_Unicast_IP.getBytes(), 
                                                       My_Unicast_IP.length(), 
                                                       group, portGroup);
          socket.send(myIP_pkg);
          
          DatagramPacket packet   = new DatagramPacket(buffer, buffer.length);
          socket.receive(packet);

          Times = String.valueOf( Integer.parseInt(Times) + 1);
          My_Unicast_IP = "UNICAST_IP_INFOS"+ MyIP +"|#||ID_MEMBER||#|"+ ID_member  +
                                                    "|#||MY_PORT||#|"  + MyPort     +
                                                    "|#||INDEX||#|"    + MyPosition +
                                                    "|#||TIMES||#|"    + Times      +
                                                    "|#||SP||#|"       + PortStable;

          String msg = new String(packet.getData(), 
                                  packet.getOffset(), 
                                  packet.getLength());
          
          // checkMSG = | msg1 |
          String checkMSG = msg.copyValueOf(msg.toCharArray(),0,16);
          
          if("UNICAST_IP_INFOS".equals(checkMSG)){
            int stop_read = msg.indexOf("|#||INDEX||#|");
            // CheckMSG = | IP da msg | 
            checkMSG      = msg.copyValueOf(msg.toCharArray(), 16, (stop_read - 16));
          
            // Le IP, ID_MEMBER e Porta  
            for(String interator : IP_Members){
              if( interator.equals(checkMSG) ){
                addIP_flag = false;
                break;
              }
            }
            if(addIP_flag ){
              System.out.println("\n\n========================================================================================================================\n");
              int readPort  = Get_info(msg, "|#||MY_PORT||#|");
              int readIndex = Get_info(msg, "|#||INDEX||#|");
              int readTimes = Get_info(msg, "|#||TIMES||#|");
              int readSP    = Get_info(msg, "|#||SP||#|");
              
              // Altera valor de Porta e indice qndo necessario
              if( (readPort >= Integer.parseInt(MyPort) && 
                  (readTimes > Integer.parseInt(Times)) ) ){ 
           
                MyPort = String.valueOf(readPort + 1);    
              }
              if( (readIndex >= MyPosition) && 
                  (readTimes > Integer.parseInt(Times))){               
               
                MyPosition = readIndex + 1;
              }

              stop_read = msg.indexOf("|#||ID_MEMBER||#|");
              
              // esepra TIME > 3
              if(readTimes > 6){
                
                if(readSP == 1){
                  if(Integer.parseInt(MyPort) != readPort) IP_Members.add(checkMSG);     
                }
                String read_Member = Get_String(msg, "|#||ID_MEMBER||#|", "|#||MY_PORT||#|");
                System.out.println("\t\tread_Member: \t\t"+read_Member);
                
                if(ID_member.equals(read_Member)){
                  IP_Members.add(checkMSG);
                  PortStable = 1;
                  System.out.println("\t\t Porta estabilizada\n\n");
                }
              }

              sizeMembers = IP_Members.size();
              System.out.println("\t\t[Unicast IP] >> "+msg);
              String auxVC[]   = {"0"};
              String auxMC[][] = { {"-1"}, {"-1"} };
              
              // Aumenta dimensoes do vetor e da matriz
              if(VC != null) Copy_all(auxVC, auxMC);
              Upgrade_VC_MC(auxVC, auxMC);
              System.out.println("\n\n==========================================================================================================================\n");
            }
          }
          Thread.sleep(500);
        }
      }catch(Exception ex){
        ex.printStackTrace();
      }
    }
  }

  private static void Copy_all(String[] auxVC, String[][] auxMC){
    int i = VC.length;
    
    auxVC = new String[i];
    auxMC = new String[i][i];
    i = 0;
    for(String interator : VC){
      auxVC[i] = interator;
      i++;
    }
    int j;
    for(i=0; i<VC.length; i++){
      for(j=0; j<VC.length; j++)
        auxMC[i][j] = MC[i][j];
    }
  }

  // Aumenta a dimensao do vetor ou da matriz logica
  private static void Upgrade_VC_MC(String[] auxVC, String[][] auxMC){
    int i = 0;
    int j;
    
    if ( sizeMembers > 1 ){
      VC = new String[sizeMembers];
      MC = new String[sizeMembers][sizeMembers];
    }
    else{
      VC = new String[2];
      MC = new String[2][2];
      VC[0] = "0";
      VC[1] = "0";
      for(i=0;i<2;i++){
        for(j=0;j<2;j++){
          MC[i][j] = "-1";
        }
      }
    }
    
    System.out.println("sizeMembers at Upgrade_VC_MC =>\t\t"+ sizeMembers);
    for(i=0; i< auxVC.length; i++){
      VC[i] = auxVC[i];
    }
    for(i=auxVC.length; i<(sizeMembers-auxVC.length+1);i++){
      VC[i] = String.valueOf(0);  // Consideras-se q primeiro os middlwares tomarao ciencia
    }                             //   da existencia de um novo membro, para dps ele env-
                                  //   iar alguma mensagem.
    for(i=0; i<(sizeMembers-auxVC.length+1);i++){
      for(j=0; j<(sizeMembers-auxVC.length+1);j++){
        MC[i][j] = String.valueOf(-1);
      }
    }

    for(i=0; i< auxVC.length; i++){
      for(j=0; j< auxVC.length; j++){  
        MC[i][j] = auxMC[i][j];
      }
    }
  }
  
  private static String Add_vectors_at_msg(String msg, String start){
    
    int i;
    if("|#||VECTOR_CLOCK||#|".equals(start)){
      for(i=0; i<VC.length; i++){
        System.out.print("\t\t|mcsend| VC["+i+"]"+VC[i]);
        msg = msg+"="+VC[i]+"=";
      }
    }else{
      for(i=0; i<VC.length; i++){
        System.out.print("\t\t|mcsend| MC["+MyPosition+"]["+i+"] "+MC[MyPosition][i]);
        msg = msg+"="+MC[MyPosition][i]+"=";
      }
    }
    System.out.println("\n\n");
    return msg;
  }

  /* Recebe uma String que possui algum vetor logico e
     retorna um vetor logico em um array do tipo int
  */
  private static int[] Get_msgVC(String msg, String start){
    int i = msg.indexOf(start);
    int count_char = 0; 
    String VCmsg, VC_aux, number;
    VCmsg = msg.copyValueOf(msg.toCharArray(), i+start.length(), (msg.length()-(i+start.length())));
    
    if(start.equals("|#||VECTOR_CLOCK||#|")){
      i     = VCmsg.indexOf("|#||MC_CLOCK||#|");
      VCmsg = VCmsg.copyValueOf(VCmsg.toCharArray(), 0, i);
    }
    
    int [] VCnew;
    int count_number = 0;
    int String_VC_len = VCmsg.length();
    
    // A quantidade de mensagens enviadas por cada processo esta contida na mensagem 
    // e estao divididas entre dois caracteres "-".
    // Portanto, para conhecer VC[x], basta isolar o numero que esta entre dois "-"
    int frst_simb = 0;
    int scnd_simb = 0;
    
    int show = 3;
    char ifen = '=';
    for (i = 0; i < VCmsg.length(); i++) {
      if (ifen == VCmsg.charAt(i))
        count_char++;
    }

    count_number = count_char/2;
    VCnew = new int[count_number];
    VCnew[0] = 0;
    i = 0;
    
    /* Os elementos do vetor logico estao separados pelo caracter '=',
       portanto para converte-lo em um array do tipo int é preciso ler
       separadamente cada numero, que eh do tipo string.

       |#|=x=y=z=|#|, onde x,y e sao numeros inteiros e postivos
       o retorno sera:

       return (int)[x, y, z]
    */
    while( (count_char > 2) && (scnd_simb > -1) ){
      frst_simb     = VCmsg.indexOf("=");
      VC_aux        = VCmsg.copyValueOf(VCmsg.toCharArray(), 1 , (VCmsg.length()-1));
      scnd_simb     = VC_aux.indexOf("=");
      
      if(scnd_simb > -1){ 
        number = VCmsg.copyValueOf(VCmsg.toCharArray(), 1, scnd_simb + frst_simb);
        if( (number != "null") && (i<VCnew.length) ) VCnew[i] = Integer.parseInt(number);
      }

      //VC[i] = Integer.parseInt(number);
      i++;
      count_char--;
      if (count_char > 2) VCmsg = VCmsg.copyValueOf(VCmsg.toCharArray(), scnd_simb+2, (VCmsg.length()-(scnd_simb+2)));
      scnd_simb = VCmsg.indexOf("=");
    }
    
    return VCnew;
  }

// |#||MSG|.....|#|VECTOR_CLOCK|#|-VC[1]-VC[2]-...-VC[n]-|#||SNDR|...|#||VC[SENDER]|...|#| 
  
  // Retorna uma String que se encontra em um determindado frame da mensagem
  private static String Get_String(String msg, String start, String end){
    int i;
    
    if("".equals(start))  i = 0;
    else                  i = msg.indexOf(start);
    
    int j = msg.indexOf(end);
    
    String read_msg = msg.copyValueOf(msg.toCharArray(), i+start.length(), (j - (i+start.length())) );
    return read_msg;
  }

  // Verifica a ordem da mensagem, com a ordem que o usuario possui
  private static boolean Check_msgVC_with_my_VC(int[] msgVC, String[] VC){
    int i;
    boolean check = true;
    
    for(i=0; i<msgVC.length; i++){
      /* 
        Caso a quantidade de msgs q o processo X sabe q 
          foram enviadas, por cada membro; for menor que
          a quntidade de msgs q o processo Y sabe q foram
          enviadas, entao este pacote nao pode ser entreg-
          ue para a aplicacao. Isso significa q ha algm
          dado que ainda vai chegar, no qual, o contexto 
          em q foi enviado eh adequado para o grau de con-
          hecimento q o processo X tem do sistema.
      */
      if( msgVC[i] > Integer.parseInt(VC[i]) ){
        check = false;
        break;
      }
    }   
    return check;
  }
  
  private static void deposit_pkg(String msg){
    int i;
    String[] aux;

    if(Buffer_size < 2){

      aux = new String[2];
      i = 0;

      // aux = Buffer
      if(Buffer_pkg != null){
        for(String interator: Buffer_pkg){
          if(Buffer_pkg[i] != null) aux[i] = interator;
          i++;
        }
      }
      
      // Buffer aumenta suas dimensoes
      Buffer_pkg = new String[2];
      Buffer_size++;
    }
    else{
      aux = new String[Buffer_size];
      i = 0;

      for(String interator: Buffer_pkg){
        if(Buffer_pkg[i] != null) aux[i] = interator;
        i++;
      }

      Buffer_size++;
      Buffer_pkg = new String[Buffer_size];
    }

    i = 0;
    // Buffer = aux
    for(String interator: aux){
      if(aux[i] != null) Buffer_pkg[i] = interator;
      i++;
    }

    System.out.println("\n\n\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t+++++++++++++\t\t\n\n");
    System.out.println("\tDEPOSIT Buffer_pkg length at Deposit=>\t\t"+Buffer_pkg.length);
    System.out.println("\tDEPOSIT Buffer_size at Deposit=>\t\t"+Buffer_size);
    
    //Buffer[n] = msg, onde n eh a ultima posicao do buffer
    if(Buffer_size <= Buffer_pkg.length){ 
      Buffer_pkg[Buffer_size - 1] = msg;
      i = Buffer_size - 1;
    }else{
      Buffer_pkg[Buffer_size - 2] = msg;
      i = Buffer_size -2;
    }
    System.out.println("\tDEPOSIT at Buffer["+i+"] =>\t\t"+Buffer_pkg[i]);
    System.out.println("\n\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t++++++++++++++\t\t+++++++++++++\t\t\n\n");
  }
  
  // Garante Ordenamento das mensagens
  private static void order_pkgs(){ //implements ICausalMulticast{
    
    boolean Read_msg;
    boolean rept_check = false;
    boolean frst_check   = true;
    boolean VC_Order_OK = true;
    int VC_sender_index, read_dlvrd;
    String Real_msg = "=XXXXXXXX=";
    int i = 0;
    
    // Repete varredura, caso uma mensagem tiver sido entregue
    while(rept_check || frst_check){
      rept_check = false;
      // Varre buffer
      for(i =0; i<Buffer_size; i++){ 
        if( Buffer_pkg[i] != null ){
          // Verifica se pacote ja foi entregue
          read_dlvrd = Get_info(Buffer_pkg[i], "|#||DLVRD||#|");
          if(read_dlvrd == 0){
            
            VC_Order_OK     = false;
            Read_msg        = true;
            VC_sender_index = 0;
            int[] msgVC;
            
            msgVC           = Get_msgVC ( Buffer_pkg[i], "|#||VECTOR_CLOCK||#|");
            VC_sender_index = Get_info  ( Buffer_pkg[i], "|#||VC[SENDER]|");
            Real_msg        = Get_String( Buffer_pkg[i], "|#||MSG|",    "|#||VECTOR_CLOCK||#|");
            String read_src = Get_String( Buffer_pkg[i], "|#||SENDER|", "|#||VC[SENDER]|"); // read_src = ID_member
            VC_Order_OK     = Check_msgVC_with_my_VC(msgVC, VC);  // verifica se msg pode ou nao ser enviada
            
            System.out.println("\n\n\t\t//////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n");
            // |#||MSG|.....|#|VECTOR_CLOCK|#|-VC[1]-VC[2]-...-VC[n]-|#||SNDR|...|#||VC[SENDER]|...|#||#||MY_PORT||#|....|#||DLVRD||#|
            
            for(int j=0; j<sizeMembers; j++){
              System.out.println("\t\t\t|ORDER| msgVC["+j+"]  => "+msgVC[j]);
              System.out.println("\t\t\t|ORDER| VC["+j+"]     => "+VC[j]);
            }
            System.out.println("\t\t\t|ORDER| VC_Order_OK => "+VC_Order_OK);
            
            // MSG pode ser entregue para APP
            if(VC_Order_OK == true){
              rept_check = true;
              // atualiza vetor logico de ordenamento
              if(VC_sender_index != MyPosition){
                VC[VC_sender_index] = String.valueOf(Integer.parseInt( VC[VC_sender_index] ) + 1);
              }
              System.out.println("\t\t\t|ORDER| MSG Ordered and Deliveried =>\t\t"+Real_msg);
              String aux = Buffer_pkg[i];
              
              // altera valor de DLVRD para 1
              discart(Buffer_pkg[i]);
              aux = Post_info(aux, "|#||DLVRD||#|","1");
              deposit_pkg(aux);
              
              System.out.println("\n\t\t//////////////////////////////////////////////////////////////////////////////////////////////////////////////////\n\n");
              System.out.println("\n\n\t\t\t *** NOW APP NEED TO EXECUTE deliver **\n\n");
              Real_msg = read_src +":  "+ Real_msg;
              // entregua para camada de usuario
              deliverRef.deliver(Real_msg);
            } 
          } 
        } 
      }
      frst_check = false;
    }
  }
  
  private static void discart(String msg){
    int i;
    String[] aux1 = Buffer_pkg;
    
    System.out.println("\n\n\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t\n");
    for(i =0; i<Buffer_pkg.length; i++){
      System.out.println("\tBuffer before DISCART: msg => "+Buffer_pkg[i]);
    }
    System.out.println("\n");
    Buffer_size--;

    if(Buffer_size <= 1) Buffer_pkg = new String[2];
    else Buffer_pkg = new String[Buffer_size];
    
    System.out.println("\n\t\tDISCART: Buffer will have "+Buffer_size+" messages");
    System.out.println("\tDISCARTING msg => "+msg);
    int j =0;
    for(i =0; i<aux1.length; i++){
      if(aux1[i] != msg){
        Buffer_pkg[j] = aux1[i];
        j++;
      }
    }
    for(i =0; i<Buffer_pkg.length; i++){
      System.out.println("\tBuffer after DISCART: msg => "+Buffer_pkg[i]);
    }
    System.out.println("\t\tDISCART: NOW buffer have length "+Buffer_pkg.length+"\n");
    System.out.println("\n\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t---------------\t\t\n\n");
  }

  // retorna um valor inteiro presente em algm frame de uma mensagem
  private static int Get_info(String msg, String frame){
    
    int i = msg.indexOf(frame);
    String info_String;
    String stop = msg.copyValueOf(msg.toCharArray(), i+frame.length(), (msg.length()-(i+frame.length())));
    int j = stop.indexOf("|#||");
    int info_aux = i + frame.length();
    
    if (j > -1){
      j= j + i + frame.length();
      info_String = msg.copyValueOf(msg.toCharArray(), i+frame.length(), j-(i+frame.length()));
    }else{ 
      info_String = msg.copyValueOf(msg.toCharArray(), i+frame.length(), (msg.length()-(i+frame.length())));
    }
    
    return Integer.parseInt(info_String);
  }

  private static String Post_info(String msg, String frame, String new_info){
    
    int i = msg.indexOf(frame);
    String scnd_part;
    String[] msg_split;
    String stop      = msg.copyValueOf(msg.toCharArray(), i+frame.length(), (msg.length()-(i+frame.length())));
    String frst_part = msg.copyValueOf(msg.toCharArray(), 0, i);
    int j = stop.indexOf("|#||");
    int info_aux = i + frame.length();
    
    msg_split = msg.split(frame);

    if (j > -1){
      j= j + i + frame.length();
      scnd_part = msg.copyValueOf(msg.toCharArray(), j, msg.length() - j);
      msg = frst_part + frame + new_info + scnd_part;
    }else{
      msg = frst_part + frame + new_info;
    }

    return msg;    
  }

  private static void Update_MC(String msg){
    
    int read_sender = Get_info(msg, "|#||VC[SENDER]|");
    System.out.println("\t\tmsg at Update_MC=>  "+msg);
    int[] read_VC     = Get_msgVC(msg, "|#||MC_CLOCK||#|"); //problema
    int i;
    for(i=0; i<read_VC.length;i++){
      if( read_sender!=MyPosition){
        /* middleware X armazena dois tipos de info
              1- quantidade de msgs enviadas pelo middleware y
              2- quantidade msgs que o middleware y sabe q foram inviadas pelos outros participantes
        */
        MC[read_sender][i] = String.valueOf(read_VC[i]);
      }
    }
    
    //if i!=j then MCi[i][j] = M/Ci[i][j] + 1
    if(MyPosition != read_sender)
      // middleware X atualiza quantidade de msgs q o middleware Y enviou
      MC[MyPosition][read_sender] = String.valueOf( Integer.parseInt(MC[MyPosition][read_sender]) + 1);
    
    System.out.println("\t\tMC["+MyPosition+"]["+read_sender+"] = "+MC[MyPosition][read_sender]);
    for(int j=0; j<sizeMembers; j++){
        System.out.print("\t\t");
        for(int z=0; z<sizeMembers; z++){
          if(z == 0) 
            System.out.print("\t\t\t|   MC["+j+"]["+z+"] de "+ID_member+" =>  "+MC[j][z]+"  | ");
          else       
            System.out.print("|   MC["+j+"]["+z+"] de "+ID_member+" =>  "+MC[j][z]+"  | ");
        }
        System.out.println("\n");
      }
      System.out.println("\n\n");

  }

  private static void send_to_all_members(String msg, DatagramSocket socketSend){
    int i = 0;
    try{
      for(String interator : IP_Members){
      // Do send(msg) to Px endDo
        DatagramPacket pkg = new DatagramPacket( msg.getBytes(), 
                                                 msg.length(), 
                                                 InetAddress.getByName(Get_String(interator, "","|#||ID_MEMBER||#|")),
                                                 Get_info(interator,"|#||MY_PORT||#|"));
        socketSend.send(pkg);
      } 
    }catch(Exception e){
      e.printStackTrace();
    }
  }
  
  // Interface
  public interface ICausalMulticast{
    public void deliver(String msg);
  }

  public static void main(String[] args) {
  }
}
