trigger ASI_BRD_Generic_Account_AfterUpdate on Account(after update) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
    
    // Laputa Vincent Lam 20161103: check record type is null
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD_Generic') || 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Brand_CRM')){  
            ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {
                new ASI_BRD_Generic_AccountUncheckIgnore()
            }; 
        }      
        
        for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
            triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        } 
    }      
}