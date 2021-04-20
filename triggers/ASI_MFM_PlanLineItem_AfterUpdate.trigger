trigger ASI_MFM_PlanLineItem_AfterUpdate on ASI_MFM_Plan_Line_Item__c (after update) {
	ASI_MFM_PlanLineItem_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);

	// Added by jack yuan 
	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP')){
        ASI_CRM_CN_TP_PlanLineItem_TriggerClass.routineAfterUpsert(Trigger.new, Trigger.oldMap);
    }
}