/*********************************************************************************
 * Name:ASI_CRM_Promotion_Plan_BeforeUpdate
 * Description: Before Update trigger for Promotion Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 03/04/2018       Hugo Cheung             Created
*********************************************************************************/
trigger ASI_CRM_Promotion_Plan_BeforeUpdate on ASI_CRM_Promotion_Plan__c (before update) {
    List<ASI_CRM_Promotion_Plan__c> promotionPlanList = trigger.new;
    Map<Id, ASI_CRM_Promotion_Plan__c> promotionPlanMap = trigger.oldMap;
    
    List<ASI_CRM_Promotion_Plan__c> approvedPromotionPlanList = new List<ASI_CRM_Promotion_Plan__c>();
    for(ASI_CRM_Promotion_Plan__c promotionPlan : promotionPlanList) {
        ASI_CRM_Promotion_Plan__c oldPromotionPlan  = promotionPlanMap.get(promotionPlan.Id);
        String recordTypeDeveloperName = Global_RecordTypeCache.getRt(promotionPlan.RecordTypeId).DeveloperName;
        if(recordTypeDeveloperName.contains('ASI_CRM_SG_Wholesaler_Promotion_Plan') || 
           recordTypeDeveloperName.contains('ASI_CRM_SG_Outlet_Promotion_Plan')) {
        		/*
               if(oldPromotionPlan.ASI_CRM_Status__c == 'Submitted' && 
               promotionPlan.ASI_CRM_Status__c == 'Approved')
				*/
               if(!oldPromotionPlan.ASI_CRM_SYS_Send_Email__c && 
               promotionPlan.ASI_CRM_SYS_Send_Email__c)
                approvedPromotionPlanList.add(promotionPlan);
        }
    }
    
    if(approvedPromotionPlanList.size() > 0) ASI_CRM_SG_PromotionPlanService.getInstance().sendEmailToPromotionOwner(approvedPromotionPlanList); 
}