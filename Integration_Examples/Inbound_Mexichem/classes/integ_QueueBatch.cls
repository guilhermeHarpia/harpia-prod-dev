global class integ_QueueBatch implements Database.Batchable<sObject> {
	
	private List<String> eventNameList;
	private List<String> statusList;
	private Date dte;

	global integ_QueueBatch(List<String> eventNameList, List<String> statusList, Date dte) {
		this.eventNameList = eventNameList;
		this.statusList = statusList;
		this.dte = dte;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				Select Id, Name, EventName__c, Status__c
					FROM Queue__c q 
					WHERE Status__c IN : this.statusList
					AND	EventName__c IN : this.eventNameList
					//AND CreatedDate = :this.dte
					ORDER BY CreatedDate ASC
					LIMIT 50000
				]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for (Queue__c q : (List<Queue__c>)scope){
			q.Status__c = 'QUEUED';
			q.IsSync__c = true;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}