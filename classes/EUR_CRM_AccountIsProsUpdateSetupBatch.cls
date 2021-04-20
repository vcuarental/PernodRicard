global class EUR_CRM_AccountIsProsUpdateSetupBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

//    Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 1);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_AccountIsProsUpdateSetupBatch scheduledJob = new EUR_CRM_AccountIsProsUpdateSetupBatch();
//    System.schedule('Account Is Pros Updated Scheduled Job', cronExpression, scheduledJob);
    private Set<Id> prsGroupIds = new Set<Id>();

    global EUR_CRM_AccountIsProsUpdateSetupBatch() {}

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccountIsProsUpdateSetupBatch(), 1);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,
                    EUR_CRM_PRS_Group_Outlet_Type__c
            FROM EUR_CRM_Account__c
            WHERE (
//                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR
                    EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
                    OR EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
                    OR EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
                    OR EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
                )
                AND EUR_CRM_IsProsUpdate__c = FALSE
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Account__c> accounts) {
        System.debug('\n\n accounts => ' + JSON.serializePretty(accounts) + '\n');
        System.debug('\n\n accounts.size => ' + JSON.serializePretty(accounts.size()) + '\n');

        for (EUR_CRM_Account__c account : accounts) {
            account.EUR_CRM_IsProsUpdate__c = true;
            prsGroupIds.add(account.EUR_CRM_PRS_Group_Outlet_Type__c);
        }

        this.upsertRecords(accounts);
    }

    global override void finish(Database.BatchableContext bc) {
        Database.executeBatch(new EUR_CRM_PRS_QuestionSetIsUpdatedBatch(prsGroupIds));
    }


}