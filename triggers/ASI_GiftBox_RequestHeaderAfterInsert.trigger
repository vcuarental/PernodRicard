trigger ASI_GiftBox_RequestHeaderAfterInsert  on ASI_GiftBox_Request_Header__c (after insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_GiftBox_VN')){
        ASI_GiftBox_RequestHeaderTriggerClass.routineAfterInsert(trigger.new);
    }

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')){
        new ASI_CRM_VN_CapsuleCS_createCSRequestLine().executeTrigger(Trigger.new);
        
    }

}