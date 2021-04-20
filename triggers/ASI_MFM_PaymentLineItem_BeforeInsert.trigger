trigger ASI_MFM_PaymentLineItem_BeforeInsert on ASI_MFM_Payment_Line_Item__c (before insert) {
    // Added by Michael Yip (Introv) 04Jun2014 for isolating CN Payment Trigger logic
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_CN_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    // Added by Conrad Pantua (Laputa) 07Jul2014 for isolating Capex Payment Trigger logic
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP'))
    {
        ASI_MFM_CAP_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_CAP_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    } else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR'))
    {  
        ASI_MFM_KR_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
         ASI_MFM_KR_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_SG_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_SG_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    } else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_PH_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    } //Add by Andy Zhang Laputa for VN 20190212
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_VN_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_MY_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_MY_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    } else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_GF_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_GF_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC'))
    {
        ASI_MFM_SC_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);  
        ASI_MFM_SC_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP'))
    {
        ASI_MFM_MKTEXP_PaymentLine_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_MKTEXP_PaymentLine_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    else{
        ASI_MFM_PaymentLineItem_TriggerClass.routineBeforeInsert(trigger.new);
        ASI_MFM_PaymentLineItem_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }   
}