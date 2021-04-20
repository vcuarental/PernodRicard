trigger ASI_eForm_IT_Procurement_Service_Request_AfterInsert on ASI_eForm_IT_Procurement_Service_Request__c (after insert) {

		 ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_IT_Procurement_Service_Request__Share', 
	 														'ASI_eForm_IT_Procurement_Manager_Access__c', 
	 														new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c', 'ASI_eForm_Finance_Director__c',
	 																		'ASI_eForm_CIO__c'}, 
	 														null);

}