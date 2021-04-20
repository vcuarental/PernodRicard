/**
 [Ceterna Nov 2020 V1.0] - Passed NotUseRebateType as false to use rebateType always
*/
trigger ASI_CRM_Credit_Debit_Note_AfterInsert on ASI_CRM_Credit_Debit_Note__c (After insert) {
    system.debug('@#debugtrigger.new[0].recordtypeid'+trigger.new[0].recordtypeid);
    system.debug('@#debugtrigger.new.size()'+trigger.new.size());
    
    if ((trigger.new.size() == 1 && (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Credit_Note')))
        || Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Wholesaler_Debit_Note')
        ){
            System.debug('@#itshere'+trigger.new.size());
            /*[Ceterna Nov 2020 V1.0]  Starts*/
            ASI_CRM_SG_CreditNote_TriggerClass.CreateCreditNoteItemDetail(trigger.new, false, false);
            /*[Ceterna Nov 2020 V1.0]  Ends*/
    }
    ASI_CRM_SG_CreditNote_TriggerClass.createFWOCreditNote(trigger.new);
    // ASI_CRM_SG_CreditNote_TriggerClass.CreateCreditNoteItemDetail1(trigger.new);
}