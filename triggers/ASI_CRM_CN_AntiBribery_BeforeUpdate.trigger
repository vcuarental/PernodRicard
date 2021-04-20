trigger ASI_CRM_CN_AntiBribery_BeforeUpdate on ASI_CRM_Anti_Bribery__c (Before Update) {
    
    ASI_CRM_CN_AntiBriberyTriggerClass.entryCriteriaCheck(trigger.new, trigger.oldMap);
    
}