public with sharing class integ_QmMeasureCodeFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        return String.valueOf(externalDataMap.get('NQMSF')) + String.valueOf(externalDataMap.get('MANUM')); 
    }
}