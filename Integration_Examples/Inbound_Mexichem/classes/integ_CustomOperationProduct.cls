public with sharing class integ_CustomOperationProduct implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationProduct::execute() ' + recordList);
		List<Product2> productList = new List<Product2>();
		productList.addAll((List<Product2>)recordList);
		upsert productList ProductCodeTxt__c;
		return productList;
	}
}