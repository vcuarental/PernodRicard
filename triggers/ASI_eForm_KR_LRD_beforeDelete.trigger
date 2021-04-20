trigger ASI_eForm_KR_LRD_beforeDelete on ASI_eForm_Leave_Request_Line_Item__c (before delete)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
		ASI_eForm_KR_checkUpdateDelete.checkLRDetailDelete(Trigger.Old);
    //}
}