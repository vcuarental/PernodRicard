trigger ASI_TH_CRM_PaymentRequest_BeforeUpdate on ASI_TH_CRM_PaymentRequest__c (before update) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request')){
        //added by Kevani Chow @Introv 13-05-2016
        ASI_TH_CRM_PaymentRequest_TriggerCls.routineBeforeUpsert(trigger.New, trigger.oldMap);
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')){
        if(trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On' || trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='TOT/MOT Contract'
            || trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='Wholesaler Promotion'
            || trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='Outlet Promotion'
            || trigger.new[0].ASI_CRM_CN_Promotion_Type__c=='Consumer Promotion'){
            //ASI_CRM_CN_Heavy_PR_TriggerCls.routineAfterInsert(trigger.new);
            ASI_CRM_CN_Heavy_PR_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
        }else{
           ASI_CRM_CN_PaymentRequest_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
        }
        
        
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request')){
        ASI_CRM_PH_PaymentRequest_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        // added by Calvin (LAPUTA) 14-01-2019
        ASI_CRM_PH_PaymentRequest_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }	
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request')){
        List<ASI_CRM_SG_TriggerAbstract> triggerClasses = new List<ASI_CRM_SG_TriggerAbstract> { new ASI_CRM_SG_AssignInvoiceNumber_Payment()        
        };
        
        for (ASI_CRM_SG_TriggerAbstract triggerClass : triggerClasses) { triggerClass.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_')){ if(!Test.isRunningTest())ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldMap);
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineBeforeUpsert(trigger.New);
    }
}