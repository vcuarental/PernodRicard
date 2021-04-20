trigger ASI_FOC_Free_Goods_Request_AfterInsert on ASI_FOC_Free_Goods_Request__c (after insert) {
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_MY_') ){
        ASI_CRM_MY_FreeGoodsRequest_TriggerCls.routineAfterUpsert(trigger.new);
    }
}