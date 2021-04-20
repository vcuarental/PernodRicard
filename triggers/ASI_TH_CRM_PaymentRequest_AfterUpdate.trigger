trigger ASI_TH_CRM_PaymentRequest_AfterUpdate on ASI_TH_CRM_PaymentRequest__c (after update) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')){
      List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
          new ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr()        
      };
      
      for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
          triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
      } 
       if(trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
              ASI_CRM_CN_Heavy_PR_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);
       
         }else{
              ASI_CRM_CN_PaymentRequest_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldMap);   
         }
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request') ||
                  trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')){
          ASI_CRM_PH_PaymentRequest_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);
    }
    // 20160407 Laputa Vincent created
    else if(trigger.new[0].recordTypeid != NULL && 
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_Payment_Request')){
                
                List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> {
                    new ASI_CRM_SG_CalculateROIinTrigger()
                        };
                            
                            for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) {
                                triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newmap, trigger.oldmap);
                            }
            }
    
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_Payment_Request') ){
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineAfterUpsert(trigger.new);
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineAfterUpdate(trigger.new, trigger.oldmap);
    }
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')
      && Trigger.new[0].ASI_CRM_CN_Promotion_Type__c == 'Promotion' && Trigger.new[0].ASI_CRM_CN_TP_Is_Trade_Plan_CN__c == true){
      ASI_CRM_CN_TP_PaymentRequest_TriggerCls.routineAfterUpsert(Trigger.new, Trigger.oldMap);
    }
    
}