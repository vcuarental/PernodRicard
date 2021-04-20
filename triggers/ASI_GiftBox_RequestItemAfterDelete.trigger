trigger ASI_GiftBox_RequestItemAfterDelete on ASI_GiftBox_Request_Item__c (after delete) {
    
    If(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')) {
        new ASI_CRM_VN_CapsuleCS_updateHeaderAmount().executeTrigger(trigger.old);
    }

}