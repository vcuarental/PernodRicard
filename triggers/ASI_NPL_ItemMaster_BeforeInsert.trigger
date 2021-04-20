trigger ASI_NPL_ItemMaster_BeforeInsert on ASI_CN_NPL_Item_Master__c (before insert) {
    
	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_NPL')){
        ASI_NPL_CN_ItemMasterTriggerAbstract.beforeInsertMethod(trigger.new);
    }
    
}