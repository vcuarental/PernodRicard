trigger ASI_eForm_Vendor_Form_BeforeUpdate on ASI_eForm_Vendor_Form__c (before update) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_SG_Vendor_Form')){
        
        ASI_eForm_SG_Vendor_Form_TriggerClass.retrieveExchangeRate(trigger.new, trigger.oldMap);
        ASI_eForm_SG_Vendor_Form_TriggerClass.assignHODApproval(trigger.new, trigger.oldMap);
		ASI_eForm_SG_Vendor_Form_TriggerClass.prefillReviseInformation(trigger.new, trigger.oldMap);
		ASI_eForm_SG_Vendor_Form_TriggerClass.duplicateBRNumberCheck(trigger.new, trigger.oldMap);
        
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_KR')) {
       // ASI_eForm_KR_Vendor_Form_TriggerClass.routineBeforeUpsert(trigger.new, Trigger.oldMap); 
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form')
             && !Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Archived')
             && !Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Webform')
            ){
        
        ASI_eForm_HK_VendorForm_TriggerClass.beforeUpdateFunction(trigger.new, trigger.newMap, trigger.oldMap);
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_CN_VA')){
        ASI_CRM_CN_VA_VendorForm_TriggerClass.beforeUpdateFunction(trigger.new, trigger.oldMap); 
    }
}