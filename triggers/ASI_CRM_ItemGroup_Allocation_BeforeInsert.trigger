trigger ASI_CRM_ItemGroup_Allocation_BeforeInsert on ASI_CRM_Item_Group_Allocation__c (Before Insert) {

    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_CN_Item_Group_Allocation')){
        
        ASI_CRM_CN_ItemGp_Allocation_TriggerCls.beforeInsertFunction(trigger.New);
    }
}