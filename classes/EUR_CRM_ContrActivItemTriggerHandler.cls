public without sharing class EUR_CRM_ContrActivItemTriggerHandler extends EUR_CRM_TriggerHandler {

    override public void afterInsert() {
        EUR_CRM_ContractRollupService.polulateRollupFields(Trigger.new);
    }

    override public void beforeUpdate() {}

    override public void afterUpdate() {
        new EUR_CRM_ContrActivItemService.ContractProductItemsWorker().deleteCpiForLumpSumCai(Trigger.new, (Map<Id, EUR_CRM_Contract_Activity_Item__c>)Trigger.oldMap);
        new EUR_ISP_ContractActivityTriggerHandler().afterUpdate(Trigger.new, (Map<Id, EUR_CRM_Contract_Activity_Item__c>)Trigger.oldMap);
        EUR_CRM_ContractRollupService.polulateRollupFields(Trigger.new, (Map<Id, EUR_CRM_Contract_Activity_Item__c>)Trigger.oldMap);
    }

    override public void beforeDelete() {}

    override public void afterDelete() {
        EUR_CRM_ContractRollupService.polulateRollupFields(Trigger.old);

    }

    override public void afterUndelete() {
        EUR_CRM_ContractRollupService.polulateRollupFields(Trigger.new);
    }

}