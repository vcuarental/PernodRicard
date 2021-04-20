trigger ASI_eForm_Vendor_Form_Attachment_AfterDelete on ASI_eForm_Vendor_Form_Attachment__c (After Delete) {
    
    if (Global_RecordTypeCache.getRt(trigger.old[0].recordTypeId).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Attachment')){
        ASI_eForm_HK_VendorForm_Attac_TriggerCls.afterDelete(trigger.old);
    }
}