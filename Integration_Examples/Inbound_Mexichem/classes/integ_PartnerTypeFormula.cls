public with sharing class integ_PartnerTypeFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        
        String value = String.valueOf(externalDataMap.get('KTOKD'));
        
        if(value=='REOR' || value=='PGFT') return value;
        else return null;
        //return value;
    }
}