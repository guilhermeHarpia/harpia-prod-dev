public with sharing class integ_ProductInchesConverterFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        
        String value = String.valueOf(externalDataMap.get('MAKTX'));
        
        value = value.replace('\'','"');
        
        return value;
    }
}