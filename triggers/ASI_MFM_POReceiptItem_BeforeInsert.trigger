trigger ASI_MFM_POReceiptItem_BeforeInsert on ASI_MFM_PO_Receipt_Item__c (before insert) {
    map<id, recordType> cnrt_map = new map<id, recordType>([select id from recordType 
        where sobjectType = 'ASI_MFM_PO_Receipt_Item__c' and developerName like 'ASI_MFM_CN%']);
    
    if (cnrt_map.containsKey(trigger.new[0].recordTypeId)) {  
        ASI_MFM_CN_POReceiptItem_TriggerClass.routineBeforeInsert(trigger.new, null);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
        ASI_MFM_KR_POReceiptItem_TriggerClass.routineBeforeInsert(trigger.new);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_CN_POReceiptItem_TriggerClass.routineBeforeInsert(trigger.new, null);  
    }
}