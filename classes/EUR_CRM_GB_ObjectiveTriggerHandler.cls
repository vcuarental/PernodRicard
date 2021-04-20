public with sharing class EUR_CRM_GB_ObjectiveTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeInsert() {
        new EUR_CRM_ObjectiveCalculateAchieveService().calculateAchievement(Trigger.new);
    }

    override protected void afterInsert() {
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_GB_Objective__c>)Trigger.new);
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }

    override protected void beforeUpdate() {
        new EUR_CRM_ObjectiveCalculateAchieveService().calculateAchievement(Trigger.new, (Map<Id, EUR_CRM_GB_Objective__c>)Trigger.oldMap);
    }

}