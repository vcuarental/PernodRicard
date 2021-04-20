trigger ASI_BRD_Generic_Account_BeforeInsert on Account(before insert) {
    List<ASI_BRD_Generic_TriggerAbstract> ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract>();
    
    // Laputa Vincent Lam 20161103: check record type is null
    if (trigger.new[0].recordTypeid != null){
        //Assign recordtype for lead conversion
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_')){ 
            ASI_BRD_Generic_triggerClasses = new List<ASI_BRD_Generic_TriggerAbstract> {   
                new ASI_BRD_Generic_AccountAssignRT()
            };
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_BRD_Generic')|| 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Brand_CRM')){   
            ASI_BRD_Generic_triggerClasses.add(new ASI_BRD_Generic_AssignAutoNumber());
            // DC - 03/25/2016 - Moved this call to AfterInsert trigger as we need the record Id to associate territories.
            // We need to put record Id in ObjectId field of ObjectTerritory2Association object in order to associate.
            // ASI_BRD_Generic_triggerClasses.add(new ASI_BRD_Generic_AccountTerritory());
            ASI_BRD_Generic_triggerClasses.add(new ASI_BRD_Generic_AccountDeduplicate());
            ASI_BRD_Generic_triggerClasses.add(new ASI_BRD_Generic_ValidateCampaign());
        }
        
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_LUX')|| 
                Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_Luxury')){    
            ASI_BRD_Generic_triggerClasses.add(new ASI_BRD_Generic_AccountDeduplicate());
        }
        
        for (ASI_BRD_Generic_TriggerAbstract triggerClass : ASI_BRD_Generic_triggerClasses){
            triggerClass.executeTriggerAction(ASI_BRD_Generic_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        }  
    }     
}