@isTest
private class ZTinteg_FieldCastExceptio {
    static testMethod void testAll() {
    	List<String> lista = new List<String>();
    	
    	try {
    		lista[53] = 'test';
    	} catch(Exception ex) {
    	
    		System.Test.startTest();
    		integ_FieldCastException castEx = new integ_FieldCastException(ex, 'name', 'type', 'message', 3);
    		System.Test.stopTest();
    			
    	}   	
    	
    }
}