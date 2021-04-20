/*********************************************************************************
 * Name:ASI_CRM_1AM_Schd_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2018-07-27       Calvin Chiu (LAPUTA)    Created
*********************************************************************************/
@isTest
public class ASI_CRM_1AM_Schd_Test {
	static testMethod void TestSchedulableClass() {
        Test.startTest(); // Start Test
    	// Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_1AM_Schd());
        
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