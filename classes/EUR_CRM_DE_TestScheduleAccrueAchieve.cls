/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_RoleUtils Class.
  @Author:      IPC
  @History:     AUG.4.2014 - Created
*/ 
@isTest(seeAllData=false)
private with sharing class EUR_CRM_DE_TestScheduleAccrueAchieve{

    static testMethod void myUnitTest() {
        
                String sched = '0 00 * * * ?';
                // Abort all CronTrigger records
               // for (CronTrigger cronTrigger : [SELECT Id FROM CronTrigger]) System.abortJob(cronTrigger.Id);
              List<CronJobDetail> details = [ SELECT Id FROM CronJobDetail where name = 'Accrue Germany Objective Achievements'];
                   if(details  != null && details.size() > 0){
                          CronJobDetail cd =details.get(0);
                       CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
                       if(d!=null)
                           System.abortJob(d.Id);
                    } 
                Test.startTest();  
                  String jobId = System.schedule('Accrue Germany Objective Achievements Test1', sched, new EUR_CRM_DE_ScheduleAccrueAchievements());
                Test.stopTest();

                CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
                
                EUR_CRM_DE_ScheduleAccrueAchievements.schedule();
                System.assertEquals(sched, ct.CronExpression); 
                System.assertEquals(0, ct.TimesTriggered);
    }
}