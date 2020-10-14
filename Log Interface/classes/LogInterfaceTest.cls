@isTest (SeeAllData = true) 
public class LogInterfaceTest{
	
	private static testMethod void logInterface(){
      //  IntegrationLog__c  logInt = new IntegrationLog__c();
    	//logInt.Name = 'Sintegra';
    	//logInt.SaveLogSintegra__c = false;
        //logInt.SaveLogECC__c = false;
        //insert logInt;
        
        
       	LogInterfaceBO logBO = LogInterfaceBO.getInstance();
		LogInterface__c log = new LogInterface__c();
		logBO.upsertLog(log);

		LogInterface__c log2 = new LogInterface__c();
		logBO.insertRecord(log2);
		logBO.getRecord(log2.Id);
	
		LogInterfaceItemBO logItemBO = LogInterfaceItemBO.getInstance();
		LogInterfaceItem__c logItem = new LogInterfaceItem__c();
		logItem.LogInterface__c = log.Id;
		LogInterfaceItem__c logItem2 = new LogInterfaceItem__c();
		logItem2.LogInterface__c = log.Id;
		List<LogInterfaceItem__c> logItemList = new List<LogInterfaceItem__c>();
		logItemList.add(logItem2);

		logItemBO.insertLogItem(logItem);
		logItemBO.insertLogItem(logItemList);
		logItemBO.lastInsertedRecord(log.Id);

		LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
		logHelper.createLog('Account');

		LogInterfaceItem__c logItem3 = new LogInterfaceItem__c();
		logHelper.logItems = new List<LogInterfaceItem__c>();
		logHelper.logItems.add(logItem3);
		logHelper.createLog('Account', true,'Sintegra');

		HttpResponse response = new HttpResponse();
		response.setStatusCode(201);
		response.setBody('<name>Anna</name>');
		logHelper.createLog(response, 'Account', 'Contact', true);
		logHelper.createLog('<name>Anna</name>', response, 'Account', 'Contact', true);

		response.setStatusCode(200);
		logHelper.createLog(response, 'Account', 'Contact', true);
		logHelper.createLog('<name>Anna</name>', response, 'Account', 'Contact', true);	
        
        //List<String> lista = new List<String>{'Contato','Conta','Oportunidade'};
        //String lista = 'Contato';
        LogInterfaceHelper logHelperIntegra = LogInterfaceHelper.getInstance();
        logHelperIntegra.createLog('Contato'); 
        //teste.authorization('Contato');
        
	}

	private static testMethod void databaseErrorsTest(){
		LogInterfaceHelper logHelper = LogInterfaceHelper.getInstance();
		LogInterface__c insertLog = new LogInterface__c();
		List<LogInterface__c> insertLogList = new List<LogInterface__c>();
		insertLogList.add(insertLog);
		Database.SaveResult[] saveResult = Database.insert(insertLogList, false);
		logHelper.addResults(saveResult, 'insertLog');

		saveResult = Database.insert(insertLogList, false);
		logHelper.addResults(saveResult, 'insertLog');
		logHelper.numErrors = 0;

		Database.UpsertResult[] upsResult = Database.upsert(insertLogList, false);
		logHelper.addResults(upsResult, 'insertLog');
		Database.DeleteResult[] delResult = Database.delete(insertLogList, false);
		logHelper.addResults(delResult, 'insertLog');

		List<Lead> errorList = new List<Lead>();
		Lead errorLead = new Lead();
		errorList.add(errorLead);
		upsResult = Database.upsert(errorList, false);
		logHelper.addResults(upsResult, 'insertLog');
		logHelper.numErrors = 0;

		List<Pricebook2> pbList = new List<Pricebook2>();
		Pricebook2 pb = new Pricebook2();
		pb.Id = Test.getStandardPricebookId();
		pbList.add(pb);
		delResult = Database.delete(pbList, false);
		logHelper.addResults(delResult, 'insertLog');

		try{
			delete pbList;
		} catch (Exception e){
			logHelper.addResults(e, 'Pricebook2');
		}

		logHelper.addError('Error message', 'Pricebook2');
		logHelper.hasErrors();
    	logHelper.addSuccess();    
    	logHelper.addError();    
    	logHelper.addSuccess(1); 
    	logHelper.addError(1); 
    }
}