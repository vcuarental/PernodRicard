trigger ASI_eForm_KR_LR_beforeUpdate on ASI_eForm_Leave_Request__c (before update) {
    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_CheckAttachemnt.checkLeaveType(Trigger.New,'ASI_eForm_Status__c');
    
    	ASI_eForm_KR_helpForApproval helper = new ASI_eForm_KR_helpForApproval();
    	helper.checkHasLeaveType(Trigger.New);
        //calling to match the approver
        ASI_eForm_KR_approverMatching match = new ASI_eForm_KR_approverMatching(trigger.new);
    	//calling to check status is allow to del/updates
    	ASI_eForm_KR_checkUpdateDelete.checkHeaderUpdate(Trigger.New,Trigger.Old,'ASI_eForm_Status__c');
    //}
}