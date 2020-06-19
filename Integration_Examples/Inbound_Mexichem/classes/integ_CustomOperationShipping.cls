public with sharing class integ_CustomOperationShipping implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		
		List<Remittance__c> shippingList = new List<Remittance__c>();
		shippingList.addAll((List<Remittance__c>)recordList);
		
		Map<String, Remittance__c> shippingMap = new Map<String, Remittance__c>();
		
		//unify list by inv
		for (Remittance__c rem : shippingList) {
			shippingMap.put(rem.CustomIDTxt__c, rem);
		}

		System.debug('*** integ_CustomOperationShipping::execute() ' + shippingMap.values());
		
		upsert shippingMap.values() CustomIDTxt__c;
		
		return shippingMap.values();
	}
}