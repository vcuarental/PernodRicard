/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @01/20/2016 12:47 PM
 * Revision History:
 * 1. 01/20/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_VN_VisitDetailUdStsCtrlTest {
    
    private static TestMethod void testController() {

        Id planRtId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c
                                        .getRecordTypeInfosByName()
                                        .get('VN Visitation Plan').getRecordTypeId();
        
        ASI_HK_CRM_Visitation_Plan__c testPlan =
            ASI_CRM_VN_TestDataFactory.getVisitationPlan('Test Plan', planRtId);
        insert testPlan;

        Id planDetailRtId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c
                                              .getRecordTypeInfosByName()
                                              .get('VN Visitation Plan Detail').getRecordTypeId();

        ASI_HK_CRM_Visitation_Plan_Detail__c testPlanDetail =
            ASI_CRM_VN_TestDataFactory.getPlanDetail(
                'Test Customer Name',
                'Test Outlet Name',
                planDetailRtId,
                testPlan.Id
            );
        insert testPlanDetail;

        System.Test.startTest();

            System.Test.setCurrentPage(Page.ASI_CRM_VN_VisitDetailUdStsPage);
            ApexPages.currentPage().getParameters().put('Id', testPlanDetail.Id);

            ApexPages.StandardController stdController = 
                new ApexPages.StandardController(testPlanDetail);

            ASI_CRM_VN_VisitDetailUdStsController controllerInstance =
                new ASI_CRM_VN_VisitDetailUdStsController(stdController);

            controllerInstance.detail.ASI_HK_CRM_Cancellation_Reason__c = 'Test Cancel Reason';
            controllerInstance.updateStatus();

        System.Test.stopTest();

    }
}