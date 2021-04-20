trigger ASI_GiftBox_TransferLogAfterInsert on ASI_GiftBox_Transfer_Log__c (after insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_GiftBox_VN')){
        ASI_GiftBox_TransferLogTriggerClass.routineAfterInsert(trigger.new);
    }
}