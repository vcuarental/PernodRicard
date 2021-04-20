public with sharing class EUR_CRM_ObjPromoAccountMappingTriggHand extends EUR_CRM_TriggerHandler {

    override protected void afterInsert() {
        new EUR_CRM_AccRelObjSharingService().createSharing((List<EUR_CRM_ObjPromo_Account_Mapping__c>)Trigger.new);
    }

}