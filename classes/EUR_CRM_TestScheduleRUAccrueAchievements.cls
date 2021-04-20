/*********************************************************************************
 * Name:EUR_CRM_TestScheduleRUAccrueAchievements
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/09/2016       Laputa: Jay             First Draft
*********************************************************************************/

@isTest
public class EUR_CRM_TestScheduleRUAccrueAchievements {
    static testMethod void TestSchedulableClass() {
      	Test.startTest(); // Start Test
    
        // Schedule the test job
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('EUR_CRM_TestScheduleRUAccrueAchievements_TestProcess',
                         CRON_EXP, 
                         new EUR_CRM_ScheduleRUAccrueAchievements());
        
        // To track the progress of the scheduled job.
        CronTrigger ct = [SELECT TimesTriggered
                               , NextFireTime
                               , CronExpression
                            FROM CronTrigger 
                           WHERE Id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
                            
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
      	Test.stopTest(); // End Test
    }
}