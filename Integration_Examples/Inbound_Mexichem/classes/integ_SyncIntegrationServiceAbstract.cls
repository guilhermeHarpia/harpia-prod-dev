public virtual class integ_SyncIntegrationServiceAbstract {

	public Object execute(String integrationId, integ_IRemoteCall remoteCall) {

		//builds a queue item and save
		EventBuilder builder = new EventBuilder();
		
		//remote result
		Object remoteResult = null;
		
		builder = builder.createEventFor(integrationId)
		                      .forObjectId('1')
		                      .withInternalID ('2')
		                      .withSender('SF')
		                      .withReceiver('SAP')
		                      .withPayload('[]')
		                      .isSync();

		try {

			//calls remote service 
			remoteResult = remoteCall.execute();
			builder.withStatus(EventQueueStatusType.DELIVERED.name());
			
		} catch(Exception ex) {
			builder.withException(ex);
			builder.withStatus(EventQueueStatusType.ERROR.name());
			throw ex;
		}
 		
 		EventQueue evt = new EventQueue(builder.build());

		//updates queue item and remote service result to payload
		if (remoteResult != null) {
			evt.addPayload('Payload', String.valueOf(remoteResult));                      
		}
		
		//save item
		evt.save();
		//evt.processEvent();
		
		return remoteResult;
	}
    
}