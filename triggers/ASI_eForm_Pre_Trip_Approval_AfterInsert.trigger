trigger ASI_eForm_Pre_Trip_Approval_AfterInsert on ASI_eForm_Pre_Trip_Approval__c (after insert) {

	 // Code to grant access on the preview approver with a custom reason
	ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 
															'ASI_eForm_Pre_Trip_Approval__Share', 
															'ASI_eForm_Pre_Trip_Manager_Access__c', 
															new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c'}, null);

}