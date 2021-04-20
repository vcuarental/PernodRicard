trigger ASI_CRM_Inventory_Visibility_Junction_BeforeInsert on ASI_CRM_Inventory_Visibility_Junction__c (before insert) {
	if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_CN')){
            ASI_CRM_CN_Inventory_V_Junc_TriggerClass.routineBeforeInsert(trigger.new);
        }
    }
}