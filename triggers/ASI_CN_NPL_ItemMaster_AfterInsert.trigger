trigger ASI_CN_NPL_ItemMaster_AfterInsert on ASI_CN_NPL_Item_Master__c (after insert) {

String recordType = Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName;

if (trigger.new[0].RecordTypeId != null && (recordType == 'ASI_CN_NPL_Item_Master_TypeA' || recordType == 'ASI_CN_NPL_Item_Master_TypeB')){
    ASI_NPL_CN_ItemMasterTriggerAbstract triggerClass = new ASI_NPL_CN_ItemMasterTriggerAbstract();
    triggerClass.executeAfterInsertTriggerAction(trigger.new);
}
}