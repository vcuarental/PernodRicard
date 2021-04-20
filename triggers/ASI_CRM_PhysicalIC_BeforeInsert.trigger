trigger ASI_CRM_PhysicalIC_BeforeInsert on ASI_CRM_Physical_Inventory_Check__c (before insert) {
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
         ASI_CRM_CN_PhysicalIC_TriggerClass.beforeUpsert(trigger.new, trigger.newmap);
     }
    
}