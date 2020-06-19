public with sharing class integ_FieldCastLookup implements integ_IFieldCast {

    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 
    		
    		SObject childObject = null;
			Schema.sObjectField field = sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c);
			
			if (field != null) {
				
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				childObject = fieldDescribe.getReferenceTo()[0].newSObject();

				System.debug('*** ' + field + childObject);
				System.debug('*** fieldDescribe' + fieldDescribe + childObject);
				System.debug('*** fieldMapItem.RelatedObjectExternalIdTxt__c' + fieldMapItem.RelatedObjectExternalIdTxt__c);
				
				if (fieldValue != null) {
					childObject.put(fieldMapItem.RelatedObjectExternalIdTxt__c, String.valueOf(fieldValue));
				} else {
					return null;
				}
			}
			
			return childObject;
    	}
    
}