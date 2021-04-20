public with sharing class EUR_CRM_AccountOwnerManagerHandler extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_AccountOwnerManagerHandler() { super('EUR_CRM_AccountOwnerManagerHandler'); }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<EUR_CRM_Account__c> accounts = (List<EUR_CRM_Account__c>) sObjList;
        Map<Id, EUR_CRM_Account__c> oldAccountById = (Map<Id, EUR_CRM_Account__c>) oldMap;

        Set<Id> ownerIdSet = new Set<Id>();
        for (EUR_CRM_Account__c acct : accounts) {
            if(tAction == TriggerAction.BEFORE_INSERT || (tAction == TriggerAction.BEFORE_UPDATE && acct.OwnerId != oldAccountById.get(acct.Id).OwnerId)) {
                ownerIdSet.add(acct.OwnerId);
            }
        }

        if (ownerIdSet.isEmpty()) { return ; }

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :ownerIdSet AND ManagerId != NULL]);
        for(EUR_CRM_Account__c acct : accounts) {
            if(userMap.containsKey(acct.OwnerId)) {
                acct.EUR_CRM_Manager_of_Account_Owner__c = userMap.get(acct.OwnerId).ManagerId;
            }
        }
    }
    
}