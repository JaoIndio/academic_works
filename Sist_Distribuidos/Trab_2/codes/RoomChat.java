import java.rmi.*;
import java.rmi.server.*;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

public class RoomChat extends UnicastRemoteObject implements IRoomChat{
               
  private ArrayList<String> RoomList = new ArrayList<String>();                              
  private Map<String, IUserChat> userList = new HashMap<String, IUserChat>();
  private final String IP_HOST = "127.0.0.1";
  private String roomName;

  public RoomChat(String roomName) throws RemoteException{
    this.roomName = roomName;
  }
                       
  public void sendMsg(String usrName, String msg) throws RemoteException{
    
    for(Map.Entry<String,IUserChat> interator : userList.entrySet()){
      
      IUserChat user = interator.getValue();
      String name = interator.getKey();
      //if( (usrName != name) && () )
      
      user.deliverMsg(usrName, msg);
    }                   
  }

  public void joinRoom(String usrName, IUserChat user) throws RemoteException{
    
    //IUserChat userRef = (IUserChat) Naming.lookup("rmi://127.0.0.1:2020/"+usrName);

    if ( userList.containsKey(usrName) ){
      //&& userList.containsValue(user) ){
      user.SetJoinResult(false);
    }else{
      userList.put(usrName, user);
      user.SetJoinResult(true);
    }
  }

  public void leaveRoom(String usrName) throws RemoteException{
    String msg = "\t"+usrName+" SAIU DA SALA\n\n";
    String from = "\n\nSYSTEM MESSAGE!!";
     
    for(Map.Entry<String,IUserChat> interator : userList.entrySet()){
     IUserChat user = interator.getValue();
     user.deliverMsg(from, msg);
     
    }
    userList.remove(usrName);
  }

  public void closeRoom() throws RemoteException{
    
    String msg = "\tSala fechada pelo Servidor \n\n";
    String from = "\n\nSYSTEM MESSAGE!!";
     
    sendMsg(from, msg);
    for(Map.Entry<String,IUserChat> interator : userList.entrySet()){
     //IUserChat user = interator.getValue();
     //user.deliverMsg(from, msg);
     
     String usrName = interator.getKey();
     this.leaveRoom(usrName);
    }

    userList.clear();
    // REMOVE REFERENCIA REMOTA DO REGISTRY
    UnicastRemoteObject.unexportObject(this, true);
    //RoomList = Server.getRooms();
  }

  public String getRoomName() throws RemoteException{
    return roomName;
  }
 
  public static void main(String args[]){
    
    //System.setSecurityManager(new RMISecurityManager()); 
    try{
      int a =1;
      //RemoteServerMethods RSM = new RemoteServerMethods();
      //LocateRegistry.createRegistry(Registry.REGISTRY_PORT);
      //Naming.rebind("rmi://"+IP_HOST+"/ServerChat", RSM);
      //System.out.println("Server started and up.");
    
    }catch (Exception e){
      e.printStackTrace();
    }
  } 

}
 

