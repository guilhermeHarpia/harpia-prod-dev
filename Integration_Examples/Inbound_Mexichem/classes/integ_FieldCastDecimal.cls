public with sharing class integ_FieldCastDecimal implements integ_IFieldCast {
    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) {
			if(fieldValue == null || String.valueOf(fieldValue) == '') return null;
			String stringValue = String.valueOf(fieldValue);
            if(stringValue.indexOf('-') == stringValue.length() - 1){
                stringValue = '-' + stringValue.substring(0,stringValue.length()-1);
            }
            return Double.valueOf(stringValue);
	}
}