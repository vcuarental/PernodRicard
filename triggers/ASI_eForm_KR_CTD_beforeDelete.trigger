trigger ASI_eForm_KR_CTD_beforeDelete on ASI_eForm_Tuition_Detail__c (before delete)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
		ASI_eForm_KR_checkUpdateDelete.checkCTDetailDelete(Trigger.Old);
    //}
}