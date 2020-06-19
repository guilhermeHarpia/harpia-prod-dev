public with sharing class integ_CustomOperationSalesArea implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationSalesArea::execute() ' + recordList);
		List<AccountAreaSales__c> accAreaSaleList = new List<AccountAreaSales__c>();
		accAreaSaleList.addAll((List<AccountAreaSales__c>)recordList);
		
        //upsert accAreaSaleList CustomIdTxt__c;
        Database.UpsertResult[] resultList = Database.upsert(accAreaSaleList, AccountAreaSales__c.CustomIDTxt__c, false);
		integer i = 0;
		for (Database.UpsertResult result : resultList) {
			if (!result.isSuccess()) {
                EventQueueProcessException e = new EventQueueProcessException();
				String msg = '';
                for(Database.Error err : result.getErrors()) {             
                    msg = msg + err.getStatusCode() + ': ' + err.getMessage()+'\n';
                }                
                e.setMessage(msg);             
                throw e;
        		System.debug(LoggingLevel.INFO, '*** DML ERROR : integ_CustomOperationSalesArea::execute() ' + accAreaSaleList[i] +  result.getErrors());
			}
			i++;
		}        
		return accAreaSaleList;
	}
	
}