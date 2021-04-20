trigger ASI_BRD_Generic_Account_BeforeUpdate on Account(before update) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
    
    // Laputa Vincent Lam 20161103: check record type is null
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD_Generic') || 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Brand_CRM')){  
            ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {
                //new ASI_BRD_Generic_AccountUdOptIn(),
                new ASI_BRD_Generic_AccountTerritory(),
                new ASI_BRD_Generic_AccountDeduplicate(),
                new ASI_BRD_Generic_ValidateCampaign()
            }; 
        }  
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_LUX') || 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury')){   
            ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {
                new ASI_BRD_Generic_AccountDeduplicate()
            }; 
        }     
        
        for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
            triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }  
    }     
}