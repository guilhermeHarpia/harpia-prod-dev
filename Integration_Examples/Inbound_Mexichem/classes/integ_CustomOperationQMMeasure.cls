public with sharing class integ_CustomOperationQMMeasure implements integ_IIntegrationOperation {
    public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationQMMeasure::execute() ' + recordList);
		List<QMMeasure__c> qmMeasureList = new List<QMMeasure__c>();
		qmMeasureList.addAll((List<QMMeasure__c>)recordList);
		
		List<QMMeasure__c> auxList = new List<QMMeasure__c>();
		
		for(QMMeasure__c aux : qmMeasureList) {
			if(aux.QMLineNmb__c != null && aux.QMLineNmb__c != 0) {
				auxList.add(aux);
			}
		}
		
		upsert auxList CustomIDTxt__c;
		return qmMeasureList;
	}
}