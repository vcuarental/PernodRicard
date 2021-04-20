trigger ASI_MFM_Event_AfterInsert on ASI_MFM_Event__c(after insert) {
    	// Added by jack yuan 
    if (trigger.new[0].recordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_TP')){
        ASI_CRM_CN_TP_Event_TriggerClass.routineAfterInsert(Trigger.new); 
    }
}