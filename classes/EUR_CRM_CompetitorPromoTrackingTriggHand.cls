public with sharing class EUR_CRM_CompetitorPromoTrackingTriggHand extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_Competitor_Promo_Tracking__c>)Trigger.new);
        EUR_CRM_AccountChildrenSharingBatch.addShares(Trigger.new);
    }

}