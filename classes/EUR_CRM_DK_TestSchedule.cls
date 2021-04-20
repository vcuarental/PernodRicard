@isTest
public class EUR_CRM_DK_TestSchedule {
	
    public static testmethod void testScheduleMassCreateFollowUps() {
    	Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('My batch Job',
                             CRON_EXP, 
                             new EUR_CRM_DK_ScheduleMassCreateFollowUps());
            
            CronTrigger ct = [SELECT TimesTriggered
                                   , NextFireTime
                                   , CronExpression
                                FROM CronTrigger 
                               WHERE Id = :jobId];
    
            System.assertEquals(CRON_EXP,
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
    }
    
    public static testmethod void testScheduleAccrueAchievements() {
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('My batch Job',
                             CRON_EXP, 
                             new EUR_CRM_DK_ScheduleAccrueAchievements());
            
            CronTrigger ct = [SELECT TimesTriggered
                                   , NextFireTime
                                   , CronExpression
                                FROM CronTrigger 
                               WHERE Id = :jobId];
    
            System.assertEquals(CRON_EXP,
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
    }
    
    public static testmethod void testMassUpdateEMObjectiveScheduler() {
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('My batch Job',
                             CRON_EXP, 
                             new EUR_CRM_MassUpdateEMObjectiveScheduler());
            
            CronTrigger ct = [SELECT TimesTriggered
                                   , NextFireTime
                                   , CronExpression
                                FROM CronTrigger 
                               WHERE Id = :jobId];
    
            System.assertEquals(CRON_EXP,
                                ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
    }
    
}