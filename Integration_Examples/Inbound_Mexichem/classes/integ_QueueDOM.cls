public with sharing class integ_QueueDOM extends fflib_SObjectDomain implements ITestAble {
    
    public integ_QueueDOM(List<Case> sObjectList){
        super((List<SObject>) sObjectList);
    }
    
    public override void onAfterInsert() {
    	handleQueue();
    }
    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    	handleQueue();
    }
    
    private void handleQueue() {
    	
		if (System.isFuture()) return;
	
	 	//all elements with status__c = Queued
	    Map<String, String> syncEvents = new Map<String,String>();
	    Map<String, String> asyncEvents = new Map<String,String>();
	
	    for (Queue__c event : (List<Queue__c>)records) {
	        
	        if (event.status__c != 'QUEUED') continue;
	        
	        if (event.IsSync__c) {
	        	syncEvents.put(event.id, event.eventName__c);
	        } else {
	        	asyncEvents.put(event.id, event.eventName__c);
	        }
	        
	    }
	
	    if (syncEvents.size() > 0) {
	        EventQueue.processEventsSync(syncEvents);
	    }

	    if (asyncEvents.size() > 0) {
	        EventQueue.processEvents(asyncEvents);
	    }
    	
    }
     
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new integ_QueueDOM(sObjectList);
        }
    }
    
    public static Queue__c getSampleObject() {
        return new Queue__c(); 
    } 
}