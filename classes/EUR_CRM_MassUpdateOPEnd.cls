global class EUR_CRM_MassUpdateOPEnd implements Database.Batchable<sObject>, Database.Stateful{
    global final String query;
    global final String VA_RT_DEVNAME_ENTER_PROMO = 'EUR_RU_ON_Enter_Promo_Kit_Quantity';
    global final String OP_RT_DEVNAME_TRADE_PHASE = 'EUR_RU_ON_Trade_Phase_2';
    global final String OP_ACTION_STATUS_EXECUTION = 'Execution';
    global final String OP_STATUS_ENDED = 'Ended';    
    global List<String> messageErrors;

    global EUR_CRM_MassUpdateOPEnd() {
        messageErrors = new List<String>();
        // TODO: Refactor query using RecordTypeHelper
        String q =  'SELECT Id, RecordType.DeveloperName, EUR_CRM_Active_End_Date__c, EUR_CRM_Evaluation_Period_End_Date__c, EUR_CRM_Status__c, '+
        			'(SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Evaluation_Required__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__c FROM EUR_CRM_O_P_Account_Mappings__r WHERE EUR_CRM_Is_Active__c = TRUE) '+
                    ' FROM EUR_CRM_ObjPromo__c '+
                    ' WHERE EUR_CRM_Status__c NOT IN (\'Ended\', \'Deactivated\') AND EUR_CRM_Really_End_Date__c < TODAY';
        query = q;        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	List<EUR_CRM_ObjPromo__c> opList = (List<EUR_CRM_ObjPromo__c>)scope;
        Map<Id, EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingToUpdate = new Map<Id, EUR_CRM_ObjPromo_Account_Mapping__c>();
        Map<Id, EUR_CRM_ObjPromo__c> objPromMapToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();
        
        for(EUR_CRM_ObjPromo__c op: opList){
            for(EUR_CRM_ObjPromo_Account_Mapping__c opMap: op.EUR_CRM_O_P_Account_Mappings__r){
               	opMap.EUR_CRM_Is_Active__c = FALSE;
                opMap.EUR_CRM_Evaluation_Required__c = FALSE;
               	opAccountMappingToUpdate.put(opMap.Id, opMap);
            }
            op.EUR_CRM_Status__c = OP_STATUS_ENDED;
            objPromMapToUpdate.put(op.Id, op);
        }
        
        System.debug('@@@ opAccountMappingToUpdate: '+ opAccountMappingToUpdate);
        System.debug('@@@ objPromMapToUpdate: '+ objPromMapToUpdate);

        if(!opAccountMappingToUpdate.isEmpty()){
            processErrors(opAccountMappingToUpdate.values(), Database.update(opAccountMappingToUpdate.values(), false), messageErrors, 'Class.EUR_CRM_MassUpdateOPEnd.execute: line 57');
        }

        if(!objPromMapToUpdate.isEmpty()) {
            processErrors(objPromMapToUpdate.values(), Database.update(objPromMapToUpdate.values(), false), messageErrors, 'Class.EUR_CRM_MassUpdateOPEnd.execute: line 61');
        }
    }

    public static void processErrors(List<sObject> sObjects, List<Database.SaveResult> srList, List<String> messageErrors, String codeLine){
        Integer i = 0;
        for(Database.SaveResult sr : srList) {
            if(!sr.isSuccess()) {
                String msg = '<br/>Operation failed. Exception on row with id '+sObjects[i].Id + '.<br/>'+codeLine;
                messageErrors.add(msg);
                for(Database.Error err : sr.getErrors()) {
                    messageErrors.add(err.getStatusCode() + ': ' + err.getMessage()+'.: '+err.getFields());
                }
            }
            i++;
        }
    }

    public Boolean isVisitActionSuccessful(EUR_CRM_Visit_Action__c visitAction) {
        // Visit action is successful depending on the value of its Status picklist
        return (visitAction.EUR_CRM_Status__c == 'Participating')? true: false;
    }    
    
    public String createKey(String objPromoId, String accountId) {
        return objPromoId + accountId;
    }
    
    global void finish(Database.BatchableContext BC){
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {}, 
                EUR_CRM_BatchApexUtilityClass.BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME, messageErrors);
    }
	
}