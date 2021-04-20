trigger ASI_eForm_KR_HA_beforeUpdate on ASI_eForm_Home_Appliance__c (before update)
{
	//if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{	
    	//calling to check status is allow to del/updates
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderUpdate(Trigger.New,Trigger.Old,'ASI_eForm_Status__c');
    //}
}