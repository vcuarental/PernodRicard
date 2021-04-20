/**
 * Created by Ilarion Tokarskyi on 10/21/2020.
 */

public with sharing class EUR_CRM_ContractAuditTriggerHandler extends EUR_CRM_TriggerHandler {
    protected override void beforeInsert() {
        new EUR_CRM_ContractAuditIsLatestService().handleIsLatestFieldOnContractAudits(Trigger.new);
    }

    protected override void beforeUpdate() {
        EUR_CRM_IsLatestBeforeUpdateService service = new EUR_CRM_IsLatestBeforeUpdateService('EUR_CRM_Contract_Audit__c');
        service.setIsLatestByChangedStatus(Trigger.new, Trigger.old);
    }

}