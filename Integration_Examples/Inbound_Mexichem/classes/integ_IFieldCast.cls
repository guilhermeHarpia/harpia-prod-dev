public interface integ_IFieldCast {
	
	Object getValue(Map<String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
		IntegrationMapItem__c item, Object fieldValue);
		
}