@isTest
private class ZTinteg_CustomOperationSalesArea
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales1 = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	AccountAreaSales__c accountAreaSales2 = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009091');
    	AccountAreaSales__c accountAreaSales3 = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009092');
    	List<AccountAreaSales__c> accountAreaSalesList = new List<AccountAreaSales__c>{accountAreaSales1, accountAreaSales2, accountAreaSales3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationSalesArea customOperationSalesArea = new integ_CustomOperationSalesArea();
    	
    	Object test01 = customOperationSalesArea.execute(accountAreaSalesList);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationSalesArea != null);
		System.assert(test01 != null);
    }
}