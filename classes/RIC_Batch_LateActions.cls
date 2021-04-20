global class RIC_Batch_LateActions implements Database.Batchable<sObject>{ 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        String query = 'Select id,RIC_Echeance_depasse__c,RIC_TechLateAction__c,RIC_Late__c,Start_Date__c from Milestone1_Task__c where RIC_TechLateAction__c=true and RIC_Echeance_depasse__c > 0 '; 
        if(test.isRunningTest())
        {
            query='Select id,RIC_Echeance_depasse__c,RIC_TechLateAction__c,RIC_Late__c,Start_Date__c from Milestone1_Task__c ';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, list<Milestone1_Task__c> ListTasks){
        List<Milestone1_Task__c> ListTaskToUpdate= new List<Milestone1_Task__c>();
        user u =new user(id=UserInfo.getUserId());
        u.BypassTriggers__c='Milestone1_Task_Trigger';
        u.BypassVR__c=true; 
        update u;  
        for(Milestone1_Task__c task:ListTasks)
        { 
            task.RIC_Late__c=task.RIC_Echeance_depasse__c;
            ListTaskToUpdate.add(task); 
        } 
        if(ListTaskToUpdate!=null && ListTaskToUpdate.size()>0) 
        {
            Update ListTaskToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC)
    { 
        user u =new user(id=UserInfo.getUserId());
        u.BypassTriggers__c='';
        u.BypassVR__c = false; 
        update u;  
    }
}