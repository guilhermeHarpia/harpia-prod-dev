public with sharing class integ_SaleAreaCustomIdFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		return String.valueOf(externalDataMap.get('KUNN2')) 
				+ String.valueOf(externalDataMap.get('VKORG'))
				+ String.valueOf(externalDataMap.get('VTWEG'))
				+ String.valueOf(externalDataMap.get('SPART'));
	}
}