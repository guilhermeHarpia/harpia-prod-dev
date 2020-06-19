public with sharing class integ_FieldCastBoolean implements integ_IFieldCast {
    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 
    	if(fieldValue == null) {
    		return false;
    	} else if(String.valueOf(fieldValue).equals('')) {
    		return false;
    	} else if(String.valueOf(fieldValue).equals('C')) {
    		return true;
    	} else if(String.valueOf(fieldValue).equals('X')) {
    		return true;
    	} else {
    		return Boolean.valueOf(fieldValue);	
    	}
	}
}