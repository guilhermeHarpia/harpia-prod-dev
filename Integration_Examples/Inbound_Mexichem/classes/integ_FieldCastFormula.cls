public with sharing class integ_FieldCastFormula implements integ_IFieldCast {

    public Object getValue(Map <String, Schema.SObjectField> sObjectFieldMap, Map<String, Object> recordFieldMap, 
    	IntegrationMapItem__c fieldMapItem, Object fieldValue) { 

			Type formulaClass = Type.forName(fieldMapItem.FormulaClassName__c);
			IFormulaField formulaField = (IFormulaField)formulaClass.newInstance();
			return formulaField.resolve(fieldMapItem, recordFieldMap);
	}

}