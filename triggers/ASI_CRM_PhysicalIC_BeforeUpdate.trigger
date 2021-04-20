trigger ASI_CRM_PhysicalIC_BeforeUpdate on ASI_CRM_Physical_Inventory_Check__c (before update) {

     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
         ASI_CRM_CN_PhysicalIC_TriggerClass.beforeUpsert(trigger.new, trigger.oldMap);
     }

}