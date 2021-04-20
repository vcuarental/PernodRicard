trigger  ASI_HK_CRM_Account_BeforeUpdate on Account (before update){   
    // Start Update by Howard Au (Introv)@05 Jun 2014, fix for MX Opportunities Too Many SOQL error Only execute for ASI record type
    List<ASI_HK_CRM_TriggerAbstract>  triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();

    /*if (trigger.new[0].recordTypeid != null){ 
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.startsWith('ASI_')){ 
            triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                new ASI_HK_CRM_AccountUpdateChannel(),
                new ASI_LUX_AssignAccountAutoNumber()
            };
        
            if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){       
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                    new ASI_TH_CRM_AccountUpdateRecordType ()            
                };                       
            }
            else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM')){
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
            }
            else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
               triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                    new ASI_CRM_TW_AccountMovement_TgrHdlr()         
                };  
            }             
        
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
    }*/
    
    //////// Rearrange condition checking to remove unused instance of ASI_HK_CRM_AccountUpdateChannel and ASI_LUX_AssignAccountAutoNumber
    if (trigger.new[0].recordTypeid != null){ 
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.startsWith('ASI_')){ 
        
            if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){       
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                    new ASI_TH_CRM_AccountUpdateRecordType ()            
                };                       
            }
            else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM')){
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
            }
            else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
               triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                    new ASI_CRM_TW_AccountMovement_TgrHdlr()         
                };  
            }
            else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.startsWith('ASI_CRM_CN_') || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.startsWith('ASI_MFM_CN_')) {
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
            }
            
            //updated by Daniel WONG (Introv) @ 2015-03-31, check RecordType = Outlet(HK) and Location = Macau
            else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_HK_CRM_Outlet' && trigger.new[0].ASI_HK_CRM_Location__c == '#_MACDPLOC'){
                ASI_CRM_MO_Account_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldMap);
            }else {
                triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                    new ASI_HK_CRM_AccountUpdateChannel(),
                        new ASI_LUX_AssignAccountAutoNumber()
                        };
            }
        
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
    }
}