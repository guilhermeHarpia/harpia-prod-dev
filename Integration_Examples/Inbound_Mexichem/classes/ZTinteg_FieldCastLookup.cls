@isTest
private class ZTinteg_FieldCastLookup {
    
     static testMethod void testAll() {

        Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get('Order__c');

		Map <String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe()
																.fields
																.getMap();
        
        IntegrationMapItem__c it = new IntegrationMapItem__c(
            TypeTxt__c = 'Lookup',
            InternalFieldNameTxt__c = 'CaseLkp__c',
            RelatedObjectExternalIdTxt__c = 'CustomIDTxt__c'
        );
        
        integ_FieldCastLookup f = new integ_FieldCastLookup();
        f.getValue(sObjectFieldMap, new Map<String, Object>{}, it, '');

     }
    
}