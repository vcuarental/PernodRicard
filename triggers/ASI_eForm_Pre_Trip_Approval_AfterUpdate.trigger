trigger ASI_eForm_Pre_Trip_Approval_AfterUpdate on ASI_eForm_Pre_Trip_Approval__c (after update) {
    
    List<Id> preTripValidIds = new List<Id>();
    Set<ID> userSet = new Set<ID>();
    
    for (ASI_eForm_Pre_Trip_Approval__c preTripApproval : Trigger.new)
    {
        if (preTripApproval.ASI_eForm_Status__c == 'Final' && preTripApproval.ASI_eForm_Notify_Travel_Agent__c 
        	&& preTripApproval.ASI_eForm_Status__c != trigger.oldMap.get(preTripApproval.id).ASI_eForm_Status__c)
        {
            preTripValidIds.add(preTripApproval.Id);
            userSet.add(preTripApproval.ownerid);
            userSet.add(preTripApproval.CreatedByid);
        }    
    }
    
    if (preTripValidIds.size() > 0)
    {
        EmailTemplate emailTemplate =  [SELECT id,name FROM EmailTemplate WHERE 
        Name in ('ASI eForm PTRAF Book Request Email Template (HK)') LIMIT 1];    
        List<Messaging.SingleEmailMessage> allMail = new List<Messaging.SingleEmailMessage>();      
        
        ASI_eForm_Email_Setting__c  emailSetting = [Select Travel_Agent_Email__c from ASI_eForm_Email_Setting__c where Location__c = 'Hong Kong'];
        List<String> addresses = new List<String>();
        addresses.add(emailSetting.Travel_Agent_Email__c);
        
        OrgWideEmailAddress itServiceDesk = ASI_eForm_GenericTriggerClass.retrieveITServiceDesk();    
       	
       	Map<ID, User> userMap = new Map<ID, User>([SELECT ID, firstName, lastName, Email FROM User WHERE ID IN : userSet]);
       	
        for (Id preTripId : preTripValidIds)
        {
        	List<String> tempAddresses = new List<String>();
        	tempAddresses.addAll(addresses);
        	
            ASI_eForm_Pre_Trip_Approval__c preTripApproval = Trigger.newMap.get(preTripId);
            
        	if (preTripApproval.ownerid != preTripApproval.CreatedByid)
        		tempAddresses.add(userMap.get(preTripApproval.CreatedById).email);
                     
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(preTripApproval.ownerId);
            
            if (itServiceDesk != null)
            {
            	email.setSenderDisplayName(itServiceDesk.DisplayName);
            	email.setReplyTo(itServiceDesk.Address);
            }
            	
            email.setToAddresses(tempAddresses);
            email.setWhatId(preTripId);
            email.setTemplateId(emailTemplate.Id);        
            allMail.add(email);     
        }
                
        Messaging.SendEmailResult [] result = Messaging.sendEmail(allMail);   
    }
    
	 // Code to grant access on the preview approver with a custom reason
	 /*List<ASI_eForm_Pre_Trip_Approval__Share> preTripShares = new List<ASI_eForm_Pre_Trip_Approval__Share>(); //sharing rule of the object
	 
	 for(ASI_eForm_Pre_Trip_Approval__c preTrip : trigger.new)
	 {
	 	
	 	if (preTrip.ASI_eForm_Preview_Approver__c != null) 
	 	{
	 		ASI_eForm_Pre_Trip_Approval__Share Pre_Trip_Manager_Access = new ASI_eForm_Pre_Trip_Approval__Share();
	 		Pre_Trip_Manager_Access.ParentId = preTrip.id; //Which object record to have rights
	 		Pre_Trip_Manager_Access.UserOrGroupId = preTrip.ASI_eForm_Approver__c; //Which user to get rights
	 		Pre_Trip_Manager_Access.AccessLevel = 'read'; //What type of rights
	 		Pre_Trip_Manager_Access.RowCause = Schema.ASI_eForm_Pre_Trip_Approval__Share.RowCause.ASI_eForm_Pre_Trip_Manager_Access__c; //Reason to get rights
	 		preTripShares.add(Pre_Trip_Manager_Access); 
	 	}
	 }
	 
	 if (preTripShares.size() > 0)
	 	Database.SaveResult[] jobShareInsertResult = Database.insert(preTripShares,false);*/
	 
	 ASI_eForm_GenericTriggerClass.assignRecordPermission(trigger.new, 'ASI_eForm_Pre_Trip_Approval__Share', 
	 														'ASI_eForm_Pre_Trip_Manager_Access__c', 
	 														new String[] {'ASI_eForm_Preview_Approver__c', 'ASI_eForm_Approver__c'}, trigger.oldMap);
     
    
}