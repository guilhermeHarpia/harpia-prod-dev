public with sharing class integ_SAPBooleanToSfFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
        Boolean aux = externalDataMap.get(item.ExternalFieldNameTxt__c) == 'X';
        System.debug(aux);
        return aux;
	}
}