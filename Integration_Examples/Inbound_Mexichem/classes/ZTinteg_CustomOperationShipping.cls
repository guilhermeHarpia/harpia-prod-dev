// TO IMPROVE
@isTest
private class ZTinteg_CustomOperationShipping
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case', 'QM__c'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	account.CodeCustomerTxt__c = '999';
    	insert account;
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;    	
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	insert order1;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Remittance__c remittance1 = ULTestData.createRemittance('name', order1.Id, '99902888A', Date.today(), Date.today());
    	List<Remittance__c> remittanceList = new List<Remittance__c>{remittance1};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationShipping customOperationShipping = new integ_CustomOperationShipping();
    	
    	Object test01 = customOperationShipping.execute(remittanceList);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationShipping != null);
		System.assert(test01 != null);
    }
}