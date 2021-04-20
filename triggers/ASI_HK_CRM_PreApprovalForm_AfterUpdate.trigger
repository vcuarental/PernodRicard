trigger ASI_HK_CRM_PreApprovalForm_AfterUpdate on ASI_HK_CRM_Pre_Approval_Form__c (after update) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK')){    
        //Trigger Record Type Check for HK CRM in ASISB5CONF
        
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {new ASI_CRM_HK_PAFChannelCustomer()};
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
        ASI_CRM_TW_PAF_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}