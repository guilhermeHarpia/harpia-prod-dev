@isTest
public class ZTinteg_QmSapFormula {
    public static testmethod void runTest(){
        integ_QmSapFormula f = new integ_QmSapFormula();
        f.resolve(null, new Map<String, Object>{
           'QMNUMSAP' => '33332' 
        });
    }
}