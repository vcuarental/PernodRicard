trigger ASI_MFM_SKU_Code_AfterInsert on ASI_MFM_SKU_Code__c (After Insert) {   
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_FOC_CN_SKU')){
        ASI_MFM_CN_SKU_TriggerClass.afterInsertMethod(trigger.new);
    }
	else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_HK_CRM_SKU')){
		ASI_FOC_HK_SKU_TriggerClass.routineAfterInsert(trigger.new);
	}

    // DC - 04/01/2016 - For SG CRM P2, create Wholesaler Depletion records on creation of SKU records.
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG_SKU')) {        
        // 20160408: does not need this currently
        /*
        List<ASI_CRM_SG_TriggerAbstract> lstSgCrmClasses = new List<ASI_CRM_SG_TriggerAbstract>();
        lstSgCrmClasses.add(new ASI_CRM_SG_GenWholesalerDepletion());

        for(ASI_CRM_SG_TriggerAbstract triggerAbstract : lstSgCrmClasses) {
            triggerAbstract.executeTriggerAction(ASI_CRM_SG_TriggerAbstract.TriggerAction.AFTER_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
        }
        */
    }

    //MY Record Type(201801 By Introv):
    List<ASI_MFM_SKU_Code__c> MY_SKUs = new List<ASI_MFM_SKU_Code__c>();
    List<ASI_MFM_SKU_Code__c> CN_POSM_SKUs = new List<ASI_MFM_SKU_Code__c>();
    
    for(ASI_MFM_SKU_Code__c sku: Trigger.New){
        if(sku.recordTypeId ==Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')){
            MY_SKUs.add(sku);
        }
		else if(sku.recordTypeId ==Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')){
            CN_POSM_SKUs.add(sku);
        }
    }
	
    if(MY_SKUs.size()>0){
        ASI_CRM_MY_SKU_TriggerClass.routineAfterInsert(MY_SKUs);
    }
    
    if(CN_POSM_SKUs.size() > 0)
        ASI_MFM_CN_SKU_TriggerClass.afterInsertMethodPOSM(CN_POSM_SKUs);
}