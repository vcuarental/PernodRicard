trigger ASI_MFM_Brand_AfterUpdate on ASI_MFM_Brand__c (after update) {

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK_CRM_Brand')){
		ASI_MFM_HK_Brand_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);       
    }
    
}