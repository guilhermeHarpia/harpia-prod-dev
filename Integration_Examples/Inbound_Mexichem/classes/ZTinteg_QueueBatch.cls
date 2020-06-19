@isTest
private class ZTinteg_QueueBatch {

	@testSetup
	public static void configure(){
        EventBuilder builder = new EventBuilder();
        EventQueue evt = new EventQueue(builder.createEventFor('NOT_FOUND_INTEG')
                              .forObjectId('1')
                              .withInternalID ('2')
                              .withSender('SAP')
                              .withReceiver('SF')
                              .withPayload('[]')
                              .isSync()
                              .build());
        evt.addPayload('Payload', '[]');                      
        
        //store event;
        evt.save();
        
        //dispatch event;
        evt.dispatch();     
	}

	
	@isTest static void test_method_one() {

		Test.startTest();

		Database.executeBatch(new integ_QueueBatch(new List<String>{'NOT_FOUND_INTEG'}, new List<String>{'UNHANDLED', 'QUEUED', 'LOADING_DATA'}, System.today()), 1);

		Test.stopTest();
	}
	
}