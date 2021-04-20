trigger ASI_eForm_Vendor_Form_Lines_BeforeDelete on ASI_eForm_Vendor_Form_Line_Item__c (before delete) {
    
    if (trigger.old[0].recordtypeid!=null  &&  Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Line')){
        ASI_eForm_HK_VendorFormLinesTriggerClass.beforeDeleteFunction(trigger.old);
    }
}