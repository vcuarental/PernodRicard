trigger ASI_NPP_New_Promotion_AfterUpdate on ASI_NPP_New_Promotion__c (after update) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_NPP_SG')){
        ASI_NPP_NewPromotion_TriggerClass.setNewProductPromotionFinalStatus(trigger.new, trigger.oldMap);
    }
}