trigger ASI_HK_CRM_PreApprovalFormItem_BeforeUpdate on ASI_HK_CRM_Pre_Approval_Form_Item__c (before update) {
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK')){    
        //Trigger Record Type Check for HK CRM in ASISB5CONF
            
        List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
            new ASI_HK_CRM_PAFItemAssignRecordType()
            , new ASI_HK_CRM_PAFItemInvestValueCalculator()
            , new ASI_HK_CRM_PAFItemCompareKABenchmark()
        };
        
        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_TW')){    
        //Trigger Record Type Check for TW CRM in ASISB6CONF
    	ASI_CRM_TW_PAFItems_TriggerCls.routineBeforeUpsert(trigger.new, trigger.oldMap);
    }    
}