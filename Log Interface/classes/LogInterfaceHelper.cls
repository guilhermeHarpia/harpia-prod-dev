//	/**
//	* LogInterfaceHelper is a class that aims to make easier and more precise the
//	* creation of log records within the LogInterface__c and LogInterfaceItem__c objects.
//	* Use this class whenever you want to create a custom log, for example, after an outbound 
//	* or inbound message.
//	* 
//	* @author      Zuinglio Lopes Ribeiro Júnior
//	* @version     1.0
//	*/
	public with sharing class LogInterfaceHelper {
//	    
//	    /** Singleton approach */
//	    private static final LogInterfaceHelper instance = new LogInterfaceHelper();
//	    
//	    /** Private constructor to prevent the creation of instances of this class.*/
//	    private LogInterfaceHelper() {}
//	    
//	    private List<LogInterfaceItem__c> logItems;
//	    
//	    private Integer numSuccess 
//	    
//	    private Integer numErrors 
//	    
//	    /**
//	    * Method responsible for providing the instance of this class.
//	    * @return LogInterfaceHelper instance.
//	    */
//	    public static LogInterfaceHelper getInstance() {
//	        return instance;
//	    }
//	    
//	    /**
//	    * Method that creates the log and log items and whether to send or not an e-mail 
//	    * reporting the results.
//	    * @param the log interface record type
//	    * @param name of the class responsible for executing the interface
//	    * @param indicates when an e-mail must be sent with the outcome
//	    */
//	    public void createLog(Id recordTypeId, String interfaceClass, Boolean sendEmail) {
//	        
//	        LogInterface__c logHeader 
//	        //logHeader.RecordTypeId
//	        logHeader.Date__c 
//	        logHeader.FailQuantity__c
//	        logHeader.SuccessQuantity__c
//	        logHeader.Interface__c
//	        logHeader.User__c
//	        
//	        /** Inserts the log header */
//	        LogInterfaceDAO.getInstance().insertRecord(logHeader);
//	        
//	        /** If there are items, inserts them */
//	        if (logItems != null) {
//	            
//	            for (LogInterfaceItem__c logItem : logItems)
//	                logItem.LogInterface__c = logHeader.Id;
//	            
//	            LogInterfaceItemDAO.getInstance().insertLogItem(logItems);
//	        }
//	        
//	        /** When true, sends an e-mail reporting the outcome. In case of failure,
//	
//	        if (sendEmail)
//	            try {
//	                SendMail.SendLogInterfaceMail(logHeader);
//	            } catch (Exception e) {
//	                LogInterfaceItem__c logItem
//	                logItem.LogInterface__c 
//	                logItem.FailDescription__c
//	                logItem.StatusCode__c
//	                logItem.Item__c
//	                
//	                LogInterfaceItemBO.getInstance().insertLogItem(logItem);
//	            }        
//	        
//	        
//	        logItems = null;
//	        numSuccess 
//	        numErrors 
//	    }
//	    
//	    /**
//	    * Method that creates the log and log items.
//	    * @param the log interface record type
//	    * @param name of the class responsible for executing the interface
//	    */    
//	    public void createLog(Id recordTypeId, String interfaceClass) {
//	        createLog(recordTypeId, interfaceClass, false);
//	    }
//	
//	    
//	    /**
//	    * Method that creates the log and log items and whether to send or not an e-mail 
//	    * reporting the results.
//	    * @param res response 
//	    * @param interfaceClass 
//	    * @param processedClassName name of the class that performed the request
//	    */    
//	    public Boolean createLog(HttpResponse res, String interfaceClass, String processedClassName, Boolean commitLog) {
//	        
//	        Boolean isOK = res.getStatusCode() == 200;
//	        
//	        if (isOK) {
//	            numSuccess++;
//	        } else {
//	            numErrors++;
//	            
//	            LogInterfaceItem__c logItem
//	            System.debug(res.getBodyDocument().toXmlString());
//	            logItem.FailDescription__c
//	            logItem.StatusCode__c
//	            logItem.Fields__c
//	            logItem.Item__c
//	            addLogItem(logItem);    
//	        }
//	        
//	        if (commitLog)
//	        
//	        
//	        return isOK;
//	    }
//	    
//	    public Boolean createLog(String reqBody, HttpResponse res, String interfaceClass, String processedClassName, Boolean commitLog) {
//	        system.debug('Creating Log');
//	        Boolean isOK = res.getStatusCode() == 200;
//	        
//	        if (isOK) {
//	            numSuccess++;
//	        } else {
//	            numErrors++;
//	            
//	            LogInterfaceItem__c logItem
//	            System.debug(res.getBodyDocument().toXmlString());
//	            logItem.FailDescription__c
//	            logItem.StatusCode__c
//	            logItem.Fields__c
//	            logItem.Item__c
//	            addLogItem(logItem);    
//	        }
//	        
//	        if (commitLog){
//	            addMessage(reqBody, interfaceClass);
//	            system.debug('afterAddMessage: ' + reqBody);
//	            system.debug(size());
//	        
//	        }
//	        return isOK;
//	    }
//	
//	    /**
//	    * Method that populates the log items with detailed information of the errors
//	    * @param errors 
//	    * @param objectLabel 
//	    */        
//	    private void setErrors(Database.Error[] errors, String objectLabel) {
//	        
//	        for (Database.Error error : errors) {
//	            LogInterfaceItem__c logItem
//	            logItem.FailDescription__c
//	            logItem.StatusCode__c
//	            logItem.Fields__c
//	            logItem.Item__c
//	            addLogItem(logItem);
//	        }
//	        
//	    }
//	
//	    /**
//	    * Method responsible for handling DML results of an insert or update operation,
//	    * counting and registering errors and success.
//	    * @param results 
//	    * @param objectLabel 
//	    */            
//	    public void addResults(Database.SaveResult[] results, String objectLabel) {
//	        
//	        for (Database.SaveResult result: results) {
//	            if (result.isSuccess()) {
//	                numSuccess++;
//	            } else {
//	                numErrors++;
//	                setErrors(result.getErrors(), objectLabel);
//	            } 
//	        }
//	    }
//	
//	    /**
//	    * Method responsible for handling DML results of an upsert operation,
//	    * counting and registering errors and success.
//	    * @param results 
//	    * @param objectLabel 
//	    */           
//	    public Boolean addResults(Database.UpsertResult[] results, String objectLabel) {
//	        
//	        for (Database.UpsertResult result: results) {
//	            if (result.isSuccess()) {
//	                numSuccess++;
//	            } else {
//	                numErrors++;
//	                setErrors(result.getErrors(), objectLabel);
//	            } 
//	        }   
//	        
//	        if(numErrors > 0) {
//	            return false;
//	        }else{
//	            return true;   
//	        }
//	    }
//	    
//	    /**
//	    * Method responsible for handling DML results of an upsert operation,
//	    * counting and registering errors and success.
//	    * @param results 
//	    * @param objectLabel 
//	    */           
//	    public Boolean addResults(Database.DeleteResult[] results, String objectLabel) {
//	        
//	        for (Database.DeleteResult result: results) {
//	            if (result.isSuccess()) {
//	                numSuccess++;
//	            } else {
//	                numErrors++;
//	                setErrors(result.getErrors(), objectLabel);
//	            } 
//	        }   
//	        
//	        if(numErrors > 0) {
//	            return false;
//	        }else{
//	            return true;   
//	        }
//	    }    
//	    
//	    /**
//	    * Method that adds a LogInterfaceItem__c object to a collection 
//	    * that will be persisted when the method createLog be invoked. 
//	    * @param results 
//	    * @param objectLabel 
//	    */      
//	    public void addResults(Exception ex, String objectLabel) {      
//	
//	        LogInterfaceItem__c logItem
//	        logItem.FailDescription__c
//	        logItem.Item__c
//	
//	      
//	    }
//	    
//	    public void addError (String message, String objectLabel) {      
//	
//	        LogInterfaceItem__c logItem
//	        logItem.FailDescription__c
//	        logItem.Item__c
//	
//	      
//	    }      
//	
//	    public void addMessage (String message, String objectLabel){
//	        LogInterfaceItem__c logItem
//	        logItem.Message__c
//	        logItem.Item__c
//	
//	      
//	    }    
//	    
//	    /**
//	    * Method that adds a LogInterfaceItem__c object to a collection 
//	    * that will be persisted when the method createLog be invoked. 
//	    * @parabatchexm results 
//	    * @param objectLabel 
//	    */      
//	    public void addLogItem(LogInterfaceItem__c logItem) {      
//	        if (logItems == null)
//	            logItems = new List<LogInterfaceItem__c>();
//	        logItems.add(logItem);   
//	    }
//	    
//	    public Integer size() {
//	        return logItems.size();
//	    }
//	    
//	    public Boolean hasErrors() {
//	        return numErrors > 0;
//	    }
//	        
//	    public Integer addSuccess() {
//	        return numSuccess++;
//	    } 
//	    
//	    public Integer addError() {
//	        return numErrors++;
//	    }
//	    
//	    public Integer addSuccess(Integer qty) {
//	        return numSuccess += qty;
//	    } 
//	    
//	    public Integer addError(Integer qty) {
//	        return numErrors += qty;
//	    }       
	}