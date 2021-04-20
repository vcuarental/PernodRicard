trigger Milestone1_Task_Trigger on Milestone1_Task__c ( before insert, before update,after insert,after update ) {
    String triggerName = 'Milestone1_Task_Trigger'; 
   User thisUser = [ SELECT Id,BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId() ];
   String bypass = ''+thisUser.BypassTriggers__c;  
	if(trigger.isBefore) {
		Milestone1_Task_Trigger_Utility.handleTaskBeforeTrigger(trigger.new); 
        if(Trigger.isUpdate) {
        if(!bypass.contains(triggerName )){ 
			Milestone1_Task_Trigger_Utility.checkEditPermissionOnTask(trigger.oldMap, trigger.newMap);
        }
	}  
    }
	
	if(trigger.isAfter) {
		if(Trigger.isUpdate){
	        //shift Dates of successor Tasks if Task Due Date is shifted
	        Milestone1_Task_Trigger_Utility.checkSuccessorDependencies(trigger.oldMap, trigger.newMap);
		}
		Milestone1_Task_Trigger_Utility.handleTaskAfterTrigger(trigger.new,trigger.old);
	}
}