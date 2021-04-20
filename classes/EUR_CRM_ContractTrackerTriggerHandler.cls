public with sharing class EUR_CRM_ContractTrackerTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_Contract_Tracker__c>)Trigger.new);
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }

}