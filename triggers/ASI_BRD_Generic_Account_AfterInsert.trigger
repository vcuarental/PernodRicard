trigger ASI_BRD_Generic_Account_AfterInsert on Account(after insert) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
    
    // Laputa Vincent Lam 20161103: check record type is null
    if (trigger.new[0].recordTypeid != null){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD_Generic')|| 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Brand_CRM')){  
            ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {
                new ASI_BRD_Generic_AccountUncheckIgnore(),
                // DC - 03/25/2016 - Moved this call from BeforeInsert trigger. 
                // Please refer the BeforeInsert trigger for more info.
                new ASI_BRD_Generic_AccountTerritory()
            }; 
        }      
        
        for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
            triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }       
}