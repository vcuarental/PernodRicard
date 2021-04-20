global class RIC_FusionNonSignAnnule implements Database.Batchable<sObject>{
    List<Milestone1_Task__c> ListActToUpdate = new List<Milestone1_Task__c>(); 
    global String query = 'select id,RIC_Status__c from Milestone1_Task__c where RIC_Status__c=\'Non significatif\'';
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(query);  
        
    }
    global void execute(Database.BatchableContext BC, list<Milestone1_Task__c> ListAction){ 
        User currUser = [select id,BypassVR__c,BypassTriggers__c 
                         from user
                         where id=:UserInfo.getUserId()
                         limit 1];
        currUser.BypassVR__c = true;
        if(currUser.BypassTriggers__c!=null)
        {
        currUser.BypassTriggers__c=currUser.BypassTriggers__c+';Milestone1_Task_Trigger_Utility';
            }
        else currUser.BypassTriggers__c='Milestone1_Task_Trigger_Utility';
        update currUser;
        for(Milestone1_Task__c Act: ListAction)
        {
            Act.RIC_Status__c='Annulé';
            ListActToUpdate.add(Act);
        }
        if(ListActToUpdate!=null && ListActToUpdate.size()>0)
        {  
            update ListActToUpdate;
        }
        
        
        
    }
    global void finish(Database.BatchableContext BC)
    {       
        User currUser = [select id,BypassVR__c,BypassTriggers__c
                         from user
                         where id=:UserInfo.getUserId()
                         limit 1];
        currUser.BypassVR__c = false; 
        if( currUser.BypassTriggers__c.contains(';Milestone1_Task_Trigger_Utility'))
        {
        currUser.BypassTriggers__c=currUser.BypassTriggers__c.replace(';Milestone1_Task_Trigger_Utility','');
            }
        else {
            currUser.BypassTriggers__c='';
        }
        update currUser; 
    }
}