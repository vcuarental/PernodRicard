trigger ASI_TnE_ClaimHeader_BeforeUpdate on ASI_TnE_ClaimHeader__c (before update) {
 
  Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select id, name, developerName from recordType 
        where sobjectType = 'ASI_TnE_ClaimHeader__c' and developerName like '%ASI_JP_TnE%']);
  
    List<ASI_TnE_ClaimHeader__c> validClaimHeaders = new List<ASI_TnE_ClaimHeader__c>();

       
    for (ASI_TnE_ClaimHeader__c claimHeader : Trigger.new)
    {         
     if (recordTypeMap.containsKey(claimHeader.recordTypeId)) {    
        validClaimHeaders.add(claimHeader);
     }        
    }  
    
    if(validClaimHeaders.size()>0)
    {
        ASI_JP_TnE_ClaimHeaderTriggerClass.updateClaimHeaderDueDateMapping(validClaimHeaders, Trigger.newMap, Trigger.oldMap, 
        recordTypeMap,true);     
    }
    
    //For Vietnam TnE
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_TnE_VN'))
        ASI_TnE_ClaimHeaderTriggerClass.routineBeforeUpsert(trigger.new, null);

    //For TnE Sea
    List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();
    
    if(//Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK') ||
       //Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_HK_Claim_Header_Finance') || //20180503 Introv Commented, HK T&E was moved to Concur System
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_SG') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_SG_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_KH') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_KH_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TH') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TH_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_PH') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_PH_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_ID') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_ID_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_MY') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_MY_Claim_Header_Finance') ||
       Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_TnE_TW')){
        ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract> { 
            new ASI_TnE_ClaimsHeaderApprovalProcess()
        };                    
    } 
    
    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
 
}