trigger ASI_eForm_Vendor_Form_Lines_BeforeUpdate on ASI_eForm_Vendor_Form_Line_Item__c (before Update) {
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Line')){
        ASI_eForm_HK_VendorFormLinesTriggerClass.beforeUpdateFunction(trigger.new, trigger.oldMap);
    }
}