public with sharing class integ_OrderAccountAreaSalesFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		return String.valueOf(externalDataMap.get('KUNNR'))
			+  String.valueOf(externalDataMap.get('VKORG'))
			+  String.valueOf(externalDataMap.get('VTWEG'))
			+  String.valueOf(externalDataMap.get('SPART'));
	}
}