trigger ASI_CRM_CN_DTF_BeforeInsert on ASI_CRM_DTF__c (before insert)
{
    //CN
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN'))
    {
        //20200226:AM@introv - for data usage application
        //ASI_CRM_CN_DTF_TriggerClass.beforeInsertMethod(Trigger.New);
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_Data_Usage_Application')) {
            ASI_CRM_CN_DTF_DUA_TriggerClass.beforeInsertMethod(Trigger.New);
        }
        else {
    		ASI_CRM_CN_DTF_TriggerClass.beforeInsertMethod(Trigger.New);
        }
    }//end if
    //CN
}//end trigger