trigger ASI_KOR_Account_AfterUpdate on Account (after update){    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_KOR_Venue') ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_KOR_Wholesaler')){
        List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {new ASI_KOR_AccountAddressHandler()};
        
        for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
            if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_KOR_Venue') ||Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_KOR_Wholesaler'))
                triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
        }
    }
}