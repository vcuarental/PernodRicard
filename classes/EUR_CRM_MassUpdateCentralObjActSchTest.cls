@isTest
public class EUR_CRM_MassUpdateCentralObjActSchTest {
    static testMethod void testSchedulableClass() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new EUR_CRM_MassUpdateCentralObjActiveSch());
        
        CronTrigger ct = [SELECT TimesTriggered
                               , NextFireTime
                               , CronExpression
                            FROM CronTrigger 
                           WHERE Id = :jobId];
        
        
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);
        
        System.assertEquals(0, ct.TimesTriggered);
    }
    
}