@isTest
public class CloneManagerTest {
    
    @isTest
    public static void testCloneQuote(){
        Id standardPbId = Test.getStandardPricebookId();
        SBQQ__Quote__c quote = BrazilCPQDataFactory.createQuote('DG SYS', standardPbId);
        quote.Project_Start_Date__c = Date.newInstance(2019, 09, 01);
        quote.Project_Duration_Months__c = 4;
        insert quote;
        Product2 product = BrazilCPQDataFactory.createProduct('name', 'code');
        product.Create_Pricebook_Entry__c = false;
        insert product;
        PricebookEntry pbEntry = BrazilCPQDataFactory.createPBE(product.Id,standardPbId,'BRL',1);
        insert pbEntry;
        SBQQ__QuoteLine__c ql = BrazilCPQDataFactory.createQuoteLine(product.Id, quote.Id);
        ql.Cost_BRL__c = 20000;
        ql.SBQQ__UnitCost__c = 20000;
        ql.Business_Unit__c = 'DG SYS';
        ql.WBS__c = 'SAG (ExW)';
        insert ql;
        
        String cloneManagerString = CloneManagerController.retrieveRelatedObjectStructured(quote.Id);
        String newQuoteId = CloneManagerController.startCloneProcessStructured(cloneManagerString, true, quote.Id);
        
        CloneManagerBso.CloneStructure cloneStructure = (CloneManagerBso.CloneStructure) JSON.deserialize(cloneManagerString, CloneManagerBso.CloneStructure.class);
        cloneStructure.parentRecord.put('SBQQ__Pricebook__c', 'InvalidValue');
        
        try{
            CloneManagerController.startCloneProcessStructured(JSON.serialize(cloneStructure), true, quote.Id);
        }
        catch(Exception e){
            
        }
        
        SBQQ__Quote__c clonedQuote = [SELECT Id, SBQQ__Source__c FROM SBQQ__Quote__c WHERE Id =: newQuoteId];
        System.assertEquals(quote.Id, clonedQuote.SBQQ__Source__c);
        
    }

}