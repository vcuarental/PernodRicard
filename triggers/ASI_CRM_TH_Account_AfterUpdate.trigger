/****************************
Filename:     ASI_CRM_TH_Account_AfterUpdate 
Author:       Twinkle LI (Introv Limited)
Purpose:      Handle TH Account After Update Trigger
Created Date: 28-04-2016
******************************/

trigger ASI_CRM_TH_Account_AfterUpdate on Account (after update) {
    if (trigger.new[0].RecordTypeId != null && 
       (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_TH_CRM_'))) {
        ASI_CRM_TH_Account_TriggerCls.routineAfterUpdate(trigger.new, trigger.old);
    }
}