@isTest
private class ZTinteg_ShippingItemOrderItem {
    static testMethod void testAll() {	
    	
    	Map<String, Object> externalDataMap = new Map<String, Object>();
    	externalDataMap.put('VGBEL', 'abc');
    	externalDataMap.put('VGPOS', 'def');
    	
    	System.Test.startTest();
    	
    	integ_ShippingItemOrderItem integ = new integ_ShippingItemOrderItem();
    	integ.resolve(null, externalDataMap);
    	
    	System.Test.stopTest();
    }
}