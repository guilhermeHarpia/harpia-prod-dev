public with sharing class integ_CSVTransformer extends TransformerAbstract {
	
	public class integ_CSVTransformerException extends Exception {}
	
	/*
		Converts CSV data to List<SObject>
	*/
	public override List<SObject> convertToSObjectList(IntegrationMap__c integrationMap, String csvData) {
		
		List<List<String>> csvDataList = CSVReader.readIETFRFC4180CSVFile(Blob.valueOf(csvData));
		
		System.debug('***' + csvDatalist);

		List<SObject> recordList = new List<SObject>();

		//load custom object fields
		Schema.sObjectType sObjectType = Schema.getGlobalDescribe().get(integrationMap.SObjectApiNameTxt__c);

		Map <String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe()
																.fields
																.getMap();
		
		//row number
		Integer rowNumber = 1;
		
		//iterate over each csv record
		for (List<String> csvRecordList : csvDataList) {
			
			Map<String, Object> recordFieldMap = new Map<String, Object>();
			
			//create a map
			Integer i = 1; 
			for (String fieldValue : csvRecordList) {
				recordFieldMap.put(String.valueOf(i++), fieldValue);
			}
			
			//create a new custom object instance
			SObject sObjectRecord = sObjectType.newSObject();
			
			//iterate over each json field
			for (IntegrationMapItem__c fieldMapItem : integrationMap.IntegrationMapItems__r) {
				
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
							throw new integ_CSVTransformerException(fieldMapItem.InternalFieldNameTxt__c + ' can\"t be null');
						}
						
						//todo validate if TypeTxt is ok
						integ_IFieldCast fieldCastImpl = this.getFieldCastImpl(fieldMapItem.TypeTxt__c);
						Object result = fieldCastImpl.getValue(sObjectFieldMap, recordFieldMap, fieldMapItem, fieldValue);
						
						if (result instanceof SObject) {
							Schema.sObjectField field = sObjectFieldMap.get(fieldMapItem.InternalFieldNameTxt__c);
							Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
							sObjectRecord.putSObject(fieldDescribe.getRelationshipName(), (SObject)result);
						} else {
							sObjectRecord.put(fieldMapItem.InternalFieldNameTxt__c, result);
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
		return null;
	}		
		
}