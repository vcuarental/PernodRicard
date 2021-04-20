/**********************************************************************************
 * Name : ASI_MFM_CAP_OTH_InputPlanItemsCtrlTest
 * Created : DC @01/18/2016 12:32 PM
 * Revision History:
 * 1. 01/18/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_MFM_CAP_OTH_InputPlanItemsCtrlTest {
    
    private static TestMethod void testCompletePlan() {
        
        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlan();

        testPlanInstance.ASI_MFM_Status__c = 'Complete';
        update testPlanInstance;

        System.Test.startTest();

            PageReference pageRef = Page.ASI_MFM_CAP_OTH_InputPlanItemsPage;
            pageRef.getParameters().put('id', testPlanInstance.Id);
            pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);

            List<ASI_MFM_Plan__c> testPlanList = [SELECT Id
                                                    FROM ASI_MFM_Plan__c
                                                   WHERE Id = :testPlanInstance.Id
                                                   LIMIT 1];

            System.Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdController = 
                new ApexPages.StandardSetController(testPlanList);

            ASI_MFM_CAP_OTH_InputPlanItemsController controllerInstance = 
                new ASI_MFM_CAP_OTH_InputPlanItemsController(stdController);

        System.Test.stopTest();
    }

    private static TestMethod void testSubmittedPlan() {
        
        ASI_MFM_Plan__c testPlanInstance = ASI_MFM_CAP_TestClassHelper.createPlan();

        testPlanInstance.ASI_MFM_Status__c = 'Submitted';
        update testPlanInstance;

        System.Test.startTest();

            PageReference pageRef = Page.ASI_MFM_CAP_OTH_InputPlanItemsPage;
            pageRef.getParameters().put('id', testPlanInstance.Id);
            pageRef.getParameters().put('prtId', testPlanInstance.RecordTypeId);

            List<ASI_MFM_Plan__c> testPlanList = [SELECT Id
                                                    FROM ASI_MFM_Plan__c
                                                   WHERE Id = :testPlanInstance.Id
                                                   LIMIT 1];

            System.Test.setCurrentPage(pageRef);
            ApexPages.StandardSetController stdController = 
                new ApexPages.StandardSetController(testPlanList);

            ASI_MFM_CAP_OTH_InputPlanItemsController controllerInstance = 
                new ASI_MFM_CAP_OTH_InputPlanItemsController(stdController);

        System.Test.stopTest();
    }

}