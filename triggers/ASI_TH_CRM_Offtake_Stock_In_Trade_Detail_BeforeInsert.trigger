trigger ASI_TH_CRM_Offtake_Stock_In_Trade_Detail_BeforeInsert on ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c (before insert) {
    if(trigger.new[0].recordtypeid == Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail')){
        ASI_CRM_MO_OT_TriggerCls.routineBeforeInsert(trigger.new);
    }
}