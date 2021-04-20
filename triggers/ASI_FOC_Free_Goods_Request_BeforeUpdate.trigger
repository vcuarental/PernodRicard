trigger ASI_FOC_Free_Goods_Request_BeforeUpdate on ASI_FOC_Free_Goods_Request__c (before update) {
    // 20181128 @Introv update for POSM start
    Private Static Final String CN_POSM_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
    Private Static Final String CN_POSM_READONLY_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
    List<ASI_FOC_Free_Goods_Request__c> CN_POSM_List = new List<ASI_FOC_Free_Goods_Request__c>();
    for(ASI_FOC_Free_Goods_Request__c obj : trigger.new){
        if(obj.recordTypeId == CN_POSM_RECORD_TYPE_ID || obj.recordTypeId == CN_POSM_READONLY_RECORD_TYPE_ID){
            CN_POSM_List.add(obj);
        }
    }
    if(CN_POSM_List.size() > 0){
        ASI_MFM_Free_Goods_Request_TriggerClass.beforeUpdateFunction(CN_POSM_List, trigger.oldMap);
    }
    // 20181128 @Introv update for POSM end

    if(trigger.new[0].recordTypeId != NULL){
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_CN')){
            ASI_FOC_Free_Goods_Request_TriggerClass.routineBeforeUpsert(trigger.new,trigger.oldMap);
            ASI_FOC_Free_Goods_Request_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
        }
        
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_HK')){
            ASI_FOC_HK_Request_TriggerClass.routineBeforeUpdate(trigger.new, trigger.oldMap);
            ASI_FOC_HK_Request_TriggerClass.routineBeforeUpsert(trigger.new, trigger.oldMap);
        }
        
        if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_FOC_MY')){
            ASI_CRM_MY_FreeGoodsRequest_TriggerCls.routineBeforeUpdate(trigger.new, trigger.oldMap);
        }
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TW')){
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.routineBeforeUpsert(trigger.New, trigger.oldMap);
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.routineBeforeUpdate(trigger.New, trigger.oldMap);
            //Michael Add 2019/09/12
            // H1 command for e approval deployment
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.SetDeliveryInstruction(trigger.New, null);
            ASI_CRM_TW_FreeGoodsRequest_TriggerCls.SetReceiver(trigger.New, null);
        }
        //20191204:AM@introv - urgent fix to merge B5 logic, will uncomment after package generation
		/*
        else if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_TH') || Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_MFM_TH_FOC')){
            ASI_FOC_TH_Free_Goods_Request_TriggerCls.routineBeforeUpsert(trigger.New, trigger.oldMap);
        }
		*/
    }
}