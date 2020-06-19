public with sharing class integ_CustomOperationContact implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationContact::execute() ' + recordList);
		List<Contact> contactList = new List<Contact>();
		contactList.addAll((List<Contact>)recordList);
				
		upsert contactList ContactCodeTxt__c;
		return contactList;
	}
}