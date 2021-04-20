/**
 * Created by Ilarion Tokarskyi on 03.06.2020.
 */

public with sharing class EUR_CRM_StoreAuditTriggerHandler extends EUR_CRM_TriggerHandler{

    protected override void beforeInsert() {
        new EUR_CRM_StoreAuditService().handleIsLatestFieldOnStoreAudit(Trigger.new);
    }

    protected override void beforeUpdate() {
        EUR_CRM_IsLatestBeforeUpdateService service = new EUR_CRM_IsLatestBeforeUpdateService('EUR_CRM_Store_Audit__c');
        service.setIsLatestByChangedStatus(Trigger.new, Trigger.old);
    }
}