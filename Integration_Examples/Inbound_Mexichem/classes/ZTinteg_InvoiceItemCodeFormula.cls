@isTest
public class ZTinteg_InvoiceItemCodeFormula {
	
    public static testmethod void runTest(){
        integ_InvoiceItemCodeFormula f = new integ_InvoiceItemCodeFormula();
        f.resolve(null, new Map<String, Object>{
            'DOCNUM' => 1,
            'ITMNUM'=> 2    
        });
    }
    
}