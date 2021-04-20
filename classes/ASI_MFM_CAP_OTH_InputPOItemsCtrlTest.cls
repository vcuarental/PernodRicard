/**********************************************************************************
 * Name : ASI_MFM_CAP_OTH_InputPOItemsCtrlTest
 * Created : DC @01/18/2016 12:14 PM
 * Revision History:
 * 1. 01/18/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_MFM_CAP_OTH_InputPOItemsCtrlTest {
    
    private static testMethod void testControllerPositive() {

        ASI_MFM_PO__c poInstance = ASI_MFM_CAP_TestClassHelper.createPO('CAPEX', ASI_MFM_CAP_TestClassHelper.createPlan());

        System.Test.startTest();
            PageReference pageRef = Page.ASI_MFM_CAP_OTH_InputPOItemsPage;
            pageRef.getParameters().put('id',poInstance.Id);
            System.Test.setCurrentPage(pageRef);
            List<ASI_MFM_PO__c> poList = [SELECT Id
                                            FROM ASI_MFM_PO__c
                                           WHERE Id = :poInstance.Id
                                           LIMIT 1];
            ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(poList);
            ASI_MFM_CAP_OTH_InputPOItemsController controllerInstance = 
                new ASI_MFM_CAP_OTH_InputPOItemsController(stdController);

        System.Test.stopTest();        

    }

}