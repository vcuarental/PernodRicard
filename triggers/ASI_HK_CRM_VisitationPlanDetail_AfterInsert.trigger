trigger ASI_HK_CRM_VisitationPlanDetail_AfterInsert on ASI_HK_CRM_Visitation_Plan_Detail__c (after insert) {
      
    if(trigger.new[0].recordTypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail') || 
       trigger.new[0].recordTypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc') ||
       trigger.new[0].recordTypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call')){
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_CRM_MY_VisitationPlanDtValidator()
        };     
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }else{      
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_VisitationPlanDtValidator()
        };     
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, null);
        }
    }
}