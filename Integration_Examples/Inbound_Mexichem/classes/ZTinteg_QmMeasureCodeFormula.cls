@isTest
public class ZTinteg_QmMeasureCodeFormula {
    public static testmethod void runTest(){
        integ_QmMeasureCodeFormula f = new integ_QmMeasureCodeFormula();
        f.resolve(null, new Map<String, Object>{
            'NQMSF' => '2339',
            'MANUM' => '04300'
        });
    }
}