trigger ASI_MFM_Item_Group_AfterUpdate on ASI_MFM_Item_Group__c (after update) {
	
    Set<String> CN_RT_SET = new Set<String>{Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group'), Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_Region'), Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_RO'), Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_RO_Region'), Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group')};
	List<ASI_MFM_Item_Group__c> CN_Item_Group = new List<ASI_MFM_Item_Group__c>();
    
    for(ASI_MFM_Item_Group__c obj : trigger.new){
        if(CN_RT_SET.contains(obj.recordTypeId)){
            CN_Item_Group.add(obj);
        }
    }
    
    if(CN_Item_Group.size() > 0){
        ASI_MFM_CN_ItemGroup_TriggerClass.afterUpdateFunction(CN_Item_Group, trigger.oldMap);
    }
    
    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_HK_CRM_Item_Group')){
		ASI_MFM_HK_Item_Group_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap);       
    }
}