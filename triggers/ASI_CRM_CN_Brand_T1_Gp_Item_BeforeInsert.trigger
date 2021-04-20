trigger ASI_CRM_CN_Brand_T1_Gp_Item_BeforeInsert on ASI_CRM_CN_Brand_T1_Group_Item__c (Before insert,Before update) {
/*ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass brand_items = new ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass();
brand_items.check_duplication(trigger.new);*/

    //2014-07-29 Stella Sing Add check CN record type before running method
    id CN_RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_T1_Group_Item__cASI_CRM_CN_Brand_T1_Group_Item');
    list<ASI_CRM_CN_Brand_T1_Group_Item__c> CN_List = new list<ASI_CRM_CN_Brand_T1_Group_Item__c>();
    
    for (ASI_CRM_CN_Brand_T1_Group_Item__c a : trigger.new){
        if (a.RecordTypeId == CN_RecordTypeId)
            CN_List.add(a);
    }
    if (CN_List.size() > 0){
        ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass brand_items = new ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass();
        brand_items.check_duplication(CN_List);
    }

}