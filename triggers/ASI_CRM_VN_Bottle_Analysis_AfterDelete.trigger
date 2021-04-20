trigger ASI_CRM_VN_Bottle_Analysis_AfterDelete on ASI_CRM_VN_Bottle_Analysis__c (after delete) {
    new ASI_CRM_VN_BottleAnalysisRollUp().executeTrigger(Trigger.new, Trigger.oldMap);
}