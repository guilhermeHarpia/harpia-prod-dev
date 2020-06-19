public with sharing class integ_FieldCastLookupFormula implements integ_IFieldCast {
    
    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 
		
		Schema.sObjectField field = sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c);
		Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
		
		Type formulaClass = Type.forName(fieldMapItem.FormulaClassName__c);
									IFormulaField formulaField = (IFormulaField)formulaClass.newInstance();
		
		SObject childObject = fieldDescribe.getReferenceTo()[0].newSObject();
		
		Object result = formulaField.resolve(fieldMapItem, recordFieldMap);
		
		if (result != null) {
			childObject.put(fieldMapItem.RelatedObjectExternalIdTxt__c, result);
		} else {
			childObject = null;
		}
		
		return childObject;
		
    }
    
}