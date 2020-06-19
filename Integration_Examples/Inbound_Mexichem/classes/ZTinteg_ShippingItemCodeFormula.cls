@isTest
private class ZTinteg_ShippingItemCodeFormula {
    static testMethod void testAll() {	
    	
    	Map<String, Object> externalDataMap = new Map<String, Object>();
    	externalDataMap.put('POSNR', 'abc');
    	externalDataMap.put('VBELN', 'def');
    	
    	System.Test.startTest();
    	
    	integ_ShippingItemCodeFormula integ = new integ_ShippingItemCodeFormula();
    	integ.resolve(null, externalDataMap);
    	
    	System.Test.stopTest();
    }
}