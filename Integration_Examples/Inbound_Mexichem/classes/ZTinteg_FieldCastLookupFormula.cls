@isTest
private class ZTinteg_FieldCastLookupFormula {
    static testMethod void testAll() {

		Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get('Order__c');

		Map <String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe()
																.fields
																.getMap();
        
        IntegrationMapItem__c it = new IntegrationMapItem__c(
            InternalFieldNameTxt__c = 'CaseLkp__c',
            RelatedObjectExternalIdTxt__c = 'CustomIDTxt__c',
            FormulaClassName__c = 'integ_OrderCaseFormula',
            TypeTxt__c = 'Lookup Formula'
        );
        
        integ_FieldCastLookupFormula f = new integ_FieldCastLookupFormula();
        f.getValue(sObjectFieldMap, new Map<String, Object>{
            'CASOSALESFORCE' => 1
        }, it, '');
        
    }
}