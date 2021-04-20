trigger ASI_GiftBox_OrderItemBeforeInsert on ASI_GiftBox_Order_Item__c (before insert) {
    ASI_GiftBox_OrderItemTriggerClass.routineBeforeInsert(trigger.new);    
}