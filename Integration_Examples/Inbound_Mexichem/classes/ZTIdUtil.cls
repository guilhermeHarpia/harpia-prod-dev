@isTest
private class ZTIdUtil
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	
    	// Start Test
		System.Test.startTest();
		
    	String test1a = IdUtil.convert15To18CharId('0011500001Dhux7');
    	String test1b = IdUtil.convert15To18CharId(null);
    	String test1c = IdUtil.convert15To18CharId('');
    	
    	String test2 = IdUtil.generateUUID();
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1a == '0011500001Dhux7AAB');
		System.assert(test1b == null);
		System.assert(test1c == null);
		System.assert(test2 != '');
    }
}