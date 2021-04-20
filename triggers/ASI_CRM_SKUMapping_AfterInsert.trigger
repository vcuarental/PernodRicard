trigger ASI_CRM_SKUMapping_AfterInsert on ASI_CRM_SKU_Mapping__c (after insert) {
	if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_HK_EDI_Item_Group_Mapping')){
            ASI_CRM_HK_SKUMapping_TriggerClass.routineAfterInsertItemGroup(trigger.new, null);
        }
    }
}