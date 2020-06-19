public with sharing class integ_CustomOperationOrder implements integ_IIntegrationOperation {
    
	public Object execute(List<SObject> recordList) {
        
        System.debug(LoggingLevel.INFO, '*** integ_CustomOperationOrder::execute() ' + recordList);
		system.debug('ALOU CUSTOMOPERATIONORDER: ');
		List<Order__c> orderList = new List<Order__c>();
		orderList.addAll((List<Order__c>)recordList);
		
		Map<String, Order__c> orderMap = new Map<String, Order__c>();
		
		//unify list by inv
		for (Order__c ord : orderList) {
            system.debug('ordem atual: '+ord);
            system.debug('ordem caso atual: '+ord.CaseLkp__c);
			if (!orderMap.containsKey(ord.CustomIDTxt__c)) {
				orderMap.put(ord.CustomIDTxt__c, ord);
			}
		}
		
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        try{
            skipVal.Skip__c = true;
            update skipVal;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
		orderList = orderMap.values(); 
		System.debug('*** orderList' + orderList);
		
        /*List<Order__c> orderCloneList = orderList.deepClone(false, false, true);
        for(Order__c o : orderCloneList){
            o.AccountAreaSalesLkp__c = null;
            o.AccountAreaSalesLkp__r = null;
            o.AccountLkp__c = null;
            o.AccountLkp__r = null;
        }*/
        
        List<Order__c> orderCloneList = new List<Order__c>();
        for(Order__c o : orderList){
            orderCloneList.add(new Order__c(SAPGUIDTxt__c = o.SAPGUIDTxt__c,
                                           CustomIdTxt__c = o.CustomIDTxt__c
                                           ));
        }
        
        System.debug('####orderCloneList');
        System.debug(orderCloneList);
        Database.UpsertResult[] resultListUpsertGUID = Database.upsert(orderCloneList, Order__c.SAPGUIDTxt__c, false);
        System.debug('####resultListUpsertGUID');
        System.debug(resultListUpsertGUID);        
		//System.debug('=======================External ID da ordem: ' + Order__c.CustomIDTxt__c);
		//
        for(Order__c o : orderList){
            o.SAPGUIDTxt__c = '';
        }
		//Database.UpsertResult[] resultList = Database.upsert(orderList, Order__c.CustomIDTxt__c, true);
		Database.UpsertResult[] resultList = Database.upsert(orderList, Order__c.CustomIDTxt__c, false);
        
        try{
            skipVal.Skip__c = false;
            update skipVal;
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
		integer i = 0;
		for (Database.UpsertResult result : resultList) {
			if (!result.isSuccess()) {
                EventQueueProcessException e = new EventQueueProcessException();
				String msg = '';
                for(Database.Error err : result.getErrors()) {             
                    msg = msg + err.getStatusCode() + ': ' + err.getMessage()+'\n';
                }                
                e.setMessage(msg);             
                throw e;
        		System.debug(LoggingLevel.INFO, '*** DML ERROR : integ_CustomOperationOrder::execute() ' + orderList[i] +  result.getErrors());
			}
			i++;
		}
		
		return orderList;
	}
}