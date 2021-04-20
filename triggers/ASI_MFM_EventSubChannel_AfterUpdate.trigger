trigger ASI_MFM_EventSubChannel_AfterUpdate on ASI_MFM_Event_Sub_Channel__c (after update) {
  if (trigger.new[0].recordTypeid != null){           
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MFM_CN_Event_Sub_Channel')){
            ASI_CRM_CN_EventSubChannel_TriggerClass.routineAfterInsert(trigger.new,trigger.oldMap);
        }
   }
}