trigger ASI_NPP_New_Product_Promotion_BeforeInsert on ASI_NPP_New_Product_Promotion__c (before insert) {
     ID SGrectypeid = Schema.SObjectType.ASI_NPP_New_Product_Promotion__c.getRecordTypeInfosByName().get('SG New Product or Promotion').getRecordTypeId();
    if(trigger.new[0].RecordTypeId == SGrectypeid )
    {
        ASI_NPP_NewProductPromotion_TriggerClass.SetSGAutoNumber(trigger.new);
        ASI_NPP_NewProductPromotion_TriggerClass.GetCalculationBase(trigger.new);
        ASI_NPP_NewProductPromotion_TriggerClass.SetAssessmentBox(trigger.new);
        ASI_NPP_NewProductPromotion_TriggerClass.GetPrismaCode(trigger.new);
        //ASI_NPP_NewProductPromotion_TriggerClass.PnLCalculation(trigger.new);
        ASI_NPP_NewProductPromotion_TriggerClass.setSubBrandBudgetVolume(trigger.new, null);

        //20170512 Wilken CHM114427152 Add Reporting Currency Exchange Rate conversion
        ASI_NPP_NewProductPromotion_TriggerClass.setReportingCurrToBaseCurrExRate(trigger.new);

        //20170512 Wilken CHM114427152 Assign approver based on market
        ASI_NPP_NewProductPromotion_TriggerClass.assignApprover(trigger.new, trigger.oldMap);
        
    }
}