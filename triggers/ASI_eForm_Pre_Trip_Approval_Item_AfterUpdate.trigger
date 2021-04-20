trigger ASI_eForm_Pre_Trip_Approval_Item_AfterUpdate on ASI_eForm_Pre_Trip_Approval_Item__c (after update) {

    List<ASI_eForm_Pre_Trip_Approval_Item__c> validItems = new List<ASI_eForm_Pre_Trip_Approval_Item__c>();
    List<ASI_eForm_Pre_Trip_Approval_Item__c> validItemsBookingStatus = new List<ASI_eForm_Pre_Trip_Approval_Item__c>();
    
    for (ASI_eForm_Pre_Trip_Approval_Item__c i : trigger.new)
    {
        if (i.ASI_eForm_ETD__c != trigger.oldMap.get(i.id).ASI_eForm_ETD__c 
            || i.ASI_eForm_ETA__c != trigger.oldMap.get(i.id).ASI_eForm_ETA__c 
            || i.ASI_eForm_Return_Date__c != trigger.oldMap.get(i.id).ASI_eForm_Return_Date__c
            || i.ASI_eForm_Booking_Status__c != trigger.oldMap.get(i.id).ASI_eForm_Booking_Status__c)
            validItems.add(i);
    }
    
    if (validItems.size() > 0)
        ASI_eForm_Pre_Trip_Approval_Item_Trigger.lowestDate(validItems);

}