public with sharing class integ_OrderItemCodeFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		return String.valueOf(externalDataMap.get('VBELN')) + String.valueOf(externalDataMap.get('POSNR'));
	}
}