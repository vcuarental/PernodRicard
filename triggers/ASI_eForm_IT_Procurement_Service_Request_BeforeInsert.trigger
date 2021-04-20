trigger ASI_eForm_IT_Procurement_Service_Request_BeforeInsert on ASI_eForm_IT_Procurement_Service_Request__c (before insert) {

    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new);

    for (ASI_eForm_IT_Procurement_Service_Request__c i : trigger.new)
    {
    	
		i = (ASI_eForm_IT_Procurement_Service_Request__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));  
    
        if (i.ASI_eForm_CIO__c != null)
            i.ASI_eForm_CIO__c = null;
        
        //if (i.ASI_eForm_Finance_Director__c != null)
        //    i.ASI_eForm_Finance_Director__c = null;
    }

}