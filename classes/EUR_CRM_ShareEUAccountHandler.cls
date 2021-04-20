public with sharing class EUR_CRM_ShareEUAccountHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ShareEUAccountHandler() {
        super('EUR_CRM_ShareEUAccountHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        System.Debug('EUR_CRM_ShareEUAccountHandler');

        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__Share> accountShareToDelete = new List<EUR_CRM_Account__Share>();

        if (tAction == TriggerAction.AFTER_INSERT) {
            accounts = filterAccountOnInsert((List<EUR_CRM_Account__c>) sObjList);
        } else if (tAction == TriggerAction.AFTER_UPDATE) {
            accounts = filterAccountOnUpdate((List<EUR_CRM_Account__c>) sObjList, (Map<Id, EUR_CRM_Account__c>) oldMap);
            accountShareToDelete = filterManualShare((List<EUR_CRM_Account__c>) sObjList, (Map<Id, EUR_CRM_Account__c>) oldMap);

            if (!accountShareToDelete.isEmpty()) {
                delete accountShareToDelete;
            }
        }
        if (!accounts.isEmpty()) {
            manualAccountShareToOwnerManager(accounts);
        }

    }
    private static List<EUR_CRM_Account__c> filterAccountOnInsert(List<EUR_CRM_Account__c> euAccounts) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c euAccount : euAccounts) {
            if (euAccount.EUR_CRM_Manager_of_Account_Owner__c != null) {
                accounts.add(euAccount);
            }
        }
        return accounts;
    }

    private static List<EUR_CRM_Account__c> filterAccountOnUpdate(List<EUR_CRM_Account__c> euAccounts, Map<Id, EUR_CRM_Account__c> oldMap) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : euAccounts) {
            EUR_CRM_Account__c oldAccount = (EUR_CRM_Account__c) oldMap.get(account.Id);
            if (account.EUR_CRM_Manager_of_Account_Owner__c != null &&
                    oldAccount.EUR_CRM_Manager_of_Account_Owner__c != account.EUR_CRM_Manager_of_Account_Owner__c) {
                accounts.add(account);
            }
        }
        return accounts;
    }

    private static List<EUR_CRM_Account__Share> filterManualShare(List<EUR_CRM_Account__c> euAccounts, Map<Id, EUR_CRM_Account__c> oldMap) {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__Share> accountShares = new List<EUR_CRM_Account__Share>();
        List<Id> ownerManagers = new List<Id>();
        for (EUR_CRM_Account__c account : euAccounts) {
            EUR_CRM_Account__c oldAccount = (EUR_CRM_Account__c) oldMap.get(account.Id);
            accounts.add(account);
            if (oldAccount.EUR_CRM_Manager_of_Account_Owner__c != null &&
                    oldAccount.EUR_CRM_Manager_of_Account_Owner__c != account.EUR_CRM_Manager_of_Account_Owner__c) {
                ownerManagers.add(oldAccount.EUR_CRM_Manager_of_Account_Owner__c);
            }
        }
        accountShares = [SELECT Id, ParentId FROM EUR_CRM_Account__Share WHERE ParentId IN :accounts AND AccessLevel = 'Edit' AND RowCause = 'Manual' AND UserOrGroupId IN :ownerManagers];
        return accountShares;
    }

    private void manualAccountShareToOwnerManager(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_Account__Share> newAccountShares = new List<EUR_CRM_Account__Share>();

        for (EUR_CRM_Account__c acc : accounts) {
            EUR_CRM_Account__Share accountShare = new EUR_CRM_Account__Share();
            accountShare.ParentId = acc.Id;
            accountShare.UserOrGroupId = acc.EUR_CRM_Manager_of_Account_Owner__c;
            accountShare.AccessLevel = 'Edit';
            accountShare.RowCause = Schema.EUR_CRM_Account__Share.RowCause.Manual;
            newAccountShares.add(accountShare);
        }
        if (!newAccountShares.isEmpty()) {
            Database.insert(newAccountShares,false);
        }

    }


}