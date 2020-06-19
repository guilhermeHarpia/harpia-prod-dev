@isTest
private class ZTinteg_SAPDateToSfFormula {
    static testMethod void testAll() {
    	
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'eventName', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	IntegrationMapItem__c integrationMapItem1 = ULTestData.createIntegrationMapItem(integrationMap.Id, 'Data', 'date', 'String');
    	insert integrationMapItem1;
    	
    	Map<String, Object> mapa1 = new Map<String, Object>(); 
    	mapa1.put(integrationMapItem1.ExternalFieldNameTxt__c, '20160506');
    	    	
    	System.Test.startTest();
    	
    	integ_SAPDateToSfFormula formula = new integ_SAPDateToSfFormula();
    	formula.resolve(integrationMapItem1, mapa1);
    	
    	System.Test.stopTest();
    	
    }
}