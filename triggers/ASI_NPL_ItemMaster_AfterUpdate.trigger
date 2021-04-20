trigger ASI_NPL_ItemMaster_AfterUpdate on ASI_CN_NPL_Item_Master__c (before update) {

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CN_NPL')){
        ASI_NPL_CN_ItemMasterTriggerAbstract.afterUpdateMethod(trigger.new, trigger.oldmap);
    }

}