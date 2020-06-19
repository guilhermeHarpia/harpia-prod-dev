public with sharing class integ_JSONTransformer extends TransformerAbstract {
	
	public class integ_JSONTransformerException extends Exception {}
	
	/*
		Converts JSON data to List<SObject>
	*/
	public override List<SObject> convertToSObjectList(IntegrationMap__c integrationMap, String jsonData) {
		system.debug('transformer:');
        system.debug('integration map items: '+integrationMap.IntegrationMapItems__r);
        system.debug('jsonData: '+jsonData);
		List<Object> rawObjList = (List<Object>)JSON.deserializeUntyped(jsonData);
		List<SObject> sObjectRecordList = new List<SObject>();
		
		List<SObject> recordList = new List<SObject>();

		//load custom object fields
		Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(integrationMap.SObjectApiNameTxt__c);

		Map <String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe()
																.fields
																.getMap();
        system.debug('sobjectfieldmap: '+sObjectFieldMap);
		
		//row number
		Integer rowNumber = 1;
		
		//iterate over each json record
		for (Object obj : rawObjList) {
			
			//cast json data record to map
			Map<String, Object> recordFieldMap = (Map<String, Object>)obj;
			
			//create a new custom object instance
			SObject sObjectRecord = sObjectType.newSObject();
			
			//iterate over each json field
			for (IntegrationMapItem__c fieldMapItem : integrationMap.IntegrationMapItems__r) {
				//system.debug('fieldmapitem atual: '+fieldMapItem);
				if (!fieldMapItem.IsActive__c) {
					continue;
				}
				
				
				//get json data
				Object fieldValue = recordFieldMap.get(fieldMapItem.ExternalFieldNameTxt__c);
				
				try {
					
					/*
					
						It just support String data attributes like:
						
						{
							attr : 'value'
						}
						
						
						In another moment we need to support 
						Object data atrributest like: 
						
						{  
							attr : { 
								attr: 'value' 
							}
						}
					
					*/
					
					if (fieldValue instanceof String  || (fieldValue == null)) {
						
						//if value is null set default as value
						if ((fieldValue == null || fieldValue == '')) {
							fieldValue = fieldMapItem.DefaultValueTxt__c; 
						}
						
						//if has no value and field is mandatory
						//throw error
						if ((fieldValue == null || fieldValue == '') && fieldMapItem.IsRequired__c) {
							throw new integ_JSONTransformerException(fieldMapItem.InternalFieldNameTxt__c + ' can\"t be null it is required for ' + integrationMap.Name);
						}
						
						//todo validate if TypeTxt is ok
						integ_IFieldCast fieldCastImpl = this.getFieldCastImpl(fieldMapItem.TypeTxt__c);
						Object result = fieldCastImpl.getValue(sObjectFieldMap, recordFieldMap, fieldMapItem, fieldValue);
						//system.debug('resulto: '+result);
                        //system.debug('campo: '+sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c));
						if (result instanceof SObject) {
							Schema.sObjectField field = sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c);
							Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
							sObjectRecord.putSObject(fieldDescribe.getRelationshipName(), (SObject)result);
						} else { 
                            //ALTERADO
                            if(!sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c).getDescribe().isAutoNumber()){
                                //AQUI ERA ONDE ESTAVA DANDO ERRO AO ASSOCIAR UMA STRING A UM CAMPO AUTONUMBER
                                sObjectRecord.put(fieldMapItem.InternalFieldNameTxt__c, result);
                            }else{
                                system.debug('entrou');
                            }
						}

        				System.debug(LoggingLevel.FINEST, '*** ' + fieldMapItem.InternalFieldNameTxt__c + ' -> ' 
        					+ fieldMapItem.ExternalFieldNameTxt__c + ' = [' + result + ']');

					}
					
				} catch(Exception ex) {
					throw new integ_FieldCastException(ex, fieldMapItem.InternalFieldNameTxt__c, fieldMapItem.TypeTxt__c, ex.getMessage(), rowNumber);
				}
				
			}
			
			rowNumber++;
			
			recordList.add(sObjectRecord);
		}
		
		return recordList;
		
	}
	
	public override String convertToRawData(List<SObject> sObjectRecordList) {
		return JSON.serialize(sObjectRecordList);
	}		
		
}