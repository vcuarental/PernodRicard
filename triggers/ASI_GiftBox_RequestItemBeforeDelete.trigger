trigger ASI_GiftBox_RequestItemBeforeDelete on ASI_GiftBox_Request_Item__c (before delete) {
    ASI_GiftBox_RequestItemTriggerClass.routineBeforeDelete(trigger.old);
}