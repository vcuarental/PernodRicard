trigger ASI_CRM_ActualOfftake_BeforeUpdate on ASI_TH_CRM_Actual_Offtake__c (before update) {
	if (trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Actual_Offtake')) ){
        new ASI_CRM_VN_ValidateActualOfftake().executeTrigger(trigger.new, trigger.oldMap);
    }
	else if (trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_PH_Actual_Offtake')) ){
		 ASI_CRM_PH_ActualOfftake_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
	}
}