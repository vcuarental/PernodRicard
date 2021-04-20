trigger ASI_CRM_AccountsAdditionalField_AfterUpdate on ASI_CRM_AccountsAdditionalField__c (After update) {
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>(); 
    if(trigger.new[0].recordTypeid != NULL){
        if(trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_Outlet_CN') || 
                                                   Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_WS'))){



                                                       ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);
                                                   }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Wholesaler') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Bar_Supplier') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Off_Trade_Outlet')){
               ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {       
                   new ASI_CRM_JP_UpdateCustomerDirAndAcc()
                       };                    
                           }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldmap);
        }
        
        for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
            triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_')){
            ASI_CRM_SG_ReUpdate_Image_Level.updateCustomerImageLevel(trigger.new, trigger.old);
            ASI_CRM_SG_ReUpdate_Image_Level.updateCustomerRelatedRecordOwner(trigger.new, trigger.oldMap);
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_Potential_Outlet') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_Outlet')) {
            List<ASI_CRM_SG_TriggerAbstract> ASI_CRM_SG_triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
                new ASI_CRM_SG_UpdateChildOutletTypeHandler()
            };

            for (ASI_CRM_SG_TriggerAbstract triggerClass : ASI_CRM_SG_triggerClasses) {
                triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){   
            ASI_CRM_TW_ReUpdate_Image_Level.updateCustomerImageLevel(trigger.new, trigger.old);
            ASI_CRM_TW_AccountsAdditional_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldmap);
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Outlet')){
            ASI_CRM_VN_AccCreateProsSegHandler handler = new ASI_CRM_VN_AccCreateProsSegHandler();
            handler.updateProsSegRecord(trigger.new, trigger.oldMap);
        }
        //Added by Twinkle @02/06/2016
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Outlet') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){   
            ASI_CRM_TH_AccountCreateProsSegHandler handler = new ASI_CRM_TH_AccountCreateProsSegHandler();
            handler.createProsSegRecord(trigger.new);  
            ASI_CRM_TH_ReUpdate_Image_Level.updateCustomerImageLevel(trigger.new, trigger.old);
            ASI_CRM_TH_AccountsAdditional_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldmap);
        }
    }
}