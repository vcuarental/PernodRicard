/*********************************************************************************
 * Name:ASI_HK_CRM_Promotion_AfterUpdate
 * Description: After insert trigger for Promotion
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-06       Vincent Lam             Created
*********************************************************************************/
trigger ASI_HK_CRM_Promotion_AfterUpdate on ASI_HK_CRM_Promotion__c (after update) {
    List<ASI_HK_CRM_Promotion__c> list_SGPromotionDetail = new List<ASI_HK_CRM_Promotion__c>();
    List<ASI_HK_CRM_Promotion__c> list_SGApprovedPromotionDetail = new List<ASI_HK_CRM_Promotion__c>();
    String FINALAPPROVED = 'Final Approved';
    
    for(ASI_HK_CRM_Promotion__c i : trigger.new){
        if(i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion') ||
           i.recordtypeid == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Promotion__cASI_CRM_SG_Ad_hoc_Trade_Promotion_Read_Only')
        ){
            if(i.ASI_HK_CRM_Status__c == FINALAPPROVED){
                list_SGApprovedPromotionDetail.add(i);
            } else {
                list_SGPromotionDetail.add(i);
            }
        }
    }
    if(list_SGPromotionDetail.size()>0) ASI_CRM_SG_PromotionService.getInstance().rollupTargetToPromotion(list_SGPromotionDetail);
    if(list_SGApprovedPromotionDetail.size()>0) ASI_CRM_SG_PromotionService.getInstance().rollupActualToPromotion(list_SGApprovedPromotionDetail);
}