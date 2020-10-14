/* 
------------------------------------------------------------------------------------------------
-- - Name   : LogInterfaceDAO 

------------------------------------------------------------------------------------------------
*/
public with sharing class LogInterfaceDAO {
	private static final LogInterfaceDAO instance = new LogInterfaceDAO();
	/** Private constructor to prevent the creation of instances of this class.*/
	private LogInterfaceDAO(){}

	/**
	* Method responsible for providing the instance of this class.
	* @return LogInterfaceDAO instance.
	*/
	public static LogInterfaceDAO getInstance(){
		return instance;
	}

    /**
    * Method responsible for making upsert of Logs.
    * @param Object LogInterface__c.
    */
	public void upsertLog(LogInterface__c log){
		Database.upsert(log);
	}
    

    /**
    * Method responsible for insert of Logs.
    * @param Object LogInterface__c.
    */        
	public void insertRecord(LogInterface__c log) {
		Database.insert(log);
	}    

    /**
    * Method responsible for retrieve LogInterface__c.
    * @param Id of RecordTypeId of object LogInterface__c.
    * @return object LogInterface__c.
    */
	public LogInterface__c getRecord(Id id) {
		return [	SELECT 		Id, 
                				Date__c, 
                				Name, 
                				Interface__c, 
                				FailQuantity__c, 
                				SuccessQuantity__c,
                				Status__c,
                				TotalQuantity__c
			   		FROM 		LogInterface__c 
					WHERE 		Id =: id
					ORDER BY 	CreatedDate DESC 
                	LIMIT 1];
	}
}