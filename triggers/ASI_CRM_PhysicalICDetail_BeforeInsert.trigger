trigger ASI_CRM_PhysicalICDetail_BeforeInsert on ASI_CRM_Physical_Inventory_Check_Item__c (before insert) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN')){
         ASI_CRM_CN_PhysicalICLI_TriggerCls.beforeUpsert(trigger.new, trigger.newmap);
     }

}