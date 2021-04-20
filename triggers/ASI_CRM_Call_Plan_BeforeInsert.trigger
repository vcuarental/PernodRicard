trigger ASI_CRM_Call_Plan_BeforeInsert on ASI_CRM_Call_Plan__c (before insert) {     
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Plan') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Call_Plan_Locked')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
            new ASI_CRM_JP_CallPlanTgrHdlr(),
            new ASI_CRM_JP_AssignApprover_LineManager(),
            new ASI_CRM_JP_CheckCallPlanOverlap()
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
}