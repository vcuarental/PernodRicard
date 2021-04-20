/**
* Class: EUR_CRM_BE_MassActivateOPAccountMapping
*
* Fired from the schedulable class EUR_CRM_BE_ScheduledMassUpdOPAcctMapping 
* Sets O/P Account Mappings active field to true for each mappings' where ObjPromo EUR_CRM_Status__c in Published and start date is today
*/
global class EUR_CRM_BE_MassActivateOPAccountMapping implements Database.Batchable<sObject>{
    
    global static String generateQuery(){
        return  'SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c, ' +
                'EUR_CRM_ObjPromo__r.EUR_CRM_Active_Start_Date__c,EUR_CRM_ObjPromo__r.EUR_CRM_Status__c ,EUR_CRM_ObjPromo__c ' + 
                'FROM EUR_CRM_ObjPromo_Account_Mapping__c ' +
                'WHERE Recordtype.DeveloperName =  \'EUR_BE_O_P_Account_Mapping\' ' +
                'AND EUR_CRM_Is_Active__c = FALSE ' +
                'AND EUR_CRM_ObjPromo__r.EUR_CRM_Active_Start_Date__c <= TODAY ' +
                'AND EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c > TODAY ' + 
                'AND EUR_CRM_ObjPromo__r.EUR_CRM_Status__c = \'Active\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('QUERY: ' + generateQuery());
        return Database.getQueryLocator(generateQuery());
    }

    //Main Logic Implementation
    global void execute (Database.Batchablecontext BC, List<sObject> scope){
        System.debug('SCOPE: ' + scope);

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapToUpdateList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : opAcctMapList){
            // Activate all OPAcct Mappings that pass by the query
            opMap.EUR_CRM_Is_Active__c = true;
            opAcctMapToUpdateList.add(opMap);
        }
        
        if(opAcctMapToUpdateList.size() > 0){
            update opAcctMapToUpdateList;
        }
    }

    global void finish(Database.BatchableContext BC){

    }	
    
}