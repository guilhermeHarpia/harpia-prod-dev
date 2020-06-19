@isTest
private class ZTinteg_CustomOperationContact
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact'});

    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina 1', '26830528000181');
    	account.CodeCustomerTxt__c = '9999316649';
    	insert account;
    	
    	Contact contact1 = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa 1', 'Tudo');
    	contact1.ContactCodeTxt__c = '99901';
    	Contact contact2 = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa 2', 'Tudo');
    	contact2.ContactCodeTxt__c = '99902';
    	insert new List<Contact>{contact1, contact2};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationContact customOperationContact = new integ_CustomOperationContact();
    	
    	Object test01 = customOperationContact.execute(new List<SObject>{contact1, contact2});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationContact != null);
		System.assert(test01 != null);
    }
}