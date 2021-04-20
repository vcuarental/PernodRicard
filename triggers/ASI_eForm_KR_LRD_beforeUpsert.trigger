trigger ASI_eForm_KR_LRD_beforeUpsert on ASI_eForm_Leave_Request_Line_Item__c (before update,before insert) {
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_LR_CheckLeave checkBalance = new ASI_eForm_KR_LR_CheckLeave();
    	checkBalance.validation(trigger.new,trigger.oldMap);
    	if(Trigger.isUpdate)
        {
            ASI_eForm_KR_checkUpdateDelete.checkLRDetailUpdate(Trigger.New);
        }
    //}
}