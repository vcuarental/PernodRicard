trigger ASI_CRM_Trade_A_P_Plan_Item_BeforeInsert on ASI_CRM_Trade_A_P_Plan_Item__c (before Insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan_Item')) {
        new ASI_CRM_Trade_AP_PlanItem_TriggerHandler().beforeInsertTrigger(Trigger.new);
    }
}