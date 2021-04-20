trigger ASI_CRM_CN_AntiBribery_BeforeInsert on ASI_CRM_Anti_Bribery__c (Before Insert) {
    
    ASI_CRM_CN_AntiBriberyTriggerClass.entryCriteriaCheck(trigger.new, null);
    
}