trigger ASI_CRM_SKUMapping_BeforeUpdate on ASI_CRM_SKU_Mapping__c (before update) {
   if(trigger.new[0].recordTypeid != NULL){
        /*if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_HK_EDI_Item_Group_Mapping')){
            ASI_CRM_HK_SKUMapping_TriggerClass.routineBeforeUpsertItemGroup(trigger.new, trigger.oldMap);
        }
		else */
		if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_HK_EDI_SKU_Mapping')){
            ASI_CRM_HK_SKUMapping_TriggerClass.routineBeforeUpdateSKU(trigger.new, trigger.oldMap);
        }
    }
}