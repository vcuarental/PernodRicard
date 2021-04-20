trigger ASI_MFM_PaymentLineItem_AfterInsert on ASI_MFM_Payment_Line_Item__c (after insert) {
    // Added by Michael Yip (Introv) 04Jun2014 for isolating CN Payment Trigger logic
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    // Added by Conrad Pantua (Laputa) 07Jul2014 for isolating Capex Payment Trigger logic
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP'))
    {
        ASI_MFM_CAP_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_JP'))
    {
        ASI_MFM_JP_PaymentLineItem_TriggerClass.routineAfterALL(trigger.new, null);
        ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR'))
    {
        ASI_MFM_KR_PaymentLineItem_TriggerClass.routineAfterALL(trigger.new, null);
        //ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_SG_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
        //Added by Andy Zhang 20190212 for VN
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_MY_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    /** else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KH')){
        ASI_MFM_KH_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    } **/
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_GF_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
    /**else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }**/
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP')){
        ASI_MFM_MKTEXP_PaymentLine_TriggerClass.routineAfterAll(trigger.new, null);
    }
    else if(!Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC')){
        ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(trigger.new, null);
    }
}