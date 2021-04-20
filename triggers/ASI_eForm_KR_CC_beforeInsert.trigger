trigger ASI_eForm_KR_CC_beforeInsert on ASI_eForm_CC_Request__c (before insert)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	//calling to auto fill in form info
    	ASI_eForm_KR_AutoFillIn.fillInMethod(trigger.new,'ASI_eForm_Requester_Record__c');
    	//calling to split words
    	ASI_eForm_KR_splitWords.CCsplitWords(Trigger.New);
    //}
}