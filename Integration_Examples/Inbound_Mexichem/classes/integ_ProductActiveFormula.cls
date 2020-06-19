public with sharing class integ_ProductActiveFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		return (externalDataMap.get('MVKE_PRAT1') != null) && (externalDataMap.get('MVKE_PRAT1') != ''); 
	}
}