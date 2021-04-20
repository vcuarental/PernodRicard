trigger ASI_MFM_AP_Code_BeforeUpdate on ASI_MFM_AP_Code__c (before update) {
  
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
      ASI_MFM_AP_Code_TriggerClass.routineBeforeUpdate(trigger.new,trigger.oldMap);
    }
}