@isTest
public class ZTinteg_OrderCaseFormula {
    public static testmethod void runTest() {
        integ_OrderCaseFormula f = new integ_OrderCaseFormula();
        f.resolve(null, new Map<String, Object>{
            'CASOSALESFORCE' => 2
        });
    }
}