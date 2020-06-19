public with sharing class IntegrationOperationInsert  implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		insert recordList;
		return recordList;
	}
}