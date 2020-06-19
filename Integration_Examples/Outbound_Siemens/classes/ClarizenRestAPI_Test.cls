/*
Name: ClarizenRestAPI_Test
Author: Luiz Almeida (RC-BR IT PTM) and Harpia Cloud
Date: 2019.11.10
Description: Testing Class for all classes used in Clarizen Integration:
                ClarizenRestAPI, ClarizenRestAPIHandler, ClarizenRestAPIField, ClarizenRestAPI_PIPVController,
                ClarizenRestAPI_EHSController, ClarizenRestAPIHandler, ClarizenRestAPI_MultiMock, ClarizenRestAPI_SingleMock, ClarizenRestAPILink
*/
@isTest
private class ClarizenRestAPI_Test {

    static testmethod void initiateTest() {
        Account testAccount = BrazilCPQDataFactory.createAccount('COPEL', '12345-345');
        testAccount.Phone = '+55 11 4004-4004';
        testAccount.S4STax_ID__c = '1245';
        testAccount.BillingCountry = 'Brazil';
        testAccount.BillingStateCode = 'SP';
		insert testAccount;
        
       	Id standardPbId = Test.getStandardPricebookId();
        
        Product2 testProduct = BrazilCPQDataFactory.createProduct('name', 'code');
        testProduct.Create_Pricebook_Entry__c = false;
        insert testProduct;
        
        PricebookEntry pbEntry = BrazilCPQDataFactory.createPBE(testProduct.Id, standardPbId, 'BRL', 1);
        insert pbEntry;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today().addDays(30);
        opp.AccountId = testAccount.Id;
        opp.Pricebook2Id = standardPbId;
        opp.SieSales_Opportunity_ID__c = '006XXXXXXXXXXXX';
        insert opp;

        SBQQ__Quote__c testQuote = BrazilCPQDataFactory.createQuote('DG SYS', standardPbId);
        testQuote.Project_Start_Date__c = Date.newInstance(2019, 09, 01);
        testQuote.Project_Duration_Months__c = 4;
        testQuote.SBQQ__Account__c = testAccount.Id;
        testQuote.SBQQ__Opportunity2__c = opp.Id;
        insert testQuote;
        
        SBQQ__QuoteLine__c testQuoteLine = BrazilCPQDataFactory.createQuoteLine(testProduct.Id, testQuote.Id);
        testQuoteLine.Cost_BRL__c = 20000;
        testQuoteLine.SBQQ__UnitCost__c = 20000;
        testQuoteLine.Business_Unit__c = 'DG SYS';
        testQuoteLine.WBS__c = 'SAG (ExW)';
        insert testQuoteLine;
        
        testQuote.ApprovalStatus__c = 'Approved';
        testQuote.SBQQ__Primary__c = true;
        update testQuote;
                
        Order testOrder = new Order(AccountId = testAccount.Id, SBQQ__Quote__c = testQuote.Id, OpportunityId = opp.Id);
        testOrder.EffectiveDate = SYstem.today().addDays(30);
        testOrder.Status = 'Draft';
        insert testOrder;
        
        List<String> quoteIdList = new List<String>();
        quoteIdList.add(testOrder.Id);
       
        ClarizenRestAPI_PIPVController.generateAndAttachPIPV(quoteIdList);
        
        ClarizenRestAPI_MultiMock mock = new ClarizenRestAPI_MultiMock();
        mock.addRequestMock('callout:ClarizenAPI/authentication/login', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"sessionId" : "SESSION_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/data/objects/Customer', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"id" : "CUSTOMER_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/data/objects/Project', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"id" : "PROJECT_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/data/objects/Document', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"id" : "DOCUMENT_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/data/objects/customerlink', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"id" : "LINK_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/bulk/execute', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"id" : "BULK_ID"}', null));
        mock.addRequestMock('callout:ClarizenAPI/data/entityQuery', new ClarizenRestAPI_SingleMock(200, 'Complete', '{"entities" : []}', null));
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        ClarizenRestAPI.initiateIntegrationProcess(quoteIdList);

		List<Interface_Queue__c> interfaceQueues = [SELECT Id, Requested_URL__c, Status__c FROM Interface_Queue__c];
		
        Test.stopTest();
        
        System.debug(interfaceQueues);
    }
    
}