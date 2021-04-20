trigger ASI_CRM_Trade_A_P_Plan_BeforeInsert on ASI_CRM_Trade_A_P_Plan__c (before insert) {
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Plan')) {
        new ASI_CRM_Trade_A_P_Plan_TriggerHandler().beforeInsertTrigger(Trigger.new);
    }
}