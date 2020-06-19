public with sharing class integ_CustomOperationInvoice implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
        
        System.debug(LoggingLevel.INFO, '*** integ_CustomOperationInvoice::execute() ' + recordList);
		
		List<Invoice__c> invoiceList = new List<Invoice__c>();
		invoiceList.addAll((List<Invoice__c>)recordList);
		
		Map<String, Invoice__c> invoiceMap = new Map<String, Invoice__c>();
		
		//unify list by inv
		for (Invoice__c inv : invoiceList) {
			if (!invoiceMap.containsKey(inv.DocumentNumberTxt__c)) {
				invoiceMap.put(inv.DocumentNumberTxt__c, inv);
			}
		}
		
		invoiceList = invoiceMap.values(); 
		Database.UpsertResult[] resultList = Database.upsert(invoiceList, Invoice__c.DocumentNumberTxt__c, true);
		
		integer i = 0;
		for (Database.UpsertResult result : resultList) {
			if (!result.isSuccess()) {
        		System.debug(LoggingLevel.INFO, '*** DML ERROR : integ_CustomOperationInvoice::execute() ' + invoiceList[i] +  result.getErrors());
			}
			i++;
		}
		
		//integ_CustomOperationException
		
		return invoiceList;
	}
}