trigger ASI_eForm_KR_HA_beforeInsert on ASI_eForm_Home_Appliance__c (before insert)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_AutoFillIn.fillInMethod(trigger.new,'ASI_eForm_Requester_Record__c');
    //}
}