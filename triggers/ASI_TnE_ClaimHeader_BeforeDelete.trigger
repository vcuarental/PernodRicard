trigger ASI_TnE_ClaimHeader_BeforeDelete on ASI_TnE_ClaimHeader__c (before delete) {

  Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select id from recordType 
        where sobjectType = 'ASI_TnE_ClaimHeader__c' and developerName like '%ASI_JP_TnE%']);
  
Id profileId=userinfo.getProfileId();
String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    List<ASI_TnE_ClaimHeader__c> validClaimHeaders = new List<ASI_TnE_ClaimHeader__c>();
       
    for (ASI_TnE_ClaimHeader__c claimHeader : Trigger.oldMap.values())
    {         
     if (recordTypeMap.containsKey(claimHeader.recordTypeId)) {    
        
        
        
        validClaimHeaders.add(claimHeader);
     }       
    }  
    
    if(validClaimHeaders.size()>0)
    {
        ASI_JP_TnE_ClaimHeaderTriggerClass.validateClaimHeaderStatus(validClaimHeaders, Trigger.newMap, Trigger.oldMap);     
    }
    
    

    /* Calling beforeDeleteMethod method which will adjust the Amount of PO when Claim Details related to
     * a Claim Header are deleted.
     */
    //VKWOK@2016/06/02 Applies re-calculation logic for TH TnE Records
    if(Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_TnE_TW') || 
       Global_RecordTypeCache.getRt(trigger.old[0].recordTypeid).developerName.contains('ASI_TnE_TH')){
        ASI_TnE_TW_ClaimHeaderTriggerClass.beforeDeleteMethod(trigger.oldMap);
    }
    
    List<ASI_TnE_TriggerAbstract> ASI_TnE_triggerClasses = new List<ASI_TnE_TriggerAbstract>();

    for (ASI_TnE_TriggerAbstract triggerClass : ASI_TnE_triggerClasses){
        triggerClass.executeTriggerAction(ASI_TnE_TriggerAbstract.TriggerAction.BEFORE_DELETE, null, null, trigger.oldMap);
    }
   
}//End ASI_TnE_ClaimHeader_BeforeDelete Trigger