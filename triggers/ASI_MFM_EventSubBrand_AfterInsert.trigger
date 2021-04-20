trigger ASI_MFM_EventSubBrand_AfterInsert on ASI_MFM_Event_Sub_Brand__c (after insert) {
  if (trigger.new[0].recordTypeid != null){           
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MFM_CN_Event_Sub_Brand')){
            ASI_CRM_CN_EventSubBrand_TriggerClass.routineAfterInsert(trigger.new,null);
        }
   }
}