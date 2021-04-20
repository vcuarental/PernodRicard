trigger ASI_eForm_Corp_Card_Request_AfterUpdate on ASI_eForm_Corp_Card_Request__c (After update) {
  if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR')){
        ASI_eForm_KR_CCR_TriggerClass.routineAfterUpdate(trigger.new, Trigger.oldMap);    
    }
}