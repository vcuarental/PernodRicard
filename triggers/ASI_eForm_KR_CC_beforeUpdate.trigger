trigger ASI_eForm_KR_CC_beforeUpdate on ASI_eForm_CC_Request__c (before update)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	//calling to split words
    	ASI_eForm_KR_splitWords.CCsplitWords(Trigger.New);
    	//calling to check the attachment
    	ASI_eForm_KR_CheckAttachemnt.checkAttachment(Trigger.new,'ASI_eForm_Status__c');
    	//calling to check status is allow to del/updates
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderUpdate(Trigger.New,Trigger.Old,'ASI_eForm_Status__c');
    //}
}