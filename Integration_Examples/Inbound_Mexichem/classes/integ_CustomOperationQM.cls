public with sharing class integ_CustomOperationQM implements integ_IIntegrationOperation {
    public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationQM::execute() ' + recordList);
		List<QM__c> qmList = new List<QM__c>();
		qmList.addAll((List<QM__c>)recordList);
		upsert qmList SalesforceQMTxt__c;
		return qmList;
	}
}