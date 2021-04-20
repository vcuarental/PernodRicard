/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_VisitationPlanSchedulerTest
 * Description: Test class for ASI_CRM_VN_VisitationPlanSchedulerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-29       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_VisitationPlanSchedulerTest {
    @IsTest static void testBehavior() {
        Test.startTest();
        ASI_CRM_VN_VisitationPlanScheduler abs= new ASI_CRM_VN_VisitationPlanScheduler();
        abs.execute(null);
        Test.stopTest();

    }
}