@isTest
private class ZTinteg_CustomOperationContactAccount
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact'});

    	Account account1 = ULTestData.createAccountPF(mapRecType.get('PersonAccountSAC'), 'Testador da pagina 1', '53199747795');
    	account1.CodeCustomerTxt__c = '89990001';
    	Account account2 = ULTestData.createAccountPF(mapRecType.get('PersonAccountSAC'), 'Testador da pagina 2', '33877204759');
    	account2.CodeCustomerTxt__c = '89990002';
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationContactAccount customOperationContactAccount = new integ_CustomOperationContactAccount();
    	
    	Object test01 = customOperationContactAccount.execute(new List<SObject>{account1, account2});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationContactAccount != null);
		System.assert(test01 != null);
    }
}