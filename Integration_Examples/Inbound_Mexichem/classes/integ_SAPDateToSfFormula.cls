public with sharing class integ_SAPDateToSfFormula implements IFormulaField {
	public Object resolve(IntegrationMapItem__c item, Map<String, Object> externalDataMap) {
		
		String dateString = (String) externalDataMap.get(item.ExternalFieldNameTxt__c);
		
		//when date is null sap send 00000000
		//so if date is 00000000
		if (dateString == '00000000') {
			return null;
		} else if (dateString == null) {
			return null;
		} else if (dateString == '') {
			return null;
		}
		
		//System.debug('sap date: ' + dateString);
		
		String year = dateString.substring(0,4);
		String month = dateString.substring(4,6);
		String day = dateString.substring(6,8);
		
		return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
		
	}
}