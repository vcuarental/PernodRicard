trigger ASI_CRM_CN_Covered_Outlet_BeforeInsert on ASI_CRM_CN_Covered_Outlet__c (Before insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Covered_Outlet')){
        ASI_CRM_CN_Covered_Outlet_TriggerClass.routineBeforeUpsert(trigger.new, null);   
    }
}