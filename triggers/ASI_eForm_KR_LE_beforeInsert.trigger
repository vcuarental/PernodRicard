trigger ASI_eForm_KR_LE_beforeInsert on ASI_eForm_KR_Leave_EE__c (before insert)
{
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
		//calling to make a external ID
    	ASI_eForm_KR_LE_settingExternalID setID = new ASI_eForm_KR_LE_settingExternalID();
    	setID.setExternalID(Trigger.New);
    //}
}