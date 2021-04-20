trigger ASI_CRM_PromoStatus_BeforeUpdate on ASI_CRM_Promotion_Status__c(before update) {
    if (trigger.new[0].recordTypeid != null){           
        if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus')){
            ASI_CRM_TW_PromoStatus_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
        }
    }
}