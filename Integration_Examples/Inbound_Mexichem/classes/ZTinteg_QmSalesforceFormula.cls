@isTest
public class ZTinteg_QmSalesforceFormula {
    public static testmethod void runTest() {
        integ_QmSalesforceFormula f = new integ_QmSalesforceFormula();
        f.resolve(null, new Map<String, Object>{
            'NQMSF' => '00006993QM1019'
        });
    }
}