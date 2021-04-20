trigger ASI_NPP_New_Product_Promotion_AfterUpdate on ASI_NPP_New_Product_Promotion__c (after update) {

     ID SGrectypeid = Schema.SObjectType.ASI_NPP_New_Product_Promotion__c.getRecordTypeInfosByName().get('SG New Product or Promotion').getRecordTypeId();
    if(trigger.new[0].RecordTypeId == SGrectypeid )
    {
        // prevent from entering dead loop
        List<ASI_NPP_New_Product_Promotion__c> newList = new List<ASI_NPP_New_Product_Promotion__c>();
        for (ASI_NPP_New_Product_Promotion__c acc: Trigger.new) {
            ASI_NPP_New_Product_Promotion__c oldAccount = Trigger.oldMap.get(acc.ID);
            if(acc != oldAccount) {
                newList.add(acc);
            }
        } 
        ASI_NPP_NewProductPromotion_TriggerClass.PnLCalculationAfterInsert(newList);
    }
}