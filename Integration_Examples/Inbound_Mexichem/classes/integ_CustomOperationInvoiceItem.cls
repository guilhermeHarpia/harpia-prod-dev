public with sharing class integ_CustomOperationInvoiceItem implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
        System.debug(LoggingLevel.INFO, '*** integ_CustomOperationInvoiceItem::execute() ' + recordList);
		List<InvoiceItem__c> invoiceItemList = new List<InvoiceItem__c>();
		invoiceItemList.addAll((List<InvoiceItem__c>)recordList);
		upsert invoiceItemList CustomIDTxt__c;
		return invoiceItemList;
	}
	
}