/***************************************************************************************************************************
 * Name:        ASI_CRM_Promotion_Plan_AfterInsert
 * Description: After insert trigger for ASI_CRM_Promotion_Plan__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-05-21       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

trigger ASI_CRM_Promotion_Plan_AfterInsert on ASI_CRM_Promotion_Plan__c (after insert) {
    List<ASI_CRM_Promotion_Plan__c> plansSG = new List<ASI_CRM_Promotion_Plan__c>();

    for (ASI_CRM_Promotion_Plan__c promotionPlan : Trigger.new) {
        String recordTypeDeveloperName = Global_RecordTypeCache.getRt(promotionPlan.RecordTypeId).DeveloperName;
        if (recordTypeDeveloperName.contains('ASI_CRM_SG_Wholesaler_Promotion_Plan') ||
            recordTypeDeveloperName.contains('ASI_CRM_SG_Outlet_Promotion_Plan')) {
            plansSG.add(promotionPlan);
        }
    }

    ASI_CRM_SG_PromotionPlanService.getInstance().createPromotionByUser(plansSG);
}