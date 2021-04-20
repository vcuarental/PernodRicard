trigger ASI_NPP_New_Product_Promotion_AfterInsert on ASI_NPP_New_Product_Promotion__c (after insert) {

     ID SGrectypeid = Schema.SObjectType.ASI_NPP_New_Product_Promotion__c.getRecordTypeInfosByName().get('SG New Product or Promotion').getRecordTypeId();
    if(trigger.new[0].RecordTypeId == SGrectypeid )
    {
        ASI_NPP_NewProductPromotion_TriggerClass.PnLCalculationAfterInsert(trigger.new);
      //  ASI_NPP_NewProductPromotion_TriggerClass.SetAssessmentBox(trigger.new);
        
    }
}