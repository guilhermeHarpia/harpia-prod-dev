public with sharing class integ_InvoiceItemCodeFormula implements IFormulaField {
    
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        return String.valueOf(externalDataMap.get('DOCNUM')) + String.valueOf(externalDataMap.get('ITMNUM')); 
    }
    
}