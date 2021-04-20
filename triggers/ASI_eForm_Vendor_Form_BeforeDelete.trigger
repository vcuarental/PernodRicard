trigger ASI_eForm_Vendor_Form_BeforeDelete on ASI_eForm_Vendor_Form__c (before delete) {
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_eForm_SG_Vendor_Form'))
        ASI_eForm_SG_Vendor_Form_TriggerClass.validationBeforeDelete(trigger.old);
    else if(Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form')){
        
        ASI_eForm_HK_VendorForm_TriggerClass.beforeDeleteFunction(trigger.old);
    }else if(Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_CN_VA_Vendor_Form')){
        ASI_CRM_CN_VA_VendorForm_TriggerClass.beforeDeleteFunction(trigger.old);
    }
}