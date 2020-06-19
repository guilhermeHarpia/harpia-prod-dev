public with sharing class integ_SaleAreaInactiveFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        return ((externalDataMap.get('AUFSD') != ''));
	}
}