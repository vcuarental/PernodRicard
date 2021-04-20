/***************************************************************************************************************************
 * Name:        ASI_CRM_Trade_A_P_PlanTriggerHandlerTest
 * Description: Test class for ASI_CRM_Trade_A_P_Plan_TriggerHandler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-30       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_Trade_A_P_PlanTriggerHandlerTest {
    @IsTest static void testBeforeDeleteTrigger() {
        ASI_CRM_Trade_A_P_Plan__c plan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        plan.ASI_CRM_Status__c = 'Submitted';
        insert plan;

        try {
            delete plan;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Cannot delete approved/submitted Promotion Plan'));
        }

        ASI_CRM_Trade_A_P_Plan__c plan2 = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        plan2.ASI_CRM_Status__c = 'Approved';
        insert plan2;

        try {
            delete plan2;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Cannot delete approved/submitted Promotion Plan'));
        }

    }

    @IsTest static void testAfterUpdateTrigger() {
        ASI_CRM_Trade_A_P_Plan__c plan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        insert plan;

        ASI_CRM_Trade_A_P_Plan_Item__c planItem = ASI_CRM_VN_TestClassHelper.createPromotionPlanItem(plan.Id);
        insert planItem;

        plan.ASI_CRM_Status__c = 'Approved';
        update plan;

        planItem = [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_Trade_A_P_Plan_Item__c];
        System.assertEquals('ASI_CRM_VN_Promotion_Plan_Item_Read_Only', planItem.RecordType.DeveloperName);
    }

}