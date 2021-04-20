trigger ASI_Pricing_Approval_AfterUpdate on ASI_Pricing_Approval__c (after update) {
    ASI_PricingApproval_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
}