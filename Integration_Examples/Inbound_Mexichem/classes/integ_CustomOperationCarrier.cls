public with sharing class integ_CustomOperationCarrier implements integ_IIntegrationOperation {
	
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationCarrier::execute() ' + recordList);
		List<Carrier__c> carrierList = new List<Carrier__c>();
		carrierList.addAll((List<Carrier__c>)recordList);
		upsert carrierList CodeCarrierTxt__c;
		return carrierList;
	}
	
}