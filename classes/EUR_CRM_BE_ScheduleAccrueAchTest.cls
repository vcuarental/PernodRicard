@isTest
public class EUR_CRM_BE_ScheduleAccrueAchTest {    
    static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_BE_ScheduleAccrueAchievements sh1 = new EUR_CRM_BE_ScheduleAccrueAchievements(); 
        EUR_CRM_BE_ScheduleAccrueAchievements.schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
}