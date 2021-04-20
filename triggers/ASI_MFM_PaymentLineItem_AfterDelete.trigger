trigger ASI_MFM_PaymentLineItem_AfterDelete on ASI_MFM_Payment_Line_Item__c (after delete) {
    // Added by Michael Yip (Introv) 04Jun2014 for isolating CN Payment Trigger logic
    if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }
    // Added by Conrad Pantua (Laputa) 07Jul2014 for isolating Capex Payment Trigger logic
    else if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_CAP'))
    {
        ASI_MFM_CAP_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }else if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_JP'))
    {
         ASI_MFM_JP_PaymentLineItem_TriggerClass.routineAfterUpdate(null, trigger.oldMap);
        ASI_MFM_JP_PaymentLineItem_TriggerClass.routineAfterALL(null, trigger.oldMap);
        ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }else if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_KR'))
    {
       
        ASI_MFM_KR_PaymentLineItem_TriggerClass.routineAfterALL(null, trigger.oldMap);
        //ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }else if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SG'))
    {       
        ASI_MFM_SG_PaymentLineItem_TriggerClass.routineAfterALL(null, trigger.oldMap);        
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_MY_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldmap);
    }else if (trigger.old[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_SC'))
    {
        ASI_MFM_SC_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }  
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldmap);
    } 
    //Added by Andy Zhang for country VN
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldmap);
    }
    else if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP'))
    {
        ASI_MFM_MKTEXP_PaymentLine_TriggerClass.routineAfterAll(null, trigger.oldmap);
    }
    else{
        ASI_MFM_PaymentLineItem_TriggerClass.routineAfterAll(null, trigger.oldMap);
    }
}