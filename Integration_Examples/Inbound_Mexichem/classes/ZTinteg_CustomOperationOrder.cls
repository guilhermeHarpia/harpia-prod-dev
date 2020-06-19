// TO IMPROVE
@isTest
private class ZTinteg_CustomOperationOrder
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
    	
    	Product2 product = ULTestData.createProduct('FITA VIDEO', '900000000000001010');
    	insert product;
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem = ULTestData.createInvoiceItem(invoice.Id, product.Id, '394368000010', 10);
    	insert invoiceItem;
    	
    	Case case1 = ULTestData.createCase(mapRecType.get('Substituicao'), account.Id, contact.Id, invoice.Id, 'Reclamação não procede', 'Aberto', 'Item', 'Transportadora', 'Email', 'email@seller.com', 'email@carrier.com');
    	insert case1;
    	
    	Order__c order1 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998713');
    	Order__c order2 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998714');
    	Order__c order3 = ULTestData.createOrder(account.Id, accountAreaSales.Id, '9998715');
    	List<Order__c> lstOrder = new List<Order__c>{order1, order2, order3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationOrder customOperationOrder = new integ_CustomOperationOrder();
    	
    	try {
    		Object test01 = customOperationOrder.execute(lstOrder);
    	}
    	catch (Exception ex) {}
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(customOperationOrder != null);
		//System.assert(test01 != null);
    }
}