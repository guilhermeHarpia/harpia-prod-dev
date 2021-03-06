/* 
------------------------------------------------------------------------------------------------
-- - Name   : LogInterfaceBO 
-- - Description : Classe que contém a regra de negócio de LogInterface__c
*/
public with sharing class LogInterfaceBO {
    private static final LogInterfaceBO instance = new LogInterfaceBO();
    /** Private constructor to prevent the creation of instances of this class.*/
    private LogInterfaceBO(){}
    
    /**
    * Method responsible for providing the instance of this class.
    * @return LogInterfaceBO instance.
    */
    public static LogInterfaceBO getInstance(){
        return instance;
    }
    
    /**
    * Method responsible for upsert of Logs.
    * @param Object LogInterface__c.
    */
    public void upsertLog(LogInterface__c log){
        LogInterfaceDAO.getInstance().upsertLog(log);
    }

    /**
    * Method responsible for insert of Logs.
    * @param Object LogInterface__c.
    */    
	public void insertRecord(LogInterface__c log) {
		LogInterfaceDAO.getInstance().insertRecord(log);
	}     
    
    /**
    * Method responsible for search for LogInterface__c
    * @param Id of id of object LogInterface__c.
    * @return object LogInterface__c.
    */
    public LogInterface__c getRecord(Id id) {
        return LogInterfaceDAO.getInstance().getRecord(id);
    }
}