trigger ASI_GiftBox_RequestHeaderBeforeDelete on ASI_GiftBox_Request_Header__c (before delete){

    If(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_CRM_VN_Capsule')) {
        ASI_GiftBox_RequestHeaderTriggerClass.routineBeforeDelete(trigger.old);
    }
  
}