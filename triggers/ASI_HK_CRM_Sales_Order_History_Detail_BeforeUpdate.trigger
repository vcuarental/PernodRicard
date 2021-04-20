trigger ASI_HK_CRM_Sales_Order_History_Detail_BeforeUpdate  on ASI_HK_CRM_Sales_Order_History_Detail__c  (before update){
    if(trigger.new[0].recordTypeid != NULL){
        if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_SG')){
            ASI_CRM_SG_SOHistoryDetail_TriggerCls.routineBeforeUpsert(trigger.New, trigger.oldMap);
        }
    }
}