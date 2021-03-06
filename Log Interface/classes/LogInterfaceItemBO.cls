/* 
------------------------------------------------------------------------------------------------
-- - Name   : LogInterfaceItemBO 
-- - Description : Classe que contém a regra de negócio de LogInterfaceItem__c
------------------------------------------------------------------------------------------------
*/
public with sharing class LogInterfaceItemBO {
    private static final LogInterfaceItemBO instance = new LogInterfaceItemBO();
    /** Private constructor to prevent the creation of instances of this class.*/
    private LogInterfaceItemBO(){}
    
    /**
    * Method responsible for providing the instance of this class.
    * @return LogInterfaceItemBO instance.
    */
    public static LogInterfaceItemBO getInstance() {
        return instance;
    }
    
    /**
    * Method responsible for insert of Logs Items.
    * @param list of Object LogInterfaceItem__c.
    */
    public void insertLogItem(List<LogInterfaceItem__c> logs) {
        LogInterfaceItemDAO.getInstance().insertLogItem(logs);
    }
    
    /**
    * Method responsible for insert a Logs Items.
    * @param list of Object LogInterfaceItem__c.
    */
    public void insertLogItem(LogInterfaceItem__c log) {
        List<LogInterfaceItem__c> items = new List<LogInterfaceItem__c>();
        items.add(log);
        insertLogItem(items);
    }    
    
    /**
    * Method responsible for search the last Log Item.
    * @param Id of object LogInterface__c.
    * @return list of object LogInterfaceItem__c.
    */
    public List<LogInterfaceItem__c> lastInsertedRecord(Id logInter){
        return LogInterfaceItemDAO.getInstance().lastInsertedRecord(logInter);
    }
}