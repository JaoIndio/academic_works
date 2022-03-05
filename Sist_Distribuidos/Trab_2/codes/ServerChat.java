// Server 2

import java.rmi.*;
import java.rmi.server.*;
import java.rmi.registry.*;
import java.util.ArrayList;
import java.util.Date;
import java.sql.Timestamp;

// GUI classes
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

import java.awt.*;
import javax.swing.*;


public class ServerChat extends UnicastRemoteObject implements IServerChat{

  private ArrayList<String> roomList = new ArrayList<String>();
  private ArrayList<RoomChat> rooms = new ArrayList<RoomChat>();

  private int ID_list = 0; // nao permite q haja listas duplicadas
  private static String IP_HOST = "127.0.0.1";
  private static final String PORT = ":2020";
  private int index = 0;
  private String[] ConvArray = null;

  JFrame frame = new JFrame("RoomList");

  JPanel buttonPanel = new JPanel();
  JPanel fieldsPanel = new JPanel();
  
  JList JRoomList;
  JButton bClose = new JButton("Close Room");

  public ServerChat() throws RemoteException{}
  
  private void ServerGUI(){
    
    ServerChat Server = this;
    this.frame.setTitle("Room Lists Created by Users");
    
    UpdateList();
      
    buttonPanel.setLayout(new FlowLayout());
    buttonPanel.add(bClose);
    frame.add(buttonPanel, BorderLayout.PAGE_END);
    
    frame.pack(); 

    bClose.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
        
        // Read de index and the String selected by the user
        int index = JRoomList.getSelectedIndex();
        String s = (String) JRoomList.getSelectedValue();
        try{
          FinishConection(s); // Fecha sala selecionada
        }catch (Exception error){
            error.printStackTrace();
        }
        UpdateList();
      }
    });

    
  }
  
  private void UpdateList(){
    
    ConvertList(roomList);
    //GUI Behaviour
    fieldsPanel.setLayout(new BoxLayout(fieldsPanel, BoxLayout.Y_AXIS));
    
    // List Config
    JRoomList = new JList(ConvArray);
    fieldsPanel.add(new JScrollPane(JRoomList));
    frame.add(fieldsPanel, BorderLayout.PAGE_START);
    frame.pack();

  }


  private void ConvertList(ArrayList<String> List){
  
    if(ConvArray!=null){
      for ( int i=0; i<ConvArray.length; i++){
        ConvArray[i] = null;
      }
    }

    String[] aux = new String[List.size()];
    ConvArray = List.toArray(aux);
  }


  public ArrayList<String> getRooms() throws RemoteException{
  
    return roomList;
  }

  public void createRoom(String roomName) throws RemoteException{
    String strID = Integer.toString(ID_list);
    roomName= roomName+strID;
    //roomName.concat(strID);
    roomList.add(roomName);
    rooms.add( new RoomChat(roomName) );
      
    RoomChat aux = rooms.get(index);
    
    try{
      Naming.rebind("rmi://"+IP_HOST+PORT+"/"+roomName, aux);
    
    } catch( Exception e){
        e.printStackTrace();
    }
      
    ID_list = ID_list + 1;
    index++;

    UpdateList();
  }
  
  private void FinishConection(String roomName) throws RemoteException{
    try{
      IRoomChat room = (IRoomChat) Naming.lookup("rmi://"+IP_HOST+PORT+"/"+roomName);
      room.closeRoom();
      
      int i = roomList.indexOf(roomName);
      
      RoomChat aux = rooms.get(i);
      aux = null;
      rooms.remove(i);
      roomList.remove(i);
    
    }catch (Exception e){
        e.printStackTrace();
    }
  }

  public static void main(String args[]) throws Exception{
    IP_HOST = args[0];   
    System.setSecurityManager(new RMISecurityManager()); 
    try{
      ServerChat RSM = new ServerChat();
      
      RSM.ServerGUI();
      RSM.frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
      RSM.frame.setVisible(true);


      LocateRegistry.createRegistry(2020);
      Naming.rebind("rmi://"+IP_HOST+":2020/Servidor", RSM);
      System.out.println("Server started and up.");
      
      Timestamp x = new Timestamp(System.currentTimeMillis());
      long y = x.getTime();
      System.out.println(y);
      //System.out.println("\n\n"+format( new Date() ));
    }catch (Exception e){
      e.printStackTrace();
    }

  }     
}
 
