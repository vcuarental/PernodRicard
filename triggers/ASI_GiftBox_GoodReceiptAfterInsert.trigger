trigger ASI_GiftBox_GoodReceiptAfterInsert on ASI_GiftBox_Good_Receipt__c (after insert) {
    ASI_GiftBox_GoodReceiptTriggerClass.routineAfterInsert(trigger.new);
}