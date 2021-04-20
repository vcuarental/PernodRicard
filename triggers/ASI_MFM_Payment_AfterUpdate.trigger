trigger ASI_MFM_Payment_AfterUpdate on ASI_MFM_Payment__c (after update) {
    // Added by Michael Yip (Introv) 04Jun2014 for isolating CN Payment Trigger logic
    if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')
       || trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN')){
           
           //20170213 Elufa
           if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
               ASI_MFM_CN_Payment_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
               ASI_MFM_CN_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
               
           }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN')){
               
               ASI_MFM_CN_Payment_SC_TriggerCls.structureCostAfterUpdate(trigger.New, trigger.oldMap);
           }
    } 
    // Added by Conrad Pantua (Laputa) 07Jul2014 for isolating Capex Payment Trigger logic
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP')
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('SG')
        // Added by Hugo Cheung (Laputa) 05May2016 for isolating Capex Payment TH Trigger logic
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('TH')
        // Added by Hugo Cheung (Laputa) 06May2016 for isolating Capex Payment HK Trigger logic
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('HK')
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('JP')) //[WL 1.0])
    {
        ASI_MFM_CAP_Payment_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    // Added by Conrad Pantua (Laputa) 27May2015 for isolating Capex Payment SG Trigger logic
    else if (trigger.new[0].RecordTypeId != null && 
             (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG') || 
              Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') ||
              Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_JP') || //[WL 1.0]
              Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')))
    {
        ASI_MFM_CAP_SG_Payment_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_SG_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR'))
    {
        ASI_MFM_KR_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-04-16 Linus@introv
        ASI_MFM_SG_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldmap);
    }
     else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH'))
    {       
        ASI_MFM_PH_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_JP'))
    {
        ASI_MFM_JP_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF'))
    {
        ASI_MFM_GF_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC'))
    {
        ASI_MFM_SC_Payment_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_SC_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH'))
    {
        ASI_MFM_PH_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    //Added by Andy Zhang
     else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN'))
     {
         ASI_MFM_VN_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
     }
    else if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MKTEXP'))
    {
        ASI_MFM_MKTEXP_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    else{
        ASI_MFM_Payment_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_Payment_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}