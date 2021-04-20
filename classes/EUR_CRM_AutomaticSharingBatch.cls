global class EUR_CRM_AutomaticSharingBatch  implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //Fake query => We don't use what we are retrieving here we just want to start the batch
        //Because we need to use the funcitonnality ScheduleCOnfig metadata that require to run a batch
        //We add a limit 1 to be sure to run only one batch
        return Database.getQueryLocator([
            SELECT Id FROM EUR_CRM_Automatic_Sharing__c 
            WHERE EUR_CRM_Status__c IN ('Waiting for batch', 'To be deleted') LIMIT 1
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        EUR_CRM_AutomaticSharingSchedule.runOperation();

    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    
    
    
}