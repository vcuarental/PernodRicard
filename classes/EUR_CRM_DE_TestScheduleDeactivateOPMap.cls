/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_DE_ScheduleDeactivateOP Class.
  @Author:      IPC
  @History:     AUG.4.2014 - Created
*/
@isTest(seeAllData=false) 
private with sharing class EUR_CRM_DE_TestScheduleDeactivateOPMap{ 

    static testMethod void myUnitTest() {
        
                String sched =  '0 04 02 * * ?';
                List<CronJobDetail> details = [SELECT Id FROM CronJobDetail where name = 'Deactivate Germany OP-Account Mapping Records'];
                   if(details  != null && details.size() > 0){
                          CronJobDetail cd =details.get(0);
                       CronTrigger d =[select id from CronTrigger where  CronJobDetailId =: cd.id ];
                       if(d!=null)
                           System.abortJob(d.Id);
                    } 
                Test.startTest();  
                  String jobId = System.schedule('Deactivate Germany OP-Account Mapping Records Test1', sched, new EUR_CRM_DE_ScheduleDeactivateOP());
                Test.stopTest();

                CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
                
                EUR_CRM_DE_ScheduleDeactivateOP.schedule();
                System.assertEquals(sched, ct.CronExpression); 
                System.assertEquals(0, ct.TimesTriggered);
    }
}