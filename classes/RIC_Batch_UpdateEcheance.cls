global Class RIC_Batch_UpdateEcheance implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String Query = 'select ID,Due_Date__c from Milestone1_Task__c ';
        return Database.getQueryLocator(query);
         
    }
    global void execute(Database.BatchableContext BC, List<Milestone1_Task__c> listtask) 
    {
        user u =new user(id=UserInfo.getUserId());
        u.BypassVR__c=true;
        u.BypassTriggers__c='Milestone1_Task_Trigger';
        update u;
        
        for(Milestone1_Task__c task :listtask){      
        }  
        update listtask;
 
    }   
    global void finish(Database.BatchableContext BC) {
    user u =new user(id=UserInfo.getUserId());
    u.BypassVR__c = false;
    u.BypassTriggers__c='';
        update u;
        }
}