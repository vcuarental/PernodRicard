trigger ASI_MFM_SKU_Code_BeforeInsert on ASI_MFM_SKU_Code__c (before insert) {
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_HK_CRM_SKU')){
        ASI_FOC_HK_SKU_TriggerClass.routineBeforeUpsert(trigger.new, null);
    }
    //CN RecordType : ASI_FOC_CN_POSM_SKU
    else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_FOC_CN_POSM_SKU')){
        ASI_MFM_CN_SKU_TriggerClass.beforeInsertMedthod(trigger.new);
    }
    
    //MY Record Type(201801 By Introv):
    List<ASI_MFM_SKU_Code__c> MY_SKUs = new List<ASI_MFM_SKU_Code__c>();
    for(ASI_MFM_SKU_Code__c sku: Trigger.New){
        if(sku.recordTypeId ==Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')){
            MY_SKUs.add(sku);
        }
    }
    if(MY_SKUs.size()>0){
        ASI_CRM_MY_SKU_TriggerClass.routineBeforeInsert(MY_SKUs);
    }
}