trigger ASI_CRM_Trade_A_P_Plan_Item_BeforeUpdate on ASI_CRM_Trade_A_P_Plan_Item__c (before update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan_Item')) {
        new ASI_CRM_Trade_AP_PlanItem_TriggerHandler().beforeUpdateTrigger(Trigger.new, Trigger.oldMap);
    }
}