@isTest
private class ZTinteg_FieldCasString {
    static testMethod void testAll() {
    	System.Test.startTest();
    	integ_FieldCastString castString = new integ_FieldCastString();
    	castString.getValue(null, null, null, 'abc');
    	System.Test.stopTest();
    }
}