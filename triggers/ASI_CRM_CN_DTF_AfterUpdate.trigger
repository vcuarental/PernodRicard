trigger ASI_CRM_CN_DTF_AfterUpdate on ASI_CRM_DTF__c (after update)
{
    //CN
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN'))
    {
        //20200226:AM@introv - for data usage application
    	//ASI_CRM_CN_DTF_TriggerClass.afterUpdateMethod(Trigger.New);
    	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_Data_Usage_Application')) {
            //do nothing
        }
        else {
    		ASI_CRM_CN_DTF_TriggerClass.afterUpdateMethod(Trigger.New);
        }
    }//end if
    //CN
}//end trigger