/*
	Formula field with zero (left pad) length = 8
*/
public with sharing class integ_OrderCaseFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		String value = String.valueOf(externalDataMap.get('CASOSALESFORCE'));
		if(value.length() > 0) {
			value = StringUtil.leftPadding(8, '0', value);
		} else {
			return null;
		}
		return value;
	}
}