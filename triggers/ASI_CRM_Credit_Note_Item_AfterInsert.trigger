trigger ASI_CRM_Credit_Note_Item_AfterInsert on ASI_CRM_Credit_Debit_Note_Line_Item__c (after Insert) {

    if(trigger.new[0].RecordTypeId == Schema.SObjectType.ASI_CRM_Credit_Debit_Note_Line_Item__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_SG_Wholesaler_Credit_Debit_Note').getRecordTypeId()){
        ASI_CRM_SG_CreditNoteItem_TriggerClass.updateItemDetails(trigger.new);
    }
    
}