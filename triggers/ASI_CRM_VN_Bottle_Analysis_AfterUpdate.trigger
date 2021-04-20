trigger ASI_CRM_VN_Bottle_Analysis_AfterUpdate on ASI_CRM_VN_Bottle_Analysis__c (after update) {
    new ASI_CRM_VN_BottleAnalysisRollUp().executeTrigger(Trigger.new, Trigger.oldMap);
}