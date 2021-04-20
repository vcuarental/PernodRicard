//Update 2017-May-17 : Add ability to update the O/P Status
global class EUR_CRM_MassUpdateOPAcctMapActive implements Database.Batchable<sObject> {
    global final String query;
    global final Set<String> validRecordTypes = EUR_CRM_RecordTypeHelper.MassUpdateOPAcctMap_validRecordTypes;
    global final Set<String> statusPushActive = new Set<String>{'Published','Under Evaluation'};

	global EUR_CRM_MassUpdateOPAcctMapActive() {
        query = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' + 
                ' EUR_CRM_ObjPromo__c, EUR_CRM_ObjPromo__r.EUR_CRM_Status__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_Start_Date__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c' +
                ' FROM EUR_CRM_ObjPromo_Account_Mapping__c' +
                ' WHERE Recordtype.DeveloperName =: validRecordTypes' +
                ' AND EUR_CRM_Is_Active__c = FALSE' +
                ' AND EUR_CRM_ObjPromo__r.EUR_CRM_Status__c IN (\'Active\',\'Published\',\'Under Evaluation\')' +
                ' AND EUR_CRM_ObjPromo__r.EUR_CRM_Active_Start_Date__c <= TODAY' +
                ' AND EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c >= TODAY';
	}
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.Batchablecontext BC, List<sObject> scope){
        System.debug('Scope: '+scope);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Map<Id, EUR_CRM_ObjPromo__c> opToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();

        // Loop through all account mappings and activates them
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope){
            opMap.EUR_CRM_Is_Active__c = TRUE;
            opAccountMappingToUpdate.add(opMap);
            if(statusPushActive.contains(opMap.EUR_CRM_ObjPromo__r.EUR_CRM_Status__c)){
                opToUpdate.put(opMap.EUR_CRM_ObjPromo__c, new EUR_CRM_ObjPromo__c(id = opMap.EUR_CRM_ObjPromo__c, EUR_CRM_Status__c = 'Active'));
            }
        }
               
        System.debug(opAccountMappingToUpdate);
        if(opAccountMappingToUpdate.size() > 0){
            try{
                update opAccountMappingToUpdate;
                update opToUpdate.values();
            } catch(Exception e){
                System.debug(e);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){   
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
    }
}