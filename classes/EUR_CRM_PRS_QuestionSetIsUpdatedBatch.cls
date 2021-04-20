/**
 * Created by larsz on 9/18/2020.
 */

public with sharing class EUR_CRM_PRS_QuestionSetIsUpdatedBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject> {

    private Set<Id> prsGroupIds;

    public EUR_CRM_PRS_QuestionSetIsUpdatedBatch(Set<Id> prsGroupIds) {
        this.prsGroupIds = prsGroupIds;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Id,
                        EUR_CRM_BrandBuildPotQuestionSet__c,
                        EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c,
                        EUR_CRM_BusinessPotentialQuestionSet__c,
                        EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c,
                        EUR_CRM_Image_Level_Question_Set__c,
                        EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c,
                        EUR_CRM_Volume_Potential_Question_Set__c,
                        EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c
                FROM EUR_CRM_PRS_Group_Outlet_Type__c
                WHERE Id IN :prsGroupIds
        ]);
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_PRS_Group_Outlet_Type__c> prsGroupOutletTypes) {
        System.debug('\n\n prsGroupOutletTypes.size => ' + JSON.serializePretty(prsGroupOutletTypes.size()) + '\n');
        System.debug('\n\n prsGroupOutletTypes => ' + JSON.serializePretty(prsGroupOutletTypes) + '\n');

        List<EUR_CRM_PRS_Question_Set__c> prsQuestionsToUpdate = changeIsQustionUpdatedFromTrueToFalse(prsGroupOutletTypes);
        System.debug('\n\n prsQuestionsToUpdate.size => ' + JSON.serializePretty(prsQuestionsToUpdate.size()) + '\n');
        System.debug('\n\n prsQuestionsToUpdate => ' + JSON.serializePretty(prsQuestionsToUpdate) + '\n');

        if (!prsQuestionsToUpdate.isEmpty()) {
            update prsQuestionsToUpdate;
        }
    }

    private List<EUR_CRM_PRS_Question_Set__c> changeIsQustionUpdatedFromTrueToFalse
            (List<EUR_CRM_PRS_Group_Outlet_Type__c> prsGroupOutletTypes) {
        List<EUR_CRM_PRS_Question_Set__c> result = new List<EUR_CRM_PRS_Question_Set__c>();

        for (EUR_CRM_PRS_Group_Outlet_Type__c prsGroupType: prsGroupOutletTypes) {
            if (prsGroupType.EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c == true) {
                result.add(new EUR_CRM_PRS_Question_Set__c(Id = prsGroupType.EUR_CRM_BrandBuildPotQuestionSet__c,
                        EUR_CRM_IsQuestionsUpdated__c = false));
            }
            if (prsGroupType.EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c == true) {
                result.add(new EUR_CRM_PRS_Question_Set__c(Id = prsGroupType.EUR_CRM_BusinessPotentialQuestionSet__c,
                        EUR_CRM_IsQuestionsUpdated__c = false));
            }
            if (prsGroupType.EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
                result.add(new EUR_CRM_PRS_Question_Set__c(Id = prsGroupType.EUR_CRM_Image_Level_Question_Set__c,
                        EUR_CRM_IsQuestionsUpdated__c = false));
            }
            if (prsGroupType.EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
                result.add(new EUR_CRM_PRS_Question_Set__c(Id = prsGroupType.EUR_CRM_Volume_Potential_Question_Set__c,
                        EUR_CRM_IsQuestionsUpdated__c = false));
            }
        }
        return result;
    }
}