trigger ASI_CRM_CN_DTF_BeforeUpdate on ASI_CRM_DTF__c (before update) {

	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN'))
    {
        //20200226:AM@introv - for data usage application
    	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_Data_Usage_Application')) {
			ASI_CRM_CN_DTF_DUA_TriggerClass.beforeUpdateMethod(Trigger.New, trigger.oldMap);
        }
        else {
    		//do nothing
        }
    }

}