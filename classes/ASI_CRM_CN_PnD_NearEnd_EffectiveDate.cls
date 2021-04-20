global class ASI_CRM_CN_PnD_NearEnd_EffectiveDate implements Database.Batchable<sObject>, Database.Stateful {

    public ASI_CRM_CN_PnD_NearEnd_EffectiveDate(){

    }


    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        String query = 'SELECT id FROM ASI_CRM_Price_And_Discount__c WHERE ' +
                'recordtype.developername IN (' +
                '\'ASI_CRM_CN_Customer_Price_and_Discount_Request_RO\',' +
                '\'ASI_CRM_CN_NPL_T1_Price_Request_RO\',' +
                '\'ASI_CRM_CN_Repacking_Price_Request_RO\',' +
                '\'ASI_CRM_CN_T1_Price_Adjustment_Request_RO\'' +
                ') AND ' +
                'ASI_CRM_Status__c = \'Completed\' AND ' +
                'ASI_CRM_Effective_To__c >= TODAY AND ' +
                'ASI_CRM_Effective_To__c <= NEXT_N_DAYS:3';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){

        if (scope == null) return;

        List<ASI_CRM_Price_And_Discount__c> pndList = scope;

        for (ASI_CRM_Price_And_Discount__c pnd : pndList) {
            pnd.ASI_CRM_CN_SYS_Send_Email__c = true;
        }
        update pndList;
    }
    global void finish(Database.BatchableContext bc){

    }
}