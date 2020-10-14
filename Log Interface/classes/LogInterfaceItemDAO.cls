/* 
------------------------------------------------------------------------------------------------
-- - Name   : LogInterfaceItemDAO 
-- - Company: CSC 
-- - Author : José Miguel Paschoa Junior 
-- - Description : Classe que contém aS conexões no banco
-- -- Date         Name                              Version    Remarks 
------------------------------------------------------------------------------------------------ 
-- -- 19-08-2015   José Miguel Paschoa Junior        1.0        Initial version 
-- -- 09-09-2015   Camila Stoppa Vicente             1.1        Ajuste do código e revisão
------------------------------------------------------------------------------------------------
*/
	
	public with sharing class LogInterfaceItemDAO {
//	    private static final LogInterfaceItemDAO instance = new LogInterfaceItemDAO();
//	    /** Private constructor to prevent the creation of instances of this class.*/
//	    private LogInterfaceItemDAO(){}
//	    
//	    /**
//	    * Method responsible for providing the instance of this class.
//	    * @return LogInterfaceItemDAO instance.
//	    */
//	    public static LogInterfaceItemDAO getInstance(){
//	        return instance;
//	    }
//	    
//	    /**
//	    * Method responsible for making insert of Logs Items.
//	    * @param List of Object LogInterfaceItem__c.
//	    */
//	    public void insertLogItem(List<LogInterfaceItem__c> logs) {
//	        Database.insert(logs);
//	    }
//	    
//	    /**
//	    * Method responsible for retrieve the last Log Item.
//	    * @param Id of object LogInterface__c.
//	    * @return list of object LogInterfaceItem__c.
//	    */
//	    public List<LogInterfaceItem__c> lastInsertedRecord(Id logInter){
//	        List<LogInterfaceItem__c> log = [SELECT Id, Name, FailDescription__c, Item__c, LogInterface__c 
//	                                         FROM LogInterfaceItem__c 
//	                                         WHERE LogInterface__c =: logInter];
//	        
//	        return log;
//	    }
	}