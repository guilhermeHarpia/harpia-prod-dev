/*
Name: ClarizenRestAPI_PIPVController
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Controller for ClarizenRestAPI_PIPV visualforce page (PIPV generator).
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPI_PIPVController {
    public Map<String, ClarizenRestAPI_PIPVField> fields {get;set;}
    public List<String> fieldsKeys {get;set;}
    public Integer columnsCount {get;set;}
    
    public List<SBQQ__QuoteLine__c> quoteLines {get;set;}
    public integer linesCount {get;set;}
    
    public ClarizenRestAPI_PIPVController() {
        String pipvType = ApexPages.currentPage().getParameters().get('pipvType');
        String entryTaxCategory;
        
        if(pipvType.toLowerCase().equals('material')) {
            pipvType = 'Material';
            entryTaxCategory = 'Material';
        } else {
            pipvType = 'Service';
            entryTaxCategory = 'Serviço';
        }
        
        List<Clarizen_Integration_PIPV__mdt> rows = [SELECT MasterLabel, Quote_Line_Field__c, orderNum__c, PIPV_Type__c FROM Clarizen_Integration_PIPV__mdt WHERE PIPV_Type__c = :pipvType ORDER BY orderNum__c ASC LIMIT 100];

        fields = new Map<String, ClarizenRestAPI_PIPVField>();
        
        for(Clarizen_Integration_PIPV__mdt field : rows) {
            String fieldType = String.valueOf(Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap().get(field.Quote_Line_Field__c).getDescribe().getType());
            fields.put(field.Quote_Line_Field__c, new ClarizenRestAPI_PIPVField(field.MasterLabel, fieldType));
        }

        columnsCount = fields.size();
        
        if(columnsCount == 0)
            return;

        fieldsKeys = new List<String>(fields.keySet());
        Map<String, ClarizenRestAPI_PIPVField> columnsCopy = fields.clone();
        
        if(columnsCopy.keySet().contains('Id'))
        	columnsCopy.remove('Id');
        if(columnsCopy.keySet().contains('SBQQ__RequiredBy__c'))
        	columnsCopy.remove('SBQQ__RequiredBy__c');
        if(columnsCopy.keySet().contains('Custom_Sort_Order__c'))
        	columnsCopy.remove('Custom_Sort_Order__c');
        if(columnsCopy.keySet().contains('Tax_Category__c'))
        	columnsCopy.remove('Tax_Category__c');
        
        String fieldsString = String.join(new List<String>(columnsCopy.keySet()), ',');
        
        String quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        List<SBQQ__QuoteLine__c> lines = Database.query('SELECT Id,SBQQ__RequiredBy__c,Custom_Sort_Order__c,Tax_Category__c,' + fieldsString + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND Tax_Category__c = :entryTaxCategory ORDER BY Custom_Sort_Order__c ASC');
        
        linesCount = lines.size();
        
        if(linesCount == 0)
            return;
        
        Map<String, SBQQ__QuoteLine__c> quoteLinesMap = new Map<String, SBQQ__QuoteLine__c>();
        quoteLines = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c line : lines) {
            if(quoteLinesMap.containsKey(line.SBQQ__RequiredBy__c)) {
                quoteLines.add(quoteLines.indexOf(quoteLinesMap.get(line.SBQQ__RequiredBy__c)), line);
            } else
                quoteLines.add(line);
        }
    }
    
    private static void callPage(String quoteId, String pipvType) {
        PageReference pageReference = new PageReference('/apex/ClarizenRestAPI_PIPV?pipvType=' + pipvType + '&quoteId=' + quoteId);
    
            String fileName = String.valueOf('PIPV_' + pipvType + '_' + quoteId);
            
            ContentVersion cv = new ContentVersion();
            
            List<ContentVersion> checkCv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = :fileName];
            if(checkCv.size() > 0) {
                cv.ContentDocumentId = checkCv.get(0).ContentDocumentId;
            } else {
                cv.ContentDocumentId = null;
            }
            
            cv.ContentLocation = 'S';
            
            if(!Test.isRunningTest()) {
                cv.VersionData = pageReference.getContent();
            } else {
                cv.VersionData = Blob.valueOf('Test file');
            }
            
            cv.Title = fileName;
            cv.PathOnClient = String.valueOf(fileName + '.xls');
            cv.Send_to_Clarizen__c = true;
            insert cv;
            
            if(checkCv.size() == 0) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = quoteId;
                cdl.ShareType = 'V';
                insert cdl;
            }
    }
    
    @InvocableMethod
    public static List<String> generateAndAttachPIPV(List<Id> quotesId) {
        if(quotesId.size() == 0)
            return new List<String>();
        
        Id quoteId = quotesId.get(0);
        
        if(quoteId == null)
            return new List<String>();
		
		callPage(quoteId, 'Material');
        callPage(quoteId, 'Service');
        
        return new List<String>();
    }
    
    public class ClarizenRestAPI_PIPVField {
        public String fieldLabel{get;set;}
        public String fieldType{get;set;}
        
        public ClarizenRestAPI_PIPVField(String fieldLabel, String fieldType) {
            this.fieldLabel = fieldLabel;
            this.fieldType = fieldType;
        }
    }
}