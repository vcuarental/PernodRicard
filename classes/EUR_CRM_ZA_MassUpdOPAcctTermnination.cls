global class EUR_CRM_ZA_MassUpdOPAcctTermnination implements Database.Batchable<sObject>{

    global final String query;

    global EUR_CRM_ZA_MassUpdOPAcctTermnination (){
        /*String q = 'Select Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c,' + 
                    ' EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE Recordtype.DeveloperName =  \'EUR_ZA_OP_Account_Mapping\' AND '+
                    'EUR_CRM_Is_Active__c = TRUE AND EUR_CRM_Evaluation_Required__c = FALSE';*/
        String q = 'Select Id, EUR_CRM_Evaluation_Period_End_Date__c, EUR_CRM_Status__c,EUR_CRM_Active_End_Date__c FROM EUR_CRM_ObjPromo__c '+
                    'WHERE Recordtype.DeveloperName =  \'EUR_ZA_Off_Trade_Display_Promo\' OR Recordtype.DeveloperName =  \'EUR_ZA_On_Trade_OP\'';
        query = q;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    //Main Logic Implementation
    global void execute (Database.Batchablecontext BC, List<sObject> scope){

        System.debug('$$SCOPE2: '+scope);
        List<EUR_CRM_ObjPromo__c> objPromotionsList = (List<EUR_CRM_ObjPromo__c>)scope;
        //List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapList = (List<EUR_CRM_ObjPromo_Account_Mapping__c>)scope;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAcctMapListToUpdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<Id> opIds = new Set<Id>();
        Set<Id> opIdsUnderEval = new Set<Id>();
        List<EUR_CRM_ObjPromo_Action__c> zaOPActions = new List<EUR_CRM_ObjPromo_Action__c>();
        Map<Id, EUR_CRM_ObjPromo__c> objPromMap = new Map<Id, EUR_CRM_ObjPromo__c>();
        Map<Id, String> objPromStatus = new Map<Id, String>();
        Map<Id, Id> succesExecAcctMap = new Map<Id, Id>();
        String OP_STATUS_ENDED = 'Ended';
        String OP_STATUS_UNDER_EVALUATION = 'Under Evaluation';
        String OP_ACTION_STATUS_PRE_SELL = 'Pre-sell';
        String OP_ACTION_STATUS_EXECUTION = 'Execution';
        String OP_ACTION_STATUS_EVALUATION = 'Evaluation';

        for(EUR_CRM_ObjPromo__c op : objPromotionsList){
            //opIds.add(opMap.EUR_CRM_ObjPromo__c);
            if(op.EUR_CRM_Active_End_Date__c < Date.Today()){
                if(op.EUR_CRM_Evaluation_Period_End_Date__c < Date.Today()){
                    op.EUR_CRM_Status__c = OP_STATUS_ENDED;
                    opIds.add(op.Id);
                } else{
                     op.EUR_CRM_Status__c = OP_STATUS_UNDER_EVALUATION;
                     opIdsUnderEval.add(op.Id);
                }
            }
        }

        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap : [SELECT Id, EUR_CRM_ObjPromo__c, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE EUR_CRM_ObjPromo__c IN :opIds]){
            opMap.EUR_CRM_Is_Active__c = FALSE;
            opMap.EUR_CRM_Evaluation_Required__c = FALSE;
            opAcctMapListToUpdate.add(opMap);
        } 

        for(EUR_CRM_Visit_Action__c visitAct : [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Is_Successful__c, EUR_CRM_OP_Action__c, EUR_CRM_OP_Action__r.EUR_CRM_Stage__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_Visit_Action__c WHERE EUR_CRM_ObjPromo__c IN :opIdsUnderEval]){
            if(objPromStatus.containskey(visitAct.EUR_CRM_ObjPromo__c)){
                if(visitAct.EUR_CRM_OP_Action__r.EUR_CRM_Stage__c == OP_ACTION_STATUS_PRE_SELL){
                    if(objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == ''){
                        objPromStatus.put(visitAct.EUR_CRM_ObjPromo__c, OP_ACTION_STATUS_PRE_SELL);
                    }
                }
                if(visitAct.EUR_CRM_OP_Action__r.EUR_CRM_Stage__c == OP_ACTION_STATUS_EXECUTION){
                    if(objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == OP_ACTION_STATUS_PRE_SELL || objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == ''){
                        objPromStatus.put(visitAct.EUR_CRM_ObjPromo__c, OP_ACTION_STATUS_EXECUTION);
                        //if(visitAct.EUR_CRM_Is_Successful__c == TRUE){
                            succesExecAcctMap.put(visitAct.EUR_CRM_ObjPromo__c, visitAct.EUR_CRM_Account__c);
                        //}
                    }
                }
                if(visitAct.EUR_CRM_OP_Action__r.EUR_CRM_Stage__c == OP_ACTION_STATUS_EVALUATION){
                    if(objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == OP_ACTION_STATUS_EXECUTION || objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == OP_ACTION_STATUS_PRE_SELL || objPromStatus.get(visitAct.EUR_CRM_ObjPromo__c) == ''){
                        objPromStatus.put(visitAct.EUR_CRM_ObjPromo__c, OP_ACTION_STATUS_EVALUATION);
                    }
                }
            }
        }

        for(EUR_CRM_ObjPromo_Account_Mapping__c opMap :  [SELECT Id, EUR_CRM_ObjPromo__c, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c FROM EUR_CRM_ObjPromo_Account_Mapping__c WHERE EUR_CRM_ObjPromo__c IN :opIdsUnderEval]){
            if(objPromStatus.containskey(opMap.EUR_CRM_ObjPromo__c)){
                if(objPromStatus.get(opMap.EUR_CRM_ObjPromo__c) == OP_ACTION_STATUS_EXECUTION){
                    if(succesExecAcctMap.containskey(opMap.EUR_CRM_ObjPromo__c)){
                        if(succesExecAcctMap.get(opMap.EUR_CRM_ObjPromo__c) == opMap.EUR_CRM_Account__c){
                            opMap.EUR_CRM_Evaluation_Required__c = TRUE;
                        }
                    } else {
                        opMap.EUR_CRM_Evaluation_Required__c = FALSE;
                    }
                    opAcctMapListToUpdate.add(opMap);
                }
            }
        }

        if(objPromotionsList.size() > 0){
            update objPromotionsList;
        }

        if(opAcctMapListToUpdate.size() > 0){
            update opAcctMapListToUpdate;
        }

    }
    
    // Send email, clean and end execution
    global void finish(Database.BatchableContext BC){   
        AsyncApexJob apexjob = [Select Id From AsyncApexJob WHERE Id =:BC.getJobId()];
        //EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexjob.id, new String[] {});
    }

}