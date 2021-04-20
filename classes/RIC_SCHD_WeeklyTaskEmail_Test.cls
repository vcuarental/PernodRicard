@isTest
public class RIC_SCHD_WeeklyTaskEmail_Test {
    
    @isTest public static void WeeklyTaskTest (){
        RIC_SCHD_WeeklyTaskEmail scheSendEmail = new RIC_SCHD_WeeklyTaskEmail();
        String cron = '0 0 7 ? * MON *';
        Id jobId = System.schedule('WeeklyTaskEmail',cron ,scheSendEmail);
        
        // Get the CronTrigger info prior to the run
        CronTrigger cronTrigger_after = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Assert that the cron job has run once
        System.assertEquals(0, cronTrigger_after.TimesTriggered);
    }
    @isTest public static void WeeklyTaskTest_Opp (){
        RIC_SCHD_WeeklyTaskEmail_Opp scheSendEmail_Opp = new RIC_SCHD_WeeklyTaskEmail_Opp();
        String cron_Opp = '0 0 7 ? * WED *';
        Id jobId = System.schedule('WeeklyTaskEmail_Opp',cron_Opp ,scheSendEmail_Opp);
        
        // Get the CronTrigger info prior to the run
        CronTrigger cronTrigger_after = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Assert that the cron job has run once
        System.assertEquals(0, cronTrigger_after.TimesTriggered);
    }
}