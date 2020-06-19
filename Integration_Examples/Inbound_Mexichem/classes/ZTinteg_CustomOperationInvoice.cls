@isTest
private class ZTinteg_CustomOperationInvoice
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Invoice__c invoice1 = ULTestData.createInvoice(carrier.Id, '02568');
    	invoice1.DocumentNumberTxt__c = '1001';
    	Invoice__c invoice2 = ULTestData.createInvoice(carrier.Id, '02567');
    	invoice2.DocumentNumberTxt__c = '1002';
    	Invoice__c invoice3 = ULTestData.createInvoice(carrier.Id, '02566');
    	invoice3.DocumentNumberTxt__c = '1003';
    	insert new List<Invoice__c>{invoice1, invoice2, invoice3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationInvoice customOperationInvoice = new integ_CustomOperationInvoice();
    	
    	Object test01 = customOperationInvoice.execute(new List<SObject>{invoice1, invoice2, invoice3});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationInvoice != null);
		System.assert(test01 != null);
    }
}