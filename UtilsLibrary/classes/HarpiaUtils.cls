/*
Name: HarpiaUtils
Author: Luan Dapunt (Harpia Cloud)
Date: 2019.10.10
Description: Class to control Field Set Utilities as a handler for others classes
TestClass: FieldSetUtilsTest
*/

public class HarpiaUtils {
    /*
     * Wrapper of the class that holds some variables that contains informations from a field: Name (API), Label, Required, Type  
     */
    public class CustomFieldDefinition{
        public String fieldName;
        public String fieldLabel;
        public Boolean isRequired;
        public String fieldType;
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
}