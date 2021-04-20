trigger ASI_CRM_Trade_A_P_Plan_Item_BeforeDelete on ASI_CRM_Trade_A_P_Plan_Item__c (before delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan_Item')) {
        new ASI_CRM_Trade_AP_PlanItem_TriggerHandler().beforeDeleteTrigger(Trigger.old);
    }
}