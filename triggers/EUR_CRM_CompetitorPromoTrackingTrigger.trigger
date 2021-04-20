trigger EUR_CRM_CompetitorPromoTrackingTrigger on EUR_CRM_Competitor_Promo_Tracking__c (after insert) {

    new EUR_CRM_CompetitorPromoTrackingTriggHand().run();

}