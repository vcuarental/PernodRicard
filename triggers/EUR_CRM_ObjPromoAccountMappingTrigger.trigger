trigger EUR_CRM_ObjPromoAccountMappingTrigger on EUR_CRM_ObjPromo_Account_Mapping__c (after insert) {

    new EUR_CRM_ObjPromoAccountMappingTriggHand().run();

}