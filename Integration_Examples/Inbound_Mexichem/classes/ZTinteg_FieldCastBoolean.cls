@isTest
private class ZTinteg_FieldCastBoolean {
    static testMethod void testAll() {
    	System.Test.startTest();
    	integ_FieldCastBoolean castBoolean = new integ_FieldCastBoolean();
    	castBoolean.getValue(null, null, null, null);
    	castBoolean.getValue(null, null, null, '');
    	castBoolean.getValue(null, null, null, 'C');
    	castBoolean.getValue(null, null, null, 'true');
    	System.Test.stopTest();
    }
}