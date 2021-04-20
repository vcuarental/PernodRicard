trigger ASI_eForm_KR_CTD_beforeUpdate on ASI_eForm_Tuition_Detail__c (before update)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_checkUpdateDelete.checkCTDetailUpdate(Trigger.New);
    //}
}