trigger EUR_CRM_OPPromoTargetTrigger on EUR_CRM_OP_Promo_Target__c (after update) {

    new EUR_CRM_OPPromoTargetTriggerHandler().run();

}