trigger ASI_MFM_Sub_brand_AfterUpdate on ASI_MFM_Sub_brand__c (after update) {

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK_CRM_Sub_brand')){
		ASI_MFM_HK_Sub_brand_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);       
    }
}