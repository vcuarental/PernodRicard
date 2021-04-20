trigger ASI_FOC_Free_Goods_Request_BeforeInsert on ASI_FOC_Free_Goods_Request__c (before insert) {
    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
            //2019/11/6 CanterDuan start
            ASI_FOC_Free_Goods_Request_TriggerClass.GetTaxRate(trigger.new);
            //2019/11/6 CanterDuan end
            ASI_FOC_Free_Goods_Request_TriggerClass.routineBeforeInsert(trigger.new);
            ASI_FOC_Free_Goods_Request_TriggerClass.routineBeforeUpsert(trigger.new,trigger.oldMap);
        }
        else if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_HK')){
            ASI_FOC_HK_Request_TriggerClass.routineBeforeUpsert(trigger.new,trigger.oldMap);
            
             List<ASI_HK_CRM_TriggerAbstract> triggerClasses = new List<ASI_HK_CRM_TriggerAbstract> {
                 new ASI_CRM_HK_FreeGoodsRequestFindAR()
             };
            for (ASI_HK_CRM_TriggerAbstract triggerClass : triggerClasses) {
                triggerClass.executeTriggerAction(ASI_HK_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, null, null);
            }
            
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_FOC_MY_')){
            ASI_CRM_MY_FreeGoodsRequest_TriggerCls.routineBeforeInsert(trigger.New);
        }   
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.routineBeforeInsert(trigger.New);
        }
    }
}