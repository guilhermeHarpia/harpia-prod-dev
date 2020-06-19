// TO IMPROVE
@isTest
private class ZTinteg_CustomOperationShippingItem
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
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;    	
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	insert order1;
    	
    	OrderItem__c orderItem1 = ULTestData.createOrderItem(order1.Id, carrier.Id, '999001');
    	insert orderItem1;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Remittance__c remittance = ULTestData.createRemittance('name', order1.Id, '99902888A', Date.today(), Date.today());
    	insert remittance;
    	
    	RemittanceItem__c remittanceItem1 = ULTestData.createRemittanceItem(remittance.Id, product.Id, orderItem1.Id, '9990101');
    	List<RemittanceItem__c> remittanceItemList = new List<RemittanceItem__c>{remittanceItem1};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationShippingItem customOperationShippingItem = new integ_CustomOperationShippingItem();
    	
    	Object test01 = customOperationShippingItem.execute(remittanceItemList);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationShippingItem != null);
		System.assert(test01 != null);
    }
}