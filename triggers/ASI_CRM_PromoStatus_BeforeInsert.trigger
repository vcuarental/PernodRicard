trigger ASI_CRM_PromoStatus_BeforeInsert on ASI_CRM_Promotion_Status__c (before insert){
    if (trigger.new[0].recordTypeid != null){           
        if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus')){
            ASI_CRM_TW_PromoStatus_TriggerCls.routineBeforeInsert(trigger.new, null);
        }
    }
}