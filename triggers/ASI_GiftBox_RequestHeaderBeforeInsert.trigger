trigger ASI_GiftBox_RequestHeaderBeforeInsert  on ASI_GiftBox_Request_Header__c (before insert) {
    ASI_GiftBox_RequestHeaderTriggerClass.routineBeforeInsert(trigger.new);
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_POSM_VN'))
    {
        new ASI_CRM_VN_POSMRequest_AssignDefaultVal().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_GiftBoxRequestBeforeInsert().beforeInsertPopulateHrFinanceMarketingUsers(trigger.new);
        if(trigger.new[0].ASI_CRM_VN_Contract__c == null)
        {

        }
        else {
            new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_FOC'))
    {
        new ASI_CRM_VN_FOCRequest_AssignDefaultVal().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_CS'))
    {
        new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Capsule')){
        new ASI_CRM_VN_CapsuleCS_addPaymentTime().executeTrigger(Trigger.new, Trigger.oldMap);
    }
	
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Display_Listing_Fee_Request')) {
        new ASI_CRM_VN_POSMRequest_AssignDefaultVal().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);

    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Promotion_Request')){
        new ASI_CRM_VN_POSMRequest_AssignDefaultVal().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_PromotionReq_CheckContract().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_PromotionRequest_ValidInsert().executeTrigger(Trigger.new, Trigger.oldMap);
        new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);
    }
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Outlet_Promotion')){
        new ASI_CRM_VN_OutletPromotion_Validation().executeTrigger(Trigger.new);
        new ASI_CRM_VN_CSRequest_CompareOfftake().executeTrigger(Trigger.new, Trigger.oldMap);
    }

}