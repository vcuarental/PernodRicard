public with sharing class EUR_CRM_AccountTargetGroupTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void beforeInsert() {
        EUR_CRM_DynamicGroupService.addDailyRecalculation(Trigger.new);
    }

    override protected void beforeUpdate() {
        EUR_CRM_DynamicGroupService.changeDailyRecalculation(Trigger.new, Trigger.oldMap);
    }

    override protected void afterInsert() {
        EUR_CRM_DynamicGroupService.addDynamicGroupMembers(Trigger.new);
    }

    override protected void afterUpdate() {
        EUR_CRM_DynamicGroupService.changeDynamicGroupMembers(Trigger.new, Trigger.oldMap);
    }

}