public with sharing class integ_QmErrorFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		String value = String.valueOf(externalDataMap.get('MSGV1'));
		
		if(value != null && !value.equals('')) {
			value = value.replace(';', '\n');
			return value;
		} else return '';
	}
}