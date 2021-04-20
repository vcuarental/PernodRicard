trigger ASI_eForm_KR_Tuition_beforeDelete on ASI_eForm_Tuition__c (before delete)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderDelete(Trigger.Old,'ASI_eForm_Status__c');
    //}
}