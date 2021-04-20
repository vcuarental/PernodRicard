trigger ASI_CRM_CN_AntiBribery_AfterInsert on ASI_CRM_Anti_Bribery__c (After insert) {

    ASI_CRM_CN_AntiBriberyTriggerClass.AfterInsertMethod(trigger.new);
    
}