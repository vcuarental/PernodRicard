/*********************************************************************************
 * Name:ASI_CRM_9AM_Schd_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2018-07-27       Calvin Chiu (LAPUTA)    Created
*********************************************************************************/
@isTest
public class ASI_CRM_9AM_Schd_Test {
    static testMethod void TestSchedulableClass() {
        ASI_CRM_TW_UpdateActualOfftake_Test.ASI_CRM_TW_UpdateActualOfftake_Batch_Test();
            
            
        List<ASI_KR_Schd_Setting__c> schdSettings = new List<ASI_KR_Schd_Setting__c>();
      schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For LR Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_LRSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For CC Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CCSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For CT Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CTSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For AnP Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CTSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For TnE Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_eForm_KR_CTSchd'));
        insert schdSettings;
        
        Test.startTest(); // Start Test
        // Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_9AM_Schd());
        
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