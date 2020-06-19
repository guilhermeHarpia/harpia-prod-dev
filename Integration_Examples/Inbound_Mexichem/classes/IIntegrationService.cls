public interface IIntegrationService {
 	void execute (EventQueue event, TransformerAbstract transformer, integ_IIntegrationOperation operation, IntegrationMap__c integMap);
}