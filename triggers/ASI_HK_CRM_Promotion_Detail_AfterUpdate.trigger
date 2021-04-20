/*********************************************************************************
 * Name:ASI_HK_CRM_Promotion_Detail_AfterUpdate
 * Description: After insert trigger for Promotion Detail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-06       Vincent Lam             Created
*********************************************************************************/
trigger ASI_HK_CRM_Promotion_Detail_AfterUpdate on ASI_HK_CRM_Promotion_Detail__c (after update) {
    List<ASI_HK_CRM_Promotion_Detail__c> list_SGPromotionDetail = new List<ASI_HK_CRM_Promotion_Detail__c>();
    
    for(ASI_HK_CRM_Promotion_Detail__c i : trigger.new){
        if(i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion_Detail__cASI_CRM_SG_Customer')){
            list_SGPromotionDetail.add(i);
        }
    }
    if(list_SGPromotionDetail.size()>0) ASI_CRM_SG_PromotionDetailService.getInstance().rollupToPromotion(list_SGPromotionDetail);
}