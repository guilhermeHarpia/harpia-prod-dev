public with sharing class integ_CustomOperationContactAccount implements integ_IIntegrationOperation {
    public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationAccountContact::execute() ' + recordList);
		List<Account> accountContactList = new List<Account>();
		
		RecordType rt = [Select Id from RecordType where DeveloperName = 'SAPPersonAccount'];
		
		for(Account acc : (List<Account>)recordList) {
			acc.RecordTypeId = rt.Id;
			accountContactList.add(acc);
		}
		
		//accountContactList.addAll((List<Account>)recordList);
		upsert accountContactList CodeCustomerTxt__c;
		return accountContactList;
	}
}