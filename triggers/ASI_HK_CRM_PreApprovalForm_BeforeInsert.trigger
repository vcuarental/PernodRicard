trigger ASI_HK_CRM_PreApprovalForm_BeforeInsert on ASI_HK_CRM_Pre_Approval_Form__c (before insert) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK')){    
        //Trigger Record Type Check for HK CRM in ASISB5CONF
        
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_PAFAssignAutoNumber()
            , new ASI_HK_CRM_PAFApprovalProcessCalculator()
            , new ASI_HK_CRM_PreApprovalFormAssignApprover()
        };
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
        }
    }
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        
        ASI_CRM_TW_PAF_TriggerCls.routineBeforeInsert(trigger.new, null);
        ASI_CRM_TW_PAFAssignAutoNumber.executeTriggerAction(trigger.new);
    }   
}