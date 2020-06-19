public with sharing class integ_CustomOperationAddress implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationAddress::execute() ' + recordList);
		List<Address__c> addressList = new List<Address__c>();
		addressList.addAll((List<Address__c>)recordList);
		upsert addressList CustomIDTxt__c;
		return addressList;
	}
}