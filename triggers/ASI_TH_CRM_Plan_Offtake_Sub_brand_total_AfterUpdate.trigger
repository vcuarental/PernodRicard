trigger ASI_TH_CRM_Plan_Offtake_Sub_brand_total_AfterUpdate on ASI_TH_CRM_Plan_Offtake_Sub_brand_Total__c (after update) {
    ASI_TH_CRM_Plan_Offtake_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
}