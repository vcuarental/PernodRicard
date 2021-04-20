trigger ASI_CRM_CN_Channel_Strategy_BeforeUpdate on ASI_CRM_CN_Channel_Strategy__c (before update) {

	if (trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_NPL_CN_Channel_Strategy')) {
        //20200805:AM@introv - add team
        ASI_NPL_CN_Channel_Strategy_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);  
    }

}