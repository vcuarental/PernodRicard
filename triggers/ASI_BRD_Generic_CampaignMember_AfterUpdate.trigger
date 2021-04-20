trigger ASI_BRD_Generic_CampaignMember_AfterUpdate on CampaignMember (after update) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
       
    if(trigger.new[0].recordTypeid != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_LUX_Regional')){    
        ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {   
            new ASI_BRD_Generic_CalcAttendedEvents()
        };
    }
    
    for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
        triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    } 
}