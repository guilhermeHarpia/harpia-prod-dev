@isTest
public class ZTinteg_QmErrorFormula {
    public static testmethod void runTest() {
        integ_QmErrorFormula f = new integ_QmErrorFormula();
        f.resolve(null, new Map<String, Object>{
            'MSGV1' => 'first message;second message;'
        });
    }
}