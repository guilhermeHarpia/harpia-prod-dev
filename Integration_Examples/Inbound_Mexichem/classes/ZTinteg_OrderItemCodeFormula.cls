@isTest
public class ZTinteg_OrderItemCodeFormula {
    public static testmethod void runTest() {
        integ_OrderItemCodeFormula f = new integ_OrderItemCodeFormula();
        f.resolve(null, new Map<String, Object>{
            'VBELN' => '1',
            'POSNR' => '2'
        });
    }
}