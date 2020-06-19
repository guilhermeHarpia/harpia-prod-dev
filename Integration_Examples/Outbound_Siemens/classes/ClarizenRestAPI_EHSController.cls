/*
Name: ClarizenRestAPI_EHSController
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Controller for ClarizenRestAPI_EHS visualforce page (EHS file generator).
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPI_EHSController {
    public List<List<String>> pageAnswers {get;set;}
    
    public ClarizenRestAPI_EHSController() {
		String answersText = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('answers'), 'UTF-8');
        
        List<String> answersList = answersText.split('\\|;\\|');
        
        System.debug(answersList);
        pageAnswers = new List<List<String>>();
        for(String answer : answersList)
            pageAnswers.add(answer.split('\\|:\\|'));
    }
    
	@InvocableMethod
    public static void generateFile(List<String> answers) {
        //Each father list is a question.
        //Inside each child list there will be 0 - Question; 1 - Answer; 2 - Next step
        
        String answersRaw = answers.get(0);
        List<String> answerExploded = answersRaw.stripHtmlTags().split('\\|q\\|');
        String answersText = EncodingUtil.urlEncode(answerExploded.get(0), 'UTF-8');
        String quoteId = answerExploded.get(1);

        PageReference pageReference = new PageReference('/apex/ClarizenRestAPI_EHS?answers=' + answersText);
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        
        if(!Test.isRunningTest()) {
           	cv.VersionData = pageReference.getContent();
        } else {
            cv.VersionData = Blob.valueOf('Test file');
        }
        
        cv.Title = String.valueOf('EHS_' + quoteId);
        cv.PathOnClient = String.valueOf('EHS_' + quoteId + '.xls');
        cv.Send_to_Clarizen__c = true;
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = quoteId;
        cdl.ShareType = 'V';
        insert cdl;
    }
    
}