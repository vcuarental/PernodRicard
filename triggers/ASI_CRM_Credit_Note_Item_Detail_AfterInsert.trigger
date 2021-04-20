trigger ASI_CRM_Credit_Note_Item_Detail_AfterInsert on ASI_CRM_SG_Credit_Note_Item_Detail__c (after insert) {
    //2020-04-14 Ceterna: Created
    if (trigger.new[0].recordtypeid != null && Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Credit_Note_Item_Detail')){
        ASI_CRM_SG_CreditNoteDetail_TriggerClass.CreateCreditNoteItem(trigger.newMap);
    }
}