// TO IMPROVE
@isTest
private class ZTinteg_CustomOperationOrderItem
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
    	insert order1;
    	
    	OrderItem__c orderItem1 = ULTestData.createOrderItem(order1.Id, carrier.Id, '999001');
    	OrderItem__c orderItem2 = ULTestData.createOrderItem(order1.Id, carrier.Id, '999002');
    	OrderItem__c orderItem3 = ULTestData.createOrderItem(order1.Id, carrier.Id, '999003');
    	List<OrderItem__c> orderItemList = new List<OrderItem__c>{orderItem1, orderItem2, orderItem3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationOrderItem customOperationOrderItem = new integ_CustomOperationOrderItem();
    	
    	try {
    		Object test01 = customOperationOrderItem.execute(orderItemList);
    	}
    	catch (Exception ex) {}
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(customOperationOrderItem != null);
		//System.assert(test01 != null);
    }
}