trigger ASI_MFM_RentalRequest_BeforeInsert on ASI_MFM_Rental_Request__c (before Insert) {
    if(trigger.new[0].recordTypeId != Null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_')){
        ASI_MFM_CN_RentalRequest_TriggerClass.beforeInsertMethod(trigger.new);
    }
}