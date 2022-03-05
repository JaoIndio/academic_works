import java.rmi.*;
import java.rmi.server.*;
import java.util.ArrayList;
import java.util.Date;
import java.sql.Timestamp;


// GUI classes
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

import java.awt.*;
import java.awt.BorderLayout;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.JButton;
import javax.swing.*;

public class UserChat extends UnicastRemoteObject implements IUserChat{
  
  private static final String IP_HOST = "127.0.0.1";
  private String usrName; 
  private ArrayList<String> Teste = new ArrayList<String>();
  private ArrayList<String> RoomList = new ArrayList<String>();
  private String[] ConvArray = null;
  
  private IRoomChat slctRoom = null;
  
  private long ClientID;
  public boolean joinResult = true;
  // First GUI
  JFrame frame = new JFrame("Chatter");

  JPanel buttonPane = new JPanel();
  JPanel fieldsPanel = new JPanel();
  
  JTextField Txt = new JTextField(50);
  JTextArea Msgarea = new JTextArea(10,10);
  
  JButton bsend = new JButton("Send");
  JButton bsee = new JButton("See Rooms");
  JButton bleave = new JButton("Leave Room");

  
  // Second GUI
  JFrame fList = new JFrame("Room Lists");

  JPanel buttonPanelList = new JPanel();
  JPanel fieldsPanelList = new JPanel();
  
  JList JRoomList;
  
  JButton bJoin = new JButton("Join Room");
  JButton bCreate = new JButton("Create Room");

  
  public UserChat() throws RemoteException{

    usrName = getName("Write Your Name:", "Screen Name Definition");
    System.out.println(usrName);

    Msgarea.setEditable(false);
    ConvertList(Teste);
  }

  private void ConvertList(ArrayList<String> List){
  
    if(ConvArray!=null){
      for ( int i=0; i<ConvArray.length; i++){
        ConvArray[i] = null;
      }
    }

    String[] aux = new String[List.size()];
    aux = List.toArray(aux);
    System.out.println(aux);

    ConvArray = List.toArray(aux);
  }
  
  private String getName(String msg1, String msg2) {
    return JOptionPane.showInputDialog(frame, msg1, msg2, JOptionPane.PLAIN_MESSAGE);
  }
  public void deliverMsg(String senderName, String msg) throws RemoteException{
    // TEM Q INTERAGIR COM INTERFACE GRAFICA
    // precisa de bem mais coisas..
    Msgarea.append(senderName+": "+msg+"\n");

  }
  
  private void CreateFrame1(IServerChat Server){
    
    UserChat Client = this;
    Client.frame.setTitle("User: "+usrName);
    
    fieldsPanel.setLayout(new BoxLayout(fieldsPanel, BoxLayout.Y_AXIS));
    buttonPane.setLayout(new FlowLayout());

    fieldsPanel.add(new JScrollPane(Msgarea));
    fieldsPanel.add(Txt);

    buttonPane.add(bsee);
    buttonPane.add(bsend);
    buttonPane.add(bleave);

    frame.add(fieldsPanel, BorderLayout.CENTER);
    frame.add(buttonPane, BorderLayout.PAGE_END);
    frame.pack();

    bsee.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
        //GUI Behaviour
        UpdateList(Server);
        Client.frame.setVisible(false);
        Client.fList.setVisible(true);
         
        //RMI Behaviour
      }
    });

    bleave.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
        //GUI Behaviour
        UpdateList(Server);
        Client.frame.setVisible(false);
        Client.fList.setVisible(true);
         
        //RMI Behaviour
        try{
          slctRoom.leaveRoom(Client.usrName);
        
        }catch (Exception error){
          error.printStackTrace();
        }

        slctRoom = null;
     }
    });

    bsend.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
        
        //RMI Behaviour
        try{
        slctRoom.sendMsg(Client.usrName, Txt.getText());
        
        }catch ( Exception error){
          error.printStackTrace();
        }
        //GUI Behaviour
        Txt.setText("");


        }
    });

  }
  // UpdateChat
  private void UpdateChat(){
    
    try{
      this.frame.setTitle("User: "+usrName+", Room: "+slctRoom.getRoomName());
    }catch( Exception error){
      error.printStackTrace();
    }

    Msgarea.setText("");
    frame.pack();

  }

  // UpdateList
  private void UpdateList(IServerChat Server){
    
    // RMI Behaviour
    try{
      RoomList = Server.getRooms();
      ConvertList(RoomList);
    }catch (Exception error){
      error.printStackTrace();
    }

    //GUI Behaviour
    fieldsPanelList.setLayout(new BoxLayout(fieldsPanelList, BoxLayout.Y_AXIS));
    
    // List Config
    JRoomList = new JList(ConvArray);
    fieldsPanelList.add(new JScrollPane(JRoomList));
    fList.add(fieldsPanelList, BorderLayout.PAGE_START);
    fList.pack();

  }

  private void CreateFrame2(IServerChat Server){
    
    UserChat Client = this;
    Client.fList.setTitle("Room Lists Available to You");

    UpdateList(Server);
      
    buttonPanelList.setLayout(new FlowLayout());
    
    //Botoes
    buttonPanelList.add(bJoin);
    buttonPanelList.add(bCreate);
    
    fList.add(buttonPanelList, BorderLayout.PAGE_END);
    fList.pack();    
    
    bJoin.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
        //GUI Behaviour
        Client.frame.setVisible(true);
        Client.fList.setVisible(false);
        
        // Read de index and the String selected by the user
        int index = JRoomList.getSelectedIndex();
        String s = (String) JRoomList.getSelectedValue();

        // Testa Comando
        System.out.println(index);
        System.out.println(s);
  
        //RMI Behaviour
        try{
          // RoomChat Reference
          IRoomChat auxRef;
          boolean validJoin = true;

          auxRef = (IRoomChat) Naming.lookup("rmi://"+IP_HOST+":2020/"+s);
          
          if ( (slctRoom!=auxRef) && (slctRoom!=null) ){
            JOptionPane.showMessageDialog(frame,
            "You arleady ara in a Room Chat.\n Please, first get out your current Room Chat",
            "Invalid Join",
            JOptionPane.ERROR_MESSAGE);

            validJoin = false;
          }
          
          if(validJoin){
            slctRoom = auxRef;
            slctRoom.joinRoom(usrName, Client);
            
            // GERNCIAMENTO DE NOMES REPETIDOS ...
            // o objeto precisa sair de registry e se registrar novamente
            while(!joinResult){
              System.out.println("\n\t\t====== "+joinResult+" ======\n\n");

              Naming.unbind("rmi://"+IP_HOST+":2020/"+Client.usrName+Client.ClientID);
              usrName = getName("Ivalid Name", "Choose another name");
              
              Naming.rebind("rmi://"+IP_HOST+":2020/"+Client.usrName+Client.ClientID, Client);

              slctRoom.joinRoom(usrName, Client);
            }

            System.out.println("\n\n\t\tSaiu do while========\n\n");
            UpdateChat();
          }

          validJoin = true;

        } catch (Exception error){
          error.printStackTrace();  
        }

      }
    });

    bCreate.addActionListener(new ActionListener(){
      public void actionPerformed(ActionEvent e){
         //GUI Behaviour
        String roomName = getName("Write Room Name:", "Screen Room Definition");
        
        //RMI Behaviour
        try{
          Server.createRoom(roomName);
          UpdateList(Server);

        } catch( Exception error ){
          error.printStackTrace();
        }
      }
    });

  }

  public void SetJoinResult(boolean x) throws RemoteException{
    joinResult = x;
  }

  public static void main(String args[]){
    try {
      UserChat client = new UserChat();
      Timestamp x = new Timestamp(System.currentTimeMillis());
      client.ClientID = x.getTime();
          
      IServerChat Server = (IServerChat) Naming.lookup("rmi://"+IP_HOST+":2020/Servidor");
      Naming.rebind("rmi://"+IP_HOST+":2020/"+client.usrName+client.ClientID, client);
      
      client.CreateFrame1(Server);
      client.frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
      client.frame.setVisible(true);

      client.CreateFrame2(Server);
      client.fList.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
      client.fList.setVisible(false);

    } catch (Exception e){
        e.printStackTrace();
    }
  }
}
