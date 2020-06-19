@isTest
private class ZTinteg_CustomOperationQM
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case', 'QM__c'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;    	
    	
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
    	
    	CaseItem__c caseItem1 = ULTestData.createCaseItem(case1.Id, '999550000037unAAAQ01t55000000JhBjAAK', 'failureType', 'comments', 'qualityProblem');
    	caseItem1.ProductLkp__c = product.Id;
    	insert caseItem1;
    	
    	QM__c qm = ULTestData.createQM(mapRecType.get('QMReclamacao'), case1.Id);
    	qm.SalesforceQMTxt__c = '99001';
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CustomOperationQM customOperationQM = new integ_CustomOperationQM();
    	
    	Object test01 = customOperationQM.execute(new List<SObject>{qm});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(customOperationQM != null);
		System.assert(test01 != null);
    }
}