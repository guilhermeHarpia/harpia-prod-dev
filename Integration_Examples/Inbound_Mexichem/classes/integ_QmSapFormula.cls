public with sharing class integ_QmSapFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		String value = String.valueOf(externalDataMap.get('QMNUMSAP'));
		
		if(value == null || value.equals('')) {
			return ' ';
		} else {
			return value;
		}
	}
}