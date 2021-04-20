global class EUR_CRM_MassUpdateOPAcctMapEval implements Database.Batchable<sObject> {

    global final String query;
    global String OP_ACTION_STATUS_PRE_SELL = 'Pre-sell';
    global String OP_ACTION_STATUS_EXECUTION = 'Execution';
    global String OP_ACTION_STATUS_EVALUATION = 'Evaluation';

    global EUR_CRM_MassUpdateOPAcctMapEval (){
        String q = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' + 
                    ' EUR_CRM_ObjPromo__c, RecordtypeId FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE Recordtype.DeveloperName =  \'EUR_RU_O_P_Account_Mapping\' AND '+
                    'EUR_CRM_Is_Active__c = FALSE AND EUR_CRM_Evaluation_Required__c = TRUE';
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope;
        //List<Recordtype> visitActionTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c');
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Map<String, EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingMap = new Map<String, EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<Id> opIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, EUR_CRM_ObjPromo__c> objPromMap = new Map<Id, EUR_CRM_ObjPromo__c>();
        
        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap: opAcctMapList) {
            opIds.add(opMap.EUR_CRM_ObjPromo__c);
            accIds.add(opMap.EUR_CRM_Account__c);
            opAccountMappingMap.put(
                createKey((String)opMap.EUR_CRM_ObjPromo__c, (String)opMap.EUR_CRM_Account__c), 
                opMap
            );
        }
        
        System.debug(opIds);
        System.debug(accIds);
        System.debug(opAccountMappingMap);
        
        for(EUR_CRM_Visit_Action__c visitAct: [SELECT Id, RecordTypeId, EUR_CRM_Account__c,
                                                EUR_CRM_Status__c,
                                                EUR_CRM_Is_Successful__c, EUR_CRM_OP_Action__c,
                                                EUR_CRM_OP_Action__r.EUR_CRM_Stage__c, EUR_CRM_ObjPromo__c
                                               FROM EUR_CRM_Visit_Action__c
                                               WHERE EUR_CRM_ObjPromo__c IN :opIds
                                               AND EUR_CRM_Account__c IN :accIds
                                               AND EUR_CRM_OP_Action__r.EUR_CRM_Stage__c = :OP_ACTION_STATUS_EVALUATION]) {
        
            if(isVisitActionSuccessful(visitAct)) {
                EUR_CRM_ObjPromo_Account_Mapping__c opMap = opAccountMappingMap.get(
                    createKey((String)visitAct.EUR_CRM_ObjPromo__c, (String)visitAct.EUR_CRM_Account__c)
                );
                
                opMap.EUR_CRM_Evaluation_Required__c = false;
                
                opAccountMappingToUpdate.add(opMap);
            }
        }
        
        System.debug(opAccountMappingToUpdate);
        
        if(opAccountMappingToUpdate.size() > 0) {
            update opAccountMappingToUpdate;
        }
    }
    
    public Boolean isVisitActionSuccessful(EUR_CRM_Visit_Action__c visitAction) {
        // TODO: Adjust in the future, when the requirements are clearer
        if(visitAction.EUR_CRM_Status__c == 'Participating') {
            return true;
        }
        
        return false;
    }
    
    public String createKey(String objPromoId, String accountId) {
        return objPromoId + accountId;
    }
    
    global void finish(Database.BatchableContext BC){   
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
    }


}