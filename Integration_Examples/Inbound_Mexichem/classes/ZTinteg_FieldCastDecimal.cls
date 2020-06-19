@isTest
private class ZTinteg_FieldCastDecimal {
    static testMethod void testAll() {
    	System.Test.startTest();
    	integ_FieldCastDecimal castDec = new integ_FieldCastDecimal();
    	castDec.getValue(null,null,null,10.2);
    	System.Test.stopTest();
    }
}