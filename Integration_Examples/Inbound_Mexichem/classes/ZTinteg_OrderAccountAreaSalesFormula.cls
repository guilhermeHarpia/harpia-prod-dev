@isTest
public class ZTinteg_OrderAccountAreaSalesFormula {
    public static testmethod void runTest() {
        integ_OrderAccountAreaSalesFormula f = new integ_OrderAccountAreaSalesFormula();
        f.resolve(null, new Map<String, Object>{
            'KUNNR' => '1',
            'VKORG' => '1',
            'VTWEG' => '1',
            'SPART' => '1'
        });
    }
}