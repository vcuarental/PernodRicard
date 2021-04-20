/**********************************************************************************
 * Name : ASI_CRM_SG_YtdAchievementNotifSchdulTest
 * Created : DC @04/21/2016 12.30 PM
 * Revision History:
 * 1. 04/21/2016 - [DC 1.0] Created
 **********************************************************************************/
@isTest
private class ASI_CRM_SG_YtdAchievementNotifSchdulTest {

    static testMethod void TestSchedulableClass() {

      Test.startTest(); // Start Test
          // Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_SG_YtdAchievementNotif_Scheduler());
        
        // To track the progress of the scheduled job.
        CronTrigger ct = [SELECT TimesTriggered
                               , NextFireTime
                               , CronExpression
                            FROM CronTrigger 
                           WHERE Id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

      Test.stopTest(); // End Test
    }

}