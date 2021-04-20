trigger ASI_MFM_IBD_BeforeUpdate on ASI_MFM_InventoryBalanceDetail__c (before update) {

    Set<String> CN_RT_SET = new Set<String>{Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')};
    List<ASI_MFM_InventoryBalanceDetail__c> CN_IBD = new List<ASI_MFM_InventoryBalanceDetail__c>();
    
    for(ASI_MFM_InventoryBalanceDetail__c obj : trigger.new){
        if(CN_RT_SET.contains(obj.recordTypeId)){
            CN_IBD.add(obj);
        }
    }
    
    if(CN_IBD.size() > 0){
        ASI_MFM_CN_IBD_TriggerClass.beforeUpdateFunction(CN_IBD);
    }

}