trigger ASI_CRM_AccountsAdditionalField_BeforeUpdate on ASI_CRM_AccountsAdditionalField__c (before update) {
    
    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(trigger.new[0].recordTypeid != NULL){
        System.Debug(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName);
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Outlet') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_KeyAccount') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Wholesaler')){
               
               triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                   new ASI_CRM_TW_AccountMovement_TgrHdlr(),
                       new ASI_CRM_TW_AdditionalFieldToAccount()            
                       };
        }
        else if(trigger.new[0].RecordTypeId != null && (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_Outlet_CN') || 
                                                        Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN_WS') ||
                                                        Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Prospect')))
        {//20161026 Elufa
            ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
            ASI_CRM_CN_Customer_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);    
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') ||
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Wholesaler') ||
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Bar_Supplier') ||
                    Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Off_Trade_Outlet')){
            ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
                new ASI_CRM_JP_CustomerTgrHdlr(),
                // DC - 04/14/2016 - Uncommented out controller after test completion.
                // DC - 03/15/2016 - Commented out controller for creating test records.
                // DC - 03/14/2016 - Added handler to list for converting full-width characters to half-width characters.
                new ASI_CRM_JP_EncodingConverter() 
            };                    
        }
        //Added by Introv - Twinkle LI @20160405
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Outlet') ||
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){
            triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                new ASI_CRM_TH_AdditionalFieldToAccount()       
            };  
            ASI_CRM_TH_AccountsAdditional_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldmap);
        } 
        
        /*if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')) {
            ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_ChangeAutoNumber_Customer());
        }*/

       if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Inactive_Direct_Sales_Customer') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Sales_Ship_To') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Sales_Bill_To') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Marketing_Venue')){
            ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_Customer_AssignAddress());
        }

        for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
        
        for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
            triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        } 
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineBeforeUpsert(trigger.New);
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldmap);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_HK_Outlet'){
            ASI_CRM_MO_AccountAdditional_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldmap);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName == 'ASI_CRM_SG_Converted_Outlets'){
            ASI_CRM_SG_ReUpdate_Image_Level.assignJDECustomerNumber(trigger.new, trigger.oldMap);
        } else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Potential_Outlet') || 
                  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Outlet')) {
            List<ASI_CRM_SG_TriggerAbstract> ASI_CRM_SG_triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
                new ASI_CRM_SG_ChangeParentOutletHandler()
            };

            for (ASI_CRM_SG_TriggerAbstract triggerClass : ASI_CRM_SG_triggerClasses) {
                triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
            }
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN')){
            if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_VN_Outlet')){
              ASI_CRM_VN_CustomerChangeOutlet.execute(trigger.new,trigger.oldMap);  
                new ASI_CRM_VN_CustomerValidation().executeTrigger(trigger.new,trigger.oldMap);
                new ASI_CRM_VN_OutletValidateTriggerHandler().executeTrigger(trigger.new,trigger.oldMap);
            }
            
            //Wilken 20161212, Populate approver whenever Outlet is updated.
            new ASI_CRM_VN_CusPopulateApprovers().populateSysApproverFields(trigger.new);
        }
    }    
}