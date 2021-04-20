trigger ASI_CRM_AccountsAdditionalField_BeforeInsert on ASI_CRM_AccountsAdditionalField__c (before insert) {        
    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();    
    List<ASI_CRM_SG_TriggerAbstract> ASI_CRM_SG_triggerClasses = new List<ASI_CRM_SG_TriggerAbstract>();
    
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_Outlet_CN') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_WS') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Prospect')){//20161026 Elufa
            triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                new ASI_CRM_CN_AccountsCRMCodeAutoNumber()            
            };  
            ASI_CRM_CN_AccountsAdditional_TriggerCls.routineBeforeInsert(trigger.new, trigger.oldMap);       
            ASI_CRM_CN_Customer_TriggerClass.routineBeforeUpsert(trigger.new, null);    
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Outlet') || 
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_KeyAccount') || 
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Wholesaler')){
            
            triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                new ASI_CRM_TW_AdditionalFieldToAccount(),
                new ASI_CRM_TW_AccountMovement_TgrHdlr()         
            };  
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') ||
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
         }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Potential_Outlet') ||
                  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler') ||
                  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Outlet')){
                      ASI_CRM_SG_triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {            
                          new ASI_CRM_SG_CustomerTgrHdlr()
                      };   
            
                      if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Potential_Outlet') || 
                         Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Outlet')) {
                          ASI_CRM_SG_triggerClasses.add(new ASI_CRM_SG_ChangeParentOutletHandler());
                      }
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineBeforeInsert(trigger.New);
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineBeforeUpsert(trigger.New);
        }  
        //Added by Introv - Twinkle LI @20160405
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Outlet') ||
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){
             triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {            
                new ASI_CRM_TH_AdditionalFieldToAccount()       
            };  
        } 
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet')){
            ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_AssignAutoNumber_Customer() );
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Inactive_Direct_Sales_Customer') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Sales_Ship_To') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Direct_Sales_Bill_To')||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Marketing_Venue')){
            ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_Customer_AssignAddress());
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Inactive_Direct_Sales_Customer')) {
            ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_CustomerAssignApprover());
        }
    }
    
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }  
    for (ASI_CRM_SG_TriggerAbstract triggerClass : ASI_CRM_SG_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
}