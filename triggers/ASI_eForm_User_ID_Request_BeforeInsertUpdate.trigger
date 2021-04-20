trigger ASI_eForm_User_ID_Request_BeforeInsertUpdate on ASI_eForm_User_ID_Request__c (before insert, before update) {

	Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new); 
                                            
	for (ASI_eForm_User_ID_Request__c i : trigger.new)
	{
		if (trigger.isUpdate)
		{
    		if (i.ownerid != trigger.oldmap.get(i.id).ownerid)	
    			i = (ASI_eForm_User_ID_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
		}
		else
			i = (ASI_eForm_User_ID_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
	}

    ASI_eForm_UserIDRequestsHandler.processUserIdChangeUserProfile(Trigger.new, Trigger.oldMap);

}