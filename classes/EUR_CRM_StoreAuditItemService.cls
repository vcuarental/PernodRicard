/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

public with sharing class EUR_CRM_StoreAuditItemService {
    /* ========================================================= */
    /*     Interface (Is_Latest Logic)
    /* ========================================================= */

    public void handleIsLatestFieldOnStoreAuditWithItems(List<EUR_CRM_Store_Audit_Item__c> newAuditItems) {
        System.debug('\n\n New Store Audit Items => ' + JSON.serializePretty(newAuditItems) + '\n');
        this.changeIsLatestFieldOnStoreAuditItems(newAuditItems);
    }

    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */

    private void changeIsLatestFieldOnStoreAuditItems(List<EUR_CRM_Store_Audit_Item__c> newAuditItems) {
        Map<Id, EUR_CRM_Store_Audit__c> storeAuditsMap = getStoreAuditsFromItemsList(newAuditItems);
        System.debug('\n\n storeAuditsMap => ' + JSON.serializePretty(storeAuditsMap) + '\n');
        for (EUR_CRM_Store_Audit_Item__c auditItem: newAuditItems) {
            if (storeAuditsMap.get(auditItem.EUR_CRM_Store_Audit__c).EUR_CRM_Is_Latest__c == true) {
                auditItem.EUR_CRM_Is_Latest__c = true;
            }
        }
        System.debug('\n\n newAuditItems after check by Store Audit => ' + JSON.serializePretty(newAuditItems) + '\n');
    }

    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, EUR_CRM_Store_Audit__c> getStoreAuditsFromItemsList(List<EUR_CRM_Store_Audit_Item__c> auditItems) {
        Set<Id> ids = new Set<Id>();
        for (EUR_CRM_Store_Audit_Item__c item: auditItems) {
            ids.add(item.EUR_CRM_Store_Audit__c);
        }
        return getStoreAuditsMapByIds(ids);
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */

    private Map<Id, EUR_CRM_Store_Audit__c> getStoreAuditsMapByIds(Set<Id> ids) {
        return new Map<Id, EUR_CRM_Store_Audit__c>([
                SELECT Id, EUR_CRM_Is_Latest__c
                FROM EUR_CRM_Store_Audit__c
                WHERE Id IN : ids
        ]);
    }
}