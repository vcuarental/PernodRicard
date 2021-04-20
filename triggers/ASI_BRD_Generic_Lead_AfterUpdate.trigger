trigger ASI_BRD_Generic_Lead_AfterUpdate on Lead (after update) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD') ||
         Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_LUX')){
         ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {            
            new ASI_BRD_Generic_LeadConversion()
         };                    
    }     
    
    for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
        triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }       
}