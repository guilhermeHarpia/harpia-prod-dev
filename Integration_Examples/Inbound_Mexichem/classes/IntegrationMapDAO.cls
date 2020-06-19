public with sharing class IntegrationMapDAO {
	
	public static List<IntegrationMap__c> getAll() {
		return [
			SELECT Id, Name, DMLOperationTxt__c, SObjectApiNameTxt__c, CommandClassName__c, IntegrationId__c, CustomOperationClassName__c, OutputDataTypeTxt__c,
			(SELECT Id, Name, IsRequired__c, DefaultValueTxt__c, ExternalFieldNameTxt__c, InternalFieldNameTxt__c, TypeTxt__c, RelatedObjectExternalIdTxt__c, FormulaClassName__c, IsActive__c FROM IntegrationMapItems__r ORDER BY NAME), 
			(SELECT Id, Name, ParentLkp__c, ChildLkp__c, ChildLkp__r.IntegrationId__c FROM IntegratioMapParents__r ORDER BY OrderNmb__c) 
			FROM IntegrationMap__c
			LIMIT 100
		];
	}
    
}