import java.io.IOException;

import java.net.DatagramSocket;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

import java.net.UnknownHostException;
import java.util.Scanner;
import java.util.ArrayList;

import CausalMulticast.Causal.ICausalMulticast;
import CausalMulticast.*;

public class App {

  private static ArrayList<String> OldMessages = new ArrayList<String>();

  //private int      OldMessages_size;
  private static String   msg;
  private static String   My_name;
  public static  Causal   acessGroup;

  public App(String ID, client user){ 
    My_name = ID;
    acessGroup = new Causal(ID, user);
  }
  public static class client implements ICausalMulticast{
    //public client(){ }  
  
    @Override
    public void deliver(String msg){
      System.out.println("\n\n\t\t\t**** EXECUTING DELIVER AT App.java ****\n\n");
      OldMessages.add(msg);
      if(OldMessages.size() > 200){
        OldMessages.remove(0);
      }
    //Atualiza OldMessages;
    }
  }
  
  public static void main(String[] args){
    client user   = new client();
    App    member = new App(args[0], user); 
    try{
      int time = 24;
      int i;
      int j = time*5;
      for(i=0;i<time;i++){
        System.out.println("In "+j+"seconds you will be able to send messages...");
        Thread.sleep(5000);
        j-=5;
      }
    }catch (Exception e){
      e.printStackTrace();
    }
    
    System.out.println("\n\n\n\t\t\t\tWelcome to Group\n\n");
    Scanner sc1 = new Scanner(System.in);
    String answare;
    while(true){
      // ShowOldMessages();
      //sc1 = new Scanner(System.in);
      System.out.println("\n\n'''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT \n\n");
      for(String interator: OldMessages){
       System.out.println(interator); 
      }
      System.out.println("\n\n'''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT '''''''''' CHAT \n\n");
      System.out.println("\n\n-----------------------------------------------------------------------------------------------------------------\n");
      System.out.print(My_name+ ": ");
      
      answare = "";
      //answare+=sc1.nextLine();
      //while(sc1.hasNextLine()){
        answare = sc1.nextLine();
      //}
      
      if("appchat -r".equals(answare)){ 
        System.out.println("\n\t\t***** Reprinting chat ****\n\n");
      }else{
        member.acessGroup.mcsend(answare, user);
      }
      //sc1.close();
      //sc1 = null;
    }
  }
}

