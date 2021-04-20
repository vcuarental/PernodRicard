/*********************************************************************************
 * Name:ASI_CRM_SG_AssignContToOfftake_ScheTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-24       Laputa: Vincent            Created
*********************************************************************************/
@isTest
public class ASI_CRM_SG_AssignContToOfftake_ScheTest {
  
    @TestSetup
    public static void setupTestData() {
        
    }
    
    static testMethod void TestSchedulableClass() {

      Test.startTest(); // Start Test
          // Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_SG_AssignContractToOfftake_Sche());
        
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