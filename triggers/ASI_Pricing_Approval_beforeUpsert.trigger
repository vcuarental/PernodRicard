trigger ASI_Pricing_Approval_beforeUpsert on ASI_Pricing_Approval__c (before insert, before update) {
    ASI_PricingApproval_TriggerClass.routineBeforeUpsert(trigger.new);
}