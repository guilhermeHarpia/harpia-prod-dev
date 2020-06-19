@isTest
private class ZTinteg_CustomOperationCarrier
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Carrier__c carrier1 = ULTestData.createCarrier('name1', 'carrier1@email.com.br');
    	carrier1.CodeCarrierTxt__c = '999001';
    	Carrier__c carrier2 = ULTestData.createCarrier('name2', 'carrier2@email.com.br');
    	carrier2.CodeCarrierTxt__c = '999002';
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationCarrier customOperationCarrier = new integ_CustomOperationCarrier();
    	
    	Object test01 = customOperationCarrier.execute(new List<SObject>{carrier1, carrier2});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationCarrier != null);
		System.assert(test01 != null);
    }
}