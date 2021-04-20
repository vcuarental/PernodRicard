trigger ASI_CRM_VN_Bottle_Analysis_AfterInsert on ASI_CRM_VN_Bottle_Analysis__c (after insert) {
    new ASI_CRM_VN_BottleAnalysisRollUp().executeTrigger(Trigger.new, Trigger.oldMap);
}