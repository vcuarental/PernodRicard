trigger ASI_MFM_PO_AfterUpdate on ASI_MFM_PO__c (after update) {        
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);    
        ASI_MFM_TW_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);          
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
        ASI_MFM_HK_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        ASI_MFM_HK_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);   
        ASI_MFM_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        ASI_MFM_TR_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldmap);
        //ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);  
        ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        ASI_MFM_RM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);  
        ASI_MFM_RM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);        
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap); 
        ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap); 
        ASI_MFM_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_JP')){
        ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);    
        ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);  
        ASI_MFM_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MY')){
        ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);     
        ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap); 
        ASI_MFM_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP') 
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('HK')){
        ASI_MFM_CAP_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);   
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        //ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        //ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_CN_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        ASI_MFM_CN_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap); // 2014-10-27      Axel@introv     #95 For Plan's Header Total PO Amount issue
        ASI_MFM_CN_PO_SetPlan_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap); // 201905 Enoch@Introv update plan balance
    }
    //Tony Ren(elufa) 5Feb2015
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        ASI_MFM_CAP_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_SG_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        //ASI_MFM_CAP_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        //ASI_MFM_CAP_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);   
    }
     else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR')){
          ASI_MFM_KR_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
         ASI_MFM_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
     }
    //Tony Ren(elufa) 25 Feb 2015
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TH')){
        ASI_MFM_CAP_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
        ASI_MFM_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_PH_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
    }
    //Added by Andy Zhang @Laputa 20190216 for VN
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PO_TriggerClass.routineAfterUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_VN_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC')){
        ASI_MFM_SC_PO_TriggerClass.routineAfterAll(trigger.new, trigger.oldMap);
        ASI_MFM_SC_PO_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
}