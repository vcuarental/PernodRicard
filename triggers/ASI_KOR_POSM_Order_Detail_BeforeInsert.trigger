trigger ASI_KOR_POSM_Order_Detail_BeforeInsert on ASI_KOR_POSM_Order_Detail__c (before insert) {
	if (trigger.new[0].recordtypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR_POSM_Order_Detail')){
        ASI_KOR_POSM_Details_TriggerClass.routineBeforeInsert(Trigger.New);  

    }
}