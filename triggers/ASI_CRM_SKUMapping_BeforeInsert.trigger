trigger ASI_CRM_SKUMapping_BeforeInsert on ASI_CRM_SKU_Mapping__c (before insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_HK_EDI_Item_Group_Mapping')){
        ASI_CRM_HK_SKUMapping_TriggerClass.routineBeforeInsertItemGroup(trigger.new);
    }
}