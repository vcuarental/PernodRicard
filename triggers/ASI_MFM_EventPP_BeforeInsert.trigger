trigger ASI_MFM_EventPP_BeforeInsert on ASI_MFM_Event_PP__c (before insert) {
	
    list<ASI_MFM_Event_PP__c> triggerNewCN = new list<ASI_MFM_Event_PP__c>();
    for(ASI_MFM_Event_PP__c eventPP: trigger.new)
        if(Global_RecordTypeCache.getRt(eventPP.RecordTypeId).developerName.startsWith('ASI_MFM_CN_'))
        	triggerNewCN.add(eventPP);
    
    if(triggerNewCN.size()>0)
        ASI_MFM_CN_EventPP_TriggerClass.routineBeforeInsert(triggerNewCN);
}