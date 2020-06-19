@isTest
private class ZTinteg_SaleAreaCustomIdFormula {
    static testMethod void testAll() {
    	Map<String, Object> externalDataMap = new Map<String, Object>();
    	externalDataMap.put('KUNN2','teste');
    	externalDataMap.put('VKORG','teste');
    	externalDataMap.put('VTWEG','teste');
    	externalDataMap.put('SPART','teste');
    	
    	System.Test.startTest();
    	
    	integ_SaleAreaCustomIdFormula saleArea = new integ_SaleAreaCustomIdFormula();
    	saleArea.resolve(null,externalDataMap);
    	
    	System.Test.stopTest();
    	
    }
}