/*********************************************************************************
 * Name:ASI_CRM_Promotion_Plan_AfterUpdate
 * Description: Before Update trigger for Promotion Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-06       Vincent Lam             Created
*********************************************************************************/
trigger ASI_CRM_Promotion_Plan_AfterUpdate on ASI_CRM_Promotion_Plan__c (after update) {
    List<ASI_CRM_Promotion_Plan__c> promotionPlanList = trigger.new;
    Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap = trigger.oldMap;
    
    List<ASI_CRM_Promotion_Plan__c> approvedPromotionPlanList = new List<ASI_CRM_Promotion_Plan__c>();
    List<ASI_CRM_Promotion_Plan__c> rejectedPromotionPlanList = new List<ASI_CRM_Promotion_Plan__c>();
    for(ASI_CRM_Promotion_Plan__c promotionPlan : promotionPlanList) {
        ASI_CRM_Promotion_Plan__c oldPromotionPlan  = promotionPlanMap.get(promotionPlan.Id);
        String recordTypeDeveloperName = Global_RecordTypeCache.getRt(promotionPlan.RecordTypeId).DeveloperName;
        if(recordTypeDeveloperName.contains('ASI_CRM_SG_Wholesaler_Promotion_Plan') || 
           recordTypeDeveloperName.contains('ASI_CRM_SG_Outlet_Promotion_Plan')) {
          if(oldPromotionPlan.ASI_CRM_Status__c != 'Final Approved' && 
               promotionPlan.ASI_CRM_Status__c == 'Final Approved')
                approvedPromotionPlanList.add(promotionPlan);
        }
        if(recordTypeDeveloperName.contains('ASI_CRM_SG_Wholesaler_Promotion_Plan_Read_Only') || 
           recordTypeDeveloperName.contains('ASI_CRM_SG_Outlet_Promotion_Plan_Read_Only')) {
          if(oldPromotionPlan.ASI_CRM_Status__c != 'Rejected' && 
               promotionPlan.ASI_CRM_Status__c == 'Rejected')
                rejectedPromotionPlanList.add(promotionPlan);
        }
    }
    
    if(approvedPromotionPlanList.size() > 0) ASI_CRM_SG_PromotionPlanService.getInstance().finalApproveAllPromotions(approvedPromotionPlanList);
    if(rejectedPromotionPlanList.size() > 0) ASI_CRM_SG_PromotionPlanService.getInstance().rejectAllPromotions(rejectedPromotionPlanList); 
}