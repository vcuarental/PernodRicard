trigger ASI_CRM_Visual_Application_BeforeInsert on ASI_CRM_Visual_Application__c (before insert,before update) {

    // lokman 4/5/2014

        ASI_CRM_Visual_Application_TriggerClass.routineBeforeInsert(Trigger.new);
 
    
    }