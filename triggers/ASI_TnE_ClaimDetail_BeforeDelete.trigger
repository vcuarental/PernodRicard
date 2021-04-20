trigger ASI_TnE_ClaimDetail_BeforeDelete on ASI_TnE_ClaimDetail__c (before delete) {

  Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select id from recordType 
        where sobjectType = 'ASI_TnE_ClaimDetail__c' and developerName like '%ASI_JP_TnE%']);
        
    Id profileId=userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

    List<ASI_TnE_ClaimDetail__c> validClaimDetails = new List<ASI_TnE_ClaimDetail__c>();
       
    for (ASI_TnE_ClaimDetail__c claimDetail : Trigger.oldMap.values())
    {         
         if (recordTypeMap.containsKey(claimDetail.recordTypeId)) {    
            validClaimDetails.add(claimDetail);
         }
     }
        
     if(validClaimDetails.size()>0)
     {
      ASI_TnE_JP_TnEDetailCheckDel.executeTrigger(validClaimDetails);
      ASI_JP_TnE_ClaimDetailTriggerClass.validateClaimDetailStatus(validClaimDetails);     
     }
    
    
    List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();
  
    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_DELETE, null, null, trigger.oldMap);
    }
}