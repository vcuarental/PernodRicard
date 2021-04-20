@isTest
public class EUR_CRM_MassActivateOPSchTest {
     static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_MassActivateOPSch sh1 = new EUR_CRM_MassActivateOPSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
}