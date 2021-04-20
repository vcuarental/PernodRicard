public with sharing class ASI_HK_CRM_ContactUpdateAcctMainContact extends ASI_HK_CRM_TriggerAbstract {

    public ASI_HK_CRM_ContactUpdateAcctMainContact() {
        super('ASI_HK_CRM_ContactUpdateAcctMainContact');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    /*
        if ((tAction == TriggerAction.AFTER_INSERT || tAction == TriggerAction.AFTER_UPDATE
                || tAction == TriggerAction.AFTER_DELETE || tAction == TriggerAction.AFTER_UNDELETE)
                && !isBypassByCurrentUser()) {
            final Set<String> validRTDevNameSet = new Set<String>{
                ASI_HK_CRM_ContactGenerator.RT_Credit
                , ASI_HK_CRM_ContactGenerator.RT_Potential
            };
            List<RecordType> validRTList = [SELECT Id FROM RecordType WHERE DeveloperName IN :validRTDevNameSet AND SobjectType = 'Contact'];
            Set<ID> validRTIdsSet = new Set<ID>();
            for (RecordType rt : validRTList) validRTIdsSet.add(rt.Id);
            
            List<Contact> ctList = (List<Contact>)sObjList;
            Set<ID> acctIdSet = new Set<ID>();
            Map<ID, Contact> acctIdToNewActiveCtMap = new Map<ID, Contact>();
            Map<ID, Set<ID>> acctIdToInactiveCtIdsMap = new Map<ID, Set<ID>>();
            for (Contact ct : ctList) {
                if (!isBypass(ct) && ct.RecordTypeId != null && validRTIdsSet.contains(ct.RecordTypeId)) {
                    // Find out all accounts whose main contact is needed to be updated
                    Contact oldCt = null;
                    if (oldMap != null) {
                        oldCt = (Contact)oldMap.get(ct.Id);
                    }
                    if (((oldCt == null || tAction == TriggerAction.AFTER_DELETE) && ct.ASI_HK_CRM_Active__c == true)
                        || (oldCt != null && ct.ASI_HK_CRM_Active__c != oldCt.ASI_HK_CRM_Active__c)) {
                        acctIdSet.add(ct.AccountId);
                        if (ct.ASI_HK_CRM_Active__c == true && tAction != TriggerAction.AFTER_DELETE) {
                            acctIdToNewActiveCtMap.put(ct.AccountId, ct);
                        } else {
                            Set<ID> ctIdSet = acctIdToInactiveCtIdsMap.get(ct.AccountId);
                            if (ctIdSet == null) {
                                ctIdSet = new Set<ID>();
                                acctIdToInactiveCtIdsMap.put(ct.AccountId, ctIdSet);
                            }
                            ctIdSet.add(ct.Id);
                        }
                    }
                }
            }
            if (acctIdSet.size() > 0) {
                List<Account> acctList = [SELECT Id, ASI_HK_CRM_Main_Contact__c
                        , (SELECT Id, CreatedDate FROM Contacts WHERE RecordType.DeveloperName IN :validRTDevNameSet AND ASI_HK_CRM_Active__c = TRUE)
                    FROM Account
                    WHERE Id IN :acctIdSet
                ];
                Set<ID> alreadyHandledAcctIds = new Set<ID>();
                List<Account> updateAcctList = new List<Account>();
                for (Account acct : acctList) {
                    if (!alreadyHandledAcctIds.contains(acct.Id)) {
                        Contact ct = acctIdToNewActiveCtMap.get(acct.Id);
                        if (ct != null) { // new active contact found
                            // Set to new main contact
                            acct.ASI_HK_CRM_Main_Contact__c = ct.Id;
                            updateAcctList.add(acct);
                        } else {
                            Set<ID> inactiveCtIdSet = acctIdToInactiveCtIdsMap.get(acct.Id);
                            if (acct.ASI_HK_CRM_Main_Contact__c == null || inactiveCtIdSet.contains(acct.ASI_HK_CRM_Main_Contact__c)) { // Original active main contact is deactivated/removed
                                // Find an active contact
                                List<Contact> activeCtList = acct.Contacts;
                                Contact latestCreatedCt = null;
                                for (Contact activeCt : activeCtList) {
                                    if (latestCreatedCt == null || activeCt.CreatedDate > latestCreatedCt.CreatedDate) {
                                        latestCreatedCt = activeCt;
                                    }
                                }
                                acct.ASI_HK_CRM_Main_Contact__c = latestCreatedCt == null ? null : latestCreatedCt.Id;
                                updateAcctList.add(acct);
                            }
                        }
                        alreadyHandledAcctIds.add(acct.Id);
                    }
                }
                if (updateAcctList.size() > 0)
                    update updateAcctList;
            }
        }
        */
    }
    
    private Boolean isBypass(Contact ct) {
        return (ct.ASI_HK_CRM_Bypass_Triggers__c != null && (';' + ct.ASI_HK_CRM_Bypass_Triggers__c + ';').contains(';ASI_HK_CRM_ContactUpdateAcctMainContact;'));
    }

}