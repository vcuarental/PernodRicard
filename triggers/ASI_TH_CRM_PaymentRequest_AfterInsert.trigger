trigger ASI_TH_CRM_PaymentRequest_AfterInsert on ASI_TH_CRM_PaymentRequest__c (after insert) {
    // Modified by Michael Yip (Introv) 26Apr2014 Separate trigger class by recordtype, assume same record type for all records in trigger.new 
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request')){
        
    }
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')){
        
        if((new Set<String>{'Heavy Contract On', 'TOT/MOT Contract', 'Outlet Promotion', 'Wholesaler Promotion', 'Consumer Promotion'}).contains(trigger.new[0].ASI_CRM_CN_Promotion_Type__c)){
            ASI_CRM_CN_Heavy_PR_TriggerCls.routineAfterInsert(trigger.new);
        }else{
           ASI_CRM_CN_PaymentRequest_TriggerCls.routineAfterInsert(trigger.new); 
        }
        
    }
   
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_MY_Payment_Request')  ){
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineAfterInsert(trigger.new);
        ASI_CRM_MY_PaymentRequest_TriggerCls.routineAfterUpsert(trigger.new);
    }
    //Added by Laputa
    else if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_SG_CRM_Payment_Request')){
        
    }
}