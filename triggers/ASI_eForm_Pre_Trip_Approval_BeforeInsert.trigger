trigger ASI_eForm_Pre_Trip_Approval_BeforeInsert on ASI_eForm_Pre_Trip_Approval__c (before insert) {

    Map<ID, User> userOwnerMap = ASI_eForm_GenericTriggerClass.mapUser(trigger.new, true); 
                                            
    for (ASI_eForm_Pre_Trip_Approval__c i : trigger.new)
    {
        if (i.ownerID != i.ASI_eForm_Employee_Traveller__c && i.ASI_eForm_Employee_Traveller__c != null)
            i.ownerid = i.ASI_eForm_Employee_Traveller__c;

        // ISSUE FIX: Input Company of Owner if Employee Traveller is empty
        //if (i.ASI_eForm_Employee_Traveller__c != null)
            i = (ASI_eForm_Pre_Trip_Approval__c)(ASI_eForm_GenericTriggerClass.assignOwnerInfo(i, userOwnerMap));
            
        if (i.ASI_eForm_Employee_Traveller__c == null && i.ASI_eForm_Position__c != null && i.ASI_eForm_Traveller__c!= null)
        {
            //i.ASI_eForm_Company__c = null;
            i.ASI_eForm_Position__c = null;
            i.ASI_eForm_Country__c = null;
            i.ASI_eForm_Department__c = null;
        }
        // END OF FIX
        
        if (i.ASI_eForm_Traveller__c != null)
        {   
            i.ASI_eForm_Traveller__c = i.ASI_eForm_Traveller__c.toUpperCase();
        }
        
    }

}