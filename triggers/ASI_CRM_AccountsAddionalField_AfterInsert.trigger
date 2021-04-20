trigger ASI_CRM_AccountsAddionalField_AfterInsert on ASI_CRM_AccountsAdditionalField__c (after insert) {    
    List<ASI_CRM_AccountsAdditionalField__c> updateAccountsAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
    Set<Id> ids = new Set<Id>();
    List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract>();
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    List <ASI_CRM_AccountsAdditionalField__c> ASI_CRM_MY_CustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
    
    System.debug('ASI_CRM_AccountsAddionalField_AfterInsert Start');
    if(trigger.new[0].recordTypeid != NULL){
        System.debug('RecordType:' + Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName);
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){      
            System.debug('ASI_TH_CRM_Potential_Outlet Start');
            for(ASI_CRM_AccountsAdditionalField__c accountsAdditionalField : trigger.new){
                System.debug('accountsAdditionalField.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c' + accountsAdditionalField.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c);
                
                ids.add(accountsAdditionalField.id); 
            }   
            
            for(ASI_CRM_AccountsAdditionalField__c accountsAdditionalField : [SELECT id, ASI_CRM_AccountAdditionalField_EXID__c, ASI_CRM_Account__r.ASI_KOR_Customer_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id in :ids] ){
                accountsAdditionalField.ASI_CRM_AccountAdditionalField_EXID__c = accountsAdditionalField.ASI_CRM_Account__r.ASI_KOR_Customer_Code__c;           
                updateAccountsAdditionalFieldList.add(accountsAdditionalField);
            }
            
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_Outlet_CN') || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_WS')){     //Edited by Steve Wan 12 May 2014 adding logic to create an account
            ASI_CRM_CN_AccountsAdditional_TriggerCls.routineAfterInsert(trigger.new, trigger.oldMap);
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Bar_Supplier') || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Off_Trade_Outlet') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_On_Trade_Outlet') || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Wholesaler')){
            ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {            
                new ASI_CRM_JP_Insert_CustomerDir()           
            };                         
        }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){
            ASI_CRM_MY_AccountAdditional_TriggerCls.routineAfterInsert(trigger.new);
        }
        
        if (updateAccountsAdditionalFieldList != null && updateAccountsAdditionalFieldList.size() > 0)
            update updateAccountsAdditionalFieldList;      
        System.debug('ASI_CRM_AccountsAddionalField_AfterInsert End');
        
        
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Outlet') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_KeyAccount') || 
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW_Wholesaler')){
               
               triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                   //new ASI_CRM_TW_AccountMovement_TgrHdlr()                     
            };
            ASI_CRM_TW_AccountCreateProsSegHandler handler = new ASI_CRM_TW_AccountCreateProsSegHandler();
            handler.createProsSegRecord(trigger.new);       
        } 
            
        //Added by Twinkle LI @04/03/2016
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Outlet') ||
           Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TH_CRM_Potential_Outlet')){      
            ASI_CRM_TH_AccountCreateProsSegHandler handler = new ASI_CRM_TH_AccountCreateProsSegHandler();
            handler.createProsSegRecord(trigger.new);       
        }   
    }
    for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses) {
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }
    
    //Automatic create of Pros Seg record for SG record types
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG')){
        ASI_CRM_AccountCreateProsSegHandler handler = new ASI_CRM_AccountCreateProsSegHandler();
        handler.createProsSegRecord(trigger.new);    
    }
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_Potential_Outlet') || 
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_SG_Outlet')) {
        List<ASI_CRM_SG_TriggerAbstract> ASI_CRM_SG_triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
            new ASI_CRM_SG_UpdateChildOutletTypeHandler()
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : ASI_CRM_SG_triggerClasses) {
            triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    
    //Automatic create of Pros Seg record for VN record types
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN')){
        ASI_CRM_VN_AccCreateProsSegHandler handler = new ASI_CRM_VN_AccCreateProsSegHandler();
        handler.createProsSegRecord(trigger.new);    
    }
    
    //Automatically create PROS SEG RECORDS FOR my record types:
    for(ASI_CRM_AccountsAdditionalField__c MY_Cust:  Trigger.new){
        if(My_Cust.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet')){
            ASI_CRM_MY_CustomerList.add(My_Cust);
        }
    }
    if(ASI_CRM_MY_CustomerList.size()>0){
        ASI_CRM_MY_AccountCreateProsSegHandler.createProsSegRecord(ASI_CRM_MY_CustomerList);
    }
    
}