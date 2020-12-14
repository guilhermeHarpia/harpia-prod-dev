/*
Name: FieldSetUtils
Author: Harpia Cloud
Date: 2019.10.16
Description: Class to control Field Set Utilities as a handler for others classes

------------ Change History ----------------------------------------------------------------------------------------------------------------
#change                                               Date                                      User                                      Description
00                                                           yyyy.mm.dd                       u.ser                                      description of changes
----------------------------------------------------------------------------------------------------------------------------------------------
*/

public class FieldSetUtils {
    /*
     * Wrapper of the class that holds some variables that contains informations from a field: Name (API), Label, Required, Type  
     */
    public class CustomFieldDefinition{
        public String fieldName;
        public String fieldLabel;
        public Boolean isRequired;
        public String fieldType;
    }
    
    public static List<String> getFieldNames(String sobjectName, String fieldsetName){
        List<String> resultList = new List<String>();
        List<CustomFieldDefinition> fieldSetInfo = getFields(sobjectName, fieldsetName);
        for(CustomFieldDefinition cfd : fieldSetInfo){
            resultList.add(cfd.fieldName);
        }
        return resultList;
    }
    
    /*
     * Method to get all fields from a specific object and fieldset from it's object, it returns a list of the wrapper CustomFieldDefinition that contains
     * information about the fields that can be acessed from that list.
     * 
     * Parameters: sobjectName (Object API), fieldsetName (fieldset API) 
     */
    public static List<CustomFieldDefinition> getFields(String sobjectName, String fieldsetName){
        
        List<CustomFieldDefinition> resultList = new List<CustomFieldDefinition>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sobjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        
        List<Schema.FieldSetMember> fieldsetMembers = fieldSetObj.getFields();
        for(Schema.FieldSetMember member : fieldsetMembers){
            if(member.getSObjectField().getDescribe().isAccessible()){
                CustomFieldDefinition fd = new CustomFieldDefinition();
                fd.fieldName = member.getFieldPath();
                fd.isRequired = member.getRequired();
                fd.fieldType = String.valueOf(member.getType());
                fd.fieldLabel = member.getLabel();
                system.debug(fd);
                resultList.add(fd);
            }
        }
        return resultList;
    }
    
    /*
     * Method to get the picklist values from a Picklist field in a specific Object. It returns a list of string with all values into the picklist
     * 
     * Parameters: ObjectAPi_name (Object API), Field_name (Picklist field API)
     */
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 
        List<String> lstPickvals = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    }
    
    
    public static String getType(Object o){
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+'';
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets
    }
    
    //Method builds a Map from a list and a key field informed
    public static Map<String,List<SObject>> builMapByListChoosingFieldKey(String campoNomeAPI, List<SObject> registros) {
        Map<String,List<SObject>> retorno = new Map<String,List<SObject>>();
        
        for(SObject registro : registros) {
            List<SObject> temp;
            IF(retorno.ContainsKey((String) registro.get(campoNomeAPI))){
                temp = retorno.get((String) registro.get(campoNomeAPI));
            } else {
                temp = new List<SObject>();
            }
            temp.add(registro);
            retorno.put((String) registro.get(campoNomeAPI),temp);
        }
        return retorno;
    }
    
    //Method builds a set from a field by the list
    public static Set<String> getSetOfField(List<SObject> sObjs, String fieldName) {
        Set<String> setField = new Set<String>();
        for (SObject sObj : sObjs) {   
            setField.add( (String) sObj.get(fieldName) );
        }
        return setField;
    }
    
}