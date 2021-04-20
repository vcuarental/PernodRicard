trigger ASI_eForm_Corp_Card_Request_BeforeInsert on ASI_eForm_Corp_Card_Request__c (before insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR')){
        ASI_eForm_KR_CCR_TriggerClass.routineBeforeUpsert(trigger.new, Trigger.oldMap);    
    }
         
}