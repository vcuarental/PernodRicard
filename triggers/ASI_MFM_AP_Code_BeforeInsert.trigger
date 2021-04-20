trigger ASI_MFM_AP_Code_BeforeInsert on ASI_MFM_AP_Code__c (before insert) {
  
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
      ASI_MFM_AP_Code_TriggerClass.routineBeforeInsert(trigger.new);
    }
}