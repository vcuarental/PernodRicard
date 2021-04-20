trigger ASI_eForm_KR_HAD_beforeUpdate on ASI_eForm_HA_Detail__c (before update)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_checkUpdateDelete.checkHADetailUpdate(Trigger.New);
    //}
}