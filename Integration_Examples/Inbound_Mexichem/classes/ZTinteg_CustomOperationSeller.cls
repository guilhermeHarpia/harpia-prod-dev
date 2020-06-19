@isTest
private class ZTinteg_CustomOperationSeller
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Seller__c seller1 = ULTestData.createSeller('John Doe 1', '1000');
    	Seller__c seller2 = ULTestData.createSeller('John Doe 2', '1001');
    	Seller__c seller3 = ULTestData.createSeller('John Doe 3', '1002');
    	List<Seller__c> sellerList = new List<Seller__c>{seller1, seller2, seller3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationSeller customOperationSeller = new integ_CustomOperationSeller();
    	
    	Object test01 = customOperationSeller.execute(sellerList);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationSeller != null);
		System.assert(test01 != null);
    }
}