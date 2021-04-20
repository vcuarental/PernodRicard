trigger ASI_Attachment_BeforeDelete on Attachment (before delete) {

    //ASI Pricing Approval Not allow delete attachment for record submitted for approval
    map<id,attachment> ASI_PricingApproval_AttMap = new map<id, attachment>();
    for (Attachment att : trigger.oldmap.values()){
        if ((att.ParentId).getSObjectType().getDescribe().getName() == 'ASI_Pricing_Approval__c'){
            ASI_PricingApproval_AttMap.put(att.id, att);
        }
    }
    if (ASI_PricingApproval_AttMap.size() > 0)
        ASI_Attachment_TriggerClass.routineBeforeDelete(ASI_PricingApproval_AttMap);
    //ASI Pricing Approval End
}