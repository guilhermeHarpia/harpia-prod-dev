public with sharing class integ_QmSalesforceFormula implements IFormulaField {
    public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		String value = String.valueOf(externalDataMap.get('NQMSF'));
		String caso = value.split('QM')[0];
		caso = StringUtil.leftPadding(8, '0', caso);
		value = caso + 'QM' + value.split('QM')[1];
		return value;
	}
}