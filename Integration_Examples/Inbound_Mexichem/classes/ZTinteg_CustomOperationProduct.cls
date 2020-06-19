@isTest
private class ZTinteg_CustomOperationProduct
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
    	AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	Contact contact = ULTestData.createContact(mapRecType.get('ContactSAC'), account.Id, 'Testa', 'Tudo');
    	insert contact;
    	
    	Carrier__c carrier = ULTestData.createCarrier('Transporta tudo', 'teste@transportatudo.com.br');
    	insert carrier;
    	
    	Product2 product1 = ULTestData.createProduct('FITA VIDEO 1', '900000000000001011');
    	Product2 product2 = ULTestData.createProduct('FITA VIDEO 2', '900000000000001012');
    	Product2 product3 = ULTestData.createProduct('FITA VIDEO 3', '900000000000001013');
    	List<Product2> lstProduct = new List<Product2>{product1, product2, product3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationProduct customOperationProduct = new integ_CustomOperationProduct();
    	
    	Object test01 = customOperationProduct.execute(lstProduct);
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationProduct != null);
		System.assert(test01 != null);
    }
}