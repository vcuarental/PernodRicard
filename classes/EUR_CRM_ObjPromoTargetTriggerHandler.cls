public with sharing class EUR_CRM_ObjPromoTargetTriggerHandler {

    public void onAfterInsert(List<EUR_CRM_ObjPromo_Target__c> insertedObjPromoTargets) {
        EUR_CRM_DE_TargetHandler.aggregateActualVolume_AIAU(insertedObjPromoTargets);
    }

    public void onAfterUpdate(List<EUR_CRM_ObjPromo_Target__c> updatedObjPromoTargets, Map<Id, EUR_CRM_ObjPromo_Target__c> oldObjPromoTargetById) {
        EUR_CRM_DE_TargetHandler.aggregateActualVolume_AIAU(updatedObjPromoTargets);
        new EUR_CRM_ObjPromoTargetQuotaHandler().executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, updatedObjPromoTargets, null, null);
        new EUR_CRM_ObjPromoTargetCalculation().calculate(updatedObjPromoTargets, oldObjPromoTargetById);
    }

}