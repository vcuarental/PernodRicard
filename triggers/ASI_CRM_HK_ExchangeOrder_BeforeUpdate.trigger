trigger ASI_CRM_HK_ExchangeOrder_BeforeUpdate on ASI_CRM_Exchange_Order__c (before update) {
    //System.debug('Test3@@@@@' + Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName);
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order')){ 
        ASI_CRM_HK_ExchangeOrder_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
    }
    System.debug('DONE DONE------------' );
}