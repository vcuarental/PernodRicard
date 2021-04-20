public with sharing class EUR_CRM_AccountIsProsUpdateService {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleIsProsUpdateUncheck(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
//        List<EUR_CRM_Account__c> accountsToUpdate = this.getAccountIdsToUpdateSetOfQuestions(accounts, oldAccountById);
//        System.debug('\n\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
//        if (accountsToUpdate.isEmpty()) { return ; }

//        this.updateSetOfQuestions(accountsToUpdate);
    }
//
//    public void handleUpdateNullPriorityLevelMatrixField(Map<Id, EUR_CRM_Account__c> newAccountsMap) {
//        Set<Id> accountsIdsWithNullPriorityField = getAccountsIdsWithNullPRSMatrixField(newAccountsMap.values());
//        System.debug('Quantity of account with null field  =>  ' + accountsIdsWithNullPriorityField.size());
//
//        if (!accountsIdsWithNullPriorityField.isEmpty()) {
//            updateNullPriorityLevelMatrixField(accountsIdsWithNullPriorityField);
//        }
//
//    }
//
//
//    /* ========================================================= */
//    /*     Delegate Methods
//    /* ========================================================= */
//    private void updateSetOfQuestions(List<EUR_CRM_Account__c> accounts) {
//        Set<Id> groupOutletTypeIds = this.extractGroupOutletTypeIds(accounts);
//        System.debug('\n\n groupOutletTypeIds => ' + JSON.serializePretty(groupOutletTypeIds) + '\n');
//
//        List<SObject> sObjectsToUpdate = new List<SObject>();
//        if( ! groupOutletTypeIds.isEmpty()) {
//            sObjectsToUpdate.addAll((List<SObject>)this.getCriteriaSetsToUpdate(groupOutletTypeIds));
//        }
//
//        Set<Id> prsGroupOutletTypeIds = this.extractPRSGroupOutletTypeIds(accounts);
//        System.debug('\n\n prsGroupOutletTypeIds => ' + JSON.serializePretty(prsGroupOutletTypeIds) + '\n');
//        if( ! prsGroupOutletTypeIds.isEmpty()) {
//            sObjectsToUpdate.addAll((List<SObject>)this.getQuestionSetsToUpdate(prsGroupOutletTypeIds));
//        }
//
//        System.debug('\n\n sObjectsToUpdate => ' + JSON.serializePretty(sObjectsToUpdate) + '\n');
//        if( ! sObjectsToUpdate.isEmpty()) {
//            update sObjectsToUpdate;
//        }
//    }
//
//    private void updateNullPriorityLevelMatrixField(Set<Id> accIds) {
//        List<EUR_CRM_Account__c> accountsToUpdate = fillPriorityLevelMatrixFieldOnAccounts
//                (selectAccountsByIdsWithPRSSegmentation(accIds));
//        System.debug('Accounts to update with filled Matrix Field  => ' + JSON.serializePretty(accountsToUpdate));
//
//        if (!accountsToUpdate.isEmpty()) {
//            update accountsToUpdate;
//        }
//
//    }
//
//
//    /* ========================================================= */
//    /*     High Level Helpers
//    /* ========================================================= */
//    private List<EUR_CRM_Criteria_Set__c> getCriteriaSetsToUpdate(Set<Id> groupOutletTypeIds) {
//        List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = this.selectGroupOutletTypesWhereIds(groupOutletTypeIds);
//        System.debug('\n\n groupOutletTypes => ' + JSON.serializePretty(groupOutletTypes) + '\n');
//        if (groupOutletTypes.isEmpty()) { return new List<EUR_CRM_Criteria_Set__c>(); }
//
//        Set<Id> criteriaSetIds = new Set<Id>();
//        for (EUR_CRM_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            if (groupOutletType.EUR_CRM_Image_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                criteriaSetIds.add(groupOutletType.EUR_CRM_Image_Criteria_Set__c);
//            } else if (groupOutletType.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                criteriaSetIds.add(groupOutletType.EUR_CRM_Volume_Criteria_Set__c);
//            }
//        }
//        if (criteriaSetIds.isEmpty()) { return new List<EUR_CRM_Criteria_Set__c>(); }
//
//        List<EUR_CRM_Criteria_Set__c> criteriaSetsToUpdate = new List<EUR_CRM_Criteria_Set__c>();
//        for (Id criteriaSetId : criteriaSetIds) {
//            criteriaSetsToUpdate.add(new EUR_CRM_Criteria_Set__c(
//                Id = criteriaSetId
//            ,   EUR_CRM_IsQuestionsUpdated__c = false
//            ));
//        }
//        System.debug('\n\n criteriaSetsToUpdate => ' + JSON.serializePretty(criteriaSetsToUpdate) + '\n');
//        return criteriaSetsToUpdate;
//    }
//
//    private List<EUR_CRM_PRS_Question_Set__c> getQuestionSetsToUpdate(Set<Id> prsGroupOutletTypeIds) {
//        List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = this.selectPRSGroupOutletTypesWhereIds(prsGroupOutletTypeIds);
//        System.debug('\n\n groupOutletTypes => ' + JSON.serializePretty(groupOutletTypes) + '\n');
//        if (groupOutletTypes.isEmpty()) { return new List<EUR_CRM_PRS_Question_Set__c>(); }
//
//        Set<Id> questionSetIds = new Set<Id>();
//        for (EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType : groupOutletTypes) {
//            if (groupOutletType.EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                questionSetIds.add(groupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c);
//            } else if (groupOutletType.EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                questionSetIds.add(groupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c);
//            } else if (groupOutletType.EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                questionSetIds.add(groupOutletType.EUR_CRM_Image_Level_Question_Set__c);
//            } else if (groupOutletType.EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c == true) {
//                questionSetIds.add(groupOutletType.EUR_CRM_Volume_Potential_Question_Set__c);
//            }
//        }
//        if (questionSetIds.isEmpty()) { return new List<EUR_CRM_PRS_Question_Set__c>(); }
//
//        List<EUR_CRM_PRS_Question_Set__c> questionSetsToUpdate = new List<EUR_CRM_PRS_Question_Set__c>();
//        for (Id questionSetId : questionSetIds) {
//            questionSetsToUpdate.add(new EUR_CRM_PRS_Question_Set__c(
//                Id = questionSetId
//            ,   EUR_CRM_IsQuestionsUpdated__c = false
//            ));
//        }
//        System.debug('\n\n questionSetsToUpdate => ' + JSON.serializePretty(questionSetsToUpdate) + '\n');
//        return questionSetsToUpdate;
//    }
//
//
//    /* ========================================================= */
//    /*     Middle Level Helpers
//    /* ========================================================= */
//    private List<EUR_CRM_Account__c> getAccountIdsToUpdateSetOfQuestions(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
//        List<EUR_CRM_Account__c> resultAccounts = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if (this.isNeedToUpdateSetOfQuestions(account, oldAccountById)) {
//                resultAccounts.add(account);
//            }
//        }
//        return resultAccounts;
//    }
//
//    private Set<Id> extractGroupOutletTypeIds(List<EUR_CRM_Account__c> accounts) {
//        Set<Id> groupOutletTypeIds = new Set<Id>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if (account.EUR_CRM_Group_Outlet_Type__c != null) {
//                groupOutletTypeIds.add(account.EUR_CRM_Group_Outlet_Type__c);
//            }
//        }
//        return groupOutletTypeIds;
//    }
//
//    private Set<Id> extractPRSGroupOutletTypeIds(List<EUR_CRM_Account__c> accounts) {
//        Set<Id> groupOutletTypeIds = new Set<Id>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if (account.EUR_CRM_PRS_Group_Outlet_Type__c != null) {
//                groupOutletTypeIds.add(account.EUR_CRM_PRS_Group_Outlet_Type__c);
//            }
//        }
//        return groupOutletTypeIds;
//    }
//
//    private List<EUR_CRM_Account__c> fillPriorityLevelMatrixFieldOnAccounts(List<EUR_CRM_Account__c> accounts) {
//        System.debug('List of accounts to fill  => ' + JSON.serializePretty(accounts));
//        List<EUR_CRM_Account__c> result = new List<EUR_CRM_Account__c>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if (!account.EUR_CRM_PRS_Segmentation__r.isEmpty()) {
//                account.EUR_CRM_PRS_Priority_Level_Criteria__c = account.EUR_CRM_PRS_Segmentation__r[0]
//                        .EUR_CRM_PRS_Priority_Level_Criteria__c;
//                result.add(account);
//            }
//        }
//        return result;
//    }
//
//    private Set<Id> getAccountsIdsWithNullPRSMatrixField(List<EUR_CRM_Account__c> accounts) {
//        Set<Id> result = new Set<Id>();
//        for (EUR_CRM_Account__c account : accounts) {
//            if (account.EUR_CRM_PRS_Priority_Level_Criteria__c == null) {
//                result.add(account.Id);
//            }
//        }
//        return result;
//    }
//
//
//    /* ========================================================= */
//    /*     Low Level Helpers
//    /* ========================================================= */
//    private Boolean isNeedToUpdateSetOfQuestions(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
//        return this.isProsUpdateChangedToFalse(account, oldAccountById)
//            && (
//                account.EUR_CRM_Group_Outlet_Type__c != null
//                || account.EUR_CRM_PRS_Group_Outlet_Type__c != null
//            )
//        ;
//    }
//
//    private Boolean isProsUpdateChangedToFalse(EUR_CRM_Account__c account, Map<Id, EUR_CRM_Account__c> oldAccountById) {
//        return account.EUR_CRM_IsProsUpdate__c == false
//            && oldAccountById.get(account.Id).EUR_CRM_IsProsUpdate__c == true
//        ;
//    }
//
//
//    /* ========================================================= */
//    /*     SOQL Selectors
//    /* ========================================================= */
//    private List<EUR_CRM_Group_Outlet_Type__c> selectGroupOutletTypesWhereIds(Set<Id> ids) {
//        return [
//            SELECT Id
//            ,   EUR_CRM_Image_Criteria_Set__c
//            ,   EUR_CRM_Volume_Criteria_Set__c
//            ,   EUR_CRM_Image_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c
//            ,   EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c
//            FROM EUR_CRM_Group_Outlet_Type__c
//            WHERE Id IN :ids
//                AND (
//                    EUR_CRM_Image_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                )
//        ];
//    }
//
//    private List<EUR_CRM_PRS_Group_Outlet_Type__c> selectPRSGroupOutletTypesWhereIds(Set<Id> ids) {
//        return [
//            SELECT Id
//            ,   EUR_CRM_BrandBuildPotQuestionSet__c
//            ,   EUR_CRM_BusinessPotentialQuestionSet__c
//            ,   EUR_CRM_Image_Level_Question_Set__c
//            ,   EUR_CRM_Volume_Potential_Question_Set__c
//            ,   EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c
//            ,   EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c
//            ,   EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c
//            ,   EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c
//            FROM EUR_CRM_PRS_Group_Outlet_Type__c
//            WHERE Id IN :ids
//                AND (
//                    EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                    OR EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_IsQuestionsUpdated__c = TRUE
//                )
//        ];
//    }
//
//    private List<EUR_CRM_Account__c> selectAccountsByIdsWithPRSSegmentation(Set<Id> accIds) {
//        return [
//                SELECT Id, (
//                        SELECT Id, EUR_CRM_PRS_Priority_Level_Criteria__c
//                        FROM EUR_CRM_PRS_Segmentation__r
//                        WHERE EUR_CRM_PRS_Priority_Level_Criteria__c != NULL
//                        ORDER BY LastModifiedDate DESC
//                )
//                FROM EUR_CRM_Account__c
//                WHERE Id IN :accIds
//                LIMIT 50000
//        ];
//    }

}