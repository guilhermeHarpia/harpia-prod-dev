@isTest
private class ZTinteg_CustomOperationInvoiceItem
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
    	
    	Product2 product1 = ULTestData.createProduct('FITA VIDEO 1', '900000000000001010');
    	Product2 product2 = ULTestData.createProduct('FITA VIDEO 2', '900000000000001011');
    	Product2 product3 = ULTestData.createProduct('FITA VIDEO 3', '900000000000001012');
    	insert new List<Product2>{product1, product2, product3};
    	
    	Invoice__c invoice = ULTestData.createInvoice(carrier.Id, '02568');
    	insert invoice;
    	
    	InvoiceItem__c invoiceItem1 = ULTestData.createInvoiceItem(invoice.Id, product1.Id, '394368000010', 10);
    	InvoiceItem__c invoiceItem2 = ULTestData.createInvoiceItem(invoice.Id, product2.Id, '394368000011', 10);
    	InvoiceItem__c invoiceItem3 = ULTestData.createInvoiceItem(invoice.Id, product3.Id, '394368000012', 10);
    	insert new List<InvoiceItem__c>{invoiceItem1, invoiceItem2, invoiceItem3};
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationInvoiceItem customOperationInvoiceItem = new integ_CustomOperationInvoiceItem();
    	
    	Object test01 = customOperationInvoiceItem.execute(new List<SObject>{invoiceItem1, invoiceItem2, invoiceItem3});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationInvoiceItem != null);
		System.assert(test01 != null);
    }
}