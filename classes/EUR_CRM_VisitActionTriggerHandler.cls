public with sharing class EUR_CRM_VisitActionTriggerHandler {

    public void onBeforeInsert(List<EUR_CRM_Visit_Action__c> visitActionsToInsert) {
        new EUR_CRM_VisitActionSuccessfulService().handleSuccess(visitActionsToInsert);
    }

    public void onAfterInsert(List<EUR_CRM_Visit_Action__c> insertedVisitActions, Map<Id, EUR_CRM_Visit_Action__c> newVisitActionById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> {
            new EUR_CRM_DE_VisitActionHandler()
        };

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, insertedVisitActions, newVisitActionById, null);
        }
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }

    public void onBeforeUpdate(List<EUR_CRM_Visit_Action__c> visitActionsToUpdate, Map<Id, EUR_CRM_Visit_Action__c> oldVisitActionById) {
        new EUR_CRM_VisitActionSuccessfulService().handleSuccess(visitActionsToUpdate, oldVisitActionById);

        new EUR_CRM_VisitActionPromoActiveHandler().executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }

}