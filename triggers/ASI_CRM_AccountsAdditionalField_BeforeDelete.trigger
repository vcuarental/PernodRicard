trigger ASI_CRM_AccountsAdditionalField_BeforeDelete on ASI_CRM_AccountsAdditionalField__c (Before Delete) {
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>(); 

    if(trigger.old[0].RecordTypeId != null && 
       (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_Outlet_CN') || 
        Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_CRM_CN_WS'))){
            ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeDelete(trigger.old, null);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') ||
             Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_JP_Wholesaler') ||
             Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_JP_Bar_Supplier') ||
             Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_JP_Off_Trade_Outlet')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
            new ASI_CRM_JP_DeleteAccCusDirAfterCus()
        };
    }  
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_DELETE, trigger.new, trigger.newMap, trigger.oldMap);
    }    
}