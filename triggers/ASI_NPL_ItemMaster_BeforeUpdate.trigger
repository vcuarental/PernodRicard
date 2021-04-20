trigger ASI_NPL_ItemMaster_BeforeUpdate on ASI_CN_NPL_Item_Master__c (Before Update) {

	if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_NPL')){
		ASI_CRM_CN_NPLT1Price_triggerclass.beforeUpdateMethod(trigger.new);
        ASI_NPL_CN_ItemMasterTriggerAbstract.beforeUpdateMethod(trigger.new, trigger.oldmap);
    }
    
}