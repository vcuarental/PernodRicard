trigger ASI_eForm_Pre_Trip_Approval_BeforeUpdate on ASI_eForm_Pre_Trip_Approval__c (before update) {

    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new, true); 

    for (ASI_eForm_Pre_Trip_Approval__c i : trigger.new)
    {
        
        if (i.ownerID != i.ASI_eForm_Employee_Traveller__c && i.ASI_eForm_Employee_Traveller__c != null)
            i.ownerid = i.ASI_eForm_Employee_Traveller__c;
        
        if (i.ASI_eForm_Employee_Traveller__c != trigger.oldmap.get(i.id).ASI_eForm_Employee_Traveller__c && i.ASI_eForm_Employee_Traveller__c!= null)  
            i = (ASI_eForm_Pre_Trip_Approval__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
        
        // ISSUE FIX: Input Company of Owner if Employee Traveller is empty
        if (i.ownerID != trigger.oldmap.get(i.id).ownerID && i.ASI_eForm_Employee_Traveller__c == null)  
            i = (ASI_eForm_Pre_Trip_Approval__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
        
        if (i.ASI_eForm_Employee_Traveller__c == null && i.ASI_eForm_Company__c != null && i.ASI_eForm_Traveller__c != null)
        {
            //i.ASI_eForm_Company__c = null;
            i.ASI_eForm_Position__c = null;
            i.ASI_eForm_Country__c = null;
            i.ASI_eForm_Department__c = null;
        }
        
        /*if (i.ASI_eForm_Traveller__c == null && i.ASI_eForm_Traveller_Company__c != null)
        {
            i.ASI_eForm_Traveller_Company__c = null;
        }*/
        // END OF FIX
        
        if((trigger.oldmap.get(i.id).ASI_eForm_Traveller__c != null ? 
            (!trigger.oldmap.get(i.id).ASI_eForm_Traveller__c.equals(i.ASI_eForm_Traveller__c)) : (true))
            && i.ASI_eForm_Traveller__c != null)
        {  
            i.ASI_eForm_Traveller__c = i.ASI_eForm_Traveller__c.toUpperCase();
        }
    }

}