public with sharing class EUR_CRM_ObjPromoToAccAssignAuraCtrl {


    /* ========================================================= */
    /*     Interface (Getters)
    /* ========================================================= */
    @AuraEnabled
    public static List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> getInitialTargets(String recordId) {
        return EUR_CRM_ObjPromoTargetMngmntCtrl.getInitialTargets(recordId);
    }

    @AuraEnabled
    public static List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> getProductsWithManagersAndSalesReps(String productWrapperAsJSON, String productIdsJSON, String recordId, String accountIdsAsJSON) {
        return EUR_CRM_ObjPromoTargetMngmntCtrl.getProductsWithManagersAndSalesReps(productWrapperAsJSON, productIdsJSON, recordId, accountIdsAsJSON);
    }

    @AuraEnabled
    public static String saveData(String data, String recordId) {
        DataWrapper dw = (DataWrapper)JSON.deserialize(data, DataWrapper.class);
        saveAccountTargetGroup(dw, recordId);

        EUR_CRM_ObjPromoTargetMngmntCtrl.createTargets(JSON.serialize(dw.products), recordId);

        return 'OK';
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    @AuraEnabled
    public static String saveAccountTargetGroup(DataWrapper dw, String recordId) {
        if (dw.accountTargetGroup == null) { return 'OK'; }

        String action = dw.accountTargetGroup.accountGroup.action;
        System.debug('\n\n action => ' + JSON.serializePretty(action) + '\n');
        if (action == null) { return 'OK'; }

        EUR_CRM_Account_Target_Group__c accountTargetGroup = extractAccountTargetGroup(dw, action);
        System.debug('\n\n accountTargetGroup => ' + JSON.serializePretty(accountTargetGroup) + '\n');

        if ( ! action.equalsIgnoreCase('assign')) {
            refreshAccountsInGroup(accountTargetGroup, dw);
        }

        update new EUR_CRM_Objectives_Promotions__c(
            Id = recordId
        ,   EUR_CRM_Account_Target_Group__c = accountTargetGroup.Id
        );

        return 'OK';
    }

    private static void refreshAccountsInGroup(EUR_CRM_Account_Target_Group__c accountTargetGroup, DataWrapper dw) {
        if (accountTargetGroup.EUR_CRM_IsDynamic__c == false) {
            Map<Id, EUR_CRM_Account_in_Target_Group__c> accountInTargetGroupByAccountId = getAccountInTargetGroupByAccountId(dw, accountTargetGroup.Id);

            List<EUR_CRM_Account_in_Target_Group__c> existAccountInTargetGroups = selectAccountInTargetGroups(accountTargetGroup.Id);
            Map<Id, EUR_CRM_Account_in_Target_Group__c> existAccountInTargetGroupByAccountId = new Map<Id, EUR_CRM_Account_in_Target_Group__c>();

            List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroupsToDelete = new List<EUR_CRM_Account_in_Target_Group__c>();

            for (EUR_CRM_Account_in_Target_Group__c existAccountInTargetGroup : existAccountInTargetGroups) {
                if ( ! accountInTargetGroupByAccountId.containsKey(existAccountInTargetGroup.EUR_CRM_Account__c)) {
                    accountInTargetGroupsToDelete.add(existAccountInTargetGroup);
                } else {
                    existAccountInTargetGroupByAccountId.put(existAccountInTargetGroup.EUR_CRM_Account__c, existAccountInTargetGroup);
                }
            }
            System.debug('\n\n accountInTargetGroupsToDelete => ' + JSON.serializePretty(accountInTargetGroupsToDelete) + '\n');
            System.debug('\n\n existAccountInTargetGroupByAccountId => ' + JSON.serializePretty(existAccountInTargetGroupByAccountId) + '\n');

            List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroupsToCreate = new List<EUR_CRM_Account_in_Target_Group__c>();
            for (Id accId : accountInTargetGroupByAccountId.keySet()) {
                if ( ! existAccountInTargetGroupByAccountId.containsKey(accId)) {
                    accountInTargetGroupsToCreate.add(accountInTargetGroupByAccountId.get(accId));
                }
            }
            System.debug('\n\n accountInTargetGroupsToCreate.size() => ' + JSON.serializePretty(accountInTargetGroupsToCreate.size()) + '\n');
            System.debug('\n\n accountInTargetGroupsToCreate => ' + JSON.serializePretty(accountInTargetGroupsToCreate) + '\n');

            delete accountInTargetGroupsToDelete;
            insert accountInTargetGroupsToCreate;

//            Map<Integer, EUR_CRM_Account_in_Target_Group__c> accountInTargetGroupsToCreateByInteger = new Map<Integer, EUR_CRM_Account_in_Target_Group__c>();
//            Integer index = 0;
//            for (EUR_CRM_Account_in_Target_Group__c accountInTargetGroup : accountInTargetGroupsToCreate) {
//                accountInTargetGroupsToCreateByInteger.put(index++, accountInTargetGroup);
//            }
//
//            Database.SaveResult[] srList = Database.insert(accountInTargetGroupsToCreate, false);
//
//            // Iterate through each returned result
//            Integer success = 0;
//            Integer errors = 0;
//            for (Database.SaveResult sr : srList) {
//                if (sr.isSuccess()) {
//                    success++;
//                    // Operation was successful, so get the ID of the record that was processed
//                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
//                } else {
//                    // Operation failed, so get all errors
//                    System.debug('\n\n success prev result => ' + JSON.serializePretty(success) + '\n');
//                    errors++;
//                    for(Database.Error err : sr.getErrors()) {
//                        System.debug('The following error has occurred.');
//                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
//                        System.debug('Account fields that affected this error: ' + err.getFields());
//                    }
//                }
//            }
//            System.debug('\n\n success => ' + JSON.serializePretty(success) + '\n');
//            System.debug('\n\n errors => ' + JSON.serializePretty(errors) + '\n');
//
//            System.debug('\n\n accountInTargetGroupsToCreateByInteger.size() => ' + JSON.serializePretty(accountInTargetGroupsToCreateByInteger.size()) + '\n');
//            System.debug('\n\n accountInTargetGroupsToCreateByInteger => ' + JSON.serializePretty(accountInTargetGroupsToCreateByInteger) + '\n');
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static EUR_CRM_Account_Target_Group__c extractAccountTargetGroup(DataWrapper dw, String action) {
        EUR_CRM_Account_Target_Group__c accountTargetGroup = new EUR_CRM_Account_Target_Group__c(
            Id = dw.accountTargetGroup.accountGroup.Id
        );

        if (action.equalsIgnoreCase('assign')) {
            return accountTargetGroup;
        }

        accountTargetGroup.Name = dw.accountTargetGroup.accountGroup.Name;
        if (dw.accountTargetGroup.accountGroup.IsDynamic != null) {
            accountTargetGroup.EUR_CRM_IsDynamic__c = dw.accountTargetGroup.accountGroup.IsDynamic;
        }
        if (dw.accountTargetGroup.accountGroup.criteria != null) {
            accountTargetGroup.EUR_CRM_Criteria__c = JSON.serialize(dw.accountTargetGroup.accountGroup.criteria);
        }
        System.debug('\n\n accountTargetGroup => ' + JSON.serializePretty(accountTargetGroup) + '\n');
        upsert accountTargetGroup;

        if (action.equalsIgnoreCase('update') && accountTargetGroup.EUR_CRM_IsDynamic__c == null) {
            accountTargetGroup = selectAccountTargetGroup(accountTargetGroup.Id);
        }

        return accountTargetGroup;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private static Map<Id, EUR_CRM_Account_in_Target_Group__c> getAccountInTargetGroupByAccountId(DataWrapper dw, Id atgId) {
        Map<Id, EUR_CRM_Account_in_Target_Group__c> accountInTargetGroupByAccountId = new Map<Id, EUR_CRM_Account_in_Target_Group__c>();

        for (AccountInGroupWrapper accGroupWrapper : dw.accountTargetGroup.accountsInGroup) {
            EUR_CRM_Account_in_Target_Group__c accountInTargetGroup = new EUR_CRM_Account_in_Target_Group__c(
                EUR_CRM_Account_Target_Group__c = atgId
            ,   EUR_CRM_Account__c = accGroupWrapper.Id
            );
            accountInTargetGroupByAccountId.put(accountInTargetGroup.EUR_CRM_Account__c, accountInTargetGroup);
        }

        return accountInTargetGroupByAccountId;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Account_in_Target_Group__c> selectAccountInTargetGroups(Id accTarGroupId) {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            FROM EUR_CRM_Account_in_Target_Group__c
            WHERE EUR_CRM_Account_Target_Group__c = :accTarGroupId
            ORDER BY EUR_CRM_Account__r.Name ASC
            LIMIT 2000
        ];
    }

    private static EUR_CRM_Account_Target_Group__c selectAccountTargetGroup(Id atgId) {
        return [
            SELECT Id
            ,   EUR_CRM_IsDynamic__c
            FROM EUR_CRM_Account_Target_Group__c
            WHERE Id = :atgId
        ];
    }


    /* ========================================================= */
    /*     Class Wrappers
    /* ========================================================= */
    public class DataWrapper {
        @AuraEnabled public AccountTargetGroupWrapper accountTargetGroup { get; set; }
        @AuraEnabled public List<EUR_CRM_ObjPromoTargetMngmntCtrl.ProductWrapper> products { get; set; }
    }

    public class AccountTargetGroupWrapper {
        @AuraEnabled public AccountGroupWrapper accountGroup { get; set; }
        @AuraEnabled public List<AccountInGroupWrapper> accountsInGroup { get; set; }

        public AccountTargetGroupWrapper(EUR_CRM_Account_Target_Group__c accountTargetGroup, List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups) {
            this.accountGroup = new AccountGroupWrapper(accountTargetGroup);

            this.accountsInGroup = new List<AccountInGroupWrapper>();
            for (EUR_CRM_Account_in_Target_Group__c accountInTargetGroup : accountInTargetGroups) {
                this.accountsInGroup.add(new AccountInGroupWrapper(accountInTargetGroup));
            }
        }
    }

    public class AccountGroupWrapper {
        @AuraEnabled public String action { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public Boolean IsDynamic { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String sobjectType { get; set; }
        @AuraEnabled public EUR_CRM_FilterBuilderService.ObjectFilterWrapper criteria { get; set; }

        public AccountGroupWrapper(EUR_CRM_Account_Target_Group__c accountTargetGroup) {
            this.Id = accountTargetGroup.Id;
            this.IsDynamic = accountTargetGroup.EUR_CRM_IsDynamic__c;
            this.Name = accountTargetGroup.Name;
            this.sobjectType = 'EUR_CRM_Account_Target_Group__c';
        }
    }

    public class AccountInGroupWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }

        public AccountInGroupWrapper(EUR_CRM_Account_in_Target_Group__c accountInTargetGroup) {
            this.Id = accountInTargetGroup.EUR_CRM_Account__c;
            this.Name = accountInTargetGroup.EUR_CRM_Account__r.Name;
        }
    }

}