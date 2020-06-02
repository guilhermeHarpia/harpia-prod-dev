/*
Name: CloneManagerController
Author: Sandeep Kumar (Siemens) and Guilherme Oliveira (Harpia Cloud)
Date: 2019.10.15
Description: Controller Class for CloneManagerBso class
TestClass: CloneManagerTest
*/

public class CloneManagerController {
/*
    @AuraEnabled
    public static Map<String,List<Object>> retrieveRelatedObject(String recordId){
        return new CloneManagerBso().retrieveRelatedObject(recordId);
    }
*/    
    @AuraEnabled
    public static String retrieveRelatedObjectStructured(String recordId){
        return new CloneManagerBso().retrieveRelatedObjectStructured(recordId);
    }
/*    
    @AuraEnabled
    public static String startCloneProcess(String relatedDataJSON,Boolean startClone,String recordId){
        Map<String,List<Object>> relatedDataMap = (Map<String,List<Object>>)JSON.deserialize(relatedDataJSON, Map<String,List<Object>>.class);      
        return new CloneManagerBso().startCloneProcess(startClone,recordId,relatedDataMap);
    }
*/    
    @AuraEnabled
    public static String startCloneProcessStructured(String cloneStructureJSON ,Boolean startClone,String recordId){
        //Map<String,List<Object>> relatedDataMap = (Map<String,List<Object>>)JSON.deserialize(relatedDataJSON, Map<String,List<Object>>.class);      
        return new CloneManagerBso().startCloneProcessStructured(startClone,recordId,cloneStructureJSON);
    }
}