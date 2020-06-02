/*
Name: CloneManagerDao
Author: Sandeep Kumar (Siemens) and Guilherme Oliveira (Harpia Cloud)
Date: 2019.10.15
Description: Custom clone with related class for cloning objects with custom related objects
TestClass: CloneManagerTest
*/

public class CloneManagerDao{
 
    public Schema.sObjectType reterieveSObjectType(String recordId){        
        return Id.valueOf(recordId).getSObjectType();
    }
    
    public List<Clone_Manager__mdt> retrieveRelatedObject(String parentObjectAPIName){
        
        return [SELECT 
                Id, 
                Child_Object__c,
                Child_Object_FieldSet__c,
                Parent_Lookup_Field__c,
                Parent_Object__c,
                Child_Columns_Fieldset__c
                FROM Clone_Manager__mdt 
                WHERE IsActive__c = true AND
                Parent_Object__c =:parentObjectAPIName];
    }
    
    public List<SObject> queryAllData(String fields,String childObject,String parentLookupField,String recordId){
        String finalQuery = 'SELECT ' + fields + ' FROM '+childObject+' WHERE '+parentLookupField+' =:recordId ORDER BY Name ASC';
        return Database.query(finalQuery);
    }
    
    

}