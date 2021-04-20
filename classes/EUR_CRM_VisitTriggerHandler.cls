public with sharing class EUR_CRM_VisitTriggerHandler extends EUR_CRM_TriggerHandler {

    protected override void beforeInsert() {
        new EUR_CRM_Visit_IsLatest_Service().handleIsLatestFieldOnVisits(Trigger.new);
        new EUR_CRM_VisitRecommendedService().handleRecommendationSuccess(Trigger.new,null);
    }


    override protected void afterInsert() {
        new EUR_CRM_AccountLastVisitDateService().updateLastVisitDateOnAccount(Trigger.new);
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_Visit__c>)Trigger.new);
        new EUR_CRM_EventCreationForVisitService().createStandardEvents(Trigger.new);
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }
    protected override void beforeUpdate() {
        EUR_CRM_IsLatestBeforeUpdateService service = new EUR_CRM_IsLatestBeforeUpdateService('EUR_CRM_Visit__c');
        service.setIsLatestByChangedStatus(Trigger.new,Trigger.old);
        new EUR_CRM_VisitRecommendedService().handleRecommendationSuccess(Trigger.new,Trigger.oldMap);
    }

    override protected void afterUpdate() {
        new EUR_CRM_AccountLastVisitDateService().updateLastVisitDateOnAccount(Trigger.new, (Map<Id, EUR_CRM_Visit__c>)Trigger.oldMap);
        new EUR_CRM_EventCreationForVisitService().updateStandardEvents(Trigger.new, (Map<Id, EUR_CRM_Visit__c>)Trigger.oldMap);
    }

    override protected void beforeDelete() {
        new EUR_CRM_EventDeletionForVisitService().deleteRelatedEventsOfVisits((Map<Id, EUR_CRM_Visit__c>)Trigger.oldMap);
    }

}