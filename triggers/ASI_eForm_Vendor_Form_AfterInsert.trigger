trigger ASI_eForm_Vendor_Form_AfterInsert on ASI_eForm_Vendor_Form__c (After Insert) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form') 
       && !Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Archived')
       && !Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Webform')){
        
        ASI_eForm_HK_VendorForm_TriggerClass.afterInsertFunction(trigger.new);
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_CN_VA')){
        ASI_CRM_CN_VA_VendorForm_TriggerClass.afterInsertFunction(trigger.new); 
    }
}