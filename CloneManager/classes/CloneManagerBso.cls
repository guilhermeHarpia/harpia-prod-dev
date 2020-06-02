/*
Name: CloneManagerBso
Author: Sandeep Kumar (Siemens) and Guilherme Oliveira (Harpia Cloud)
Date: 2019.10.15
Description: Custom clone with related class for cloning objects with custom related objects
TestClass: CloneManagerTest
*/

public class CloneManagerBso{
    
    CloneManagerDao dao;
    Map<String,String> objNameToAPINameMap;
    Map<String,List<Object>> childToRelatedRecordMap;
    CloneStructure cloneStructure;
    
    public CloneManagerBso(){
        dao = new CloneManagerDao();
        objNameToAPINameMap = new Map<String,String>();
        childToRelatedRecordMap = new Map<String,List<Object>>();
        cloneStructure = new CloneStructure();
    }
    public String retrieveRelatedObjectStructured(String recordId){
        List<SObject> relatedRecords;
        String parentObjectAPIName = String.valueOf(dao.reterieveSObjectType(recordId));
        cloneStructure.parentObject = parentObjectAPIName;
        cloneStructure.parentRecord =  dao.queryAllData(fetchRelatedFields(parentObjectAPIName, null),parentObjectAPIName,'Id',recordId)[0];
        
        for(Clone_Manager__mdt  cm : dao.retrieveRelatedObject(parentObjectAPIName)){
            
            ChildStructure childStructureAux = new ChildStructure(cm.Child_Object__c, cm.Child_Columns_Fieldset__c);
            childStructureAux.lookupField = cm.Parent_Lookup_Field__c;
            relatedRecords = null;
            relatedRecords = retrieveRecords(cm,recordId);
            childStructureAux.listRecords = relatedRecords;
            System.debug('4===>>>'+relatedRecords);
            cloneStructure.childStructures.add(childStructureAux);
        }
        system.debug(cloneStructure);
        return JSON.serialize(cloneStructure);
    }
    public String startCloneProcessStructured(Boolean startClone,Id recordId,String cloneStructureJSON){
        system.debug(cloneStructureJSON);
        CloneStructure cloneStructure = (CloneStructure) JSON.deserialize(cloneStructureJSON, CloneStructure.class);
        system.debug(cloneStructure);
        SObject parentSObject = cloneStructure.parentRecord;
        SObject newParent = parentSObject.clone(false, true, false, false);
        //TODO: Melhorar lógica de Source
        if(String.valueOf(dao.reterieveSObjectType(parentSObject.Id)) == 'SBQQ__Quote__c'){
            newParent.put('SBQQ__Source__c', parentSObject.Id);
            newParent.put('SBQQ__Primary__c', false);
            newParent.put('SBQQ__Ordered__c', false);
            newParent.put('ApprovalStatus__c', null);
            newParent.put('EHS_Check__c', false);
            newParent.put('OwnerId', UserInfo.getUserId());
        }
        List<SObject> listChildToInsert = new List<SObject>();
        
        Savepoint sp = Database.setSavepoint();
        try{
            
            insert newParent;
            system.debug(newParent);
            
            for(ChildStructure child : cloneStructure.childStructures){
                List<Sobject> listSObject = new List<Sobject>();
                List<SBQQ__QuoteLine__c> listUpdate = new List<SBQQ__QuoteLine__c>();
                Map<Id, Id> mapOriginalRequired = new Map<Id, Id>();
                Map<Id, Id> mapOriginalNew = new Map<Id, Id>();
                if(child.ObjectName == 'SBQQ__QuoteLine__c'){
                    for(SObject obj : child.listRecords){
                        mapOriginalRequired.put((Id)obj.get('Id'), (Id)obj.get('SBQQ__RequiredBy__c'));
                    }
                }
                for(SObject obj : child.listRecords){
                    SObject clonedChild = obj.clone(false, true, false, false);
                    clonedChild.put(child.lookupField, newParent.Id);
                    clonedChild.Id = null;
                    listSObject.add(clonedChild);
                }
                dynamicUpsert(listSObject, child.ObjectName);
                if(child.objectName == 'SBQQ__QuoteLine__c'){
                    for(SObject ql :  listSObject){
                        system.debug(ql.get('Id'));
                        mapOriginalNew.put(ql.getCloneSourceId(), (Id)ql.get('Id'));
                    }
                    for(SObject newObj :  listSObject){
                        if(mapOriginalRequired.containsKey(newObj.getCloneSourceId())){
                            listUpdate.add(new SBQQ__QuoteLine__c(Id = (Id)newObj.get('Id'),
                                                                  SBQQ__RequiredBy__c=  mapOriginalNew.get(mapOriginalRequired.get(newObj.getCloneSourceId()))));
                        }
                    }
                    if(listUpdate.size() > 0){
                        update listUpdate;
                    }
                }
            }
            
            //system.debug(listChildToInsert);
            //Database.upsert(listChildToInsert);
            
            return newParent.Id;
        }
        catch(Exception e){
            Database.rollback( sp );
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void dynamicUpsert(List<SObject> records, String sObjectTypeString)
    {
        Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectTypeString);
        if (sObjectType != null)
        {
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(records);
            if(sObjectTypeString == 'SBQQ__QuoteLine__c'){
                Database.upsert(castRecords);
            }
            else{
                upsert castRecords;
            }
            
        }
    }
    
    private List<SObject> retrieveRecords(Clone_Manager__mdt  cm,String recordId){
        
        String fields = fetchRelatedFields(cm.Child_Object__c,cm.Child_Object_FieldSet__c);
        
        return dao.queryAllData(fields,cm.Child_Object__c,cm.Parent_Lookup_Field__c,recordId);
    }
    
    private String fetchRelatedFields(String childObject,String childFieldSet){
        
        String fields;
        
        List<String> fieldList;
        
        if(childFieldSet == null){
            fieldList = new List<String>(Schema.getGlobalDescribe().get(childObject).getDescribe().fields.getMap().keySet());
            fields = String.join(fieldList,',');            
        }else{
            for(Schema.FieldSetMember fieldMember : readFieldSet(childObject,childFieldSet)){
                fieldList.add(fieldMember.getFieldPath());
            }            
            fields = String.join(fieldList,',');
        }
        
        return fields;
    }
    
    private List<Schema.FieldSetMember> readFieldSet(String ObjectName,String fieldSetName){
        return Schema.getGlobalDescribe().get(ObjectName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields(); 
    }
    
    public class CloneStructure{
        public String parentObject;
        public SObject parentRecord;
        public List<ChildStructure> childStructures;
        
        public CloneStructure(){
            this.childStructures = new List<ChildStructure>();
        }
    }
    
    public class ChildStructure{
        public String objectName;
        public String objectLabel;
        public String lookupField;
        public List<SObject> listRecords;
        public List<FieldSetUtils.CustomFieldDefinition> columnList;
        
        public ChildStructure(String objectName, String columnFieldSetName){
            this.objectName = objectName;
            this.objectLabel = Schema.getGlobalDescribe().get(objectName).getDescribe().getLabel();
            if(columnFieldSetName != null){
                this.columnList = FieldSetUtils.getFields(objectName, columnFieldSetName);
            }
            else {
                FieldsetUtils.CustomFieldDefinition nameField = new FieldsetUtils.CustomFieldDefinition();
                nameField.fieldLabel = 'Name';
                nameField.fieldName = 'Name';
                nameField.fieldType = 'STRING';
               	nameField.isRequired = true;
                this.columnList = new List<FieldSetUtils.CustomFieldDefinition>{nameField};
            }
            this.listRecords = new List<SObject>();
        }
    }
}