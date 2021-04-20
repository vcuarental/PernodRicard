trigger ASI_eForm_KR_Tuition_beforeUpdate on ASI_eForm_Tuition__c (before update)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_CheckAttachemnt.checkAttachment(Trigger.new,'ASI_eForm_Status__c');
    	//calling to check status is allow to del/updates
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderUpdate(Trigger.New,Trigger.Old,'ASI_eForm_Status__c');
    //}
}