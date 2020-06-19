@isTest
private class ZTinteg_FieldCastFormula {
     static testMethod void testAll() {
         IntegrationMapItem__c integItem = new IntegrationMapItem__c(FormulaClassName__c = 'integ_ProductActiveFormula');
         integ_FieldCastFormula f = new integ_FieldCastFormula();
         f.getValue(null, new Map<String, Object>{
             'MVKE_PRAT1' => 'x'
         }, integItem, null);
    }
}