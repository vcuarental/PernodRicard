trigger ASI_eForm_Vendor_Form_BeforeInsert on ASI_eForm_Vendor_Form__c (before insert) {
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_SG_Vendor_Form')){
        ASI_eForm_SG_Vendor_Form_TriggerClass.retrieveExchangeRate(trigger.new, null);
        ASI_eForm_SG_Vendor_Form_TriggerClass.duplicateBRNumberCheck(trigger.new, null);
    }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_KR')){
        ASI_eForm_KR_Vendor_Form_TriggerClass.routineBeforeUpsert(trigger.new, Null); 
    }else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form')
             && !Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_eForm_HK_Vendor_Form_Archived')
            
            ){
                
                ASI_eForm_HK_VendorForm_TriggerClass.beforeInsertFunction(trigger.new);
            }
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordtypeid).DeveloperName.contains('ASI_CRM_CN_VA')){
        ASI_CRM_CN_VA_VendorForm_TriggerClass.beforeInsertFunction(trigger.new); 
    }
}