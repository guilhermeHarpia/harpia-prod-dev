public with sharing class integ_ShippingItemCodeFormula implements IFormulaField {
    
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        return String.valueOf(externalDataMap.get('POSNR')) + String.valueOf(externalDataMap.get('VBELN')); 
    }
    
}