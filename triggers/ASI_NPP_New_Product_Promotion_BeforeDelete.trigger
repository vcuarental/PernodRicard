trigger ASI_NPP_New_Product_Promotion_BeforeDelete on ASI_NPP_New_Product_Promotion__c (before delete) {
    if(Global_RecordTypeCache.getRt(trigger.old[0].RecordTypeId).DeveloperName.contains('ASI_NPP_SG')){
        ASI_NPP_NewProductPromotion_TriggerClass.validateStatusBeforeDelete(trigger.old);
    }
}