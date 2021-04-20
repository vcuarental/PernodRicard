trigger ASI_GiftBox_RequestHeaderAfterUpdate on ASI_GiftBox_Request_Header__c (after update) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_POSM_VN_Request' || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_POSM_VN_Request_Read_Only'){
        new ASI_CRM_VN_POSM_RollUpToExpenditure().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_FOC_Request' || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_FOC_Request_Read_Only'){
        new ASI_CRM_VN_FOC_RollUpToExpenditure().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_Display_Listing_Fee_Request' || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_Display_Listing_Fee_Request_Read_Only'){
        new ASI_CRM_VN_DisplayListing_RollUpToExpen().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_CS_Request' || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_VN_CS_Request_Read_Only'){
        new ASI_CRM_VN_CS_RollUpToExpenditure().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')) {
        new ASI_CRM_VN_CapsuleCS_updateAmtToContract().executeTrigger(trigger.new, trigger.oldMap);
        new ASI_CRM_VN_CapsuleCS_ChangeLineRT().executeTrigger(trigger.new, trigger.oldMap);
    }

    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_VN_Promotion_Request')) {
        new ASI_CRM_VN_PromoReq_UpdatePromoPlanItems().executeTrigger(trigger.new, trigger.oldMap);
        new ASI_CRM_VN_PromoReq_UpdatePromotionPlan().executeTrigger(trigger.new, trigger.oldMap);
        new ASI_CRM_VN_PromotionReqUpdateContract().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    // added by Calvin (LAPUTA) 2018-12-04
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_VN_Outlet_Promotion_Request')) {
        new ASI_CRM_VN_OutletPromotionReqRollUp().executeTrigger(trigger.new, trigger.oldMap);
    }

}