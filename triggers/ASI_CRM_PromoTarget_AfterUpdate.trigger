trigger ASI_CRM_PromoTarget_AfterUpdate on ASI_CRM_Promotion_Target__c (After Update){           
    if(trigger.new[0].recordTypeid != null && trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget')){
        ASI_CRM_TW_PromoTarget_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}