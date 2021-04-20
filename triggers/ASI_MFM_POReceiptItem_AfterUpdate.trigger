trigger ASI_MFM_POReceiptItem_AfterUpdate on ASI_MFM_PO_Receipt_Item__c (after update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        ASI_MFM_CN_POReceiptItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);  
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
        ASI_MFM_CN_POReceiptItem_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);  
    }
}