trigger ASI_MFM_Setting_AfterUpdate on ASI_MFM_Settings__c (after update) {
    
  if (trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_TW_Setting')){
        ASI_MFM_Setting__c customSetting = [select ASI_MFM_TW_Accrual_PO_Generation_Day__c, ASI_MFM_TW_Today__c from ASI_MFM_Setting__c limit 1];
        
        customSetting.ASI_MFM_TW_Accrual_PO_Generation_Day__c = trigger.new[0].ASI_MFM_TW_Accrual_PO_Generation_Day__c ;
        customSetting.ASI_MFM_TW_Today__c = trigger.new[0].ASI_MFM_TW_Today__c ;
        
        update customSetting;
    }
}