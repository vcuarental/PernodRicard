trigger ASI_TnE_ClaimDetail_BeforeInsert on ASI_TnE_ClaimDetail__c (before insert) {

     if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_JP_TnE'))
        ASI_JP_TnE_ClaimDetailTriggerClass.routineBeforeUpsert(trigger.new, Trigger.oldMap);     
    
    else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_TnE_VN'))
         ASI_TnE_ClaimDetailTriggerClass.routineBeforeUpsert(trigger.new,null);
    

         
    List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_KH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_ID_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_PH_Claim_Detail') ||
            Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_MY_Claim_Detail') ){
        
        
        ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract> { 
            new ASI_TnE_AssignAutoNumber_ClaimDetail(),
            new ASI_TnE_ClaimsDetailCalcTax(),
            new ASI_TnE_ClaimsDetailGenAccountNo(),
            new ASI_TnE_ClaimsDetailValidatePO()
        };                    
    } 
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TW_Claim_Detail')){
        ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract> {
            new ASI_TnE_TW_CalPaymentAmount(),
            new ASI_TnE_ClaimsDetailCalcTax(),
            new ASI_TnE_ClaimsDetailGenAccountNo(),
            new ASI_TnE_TW_ClaimsDetailValidation(),
            //new ASI_TnE_TW_ClaimsDetailValidatePlan(),
            new ASI_TnE_GnH_TW_ClaimsDetailValidation()
        }; 
    }
    
    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        
    }            
}