/*
Name: ClarizenRestAPI
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Main class for Clarizen Integration. Holds all methods used from map load to final JSON data.
TestClass: ClarienRestAPI_Test
*/
public without sharing class ClarizenRestAPI {
    
    private static boolean debugging = true;
    public static List<Interface_Queue__c> interfaceQueues = new List<Interface_Queue__c>();
    private static List<sObject> objectsToUpdate = new List<sObject>();
    
	@InvocableMethod
    public static List<String> initiateIntegrationProcess(List<Id> startObjectId) {
        String startObjectGeneratedId = SalesforceToClarizen(startObjectId.get(0));
        
        insert interfaceQueues;
        update objectsToUpdate;
        
        List<String> result = new List<String>();
        result.add(startObjectGeneratedId);
        return result;
    }
    
    //Generate Clarizen Entity and return it's new ID
    public static String SalesforceToClarizen(Id objectId) {
        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectId + '] BEGIN');
        
        String keyField = null, alreadyExistingId = null, finalId = null;
        
        //List of child links that should be created after the main Entity is created
        List<ClarizenRestAPILink> childLinks = new List<ClarizenRestAPILink>();
        
        //List of WBS Mapping that should be executed after the main Entity is created
        Map<String, Id> wbsMappings = new Map<String, Id>();
        
        //Get current Salesforce object type
        String objectType = String.valueOf(objectId.getSObjectType());
        
        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectId + '] Object Type: ' + objectType);
        
        //Get all fields enabled for this object type
        Map<String, SObjectField> objectFieldMap = getObjectFieldMap(objectType);
        
        //Get all fields mapped to the correspondent Clarizen entity
        Map<String, Clarizen_Integration_Mapping__mdt> clarizenFieldMap = getClarizenFieldMap(objectType);
        
        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Mapped Fields: ' + clarizenFieldMap.size());

        //Checks if there are active mapped fields
        if(clarizenFieldMap.size() == 0) {
            if(debugging) System.debug('[WARNING][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] There are no mapped fields for this Salesforce Object.');

            return null;
        }
        
        //Fields to be added to the new Clarizen entity
        Map<String, ClarizenRestAPIField> newClarizenEntityFields = new Map<String, ClarizenRestAPIField>();
        
        //Fields validated to be selected from DB
        List<String> objectFieldsToSelect = new List<String>();
        
        //Loop to validate mapped fields
        for(String fieldName : clarizenFieldMap.keySet()) {
            Clarizen_Integration_Mapping__mdt clarizenField = clarizenFieldMap.get(fieldName);
   
            //Checks if this field is avaiable in this object
            if(clarizenField.Salesforce_Field__c.indexOf('.') != -1) {
                String relationshipName = clarizenField.Salesforce_Field__c.split('\\.')[0];
                String relationshipFieldName = clarizenField.Salesforce_Field__c.split('\\.')[1];
                String relationshipObject = relationshipName.replace('__r', '__c');                
                
                if(!getObjectFieldMap(relationshipObject).containsKey(relationshipFieldName)) {
                    if(debugging) System.debug('[ERROR][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Field not found on Salesforce Object (' + clarizenField.Salesforce_Field__c + ').');
                    clarizenFieldMap.remove(fieldName);
                    continue;
                }
            } else if(!objectFieldMap.containsKey(clarizenField.Salesforce_Field__c)) {
                if(debugging) System.debug('[ERROR][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Field not found on Salesforce Object (' + clarizenField.Salesforce_Field__c + ').');
                clarizenFieldMap.remove(fieldName);
                continue;
            }
            
            if(!objectFieldsToSelect.contains(clarizenField.Salesforce_Field__c))
            	objectFieldsToSelect.add(clarizenField.Salesforce_Field__c);
        }
        
        //Checks if there are fields to select
        if(objectFieldsToSelect.size() == 0) {
            if(debugging) System.debug('[WARNING][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] There are no valid mapped fields for this Salesforce Object.');
            
        	return null;
        }
        
        if(objectType.equals('Order')) {
            objectFieldsToSelect.add('SBQQ__Quote__c');
        }
        
        //Gets the record for the provided ID
        sObject record = Database.query('SELECT ' + String.join(objectFieldsToSelect, ', ') + ' FROM ' + objectType + ' WHERE Id = :objectId');
        
        for(String fieldName : clarizenFieldMap.keySet()) {
            Clarizen_Integration_Mapping__mdt clarizenField = clarizenFieldMap.get(fieldName);
            
            //Check if this is the key field
            if(clarizenField.Primary_Key__c)
                keyField = fieldName;
            
            String fieldType, fieldValue, originalFieldValue, fieldLabel;
            DescribeFieldResult fieldDescribe;
            
            try {
                fieldDescribe = objectFieldMap.get(clarizenField.Salesforce_Field__c).getDescribe();
                fieldType = String.valueOf(fieldDescribe.getType());
                fieldLabel = String.valueOf(fieldDescribe.getLabel());
            } catch (Exception e) {
                fieldType = '';
                fieldLabel = '';
            }
            
            if(clarizenField.Salesforce_Field__c.indexOf('.') != -1) {
                String relationshipName = clarizenField.Salesforce_Field__c.split('\\.')[0];
                String relationshipFieldName = clarizenField.Salesforce_Field__c.split('\\.')[1];
                
                fieldDescribe = getObjectFieldMap(relationshipName.replace('__r', '__c')).get(relationshipFieldName).getDescribe();
                fieldType = String.valueOf(fieldDescribe.getType());
                fieldLabel = String.valueOf(fieldDescribe.getLabel());
                originalFieldValue = String.valueOf(record.getSobject(relationshipName).get(relationshipFieldName));
            } else
                originalFieldValue = String.valueOf(record.get(clarizenField.Salesforce_Field__c));

            //Relationship handler
            if(fieldType.contains('REFERENCE') && originalFieldValue != null && !originalFieldValue.equals('')) {
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Begin Reference Handler: ' + clarizenField.Salesforce_Field__c);
                
                //Execute itself again for the referenced object
                fieldValue = SalesforceToClarizen(originalFieldValue);
                
                if(fieldValue == null) {
                    if(debugging) System.debug('[ERROR][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Reference Handler returned an empty ID for ' + clarizenField.Salesforce_Field__c);
                	continue;
                }
                
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Continue Reference Handler: ' + clarizenField.Salesforce_Field__c);
                
                Clarizen_Integration__mdt clarizenChildEntityInfo = getClarizenEntityInfo(String.valueOf(Id.valueOf(originalFieldValue).getSObjectType()));
                
                if(clarizenChildEntityInfo.Create_Link__c) {
                    if(clarizenChildEntityInfo.Link_Endpoint__c == null) {
                        if(debugging) System.debug('[ERROR][SalesforceToClarizen: ' + objectType + ': ' + objectId + '][Reference Handler: ' + clarizenField.Salesforce_Field__c + '] There is no Endpoint to create the Link for this reference.');
                    } else {
                        //Queue link to be created when parent Entity be created
                        childLinks.add(new ClarizenRestAPILink(clarizenChildEntityInfo.Link_Endpoint__c, clarizenChildEntityInfo.Clarizen_Entity__c, fieldValue));
                        
                        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Reference Link Queued: ' + clarizenChildEntityInfo.Clarizen_Entity__c);
                    }
                }
                
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] End Reference Handler: ' + clarizenField.Salesforce_Field__c);
            } else {
                fieldValue = originalFieldValue;
                
                if(fieldValue == null)
                    fieldValue = '';
                
                if(fieldValue.length() > 0) {
                    boolean isQuoted = true;
                    
                    if(fieldLabel.contains('%')) {
                        fieldType = 'PERCENT';
                        
                        if(fieldValue.indexOf('%') > -1)
                        	fieldValue = fieldValue.replace('%', '');
                    }
                    
                    //Define if this field should be quoted in JSON (number and boolean format shouldn't be)
                    if(fieldType.contains('CURRENCY') | fieldType.contains('DOUBLE') | fieldType.contains('PERCENT') | fieldType.contains('BOOLEAN')) {
                        isQuoted = false;
                        
                        if(fieldValue == null)
                            fieldValue = '0';
                        
                        if(fieldType.contains('CURRENCY') | fieldType.contains('DOUBLE'))
                            fieldValue = String.valueOf(Decimal.valueOf(fieldValue).setScale(2, RoundingMode.HALF_UP));
                    }
                    
                    if(fieldType.equals('DATE') && fieldValue.contains(' ')) {
                        String[] explodedDate = fieldValue.split(' ')[0].split('-');
                        
                        //+1 day because Clarizen API is decreasing dates by 1
                        Date dateInstance = Date.newInstance(Integer.valueOf(explodedDate[0]), Integer.valueOf(explodedDate[1]), Integer.valueOf(explodedDate[2]));
                        fieldValue = String.valueOf(dateInstance.addDays(1));
                    }
                    
                    //Add this field to the new Clarizen Entity
                    newClarizenEntityFields.put(fieldName, new ClarizenRestAPIField(fieldValue, isQuoted));
                }
            }
        }
        
        //Get Clarizen Entity Info
        Clarizen_Integration__mdt clarizenEntityInfo = getClarizenEntityInfo(objectType);
        
        //Check if there is a record in Clarizen based on this key field
       if(keyField != null && newClarizenEntityFields.get(keyField) != null && newClarizenEntityFields.get(keyField).getValue() != null) {
            Map<String, String> searchFields = new Map<String, String>();
            searchFields.put(keyField, newClarizenEntityFields.get(keyField).getValue());
            
           	alreadyExistingId  = ClarizenRestAPIHandler.queryEntity(clarizenEntityInfo.Clarizen_Entity__c, searchFields);
        }
        
        //If the record already exists, return it and don't create a new one
        if(alreadyExistingId != null) {
            if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Clarizen Entity (' + clarizenEntityInfo.Clarizen_Entity__c + ') Record found: ' + alreadyExistingId);
            
            finalId = alreadyExistingId;
        } else {
            if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Clarizen Entity Record not found');
            
            //If this Clarizen Entity is read-only, we should not create it
            if(clarizenEntityInfo.Read_Only__c)
                finalId = null;
            else {
                //Get JSON format
                String jsonMap = mapToJson(newClarizenEntityFields);
                
                //Create Clarizen Entity and return it's ID
                String generatedId = ClarizenRestAPIHandler.createEntity(clarizenEntityInfo.Clarizen_Entity__c, jsonMap, new Interface_Queue__c(Service_Name__c = 'Clarizen Rest API', Digioffer_ID__c = objectId, Object_Type__c = objectType, External_Object_Type__c = clarizenEntityInfo.Clarizen_Entity__c, Status__c = 'Pending'));
                
                if(generatedId != null) {
                	if(debugging) System.debug('[SUCCESS][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Clarizen Entity (' + clarizenEntityInfo.Clarizen_Entity__c + ') created: ' + generatedId);
                	
                    if(clarizenEntityInfo.Store_Generated_ID__c) {
                        sObject objectToUpdate = Database.query('SELECT Id, Clarizen_ID__c FROM ' + objectType + ' WHERE Id = :objectId');
                        objectToUpdate.put('Clarizen_ID__c', generatedId);
                        objectsToUpdate.add(objectToUpdate);
                    }
                }
                
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Begin Reference Link Handler');
                
                //Iterate over Child Links list and create all links for this parent
                for(ClarizenRestAPILink childLink : childLinks)
                    if(ClarizenRestAPIHandler.attach(childLink.getLinkUrl(), generatedId, childLink.getChildType(), childLink.getChildId(), new Interface_Queue__c(Service_Name__c = 'Clarizen Rest API', Digioffer_ID__c = objectId, Key__c = generatedId, Object_Type__c = objectType, External_Object_Type__c = clarizenEntityInfo.Clarizen_Entity__c + ' link to ' + childLink.getChildType(), Status__c = 'Pending')))
                    	if(debugging) System.debug('[SUCCESS][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Reference Link to ' + childLink.getChildType() + ' created');
                    else
                        if(debugging) System.debug('[ERROR][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Reference Link to ' + childLink.getChildType() + ' not created');
                
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] End Reference Link Handler');
                
                finalId = generatedId;
            }
        }
        
        //If Clarizen Entity exists, check for the attachments
        if(finalId != null && clarizenEntityInfo.Send_Allowed_Attachments__c) {
            if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Begin Attachments Handler');
            
            //Get attached files for this Salesforce Object
            List<ContentDocumentLink> attachmentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :objectId];
            
            Map<String, String> customFields = new Map<String, String>();
            
            /*if(objectType.equals('Order'))
            	customFields.put('C_ProjectHandoverAfterSales', finalId);*/
            
            customFields.put('DocumentType', 'Sales Handover');
            
            for(ContentDocumentLink link : attachmentLinks) {
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Sending attachment (ContentDocument): ' + link.contentDocumentId);
                
                //Send attachment to Clarizen
                String documentId = ClarizenRestAPIHandler.createDocument(link.ContentDocumentId, customFields, new Interface_Queue__c(Service_Name__c = 'Clarizen Rest API', Digioffer_ID__c = link.ContentDocumentId, Object_Type__c = 'ContentDocument', External_Object_Type__c = 'Document', Status__c = 'Pending'));
                if(documentId != null) {
                    ClarizenRestAPIHandler.attach('attachmentlink', finalId, 'Document', documentId, new Interface_Queue__c(Service_Name__c = 'Clarizen Rest API', Digioffer_ID__c = link.ContentDocumentId, Key__c = documentId, Object_Type__c = 'ContentDocument', External_Object_Type__c = 'Attachment link to ' + objectType, Status__c = 'Pending'));
                }
            }
            
            if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] End Attachments Handler');
        }
        
        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Begin WBS Fields Handler');
        
        if(objectType.equals('Order') && finalId != null && !finalId.equals('')) {
            String wbsJson = null;
            try {
            	wbsJson = WBS_Helper.getWBS_Data(String.valueOf(record.get('SBQQ__Quote__c')));
            } catch(Exception e) {
                if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] Failed while loading WBS');
                System.debug(e.getStackTraceString() + ': ' + e.getMessage());
            }
           
            if(wbsJson != null) {
                List<WBS_Helper.WBSWrapper> wbsLines = (List<WBS_Helper.WBSWrapper>) JSON.deserialize(wbsJson, List<WBS_Helper.WBSWrapper>.class);
                List<Map<String, Map<String, ClarizenRestAPIField>>> wbsLinesFormatted = new List<Map<String, Map<String, ClarizenRestAPIField>>>();
                
                for(WBS_Helper.WBSWrapper WBSLine : wbsLines) {
                    Map<String, ClarizenRestAPIField> wbsFields = new Map<String, ClarizenRestAPIField>();
                    wbsFields.put('Description', new ClarizenRestAPIField(WBSLine.WBS_Name, true));
                    wbsFields.put('C_ProjectWBS', new ClarizenRestAPIField(finalId, true));
                    wbsFields.put('C_PlanCostsOfferPM080', new ClarizenRestAPIField(String.valueOf(WBSLine.WBS_PI.setScale(2, RoundingMode.HALF_UP)), false));
                    
                    Map<String, Map<String, ClarizenRestAPIField>> wbsFieldsFormatted = new Map<String, Map<String, ClarizenRestAPIField>>();
                    wbsFieldsFormatted.put('ExpenseSheet', wbsFields);
                    wbsLinesFormatted.add(wbsFieldsFormatted);
                }
                
                String listJson = listToJson(wbsLinesFormatted);
                ClarizenRestAPIHandler.createEntities(listJson, JSON.serialize(new Interface_Queue__c(Service_Name__c = 'Clarizen Rest API', Digioffer_ID__c = objectId, Object_Type__c = 'WBS', External_Object_Type__c = 'ExpenseSheet', Status__c = 'Pending'))); 
            }       
        }
        
        if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectType + ': ' + objectId + '] End WBS Fields Handler');
		
		if(debugging) System.debug('[INFO][SalesforceToClarizen: ' + objectId + '] END');
        return finalId;
    }
    
    //Return all field for this Salesforce Object Type
    public static Map<String, SObjectField> getObjectFieldMap(String objectType) {
        return Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
    }
    
    //Return all active mapped field for this object integration
    public static Map<String, Clarizen_Integration_Mapping__mdt> getClarizenFieldMap(String objectType) {
        Map<String, Clarizen_Integration_Mapping__mdt> fieldMapping = new Map<String, Clarizen_Integration_Mapping__mdt>();
        
        List<Clarizen_Integration__mdt> mappingList = [SELECT (SELECT Salesforce_Field__c, Clarizen_Field__c, Primary_Key__c FROM Clarizen_Integration_Mappings__r WHERE IsActive__c = true) FROM Clarizen_Integration__mdt WHERE IsActive__c = true AND Salesforce_Object__c = :objectType];

		if(mappingList.size() == 0)
            return fieldMapping;
        
        for(Clarizen_Integration_Mapping__mdt mapping : mappingList.get(0).Clarizen_Integration_Mappings__r) {
            fieldMapping.put(mapping.Clarizen_Field__c, mapping);
        }
        
        return fieldMapping;
    }
    
    //Return Clarizen Entity Info for provided Salesforce Object Type
    public static Clarizen_Integration__mdt getClarizenEntityInfo(String objectType) {
        List<Clarizen_Integration__mdt> clarizenIntegration = [SELECT Id, Clarizen_Entity__c, Create_Link__c, Link_Endpoint__c, Read_Only__c, Send_Allowed_Attachments__c, Store_Generated_ID__c FROM Clarizen_Integration__mdt WHERE Salesforce_Object__c = :objectType LIMIT 1];
        
        if(clarizenIntegration.size() == 1)
            return clarizenIntegration.get(0);
        else
            return null;
    }
    
    //Generates a JSON string based on a Map<String, ClarizenRestAPIField>
    private static String mapToJson(Map<String, ClarizenRestAPIField> fields) {
        String jsonContent = '{';
        Integer i = 0;
            
        for(String fieldName : fields.keySet()) {
            i++;
            
            if(fields.get(fieldName).getValue() == null)
                fields.get(fieldName).setValue('');
            
            if(fields.get(fieldName).isQuoted())
            	jsonContent = jsonContent + '"' + fieldName + '":"' + fields.get(fieldName).getValue() + '"';
            else
                jsonContent = jsonContent + '"' + fieldName + '":' + fields.get(fieldName).getValue();
            
            if (i < fields.size())
                jsonContent = jsonContent + ',';      
        }
        
        jsonContent = jsonContent + '}';
        
        return jsonContent;
    }
    
    private static String listToJson(List<Map<String, Map<String, ClarizenRestAPIField>>> entities) {
        String jsonContent = '[';
        
        Integer i = 0;
        for(Map<String, Map<String, ClarizenRestAPIField>> entityMap : entities) {
            String entityName = '';
            
            for(String nameText : entityMap.keySet())
                entityName = nameText;
            
            i++;
            
            Map<String, ClarizenRestAPIField> entity = entityMap.get(entityName);
            
            jsonContent = jsonContent + '{"url":"data/objects/' + entityName + '","method":"PUT","body":{';
            
            Integer j = 0;
            for(String fieldName : entity.keySet()) {
                j++;
                
                if(entity.get(fieldName).getValue() == null)
               		entity.get(fieldName).setValue('');
            
                if(entity.get(fieldName).isQuoted())
                    jsonContent = jsonContent + '"' + fieldName + '":"' + entity.get(fieldName).getValue() + '"';
                else
                    jsonContent = jsonContent + '"' + fieldName + '":' + entity.get(fieldName).getValue();

				if (j < entity.size())
                	jsonContent = jsonContent + ',';    
                
            }
            
            jsonContent = jsonContent + '}}';
            
            if (i < entities.size())
                	jsonContent = jsonContent + ',';   
        }
        
        jsonContent = jsonContent + ']';
        return jsonContent;
    }
    
}