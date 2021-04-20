trigger ASI_TH_CRM_Contract_AfterDelete on ASI_TH_CRM_Contract__c (after delete) {
    // Added by Michael Yip (Introv) 03Jul2014 for CRM CN
    if (trigger.old[0].RecordTypeId != null && trigger.old[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')){
        ASI_CRM_CN_Contract_TriggerClass.routineAfterDelete(trigger.old);
    }
    
}