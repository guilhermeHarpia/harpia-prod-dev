@isTest
private class ZTinteg_CustomOperationAccount
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account'});

    	Account account1 = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina 1', '26830528000181');
    	account1.CodeCustomerTxt__c = '9999316649';
    	Account account2 = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina 2', '87619164000180');
    	account2.CodeCustomerTxt__c = '9999316650';
    	
    	// Start Test
		System.Test.startTest();
		testData.createSkipValidations();
    	integ_CustomOperationAccount customOperationAccount= new integ_CustomOperationAccount();
    	
    	Object test01 = customOperationAccount.execute(new List<SObject>{account1, account2});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationAccount != null);
		System.assert(test01 != null);
    }
}