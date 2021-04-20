trigger ASI_MFM_Rental_Request_Line_BeforeUpdate on ASI_MFM_Rental_Request_Line__c (before update) {

    if(trigger.new[0].recordtypeid != Null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN_')){
        ASI_MFM_CN_RentalRequestLine_TriggerCls.beforeUpdateMethod(trigger.new, trigger.oldMap);
    }
}