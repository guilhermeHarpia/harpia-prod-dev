@isTest
public class ZTinteg_JSONTransformer {
    
    public static testmethod void productImport(){
        
        IntegrationMap__c integ = new IntegrationMap__c(
        	Name = 'Integração de Produto',
            IntegrationId__c = 'SYNC_PRODUCT_INBOUND',
            SObjectApiNameTxt__c = 'Product2',
            DMLOperationTxt__c = 'Custom',
            CustomOperationClassName__c = 'integ_CustomOperationProduct',
            CommandClassName__c = 'GenericIntegrationService',
            OutputDataTypeTxt__c  = 'JSON'
        );
        insert integ;
        
        IntegrationMapItem__c integItem = new IntegrationMapItem__c(
            IntegrationMap__c = integ.Id,
            TypeTxt__c  = 'String',
            InternalFieldNameTxt__c = 'ProductCodeTxt__c',
            ExternalFieldNameTxt__c = 'MATNR'
        );
        insert integItem;
        
        
        Test.startTest();
        
        WSInBoundOrquestration.WSInBoundOrquestrationVO vo = new WSInBoundOrquestration.WSInBoundOrquestrationVO();
        vo.integrationId = 'SYNC_PRODUCT_INBOUND';
        vo.content = '[{"MAKTX":"FITA VIDEO","BREIT":"0.000 ","BRGEW":"0.149 ","EAN11":"","GEWEI":"KG","HOEHE":"0.000 ","LAENG":"0.000 ","MATNR":"000000000000001010","MEINS":"ST","NTGEW":"0.149 ","SPART":""}]';
        vo.isSync = true;
        
        WSInBoundOrquestration.executePost(vo);
        
        integ_JSONTransformer transf = new integ_JSONTransformer();
        transf.convertToRawData(new List<Contact>{});
        
        Test.stopTest();
        
    }
    
}