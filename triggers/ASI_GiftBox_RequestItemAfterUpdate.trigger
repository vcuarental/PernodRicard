trigger ASI_GiftBox_RequestItemAfterUpdate on ASI_GiftBox_Request_Item__c (after update) {
    ASI_GiftBox_RequestItemTriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    ASI_GiftBox_RequestItemTriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);

    If(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_POSM_Request_Item') || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_FOC_Request_Item') || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Promotion_Request_Item') || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Display_Listing_Request_Item')) {
        new ASI_CRM_VN_RequestItemRollupAmount().executeTrigger(trigger.new, trigger.oldMap);
    }
    
    If(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')) {
        new ASI_CRM_VN_CapsuleCS_updateHeaderAmount().executeTrigger(trigger.new, trigger.oldMap);
    }
}