trigger ASI_eForm_KR_HAD_beforeDelete on ASI_eForm_HA_Detail__c (before delete)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
		ASI_eForm_KR_checkUpdateDelete.checkHADetailDelete(Trigger.Old);
    //}
}