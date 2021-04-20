trigger ASI_eForm_Vendor_Form_Lines_BeforeInsert on ASI_eForm_Vendor_Form_Line_Item__c (Before Insert) {
    if ( trigger.new[0].recordtypeid!=null && Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Line')){
        ASI_eForm_HK_VendorFormLinesTriggerClass.beforeInsertFunction(trigger.new);
    }
}