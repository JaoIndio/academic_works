import java.rmi.*;

public interface IUserChat extends java.rmi.Remote {

  public void deliverMsg(String senderName, String msg) throws RemoteException;
  
  public void SetJoinResult(boolean x) throws RemoteException;
}
