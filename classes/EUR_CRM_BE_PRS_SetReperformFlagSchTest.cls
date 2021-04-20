@isTest
public class EUR_CRM_BE_PRS_SetReperformFlagSchTest {
    
    static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_BE_PRS_SetReperformFlagSch sh1 = new EUR_CRM_BE_PRS_SetReperformFlagSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        
        EUR_CRM_BE_PRS_SetReperformFlagSch.schedule();
        Test.stopTest();
        
    }
}