trigger ASI_CRM_Employee_Attendee_BeforeInsert on ASI_CRM_Employee_Attendee__c (before insert) {    
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Employee_Attendee')) {
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
            new ASI_CRM_JP_EmployeeAttendeeTgrHdlr()          
        };                    
    }   
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}