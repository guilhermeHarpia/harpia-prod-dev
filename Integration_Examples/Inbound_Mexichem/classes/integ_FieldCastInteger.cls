public with sharing class integ_FieldCastInteger implements integ_IFieldCast {
    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 
		return Integer.valueOf(fieldValue);
	}
}