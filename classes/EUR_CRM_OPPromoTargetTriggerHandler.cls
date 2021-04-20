public with sharing class EUR_CRM_OPPromoTargetTriggerHandler extends EUR_CRM_TriggerHandler {

    override protected void afterUpdate() {
        new EUR_CRM_OPPromTargDistToHandler().handleDistanceToGoal(Trigger.new, (Map<Id, EUR_CRM_OP_Promo_Target__c>)Trigger.oldMap);
    }
}