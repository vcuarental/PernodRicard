/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

public with sharing class EUR_CRM_StoreAuditItemTriggerHandler {
    public void onBeforeInsert(List<EUR_CRM_Store_Audit_Item__c> newStoreAuditItems) {
        System.debug('\n\n## EUR_CRM_StoreAuditItemTriggerHandler - Before Insert ## \n');
        System.debug('\n\n newStoreAuditItems => ' + JSON.serializePretty(newStoreAuditItems) + '\n');
        new EUR_CRM_StoreAuditItemService().handleIsLatestFieldOnStoreAuditWithItems(newStoreAuditItems);
    }
}