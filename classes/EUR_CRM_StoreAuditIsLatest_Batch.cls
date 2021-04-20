/**
 * Created by larsz on 8/12/2020.
 */

global class EUR_CRM_StoreAuditIsLatest_Batch implements Database.Batchable<SObject> {
    @TestVisible
    private static final String FINISH_STATUS = 'Finished';


    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, EUR_CRM_Is_Latest_Store_Audit_Formula__c FROM EUR_CRM_Store_Audit__c WHERE
                        EUR_CRM_Is_Latest_Store_Audit_Formula__c = TRUE
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Store_Audit__c> strAudits) {
        for (EUR_CRM_Store_Audit__c strAudit: strAudits) {
            strAudit.EUR_CRM_Status__c = FINISH_STATUS;
        }
        update strAudits;
    }

    global void finish(Database.BatchableContext BC) {
    }

}