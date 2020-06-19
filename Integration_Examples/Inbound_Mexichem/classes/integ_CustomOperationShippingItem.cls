public with sharing class integ_CustomOperationShippingItem implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationShippingItem::execute() ' + recordList);
		List<RemittanceItem__c> remItemList = new List<RemittanceItem__c>();
		remItemList.addAll((List<RemittanceItem__c>)recordList);
		upsert remItemList CustomIDTxt__c;
		return remItemList;
	}
	
}