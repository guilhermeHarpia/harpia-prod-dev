@isTest
private class ZTinteg_CustomOperationAddress
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account'});

    	Account account1 = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina 1', '26830528000181');
    	account1.CodeCustomerTxt__c = '9999316649';
    	Account account2 = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina 2', '87619164000180');
    	account2.CodeCustomerTxt__c = '9999316650';
    	insert new List<Account>{account1, account2};
    	
    	Address__c address1 = ULTestData.createAddress(account1.Id, '99901', 'Barra', '99999-999', 'Rio de Janeiro', 'RJ');
    	Address__c address2 = ULTestData.createAddress(account2.Id, '99902', 'Centro', '99999-999', 'Rio de Janeiro', 'RJ');
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationAddress customOperationAddress = new integ_CustomOperationAddress();
    	
    	Object test01 = customOperationAddress.execute(new List<SObject>{address1, address2});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationAddress != null);
		System.assert(test01 != null);
    }
}