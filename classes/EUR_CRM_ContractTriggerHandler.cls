public with sharing class EUR_CRM_ContractTriggerHandler extends EUR_CRM_TriggerHandler {

//    override public void beforeInsert() {
//
//    }
//
//    override public void afterInsert() {
//
//    }

    override public void beforeUpdate() {
        new EUR_CRM_ContractApprovalProcessRunner().validateToRunApprovalProcess(Trigger.new, (Map<Id, EUR_CRM_Contract__c>)Trigger.oldMap);
    }

    override public void afterUpdate() {
        new EUR_CRM_ContractApprovalProcessRunner().runApprovalProcess(Trigger.new, (Map<Id, EUR_CRM_Contract__c>)Trigger.oldMap);
    }

//    override public void beforeDelete() {
//
//    }
//
//    override public void afterDelete() {
//
//    }

}