@isTest
public class EUR_CRM_PT_AssignOPTargetActualNoSchTest {
    static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_PT_AssignOPTargetActualNoSched sh1 = new EUR_CRM_PT_AssignOPTargetActualNoSched();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
}