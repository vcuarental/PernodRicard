trigger ASI_CRM_Trade_A_P_Plan_AfterUpdate on ASI_CRM_Trade_A_P_Plan__c (after update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan')) {
        new ASI_CRM_Trade_A_P_Plan_TriggerHandler().afterUpdateTrigger(Trigger.new, Trigger.oldMap);
    }
}