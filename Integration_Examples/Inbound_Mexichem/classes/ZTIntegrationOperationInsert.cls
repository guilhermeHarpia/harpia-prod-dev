@isTest
public class ZTIntegrationOperationInsert {
    public static testmethod void runTest(){
        IntegrationOperationInsert op = new IntegrationOperationInsert();
        op.execute(new List<Contact>{new Contact(LastName = 'QDros')});
    }
}