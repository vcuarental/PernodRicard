trigger ASI_MFM_PO_BeforeUpdate on ASI_MFM_PO__c (before update) {

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_HK')){
       // ASI_MFM_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_HK_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TR')){
        // Added by 2018-04-30 Linus@introv
        ASI_MFM_TR_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_TR_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')
             || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost')
            ){
                if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')) {
                    ASI_MFM_CN_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
                    ASI_MFM_CN_PO_SetPlan_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap); // Introv Enoch@201905 update po plan 
                } else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost'))
                    ASI_MFM_CN_PO_StructureCost_TriggerClass.beforeUpdateMethod(trigger.new, trigger.oldMap);
                    
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_RM')){
        ASI_MFM_RM_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_RM_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_GF')){
        // Added by 2018-03-26 Linus@introv
        ASI_MFM_GF_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_GF_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW')){
        ASI_MFM_TW_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_TW_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_PH')){
        ASI_MFM_PH_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_PH_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_VN')){
        ASI_MFM_VN_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_VN_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_JP')){
        ASI_MFM_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_JP_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);  
    }
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP') 
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('SG')
        // Added by Hugo Cheung (Laputa) 05May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('TH')
        // Added by Hugo Cheung (Laputa) 06May2016
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('HK')
        //20170207 Elufa
        && !Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_CN_Structure_Cost')){
        ASI_MFM_CAP_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_CAP_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
    // Tony Ren(elufa) 5Feb 2015
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
        // Added by 2018-03-15 Linus@introv
        ASI_MFM_SG_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_SG_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
     // Tony Ren (elufa) 25Feb 2015
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TH') ||                           
             Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_MY') ){
        ASI_MFM_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);   
    }
      //for KR, added by Leo, 2015-11-23, B6
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_KR_PO')){
        ASI_MFM_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        
        //20180223 Introv bypass prepayment and offset payment
        List<ASI_MFM_PO__c> triggerNew = new List<ASI_MFM_PO__c>();
        for(ASI_MFM_PO__c po:trigger.new){
            if(!(po.ASI_MFM_Is_Direct_Payment__c || po.ASI_MFM_Is_Pre_Payment__c || po.ASI_MFM_Is_Offset_Payment__c )){
                triggerNew.add(po);
            }
        }        
        if(triggerNew.size()>0){
            ASI_MFM_KR_PO_TriggerClass.beforeUpsertMethod(triggerNew, trigger.oldMap); 
        }
    }else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_SC_')) {
        ASI_MFM_SC_PO_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        ASI_MFM_SC_PO_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
}