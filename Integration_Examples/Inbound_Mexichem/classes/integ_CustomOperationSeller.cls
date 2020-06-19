public with sharing class integ_CustomOperationSeller implements integ_IIntegrationOperation {
	public Object execute(List<SObject> recordList) {
		System.debug('*** integ_CustomOperationSeller::execute() ' + recordList);
		List<Seller__c> sellerLIst = new List<Seller__c>();
		sellerLIst.addAll((List<Seller__c>)recordList);
		upsert sellerLIst SellerNumberNmb__c;
		return sellerLIst;
	}
}