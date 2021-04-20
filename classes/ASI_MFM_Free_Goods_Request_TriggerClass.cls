public without sharing class ASI_MFM_Free_Goods_Request_TriggerClass {
    
    Private Static Final String CN_JCT_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_CN_JCT_FGL_IBD__cASI_MFM_CN_POSM');
    Private Static Final String CN_REQ_ITEM_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
    
	public static void beforeUpdateFunction(list<ASI_FOC_Free_Goods_Request__c> trigger_new, map<id, ASI_FOC_Free_Goods_Request__c> trigger_oldMap) {
        Set<Id> freeGoodsReqIdSet = new Set<Id>();
        for(ASI_FOC_Free_Goods_Request__c fgReq : trigger_new) {
            freeGoodsReqIdSet.add(fgReq.Id);
        }
	    List<ASI_MFM_CN_JCT_FGL_IBD__c> updateJCTList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
        for(ASI_MFM_CN_JCT_FGL_IBD__c jctObj :[SELECT id, name,ASI_MFM_RequestQty__c ,ASI_MFM_Request_Status__c, ASI_MFM_FG_Quantity__c , ASI_MFM_FreeGoodsRequestStatus__c 
                                               FROM ASI_MFM_CN_JCT_FGL_IBD__c 
                                               WHERE recordTypeId = :CN_JCT_RECORD_TYPE_ID 
                                               //AND ASI_MFM_Request_Item__r.recordTypeId = :CN_REQ_ITEM_RECORD_TYPE_ID 
                                               AND ASI_MFM_Request_Item__r.ASI_FOC_Request_Order__c IN :freeGoodsReqIdSet
                                              ]){
                                                  jctObj.ASI_MFM_RequestQty__c = jctObj.ASI_MFM_FG_Quantity__c;
                                                  //jctObj.ASI_MFM_Request_Status__c  = jctObj.ASI_MFM_FreeGoodsRequestStatus__c;
                                                  updateJCTList.add(jctObj);
        }
        if(updateJCTList.size()>0) {
            update updateJCTList;
        }
    }
}