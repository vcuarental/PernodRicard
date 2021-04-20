/**
Batchable class to process all visit actions and create achievements
for Objectives & Promotions Module
*/
global class EUR_CRM_DE_DeactivateOPAccountMappings implements Database.Batchable<sObject>{
 
    global String query = ' select id,  EUR_CRM_Is_Active__c from EUR_CRM_ObjPromo_Account_Mapping__c ' +
                   ' where EUR_CRM_ObjPromo__c in (select id from EUR_CRM_ObjPromo__c where EUR_CRM_Status__c in (\'Ended\',\'Deactivated\',\'Under Evaluation\'))' +
                   ' AND EUR_CRM_Is_Active__c = true  ';
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        deactivate((List<EUR_CRM_ObjPromo_Account_Mapping__c>) scope);
    }
   
    global void finish(Database.BatchableContext BC){
    
    }
    
    public static void deactivate(List<EUR_CRM_ObjPromo_Account_Mapping__c> scope){
        for(EUR_CRM_ObjPromo_Account_Mapping__c mapping: scope){
            mapping.EUR_CRM_Is_Active__c = false;
        } 
        update scope;
    }
     
}