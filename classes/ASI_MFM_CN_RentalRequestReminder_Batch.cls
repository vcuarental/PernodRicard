global without sharing class ASI_MFM_CN_RentalRequestReminder_Batch implements Database.Batchable<sObject> ,Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String soqlQuery = 'SELECT Id, ASI_MFM_Send_Email_Reminder__c FROM ASI_MFM_Rental_Request__c WHERE ASI_MFM_Reminding_Date__c <= TODAY AND ASI_MFM_Send_Email_Reminder__c = False AND RecordType.developerName Like \'ASI_MFM_CN_Rental_Request%\'';
        
        return Database.getQueryLocator(soqlQuery);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        List<ASI_MFM_Rental_Request__c> rr = (List<ASI_MFM_Rental_Request__c>) scope;
        
        for(ASI_MFM_Rental_Request__c obj : rr){
			obj.ASI_MFM_Send_Email_Reminder__c = True;
        }
        
        if(rr.size() > 0){
            try{
                Update rr;
            }catch(dmlException dmle){
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}