/**
* LogInterfaceHelper is a class that aims to make easier and more precise the
* creation of log records within the LogInterface__c and LogInterfaceItem__c objects.
* Use this class whenever you want to create a custom log, for example, after an outbound 
* or inbound message.
*/
public with sharing class LogInterfaceHelper {
    
    /** Singleton approach */
    private static final LogInterfaceHelper instance = new LogInterfaceHelper();
    
    /** Private constructor to prevent the creation of instances of this class.*/
    private LogInterfaceHelper() {}
    
    @TestVisible private List<LogInterfaceItem__c> logItems;
    
    private Integer numSuccess 	= 0;
 
    @TestVisible private Integer numErrors 	= 0;
    
    /**
    * Method responsible for providing the instance of this class.
    * @return LogInterfaceHelper instance.
    */
    public static LogInterfaceHelper getInstance() {
        return instance;
    }
    
    /**
    * Method that creates the log and log items and whether to send or not an e-mail 
    * reporting the results.
    * @param the log interface record type
    * @param name of the class responsible for executing the interface
    * @param indicates when an e-mail must be sent with the outcome
    */
    public void createLog(String interfaceClass, Boolean gravaLog, String IntegrationType) {      
        LogInterface__c logHeader 		= new LogInterface__c();
        logHeader.Date__c 				= System.now();              
        logHeader.FailQuantity__c		= numErrors;
        logHeader.SuccessQuantity__c	= numSuccess;
        logHeader.Interface__c			= interfaceClass;
        logHeader.User__c				= UserInfo.getUserId();
        logHeader.Name 					= interfaceClass; 
        
         //***********************************
         Boolean vGravaLog = gravaLog;
        /*if (IntegrationType != ''){
        	IntegrationLog__c vIntegrationLog = [SELECT SaveLogSintegra__c, SaveLogECC__c from IntegrationLog__c where  Name =: IntegrationType LIMIT 1];
            if (IntegrationType == 'Sintegra'){
            	vGravaLog = vIntegrationLog.SaveLogSintegra__c;
            }
            else{
                vGravaLog = vIntegrationLog.SaveLogECC__c;
            }
        }
        */
        If(vGravaLog){        
            /** Inserts the log header */
            LogInterfaceDAO.getInstance().insertRecord(logHeader);
            
            /** If there are items, inserts them */
            if (logItems != null) {
                
                for (LogInterfaceItem__c logItem : logItems){
                    logItem.LogInterface__c = logHeader.Id;
                }
                LogInterfaceItemDAO.getInstance().insertLogItem(logItems);
            }
            
            /** When true, sends an e-mail reporting the outcome. In case of failure,
            * an exception is thrown */
            /*if (sendEmail)
                try {
                    //SendMail.SendLogInterfaceMail(logHeader);
                } catch (Exception e) {
                    LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
                    logItem.LogInterface__c 	= logHeader.Id;
                    logItem.FailDescription__c	= 'E-mail notification has not been sent. Message: ' + e.getMessage() + ' Cause: ' + e.getCause() +' Line: ' + e.getLineNumber();
                    logItem.StatusCode__c		= 'EMAIL_ERROR';       
                   // logItem.Item__c				= SendMail.class.getName();
                    
                    LogInterfaceItemBO.getInstance().insertLogItem(logItem);
                }       
*/
        }
        
        logItems = null;
        numSuccess 	= 0;
        numErrors 	= 0;          
    }
    
    /**
    * Method that creates the log and log items.
    * @param the log interface record type
    * @param name of the class responsible for executing the interface
    */    
    public void createLog(String interfaceClass) {
        createLog(interfaceClass, false, '');
    }

    
    /**
    * Method that creates the log and log items and whether to send or not an e-mail 
    * reporting the results.
    * @param res response 		object that contains the result of a request
    * @param interfaceClass 	name of the class responsible for executing the interface
    * @param processedClassName name of the class that performed the request
    */    
    public Boolean createLog(HttpResponse res, String interfaceClass, String processedClassName, Boolean commitLog) {
        Boolean isOK = res.getStatusCode() == 200;
        
        if (isOK) {
            numSuccess++;
        } else {
            numErrors++;
            
            LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
            System.debug(res.getBodyDocument().toXmlString());
            logItem.FailDescription__c	= res.getBodyDocument().toXmlString();
            logItem.StatusCode__c		= String.valueOf(res.getStatusCode()) +' '+ res.getStatus();
            logItem.Fields__c			= null;         
            logItem.Name				= processedClassName;
            addLogItem(logItem);    
        }
        
        if (commitLog)
        	createLog(interfaceClass);  
        
        return isOK;
    }
    
    public Boolean createLog(String reqBody, HttpResponse res, String interfaceClass, String processedClassName, Boolean commitLog) {
        Boolean isOK = res.getStatusCode() == 200;
        system.debug('isok ==> ' + isOK );
        if (isOK) {
            numSuccess++;
        } else {
            numErrors++;
            
            LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
            System.debug(res.getBodyDocument().toXmlString());
            logItem.FailDescription__c	= res.getBodyDocument().toXmlString();
            logItem.StatusCode__c		= String.valueOf(res.getStatusCode()) +' '+ res.getStatus();
            logItem.Fields__c			= null;         
            logItem.Name				= processedClassName;
            addLogItem(logItem);    
        }
        
        if (commitLog){
            addMessage(reqBody, interfaceClass);
        	createLog(interfaceClass);  
        }
        return isOK;
    }

    /**
    * Method that populates the log items with detailed information of the errors
    * @param errors 		array of Database.Error that contains detailed information
    * @param objectLabel 	label of the sObject in the transaction
    */        
    private void setErrors(Database.Error[] errors, String objectLabel) {
        for (Database.Error error : errors) {
            LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
            logItem.FailDescription__c	= error.getMessage();
            logItem.StatusCode__c		= String.valueOf(error.getStatusCode());
            logItem.Fields__c			= String.join(error.getFields(), ',');         
            logItem.Name				= objectLabel;
            addLogItem(logItem);
        }
        
    }

    /**
    * Method responsible for handling DML results of an insert or update operation,
    * counting and registering errors and success.
    * @param results 		collection of Dabase.SaveResult object
    * @param objectLabel 	label of the sObject in the transaction
    */            
    public void addResults(Database.SaveResult[] results, String objectLabel) {
        for (Database.SaveResult result: results) {
            if (result.isSuccess()) {
                numSuccess++;
            } else {
                numErrors++;
                setErrors(result.getErrors(), objectLabel);
            } 
        }
    }

    /**
    * Method responsible for handling DML results of an upsert operation,
    * counting and registering errors and success.
    * @param results 		collection of Dabase.SaveResult object
    * @param objectLabel 	label of the sObject in the transaction
    */           
    public Boolean addResults(Database.UpsertResult[] results, String objectLabel) { 
        for (Database.UpsertResult result: results) {
            if (result.isSuccess()) {
                numSuccess++;
            } else {
                numErrors++;
                setErrors(result.getErrors(), objectLabel);
            } 
        }   
        
        if(numErrors > 0) {
            return false;
        }else{
            return true;   
        }
    }
    
    /**
    * Method responsible for handling DML results of an upsert operation,
    * counting and registering errors and success.
    * @param results 		collection of Dabase.SaveResult object
    * @param objectLabel 	label of the sObject in the transaction
    */           
    public Boolean addResults(Database.DeleteResult[] results, String objectLabel) {    
        for (Database.DeleteResult result: results) {
            if (result.isSuccess()) {
                numSuccess++;
            } else {
                numErrors++;
                setErrors(result.getErrors(), objectLabel);
            } 
        }   
        
        if(numErrors > 0) {
            return false;
        }else{
            return true;   
        }
    }    
    
    /**
    * Method that adds a LogInterfaceItem__c object to a collection 
    * that will be persisted when the method createLog be invoked. 
    * @param results 		collection of Dabase.SaveResult object
    * @param objectLabel 	label of the sObject in the transaction
    */      
    public void addResults(Exception ex, String objectLabel) {
		numErrors++;
        LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
        logItem.FailDescription__c	= ex.getMessage() + '\n\n' + ex.getStackTraceString();
        logItem.Name				= objectLabel;

      	addLogItem(logItem);   
    }
    
    public void addError (String message, String objectLabel) {  
		numErrors++;
        LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
        logItem.FailDescription__c	= message;
        logItem.Name = objectLabel;

      	addLogItem(logItem);   
    }      

    public void addMessage (String message, String objectLabel){
        LogInterfaceItem__c logItem	= new LogInterfaceItem__c();
        logItem.Message__c			= message;
        logItem.Name				= objectLabel;

      	addLogItem(logItem);  
    }
    
    
    /**
    * Method that adds a LogInterfaceItem__c object to a collection 
    * that will be persisted when the method createLog be invoked. 
    */      
    public void addLogItem(LogInterfaceItem__c logItem) {     
                system.debug('Creating Log 2');
        system.debug('logItems ==>' + logItems);
        if (logItems == null)
            logItems = new List<LogInterfaceItem__c>();
       	system.debug('logitem ==> ' + logItem);
        logItems.add(logItem);
        system.debug('depois de inserir os dados');
       //insert logItems;
    }
    
    public Integer size() {
        system.debug('add size');
        return logItems.size();
    }
    
    public Boolean hasErrors() {
                system.debug('add has errors');
        return numErrors > 0;
    }
        
    public Integer addSuccess() {
                system.debug('add usceess');
        return numSuccess++;
    } 
    
    public Integer addError() {
                system.debug('add error sjkdjs');
        return numErrors++;
    }
    
    public Integer addSuccess(Integer qty) {
        return numSuccess += qty;
    } 
    
    public Integer addError(Integer qty) {
        return numErrors += qty;
    }       
}