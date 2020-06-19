public with sharing class integ_ShippingItemOrderItem implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        return String.valueOf(externalDataMap.get('VGBEL'))
            +  String.valueOf(externalDataMap.get('VGPOS'));
    }
}