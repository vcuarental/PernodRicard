trigger ASI_CRM_ActualOfftake_BeforeDelete on ASI_TH_CRM_Actual_Offtake__c (before delete) {
	if (trigger.old[0].recordtypeId != null && (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_VN_Actual_Offtake')) ){
        new ASI_CRM_VN_ValidateActualOfftake().executeTrigger(trigger.new, trigger.oldMap);
    }
}