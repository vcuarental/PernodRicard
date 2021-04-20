trigger ASI_CRM_Trade_A_P_Plan_BeforeDelete on ASI_CRM_Trade_A_P_Plan__c (before delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan')) {
        new ASI_CRM_Trade_A_P_Plan_TriggerHandler().beforeDeleteTrigger(Trigger.old);
    }
}