@isTest
public class ZTinteg_ProductActiveFormula {
    public static testmethod void runTest() {
        integ_ProductActiveFormula f = new integ_ProductActiveFormula();
        f.resolve(null, new Map<String, Object>{
            'MVKE_PRAT1' => 'x'
        });
    }
}