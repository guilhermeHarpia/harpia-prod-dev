@isTest
private class ZTinteg_CSVTransformer
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	IntegrationMap__c integrationMap = ULTestData.createIntegrationMap('Integração XXX', 'Contact', 'GenericIntegrationService', 'eventName', 'Insert', '', 'CSV');
    	insert integrationMap;
    	
    	IntegrationMapItem__c integrationMapItem1 = ULTestData.createIntegrationMapItem(integrationMap.Id, 'Name', 'XPTO_NAME', 'String');
    	insert integrationMapItem1;
    	
    	Queue__c queue = ULTestData.createQueue(integrationMap.Id, 'eventName', '99');
    	insert queue;
    	
    	String csvData = '1;2;3;4;5;6;7';
    	
    	// Start Test
		System.Test.startTest();
		
    	integ_CSVTransformer csvTransformer = new integ_CSVTransformer();
    	
    	List<SObject> test01 = csvTransformer.convertToSObjectList(integrationMap, csvData);
    	
    	String test02 = csvTransformer.convertToRawData(new List<SObject>{queue});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(csvTransformer != null);
    }
    
    public static testmethod void contactImportCSV(){
        
        IntegrationMap__c integ = new IntegrationMap__c(
        	Name = 'Integ Contact CSV',
            IntegrationId__c = 'SYNC_CONTACT_INBOUND',
            SObjectApiNameTxt__c = 'Contact',
            DMLOperationTxt__c = 'Insert',
            CommandClassName__c = 'GenericIntegrationService',
            OutputDataTypeTxt__c  = 'CSV'
        );
        insert integ;
        
        IntegrationMapItem__c integItem = new IntegrationMapItem__c(
            IntegrationMap__c = integ.Id,
            TypeTxt__c  = 'String',
            InternalFieldNameTxt__c = 'LastName',
            ExternalFieldNameTxt__c = '3'//index col number
        );
        insert integItem;
        
        WSInBoundOrquestration.WSInBoundOrquestrationVO vo = new WSInBoundOrquestration.WSInBoundOrquestrationVO();
        vo.integrationId = 'SYNC_CONTACT_INBOUND';
        vo.content = 'Dief, Quadros, OK, 02';
        vo.isSync = true;
        
        WSInBoundOrquestration.executePost(vo);
        
        integ_CSVTransformer transf = new integ_CSVTransformer();
        transf.convertToRawData(new List<Contact>{});
        
    }
    
}