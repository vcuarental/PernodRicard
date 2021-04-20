trigger ASI_eForm_KR_CC_beforeDelete on ASI_eForm_CC_Request__c (before delete)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderDelete(Trigger.Old,'ASI_eForm_Status__c');
    //}
}