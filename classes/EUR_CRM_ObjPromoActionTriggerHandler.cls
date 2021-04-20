public with sharing class EUR_CRM_ObjPromoActionTriggerHandler {

    public void onBeforeInsert(List<EUR_CRM_ObjPromo_Action__c> objPromoActionsToInsert) {
        new EUR_CRM_ObjPromoActionSetVisActRTID().setVisitActionRecordTypeId(objPromoActionsToInsert);
    }

    public void onBeforeUpdate(List<EUR_CRM_ObjPromo_Action__c> objPromoActionsToUpdate, Map<Id, EUR_CRM_ObjPromo_Action__c> oldObjPromoActionById) {
        new EUR_CRM_ObjPromoActionSetVisActRTID().setVisitActionRecordTypeId(objPromoActionsToUpdate, oldObjPromoActionById);
    }

}