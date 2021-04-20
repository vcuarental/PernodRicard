trigger ASI_CN_NPL_NewProductLaunchRequest_BeforeUpdate on ASI_CN_NPL_NPL_Request__c (before update) {

    if (trigger.new[0].RecordTypeId != null && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_NPL_KR_New_SKU_Launch')){//20180223 Introv, to exclude KR record from China logic
        ASI_CN_NPL_RequestTriggerAbstract.executeBeforeUpdateTriggerAction(trigger.new, trigger.oldmap);
        
        ASI_CRM_CN_NPLT1Price_triggerclass.beforeUpdateMethod(trigger.new);
    }
}