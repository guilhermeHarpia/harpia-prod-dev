public class ImportLinesController {

    @AuraEnabled
    public static String uploadFile(String fileName, String contentFile, String contentType, Id recordId){
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c WHERE Id = :recordId];
        List<SBQQ__QuoteLine__c> listOldLines = [SELECT Id, Custom_Sort_Order__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordId ORDER BY Custom_Sort_Order__c DESC LIMIT 1];
        Decimal customSortOrder = 0;
        if(listOldLines.size() > 0 && listOldLines[0].Custom_Sort_Order__c != null){
            customSortOrder = listOldLines[0].Custom_Sort_Order__c;
        }
        List<SBQQ__QuoteLine__c> listNewLines = new List<SBQQ__QuoteLine__c>();
        
        List<String> fileLines = new List<String>();
        String nameFile;
        System.debug(contentType);
        system.debug(contentFile);
        system.debug(fileName);
        if(contentFile == null){
            return 'Favor escolher arquivo.';
        }
        if(contentType != 'application/vnd.ms-excel'){
            return 'Formato de arquivo inválido. Utilize .CSV';
        }
        try{
            nameFile = contentFile;
        }
        catch(exception e){
            return 'Erro na leitura do arquivo.';
        }
        if(nameFile.indexOf(',') == -1){
            return 'Utilize um CSV separado com ponto e vírgula';
        }
        
        try{
            filelines = nameFile.split('\n"');
            system.debug(filelines.size());
            if(filelines.size() > 1){
                String[] inputHeader = filelines[0].split('","');
                
                for (Integer i=1;i<filelines.size();i++){
                    customSortOrder += 10;
                    SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = recordId);
                    ql.Custom_Sort_Order__c = customSortOrder;
                    String[] inputvalues = filelines[i].split('","');
                    for(Integer j=0;j<inputvalues.size();j++){
                        String headerValue = inputHeader[j].trim().removeStart('"').removeEnd('"');
                        String inputValue = inputValues[j].trim().removeStart('"').removeEnd('"');
                        system.debug(headerValue);
                        system.debug(inputValue);
                        if(inputValue != ''){
                            if(headerValue == 'Product_Code__c'){
                                ql.SBQQ__Product__r = new Product2(Product_Code__c = (String)inputValue);
                            }
                            else{
                                Schema.SObjectField field = Schema.SObjectType.SBQQ__QuoteLine__c.fields.getMap().get(headerValue);
                                Schema.DisplayType fieldType = field.getDescribe().getType();
                                if(fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Currency || fieldType == Schema.DisplayType.Percent){
                                    String newInput = inputValue.replace(',','.');
                                    system.debug(newInput);
                                    ql.put(headerValue, Decimal.valueOf(newInput));
                                } else if(fieldType == Schema.DisplayType.Boolean){
                                    ql.put(headerValue, Boolean.valueOf(inputValue));
                                }
                                else{
                                    ql.put(headerValue, inputValue);
                                }
                                
                            }
                        }
                    }
                    listNewLines.add(ql);
                }
                upsert listNewLines;
            }
            else{
                return 'Erro na leitura do arquivo. Não foi identificada mais de uma linha.';
            }
        }
        catch(Exception e){
            return e.getMessage();
        }
        return JSON.serialize(listNewLines);
    }
    
    @AuraEnabled
    public static void addFile(String quoteId, String data, String fileName){
        system.debug(data);
        data = EncodingUtil.urlDecode(data, 'UTF-8');
        system.debug(data);
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf(data);
        cv.Title = fileName;
        cv.PathOnClient = String.valueOf(fileName + '.xlsm');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = quoteId;
        cdl.ShareType = 'V';
        insert cdl;
    }
    
}