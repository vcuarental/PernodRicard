trigger ASI_eForm_KR_MDM_beforeUpsert on ASI_eForm_HR_MDM__c (before insert, before update)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_splitWords.MDMsplitWords(Trigger.New);
    //}
}