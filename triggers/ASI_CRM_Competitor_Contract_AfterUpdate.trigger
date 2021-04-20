trigger ASI_CRM_Competitor_Contract_AfterUpdate on ASI_CRM_Competitor_Contract__c (after update) {
      
    //create a list of contracts in trigger_new
    list<ASI_CRM_Competitor_Contract__c> trigger_new = new list<ASI_CRM_Competitor_Contract__c>();
    
    //loop through contracts, 
    for(ASI_CRM_Competitor_Contract__c e :trigger.new) {
        if(e.recordtypeid != null && Global_RecordTypeCache.getRt(e.RecordTypeId).DeveloperName.startsWith('ASI_CRM_CN_Competitor_Contract'))
            trigger_new.add(e);
    }
    
    if(trigger_new.size()>0)
       ASI_CRM_Competitor_Contract_TriggerClass.routineAfterInsertAfterUpdate(trigger_new);
}